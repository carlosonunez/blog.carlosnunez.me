---
title: Debugging OAuth authorization tokens from your terminal
date: 2023-10-31T10:51:08-05:00
draft: false
categories: 
  - security
  - api
  - deep-dives-in-kiddie-pools
tags: 
  - security
  - oauth
  - api
  - devops
  - devsecops
  - platform
---

Here's a quick post about something that I don't do often but is typically a
pain when I do: debugging OAuth tokens super quickly.

## An Example Scenario

You've just provisioned a shiny new Keycloak instance and want to make it the
upstream identity provider (IdP) to your company's Okta tenant because you were
volun-told to do so.

You're also using an app that is configured to do single sign-on through
Keycloak and will only log in users if they have `admin` in their access token's
`groups` claim.

You've created the Okta Identity Provider in Keycloak, set up everything
correctly in Okta, and are able to log into Keycloak through Okta just fine.
However, you're _not_ able to log into the app despite being in the `admin`
group in Okta.

What gives?

## Helpful tools

We're not going to solve this problem in this post, especially since [the internet
solved it already](https://github.com/keycloak/keycloak/discussions/13646).

What we _will_ do is talk about some CLI tools that can help simplify getting to
the bottom of this.

### `oidc-bash-client.sh`

[`oidc-bash-client.sh`](https://github.com/please-openit/oidc-bash-client) is a
mostly-compliant OAuth2 client written entirely in Bash. It's entire purpose is
to print tokens received after successfully completing token exchange.

### `browsh`

[`browsh`](https://github.com/browsh-org/browsh) is a modern text-based web
browser. It uses Firefox Marionette (like Chromedriver) to render webpages (and
JavaScript!) entirely in your terminal.

Here's a TL;DR of how to use it for a two-legged authorization code OAuth login:

> ✅ Make sure that your OAuth client has `http://127.0.0.1:8080` as a valid
> redirect URL before doing this.

1. First, clone the script somewhere:

```sh
git clone https://github.com/please-openit/oidc-bash-client /tmp
```

2. Run the command below to get an auth code. This will use `netcat` to spin up
   a local webserver that will capture redirects.

   ```sh
   /tmp/oidc-bash-client/oidc-client.sh \
    --operation authorization_code_grant \
    --client-id $CLIENT_ID \
    --openid-endpoint https://$KEYCLOAK_INSTANCE/.well-known/openid-configuration \
    --redirect-uri http://127.0.0.1:8080 \
    --scope "$SCOPES"
   ```

   This will print something like the below:

   ```text
   OPEN THIS URI IN YOUR WEB BROWSER
   https://$KEYCLOAK_INSTANCE/realms/tanzu-products/protocol/openid-connect/auth?client_id=$CLIENT_ID&scope=$SCOPES&response_type=code&response_mode=fragment&redirect_uri=http://127.0.0.1:8080&acr_values=
   -- LISTENING ON PORT 8080 FOR A REDIRECT
   ```

   Here, we _could_ copy this URL and paste it in a web browser. But that's
   lame. You're probably reading this inside of `w3m` entirely in your terminal.
   Can't be bothered.

   Instead, open another terminal tab and open it in `browsh`:

   ```sh
   browsh --startup-url '$URL_YOU_COPIED'
   ```

   This will give you a really cool retro 8-bit version of what you'd normally
   see in your browser.

   {{< post_image name="example" alt="Just like you remembered it from your childhood." >}}

   After you log in, you'll get an auth code back, like this:

   ```json
   {"state":"foobar","session_state":"e4dc98f7-bed4-49da-b81a-672c2011d30c","code":"f905d57d-e6aa-4109-9ffc-789752e146df.e4dc98f7-bed4-49da-b81a-672c2011d30c.1e75bca2-981c-4ddb-a12a-edb6e7896431"}
   ```

   `oidc-bash-client` will also exit.

   Copy the code, then go to the next step. 

3. Run the command below to exchange the code you received for access, ID and
   refresh tokens:

   ```sh
   /tmp/oidc-bash-client/oidc-client.sh \
    --operation auth_code \
    --client-id "$CLIENT_ID" \
    --client-secret "$CLIENT_SECRET" \
    --openid-endpoint https://$KEYCLOAK_INSTANCE/realms/$KEYCLOAK_REALM/.well-known/openid-configuration \
    --redirect-uri http://127.0.0.1:8080 \
    --authorization-code 'f905d57d-e6aa-4109-9ffc-789752e146df.e4dc98f7-bed4-49da-b81a-672c2011d30c.1e75bca2-981c-4ddb-a12a-edb6e7896431'
   ```

   This will give you a JSON payload with all three in it!

    ```json
    {
      "access_token": "$ACCESS_TOKEN",
      "expires_in": 300,
      "refresh_expires_in": 1800,
      "refresh_token": "$REFRESH_TOKEN",
      "token_type": "Bearer",
      "not-before-policy": 1698706734,
      "session_state": "e4dc98f7-bed4-49da-b81a-672c2011d30c",
      "scope": "profile tenant_id groups full_name email"
    }
    ```

At this point, you would take the Base64-encoded `access_token` JWT to
[jwt.io](https://jwt.io) and decode it to get the contents of the token.

We're better than that.

We'll use `jq` to decode the token right here, right now.

(Big thanks to [Vithal
Reddy](https://gist.github.com/thomasdarimont/46358bc8167fce059d83a1ebdb92b0e7?permalink_comment_id=3776714#gistcomment-3776714)
for this one.)

4. Copy the JSON blob (you won't be able to get it again without starting
   from step [2]) and save it as a variable:

   ```sh
   json=$(pbpaste) # if you're on a Mac!
   ```

5. Use `jq` to split up the JWT by period and Base64-decode each fragent:

   ```sh
   echo "$json" |
    jq -r '.access_token | split(".") | .[1] | @base64 -d | fromjson'
   ```

And _wa la!_ Your decrypted JWT appears!

```json
{
  "exp": 1698769211,
  "iat": 1698768911,
  "auth_time": 1698768896,
  "jti": "96aad20d-62af-4a8c-89c3-569d92619ad6",
  ...rest of the token
}
```
