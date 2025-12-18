---
title: "CNCF Weekly #1: Flux"
date: 2025-10-29T13:41:00-06:00
draft: false
image: "/images/cncf-weekly-1-flux/header.png"
categories:
- kubernetes
- cncf-weekly
- gitops
tags:
- kubernetes
- cncf-weekly
- cloud-native
- gitops
- flux
keywords:
- cncf-weekly
---

I'm starting off CNCF Weekly with Flux, a useful and well-known tool in the
cloud-native community.

## Key Info

|                  |                                         |
| :----            | :----                                   |
| **Project Name** | Flux                                    |
| **CNCF Status**  | Graduated                               |
| **Docs**         | [Link](https://fluxcd.io/flux/)         |
| **GitHub**       | [Link](https://github.com/fluxcd/flux2) |

## In a nutshell...

Flux enables Kubernetes clusters and their apps to be configured with Git. Time
to retire your Jenkins pipelines.

## Who's This For?

- Platform engineers and developers interested in maintaining clusters and
  their apps completely as code with Git
- Engineering managers looking for new tools to add to their arsenal

## Okay, so what is it?

{{< post_image name="k8s_made_easy" alt="kubeadm never had it so good." >}}

_(**Source**: Google Cloud's Amazing Comic on Kubernetes.
[link](https://cloud.google.com/kubernetes-engine/kubernetes-comic))_

You just spun up a brand-spankin' new Kubernetes cluster. `kubectl` works. You
can _feel_ the power within your nodes waiting to be unleashed. All is good.

It's time to install some stuff into it. [Probably something AI
related](https://github.com/kserve/kserve), since that seems like a good idea
these days.

This is easy work: grab (or make) its Helm chart, `helm upgrade --install` it
and you're off to the races.

This will _not_ be easy work when your AI-related thing finds its
[product-market fit](https://en.wikipedia.org/wiki/Product-market_fit) and now
needs 10 Kubernetes clusters with hundreds of microservices and even more
dependencies to keep up.

You'll need to automate. And you'll be overwhelmed by your options!

You could `kubectl` your way to a desired state, but that'll be a lot of work at
a small scale and basically impossible at "webscale™", as you'll observe when
you spin up cluster #2.

You could also use Terraform/OpenTofu or Ansible (or both!), like many people
do! Both of those tools are excellent for declaring and configuring infra like
Kubernetes clusters, especially when combined with Kubernetes package managers
like [Helm](https://helm.sh) or [kApp](https://carvel.dev/kapp).

{{< post_image name="gitops" alt="build the world one git commit at a time" >}}

_(**Source**: /r/Kubernetes, because they're way funnier than I am.
[link](https://old.reddit.com/r/kubernetes/comments/1o9zhfs/its_gitops_or_git_operations/))_

All of these options (and more!) are totally-valid ways of configuring apps in
clusters...but what do you do when you want to, say, update an application in
one cluster while removing another application in a different one? How do you
keep track of these changes as they happen?

This is what "GitOps", and tools like Flux, were meant to solve.

GitOps basically defines itself: operations via Git commits. It gives you the
best of both worlds: audit trails tracked by a super-well-known decentralized
version control system in near real time.

You can achieve GitOps the old-school way by creating a pipeline or two with
your [favorite build system](https://github.com/features/actions) and configure
them to execute whenever a new set of changes (perhaps through a pull request)
gets pushed up to a Git repository. This approach works great and is often used
for provisioning base infrastructure, like Kubernetes clusters.

GitOps _tools_ enable you to "remove the middleman" by
enabling your clusters to update themselves when those changes arrive instead of
waiting for a pipeline to do it for them. You gain all of the
advantages of tracking changes through Git without the fragility and latency
that can come with pipelines.

**Flux** is a tool that _only_ does GitOps. It's so dedicated to the GitOps
problem, it doesn't even come with a GUI! (Several are available, though; I
outline them in my recommended [next steps](#next-steps) at the end of this
CNCF Weekly.

## Things I Like

There are a few things about Flux that make it a really great tool for this
purpose:

- I really like how Flux leverages Kubernetes [Kustomizations](url) to install
  and configure cluster apps. Kustomizations make it easy to define a "base" of
  Kubernetes resources --- Deployments, ConfigMaps, PersistentVolumeClaims, etc.
  --- that get altered with "overlays" that are patched on top. This makes it
  possible to do things like define a folder of re-usable applications that
  every cluster can install alongside overlays that configure those applications
  based on the environment, business unit, or whatever logical partition your
  clusters are separated by.

- I also like how Flux integrates [`sOps`](https://github.com/getsops/sops), an
  excellent tool that encrypts sensitive data in a Git-safe way, to make it
  possible to manage secrets with GitOps as well. This works really well if your
  team or organization has a secrets manager like HashiCorp Vault or OpenBao and
  is completely compatible with their respective Kubernetes operators.

- It's quite enterprise-ready! Enterprise dev or platform teams can use their
  [official operator](https://fluxcd.control-plane.io/operator/fluxinstance/) to
  install and configure Flux with a single `FluxInstance` CRD. It also supports
  their other "enterprise" features, like multi-tenancy and network
  segmentation, and it works great in OpenShift, _the_ Kubernetes distribution
  for the enterprise.

## Things I Wish Were Better

- Apps with Flux are managed with `Kustomizations`, which are turned into
  Kubernetes resources by way of their requisite Kubernetes `Kustomizations`
  _which are not the same thing._ It's an unfortunate name choice that can
  really hang up some people that are new to Flux and Kubernetes.

- Some errors can be difficult to reason about, though this isn't a _Flux_
  problem as much as it's a Kubernetes side effect. Their `fluxctl` binary makes
  it easier to see where problems form, but delving into Flux `Kustomization`
  reconciliation errors can be challenging.

## Getting Started

You're going to use Flux to configure a "traditional" Kubernetes app with
secrets and a Helm chart into two local Kubernetes clusters, `dev` and `prod`,
entirely with Git, all on your machine.

Buckle up; this ride's gonna be wild!

|                       |                                                                             |
| :-----                | :-----                                                                      |
| **Time Required**     | 1-2 hours                                                                   |
| **Source**            | [GitHub](https://github.com/carlosonunez/cncf-weekly-guides/tree/main/flux) |
| **Accounts Required** | None.                                                                       |

Let's jump in.

### Steps

- [Create our workspace](#create-a-workspace)
- [Set up `dev` and `prod` Kubernetes clusters on our machine](#setting-up-our-infrastructure)
- [Start a local Git server to configure our clusters with](#setting-up-a-local-git-server)
- [Configure our machine to encrypt Kubernetes secrets](#configure-kubernetes-secrets-encryption)
- [Bootstrap Flux into our `dev` and `prod` clusters](#install-and-bootstrap-flux)
- [Install and configure a "traditional" k8s app, the GitOps way](#install-a-traditional-kubernetes-app-the-gitops-way)
- [Install and configure Helm charts, the GitOps way](#install-helm-charts-the-gitops-way)
- [Clean Up](#clean-up)

### Install tools

Let's install the tools we'll use in this guide.

#### Podman

{{< post_image name="containers" alt="Containers. Containers everywhere." >}}

**Mac**: `brew install podman`

**Windows**: `winget install RedHat.Podman`

> 📝 **Apple Silicon Mac Users**
>
> Podman uses Rosetta by default to run containers built with the `x86`
> processor architecture. If you do not want to use this, run the command below
> to have Podman use `qemu` instead:
>
> ```sh
> cat >$HOME/.config/containers/containers.conf <<-EOF
> [machine]
> rosetta=false
> EOF
> ```

Run the command below after installing Podman to set up a machine that will run
the Podman container engine:

```sh
# I recommend using a machine with at least 6 CPUs and 8GB of RAM.
# You can lower or increase these values if you wish.
podman machine init flux --cpus 6 --mem_size 8192
podman machine start flux
```

Finally, confirm that Podman's installed:

```sh
podman run --rm hello
```

You're good to go when friendly seals greet you after running your first
container with Podman.

```text
Resolved "hello" as an alias (/etc/containers/registries.conf.d/000-shortnames.conf)
Trying to pull quay.io/podman/hello:latest...
Getting image source signatures
Copying blob sha256:1ff9adeff4443b503b304e7aa4c37bb90762947125f4a522b370162a7492ff47
Copying config sha256:83fc7ce1224f5ed3885f6aaec0bb001c0bbb2a308e3250d7408804a720c72a32
Writing manifest to image destination
!... Hello Podman World ...!

         .--"--.
       / -     - \
      / (O)   (O) \
   ~~~| -=(,Y,)=- |
    .---. /`  \   |~~
 ~/  o  o \~~~~.----. ~~
  | =(X)= |~  / (O (O) \
   ~~~~~~~  ~| =(Y_)=-  |
  ~~~~    ~~~|   U      |~~

Project:   https://github.com/containers/podman
Website:   https://podman.io
Desktop:   https://podman-desktop.io
Documents: https://docs.podman.io
YouTube:   https://youtube.com/@Podman
X/Twitter: @Podman_io
Mastodon:  @Podman_io@fosstodon.org
```

#### Kind

We'll use this to create our Kubernetes clusters in Docker.

**Mac**: `brew install kind`
**Windows**: `winget install Kubernetes.kind`

#### Flux

**Mac**: `brew install fluxcd/tap/flux`
**Windows**: `winget install FluxCD.Flux`

#### sOps and GnuPG

We'll use these tools together, so it makes sense to install them together!

**Mac**: `brew install gnupg sops`
**Windows**: `winget install GnuPG.GnuPG Mozilla.SOPS`

### Create a workspace

First things first; run the command below to create a sandbox to experiment in
and enter it:

```sh
mkdir $PWD/flux; cd $PWD/flux
```

Super easy already!

### Setting up our infrastructure

Now we need our two clusters. Run the command below to create two clusters with
`kind` called `cluster-dev` and `cluster-prod`

```sh
kind create cluster --name cluster-dev
kind create cluster --name cluster-prod
```

You'll see output like this after each command:

```
using podman due to KIND_EXPERIMENTAL_PROVIDER
enabling experimental podman provider
Creating cluster "cluster-dev" ...
 ✓ Ensuring node image (kindest/node:v1.34.0) 🖼
 ✓ Preparing nodes 📦
 ✓ Writing configuration 📜
 ✓ Starting control-plane 🕹️
 ✓ Installing CNI 🔌
 ✓ Installing StorageClass 💾
Set kubectl context to "kind-cluster-dev"
# ...truncated; repeats for "cluster-prod"
```

When it finishes, run `kubectl get nodes --context cluster-dev` to confirm that
your "dev" cluster is ready and `kubectl get nodes --context cluster-prod` to
do the same for "prod".

You'll see something like this if everything's properly set up:

```
$: kubectl --context kind-cluster-dev get nodes
NAME                        STATUS   ROLES           AGE     VERSION
cluster-dev-control-plane   Ready    control-plane   2m32s   v1.34.0
```

### Setting up a local Git server

{{< post_image name="git" alt="The Git client can ALSO run a server!" >}}

Flux synchronizes Kubernetes cluster configuration with manifests in Git repos.
This means we'll need a Git repository to store configurations and stuff into,
which we'll do in this step!

Most tutorials will assume that you have a GitHub or GitLab account and will
have you initialize Flux with new repos in these services. I'd like to take a
different approach by having us use a local Git repository running in a
container for four reasons:

1. There are so many good tutorials that do a great job of showing you how to
   "bootstrap" with GitHub, GitLab or Gitea,
2. Many developers are using Git service providers that don't have Flux
   "providers" for them yet, like Azure DevOps or AWS CodeCommit. The
   instructions in this guide will work for these providers,
3. Some unique situations, like edge or disconnected computing, call for a local
   Git server that receives updates from some other channel. The steps in this
   guide will work great for these scenarios, and
4. I did say we were going on a wild ride!!!

We're going to do this in four steps:

- Create an SSH keypair to authenticate us with our Git server,
- Start a containerized Git server and confirm that our Kubernetes clusters can
  access it,
- Create a Git repository within the server (i.e. the stuff that happens when
  you click "Create Repository" in GitHub!), and
- Clone the repository on our machine and push our first change.

#### Create SSH Keys

We're going to push changes to our configuration repos over SSH. While Flux
supports HTTPS, setting this up is slightly more involved, and SSH is more
secure anyway, so SSH is what we're going to go with.

We'll need an SSH private key to do this. Run the below to create one without a
passphrase:

```sh
mkdir $PWD/keys
ssh-keygen -t rsa -f ./keys/id_rsa -qN''
```

#### Start a Git server

Now let's use Docker to create a local Git server that Flux will fetch
configurations from in both of our servers.

```sh
podman run --rm --network=kind -p 2222:22 -d \
  --name gitserver \
  -v $PWD/keys:/git-server/keys \
  jkarlos/git-server-docker
```

Like running a 100ft CAT-6 cable to a five-port switch and hoping a cat didn't
decide to bite through it, the `--network=kind` argument will connect our Git
server to our Kubernetes clusters, not that I had to do that recently or
anything.

Use the command below to confirm that our Git server is up and
running and accepts our SSH key. 
```sh
# You might need to run this a few times before you see the welcome message.
ssh -i $PWD/keys/id_rsa git@127.0.0.1 -p 2222 | grep 'Welcome'
```
You're good to go when you see a `Welcome to Git` message from the server.

#### Create a configuration repo in the Git server

Now that our Git server is humming idly ready to sync deltas and hunks and stuff
like that, run the command block below to create and initialize the repo that
Flux will synchronize with our Kubernetes clusters:

```sh
podman exec gitserver mkdir -p /git-server/repos/platform
podman exec gitserver git -C /git-server/repos/platform init --bare
podman exec gitserver chown -R git:git /git-server/repos/platform
```

For you curious cats out there, `--bare` basically makes the contents within a
typical `.git` directory, i.e. the Git "stuff", the entirety of what's in this
folder. You'll only ever need this whenever you're creating a Git repository
that will be hosted for others to work off of, like we're doing now. Now you see
some of why GitHub took over the world in the early 2010s!

#### Clone the repo and commit our first change

> 📝 **Git Users**
>
> Run `export GIT_CONFIG_GLOBAL=''` if you have features like commit signing
> turned on and want to turn those off while following this guide.

Anyway, enough lore. Clone the repo that we just created using the SSH key we
made earlier:

```sh
git clone ssh://git@localhost:2222/git-server/repos/platform \
  --config core.sshCommand="ssh -i $PWD/keys/id_rsa" \
  "$PWD/repo"
```

Then create, then push, an empty commit to make it ready for GitOps!

```sh
pushd "$PWD/repo"
git commit --allow-empty -m 'initial commit'
git push
popd
```

#### Confirm that Kubernetes clusters can reach the Git server

Since Flux will clone our Git repo within our Kubernetes clusters, checking that
they can communicate with our Git server is a good idea.

We'll do everything in the `cluster-dev` cluster first.

First, create a test Pod that we'll use to run some commands:

```sh
kubectl --context kind-cluster-dev run --image=alpine/git git-test -- \
    sleep infinity
```

Run `kubectl get pods` and wait for the `git-test` Pod to enter the `Ready`
state.

Next, copy our SSH private key into the Pod, as we'll need it to clone the repo
we created within the Pod:

```sh
kubectl --context kind-cluster-dev cp "$PWD/keys/id_rsa" git-test:/tmp/key
```

Next, attempt to clone the repo within our `git-test` test Pod with the command
below:

```sh
kubectl --context kind-cluster-dev exec git-test -- \
    git clone "ssh://git@gitserver/git-server/repos/platform" \
    /tmp/repo
```

Notice the difference in our `ssh://` address here. Podman creates a lightweight
DNS server to make it possible for containers in a shared network to talk to
each other by name. The `--network=kind` option we specified earlier enables us
to take advantage of this, which I'm happily doing here because service
discovery is awesome and calling stuff by IP address is not.

Anyway, you should see the repo clone within the Pod like you did on your
machine. You can run `git log` within the Pod to make triply-sure that the repo
was, indeed, cloned:

```sh
kubectl --context kind-cluster-dev exec git-test -- git -C /tmp/repo log -1
```

You'll see the `initial commit` commit you made earlier. Success! We can now
delete the `git-test` Pod, as we no longer need it:

```sh
kubectl --context kind-cluster-dev delete pod git-test
```

Repeat everything above on the `prod` server if you wish by replacing `--context
kind-cluster-dev` with `--context kind-cluster-prod` in the commands above.

### Configure Kubernetes Secrets Encryption

Flux works with [`sops`](https://github.com/getsops/sops) to enable encrypted
Kubernetes secrets in Git repositories to be synchronized with Kubernetes
clusters. We're now going to configure `sops` to configure anything that looks
like a Kubernetes secret in our configuration repo.

#### Create a GPG Key

`sops` supports many encryption providers, like AWS KMS, HashiCorp Vault and
[`age`](https://github.com/FiloSottile/age), a modern encryption mechanism.
We're going to keep it old-school and encrypt our Kubernetes secrets with a GPG
keypair.

Run the command below to create a GPG key without a passphrase:

```sh
gpg --quick-generate-key --batch --passphrase='' cluster
```

Afterwards, run the command below to capture its fingerprint, which we'll need
when we configure `sops`:

```sh
fp=$(gpg --list-keys cluster | grep -A 1 pub | tail -1 | tr -d ' ')
```

#### Create sOps creation rules

`sops` uses "creation rules" to decide how and with which encryption providers
data within files should be encrypted. These are defined in a YAML file, which
we'll use the command below to create now:

```sh
cat >"$PWD/repo/.sops.yaml" <<-EOF
creation_rules:
  - path_regex: .*.yaml$
    pgp: $fp
    encrypted_regex: ^(data|stringData)$
EOF
```

This creation rule tells `sops` to process any YAML file in our repo but to
**only** encrypt any `data` or `stringData` keys found within them.

I absolutely love this feature. This makes it possible to document content
within YAML files while hiding stuff that shouldn't be seen.

See for yourself! Run this to dry-run having `sops` encrypt a Kubernetes secret:

```sh
echo -en 'foo: bar\ndata: supersecret' | sops encrypt --filename-override ./secret.yaml
```

This will produce:

```yaml
foo: bar
data: ENC[AES256_GCM,data:iQ/bZlTtLOPuWNk=,iv:RxeJSNfa9cxzE9Zom90He2+fw9Gg/qH+iiYeHgCJ2+E=,tag:Gh88xiA1PhS4eld0wNlJtA==,type:str]
sops:
    lastmodified: "2025-12-18T00:50:13Z"
    mac: ENC[AES256_GCM,data:YCgDODd4AnqhXYFZfgL0t8pxNoz6wKFga7RkZ3d0kFDSUlCSe7sRM/vr045b2pQdMDDq3g0cGl5GpKS9r3xhf9SlAsOIOu9+MD6I3HcdjVL8vgO1lEcN1yS8BdUWK5hGrT38T8n6MaFBOHvkk7lQ54/NOjk/5hBIqbDUzyuh8lc=,iv:VYsQA15FWYcdPp3JOdIqJTnbj3LLP+dqR2bRPjzEZSI=,tag:VXeGQvfu3eCCZI8RfFonlw==,type:str]
    pgp:
        - created_at: "2025-12-18T00:50:13Z"
          enc: |-
            -----BEGIN PGP MESSAGE-----

            hF4D0fpShJqYulISAQdAZesPSjx1SbzeStpXxvLlRwAQoa+F17nq/tcIbvb0aS8w
            aDFw9I0A8O1Q1ROeU0EGePYIKk/RO/OvyLc/hNLpfHnmfGgY8hsF/P2nMZzmYy7T
            0lwByjxoE23mQ/dcNWZjAvH0l41g0Js6c6EU0LZTejf2uyDaNM0qrWS+b/gqp8oM
            9iHvh6pQ5km4kaI1Ap285d4cZT0xa6wu5M+T4hCZyKBU1tTluupAdv44hwSpbA==
            =nMeT
            -----END PGP MESSAGE-----
          fp: D8630B5C2954B6091E8913EFE1FE98BBFDCADE05
    encrypted_regex: ^(data|stringData)$
    version: 3.11.0
```

Notice how `foo`'s value is in plaintext while the value for `data` is encrypted
garbage. This mathematical byproduct is what will let us commit our Kubernetes secrets
to our Git repository without the fear of a nasty data breach.

Speaking of commits, run the below to commit our `.sops.yaml` and push into our
Git server:

```sh
git -C "$PWD/repo" add .sops.yaml
git -C "$PWD/repo" commit -m "add sOps config for secrets"
git -C "$PWD/repo" push
```


### Install and Bootstrap Flux

{{< post_image name="bootstrap" alt="No actual boots required." >}}

_(**Source**: A random eBay listing! Unfortunately, the auction ended.
[link](https://www.ebay.com/itm/386261123731))_

We've finally arrived at the fun stuff. It's time to set up Flux.

#### Doing the Installation

Once again, we'll start with the `dev` server. First, use `flux check --pre` to
ensure that we're good to install Flux on this server:

```sh
flux check --pre --context kind-cluster-dev
```

Unsurprisingly, you should see the below to confirm that you're good to go:

```
► checking prerequisites
✔ Kubernetes 1.34.0 >=1.32.0-0
✔ prerequisites checks passed
```

If you do, run `flux bootstrap` to get Flux up and running in your "dev"
cluster:

```sh
flux bootstrap git \
    --url=ssh://git@gitserver/git-server/repos/platform \
    --path="./clusters/$env" \
    --branch master \
    --private-key-file="/keys/id_rsa" \
    --context "kind-cluster-$env" \
    --author-email 'clusterops@example.com' \
    --author-name 'Cluster Ops Bot' \
    --silent
```

> 📝 **NOTE**: Git servers are  hardcoded to name their default branches
> `master`. I'll update this guide in the future to use `main` instead!

You'll see Flux create several components in your cluster and, in true GitOps
fashion, commit those changes back into your repository, like the output below
shows:

```
► cloning branch "master" from Git repository "ssh://git@gitserver/git-server/repos/platform"
✔ cloned repository
► generating component manifests
✔ generated component manifests
✔ committed component manifests to "master" ("12c9bb6ad390f649c0f7f1bc0cd5b586fb75ac19")
► pushing component manifests to "ssh://git@gitserver/git-server/repos/platform"
► installing components in "flux-system" namespace
✔ installed components
✔ reconciled components
► determining if source secret "flux-system/flux-system" exists
► generating source secret
✔ public key: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9znag8QuiXpbeBNynT0WWh75ByQOdWpQp4cY62Mh6lEmaOmcEuAjxqVVU1uBHGCyW9KQA65e6yeKJwqeKBOnN7slthWGpQVfCUBE/SNWAHfkvzOIxWMVEY7wOg5L/XZCPjnBmQ1wJFSgH3nYiDj8eETc41FS8187nX0OG3ZAj3em5ojGobwAw1ZEM2cbPV8rxi7Pt9UXsnXyVZDWgOfdvaT3RCj9PmUBDsLfrtQSv2rFpVcIzyznFmD/zs3pfpnYWW+9rUSQm7jSsURsZaE8vn/JhIlA/c7LAcH7rNgL0nCa4gD3ttp0zMZmlpceeE/cGl1ciMbq7qHb/yrIbkHYHhqt+Li+PXiER0CUZPo+3JFycvLzJ1WdPnelpZ6iq9Q49/n/WgDYi2/zj7Kkmaqi+DaByVhe2g/fWp/Yrp4ZhKVwtOKPFk6IdLXOV7z9qi90g/tPtLT/Fze2eFdQ3z+Sdlr7PLP/C9uof+QSaIuzMHynSbvw9Zq9LeIIuCuEBIxM=
► applying source secret "flux-system/flux-system"
✔ reconciled source secret
► generating sync manifests
✔ generated sync manifests
✔ committed sync manifests to "master" ("32dea9ae3d59a15e07f9ecd710aee10111069575")
► pushing sync manifests to "ssh://git@gitserver/git-server/repos/platform"
► applying sync manifests
✔ reconciled sync configuration
◎ waiting for GitRepository "flux-system/flux-system" to be reconciled
✔ GitRepository reconciled successfully
◎ waiting for Kustomization "flux-system/flux-system" to be reconciled
✔ Kustomization reconciled successfully
► confirming components are healthy
✔ helm-controller: deployment ready
✔ kustomize-controller: deployment ready
✔ notification-controller: deployment ready
✔ source-controller: deployment ready
✔ all components are healthy
```

This can take several minutes to finish depending on the speed of your Internet
connection.

#### Modifying Flux components...with GitOps

Since Flux added new commits to your repository, we'll need to use `git pull` to
retrieve them. Run the below to do that:

```sh
git -C "$PWD/repo" pull
```

> ✅ You'll need to add `--rebase` to the end of this if you've added some
> commits of your own to the repo.

Which will result in something like this:

```
remote: Counting objects: 22, done.
remote: Compressing objects: 100% (16/16), done.
remote: Total 22 (delta 1), reused 0 (delta 0)
Unpacking objects: 100% (22/22), 53.79 KiB | 4.89 MiB/s, done.
From ssh://localhost:2222/git-server/repos/platform
   f4aa73d..0af5ba2  master     -> origin/master
Updating f4aa73d..0af5ba2
Fast-forward
 clusters/dev/flux-system/gotk-components.yaml  | 10195 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 clusters/dev/flux-system/gotk-sync.yaml        |    27 +
 clusters/dev/flux-system/kustomization.yaml    |     5 +
 clusters/prod/flux-system/gotk-components.yaml | 10195 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 clusters/prod/flux-system/gotk-sync.yaml       |    27 +
 clusters/prod/flux-system/kustomization.yaml   |     5 +
 6 files changed, 20454 insertions(+)
 create mode 100644 clusters/dev/flux-system/gotk-components.yaml
 create mode 100644 clusters/dev/flux-system/gotk-sync.yaml
 create mode 100644 clusters/dev/flux-system/kustomization.yaml
 create mode 100644 clusters/prod/flux-system/gotk-components.yaml
 create mode 100644 clusters/prod/flux-system/gotk-sync.yaml
 create mode 100644 clusters/prod/flux-system/kustomization.yaml
```

As you can see, Flux add several files into `dev` and `prod` directories
underneath `clusters`. These are all of the components that Flux is using to
support the Flux installation in your clusters.

You can change any of these files to customize your Flux install and leave
`kubectl edit` or `kubectl patch` in the dust where they belong!

Let's see that in action now by using the command below to modify the DNS
configuration for our Flux components so that it doesn't fail to resolve records
in certain network configurations (#thanksalpine):

```sh
cat >"$PWD/repo/clusters/$env/flux-system/kustomization.yaml" <<-EOF
resources:
- gotk-components.yaml
- gotk-sync.yaml
patches:
- target:
    kind: Deployment
    labelSelector: app.kubernetes.io/part-of=flux
  patch: |
    - op: replace
      path: /spec/template/spec/dnsConfig
      value:
        options:
          - name: ndots
            value: "1"
EOF

After you commit and push these changes and wait a minute or so:

```sh
git -C "$PWD/repo" commit -m "Work-around DNS issues in Flux components" \
    *kustomization.yaml
git -C "$PWD/repo" push
```

You'll see after running `kubectl get deployment -n flux-system
source-controller -o yaml | grep -A 5` that the patch that we added has been
applied

```
      dnsConfig:
        options:
        - name: ndots
          value: "1"
      dnsPolicy: ClusterFirst
      nodeSelector:
```

GitOps!!!!


(Run `kubectl delete pods -n flux-system --all` to apply these changes, as
changes to Deployments don't pass down to running Pods.)

#### Create a sOps decryption secret for Flux

Now that Flux is running, we'll need to create a Secret that resources with
`sops`-encrypted Kubernetes secrets being managed by Flux, or "Kustomizations",
can use to decrypt those Secrets before resources are created.

Run the command below to do that in "dev":

```sh
fp=$(gpg --list-keys cluster | grep -A 1 pub | tail -1 | tr -d ' ')
gpg --export-secret-keys --armor "$fp" |
    kubectl --context kind-cluster-dev create secret generic sops-gpg \
        -n flux-system
        --from-file=sops.asc=/dev/stdin
```

Then in "prod":

```sh
fp=$(gpg --list-keys cluster | grep -A 1 pub | tail -1 | tr -d ' ')
gpg --export-secret-keys --armor "$fp" |
    kubectl --context kind-cluster-prod create secret generic sops-gpg \
        -n flux-system
        --from-file=sops.asc=/dev/stdin
```

Congrats! Flux is now set up and ready to manage apps in our cluster.

### Install a "Traditional" Kubernetes App, the GitOps Way

{{< post_image name="guestbook" alt="It's just a guestbook." >}}

We'll start with a "traditional" Kubernetes app, i.e. one that's deployed with
`kubectl apply`.
[Guestbook](https://github.com/kubernetes/examples/tree/master/web/guestbook) is
a simple app maintained by the Kubernetes authors that let's you add messages to
a guestbook.

#### About Kustomize

Flux uses
[`kustomize`](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/),
a Kubernetes component, to render traditional Kubernetes manifests in a
directory, and for good reason.

At its heart, using Kustomize is fairly straightforward. Say that you have
Deployment, Service and Ingress resources defined by `deployment.yaml`,
`service.yaml`, and `ingress.yaml` respectively. Instead of running the usual
`kubectl` commands to apply them all, like this:

```sh
kubectl apply -f deployment.yaml service.yaml ingress.yaml
```

You can create another file called `kustomization.yaml` in the same directory
that "links" them together:

```sh
# kustomization.yaml
resources:
- deployment.yaml
- service.yaml
- ingress.yaml
```

and apply the kustomization:

```sh
kubectl apply -k kustomization.yaml
```

If you have the `kustomize` application installed, you can also have Kustomize
build a YAML file based on the resources in a Kustomization:

```sh
kustomize build kustomization.yaml
```

Where `kustomize` really shines in ~k~customizing related resources, like
putting every resource into the same namespace:

```sh
# kustomization.yaml
namespace: my-app
resources:
- deployment.yaml
- service.yaml
- ingress.yaml
```

Or common labels and annotations:


```sh
# kustomization.yaml
namespace: my-app
commonAnnotations:
  owner: app-team
resources:
- deployment.yaml
- service.yaml
- ingress.yaml
```

Or modifying specific resources with patches:

```sh
# kustomization.yaml
namespace: my-app
resources:
- deployment.yaml
- service.yaml
- ingress.yaml
patches:
- target:
  kind: Deployment
  name: my-deployment
  patch: |-
  - op: replace
    path: /spec/replicas
    value: 2
```

All of these operations that would have required many `kubectl` commands to execute
were reduced to a single `kustomize build` or `kubectl apply -k`. It's pretty
neat stuff and is also a featureset that Flux heavily takes advantage of. Let's
see how.

#### Creating the Kustomization for Guestbook

First, create a directory for `guestbook`:

```sh
mkdir -p "$PWD/repo/apps/base/guestbook"
```

Afterwards, create a directory to store "registries" of apps installed into
each cluster environment. We'll explore this soon:

```sh
mkdir -p "$PWD"/repo/apps/{dev,prod}
```

Next, fetch the guestbook app from the Kubernetes repository and save it into a
file called `app.yaml` inside of the `base/guestbook` directory we just created:

```sh
curl -Lo "$PWD/repo/apps/base/guestbook/app.yaml" \
  https://raw.githubusercontent.com/kubernetes/examples/refs/heads/master/web/guestbook/all-in-one/guestbook-all-in-one.yaml
```

We're going to add a sensitive environment variable to our guestbook that's
mounted from a Kubernetes secret. First, we need to create the secret. Use the
command below to generate the secret with `kubectl` and encrypt its sensitive
bits with `sops` like we saw earlier:

```sh
kubectl create secret generic guestbook-config \
  --from-literal=env-key=superdupersecret \
  --dry-run=client \
  -o yaml | sops --config "$PWD/repo/.sops.yaml" encrypt \
    --filename-override "$PWD/repo/apps/base/guestbook/secret.yaml" \
    --output "$PWD/repo/apps/base/guestbook/secret.yaml"
```

This will produce a secret in our guestbook's directory that looks like the
pseudo-encrypted stuff we saw earlier.

Finally, create a Kubernetes kustomization that links them all together:

```sh
cat >"$PWD/repo/apps/base/guestbook/kustomization.yaml" <<-EOF
resources:
- app.yaml
- secret.yaml
patches:
  - target:
      kind: Deployment
      name: frontend
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 1
      - op: add
        path: /spec/template/spec/containers/0/env
        value:
          - name: SECRET_ENV_KEY
            valueFrom:
              secretKeyRef:
                name: guestbook-config
                key: env-key
  - target:
      kind: Deployment
      name: redis-master
    patch: |-
      - op: add
        path: /spec/template/spec/containers/0/image
        value: redis
EOF
```

The patches we're adding here add our environment variable and change the Redis
image used by Guestbook, all without having to modify Guestbook resources
directly. Behold; the power of Kustomize!

#### Installing Kustomize apps into clusters with Flux

Earlier, we created two directories: `apps/dev` and `apps/prod`. We're going to
use these directories with Kustomize to define the list of apps that get
installed into "dev" and "prod" clusters along with any modifications that need
to be made for these environments.

This is achieved as easily as running the command below:

```sh
# Add 'guestbook' to dev cluster apps
cat >"$PWD/repo/apps/dev/kustomization.yaml" <<-EOF
resources:
- ../base/guestbook
EOF

# Add 'guestbook' to prod cluster apps
cat >"$PWD/repo/apps/prod/kustomization.yaml" <<-EOF
resources:
- ../base/guestbook
EOF
```

We're now ready to use these kustomizations to install apps into our "dev" and
"prod" clusters with Flux! This is done by running `flux create kustomization`,
storing the YAML it creates into our cluster's configuration directory,
commiting and pushing our changes, and waiting for them to apply.

Run the command below to do this with our "dev" cluster:

```sh
  flux create kustomization cluster-apps \
    --context "kind-cluster-dev" \
    --target-namespace default \
    --source flux-system \
    --path ./apps/$env \
    --prune true \
    --wait true \
    --interval 1m \
    --decryption-provider=sops \
    --decryption-secret=sops-gpg \
    --export > "$PWD/repo/clusters/dev/apps-kustomization.yaml"
```

The `--decryption-provider=sops` and `--decryption-secret=sops-gpg` flags tell
Flux to decrypt any files that look like they were encrypted by `sops` with the
`sops-gpg` Kubernetes secret we created earlier.

This will create a file that looks like this:

```yaml
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: cluster-apps
  namespace: flux-system
spec:
  decryption:
    provider: sops
    secretRef:
      name: sops-gpg
  interval: 1m0s
  path: ./apps/dev
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
  targetNamespace: default
  wait: true
```

So, yeah, this is another thing called a `Kustomization`. The Flux maintainers
[strongly feel](https://fluxcd.io/flux/faq/#are-there-two-kustomization-types)
that this is correctly named and [is not
confusing](https://github.com/fluxcd/flux2/issues/321).

If you do ever get confused by the similarities, know that Flux Kustomizations
will always be in the `kustomize.toolkit.fluxcd.io/v1` API group whereas
Kubernetes Kustomizations will be in the `kustomize.config.k8s.io/v1beta1` API
group.

Anyway, repeat these steps to install into "prod", but replace references to
`kind-cluster-dev` with `kind-cluster-prod`. Commit and push your changes
afterwards to put Flux to work:

```sh
git -C "$PWD/repo" add apps clusters &&
  git -C "$PWD/repo" commit -m "install cluster apps" &&
  git -C "$PWD/repo" push
```

Then watch the magic happen. No, really, use `watch` to watch it go:

```sh
# Run `brew install watch` or `winget install echocat.watch` to watch the
# Kustomization and Deployment get created
watch -n 0.5 kubectl --context kind-cluster-dev get kustomization,deployment -A
```

Eventually, you'll see something like this:

```
NAMESPACE     NAME                                                     AGE   READY   STATUS
flux-system   kustomization.kustomize.toolkit.fluxcd.io/cluster-apps   10m   True    Applied revision: mast
er@sha1:65741dfb235aa0ee78071bcc9155593ce9532835
flux-system   kustomization.kustomize.toolkit.fluxcd.io/flux-system    10m   True    Applied revision: mast
er@sha1:65741dfb235aa0ee78071bcc9155593ce9532835

NAMESPACE            NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
default              deployment.apps/frontend                  1/1     1            1           10m
default              deployment.apps/redis-master              1/1     1            1           10m
default              deployment.apps/redis-replica             2/2     2            2           10m
flux-system          deployment.apps/helm-controller           1/1     1            1           10m
flux-system          deployment.apps/kustomize-controller      1/1     1            1           10m
flux-system          deployment.apps/notification-controller   1/1     1            1           10m
flux-system          deployment.apps/source-controller         1/1     1            1           10m
kube-system          deployment.apps/coredns                   2/2     2            2           10m
local-path-storage   deployment.apps/local-path-provisioner    1/1     1            1           10m
```

You're ready to move on once you see `frontend` in the list of resources
returned.

But wait! Did Flux actually decrypt our Secret and mount it to our deployment?
Run the below to check:

```sh
kubectl exec deployments/frontend -- sh -c "echo \"The secret is: \$SECRET_ENV_KEY\""
```

You should see:

```
The secret is: superdupersecret
```

It totally did it! **NOW** you're good to proceed!

> ✅ If you'd like to try the app, run the command below then visit
> Guestbook at http://localhost:8080 in your browser:
>
> ```sh
> kubectl port-forward deployment/frontend 8080:80
> ```
>
> Hit CTRL-C when you're done filling up your guestbook to continue.

#### Scaling production up with Flux

Everything is bigger and bolder in production, so let's use Flux and kustomize
to scale Guestbook to two replicas without changing anything in the app itself.

Run the command below to add a patch to our production app "registry" so that
every `frontend` Deployment in Guestbook gets two replicas instead of one:

```sh
cat >>"$PWD/repo/apps/prod/kustomization.yaml" <<-EOF
patches:
  - target:
      kind: Deployment
      name: frontend
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 2
EOF

Then commit and push your changes:

```sh
git -C "$PWD/repo" add apps clusters &&
  git -C "$PWD/repo" commit -m "increase replica count in prod" &&
  git -C "$PWD/repo" push
```

Wait and watch again:

```sh
# Run `brew install watch` or `winget install echocat.watch` to watch the
# Kustomization and Deployment get created
watch -n 0.5 kubectl --context kind-cluster-prod get kustomization,deployment -A
```

You'll see in about a minute that the frontend has been scaled up to two
replicas:

```
Every 0.5s: kubectl --context kind-cluster-prod get kustomization,depl… Carloss-MacBook-Pro.local: 11:27:13
                                                                                              in 0.053s (0)
NAMESPACE     NAME                                                     AGE   READY   STATUS
flux-system   kustomization.kustomize.toolkit.fluxcd.io/cluster-apps   12m   True    Applied revision: mast
er@sha1:65741dfb235aa0ee78071bcc9155593ce9532835
flux-system   kustomization.kustomize.toolkit.fluxcd.io/flux-system    12m   True    Applied revision: mast
er@sha1:65741dfb235aa0ee78071bcc9155593ce9532835

NAMESPACE            NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
default              deployment.apps/frontend                  2/2     1            1           12m
default              deployment.apps/hello-world               1/1     1            1           12m
default              deployment.apps/redis-master              1/1     1            1           12m
default              deployment.apps/redis-replica             2/2     2            2           12m
flux-system          deployment.apps/helm-controller           1/1     1            1           12m
flux-system          deployment.apps/kustomize-controller      1/1     1            1           12m
flux-system          deployment.apps/notification-controller   1/1     1            1           12m
flux-system          deployment.apps/source-controller         1/1     1            1           12m
kube-system          deployment.apps/coredns                   2/2     2            2           12m
local-path-storage   deployment.apps/local-path-provisioner    1/1     1            1           12m
```

GitOps rules!!!

### Install Helm charts, the GitOps way

{{< post_image name="helm" alt="Flux can do Helm stuff too!" >}}

We've seen how Flux enables installing and modifying "traditional" Kubernetes
apps in Kubernetes clusters entirely with Git. Flux also has some tricks up its
sleeve for GitOps-ifying Helm charts in Kubernetes clusters. Let's explore how
this works by adding Helm's example [hello-world
chart](https://github.com/helm/examples) to our small collection of apps.

#### Creating Helm resources for Flux

First, create a directory for our `hello-world` app like we did for our previous
example:

```sh
mkdir -p $PWD/repo/apps/base/hello-world
```

Next, create a "source" for the Helm chart repository that Flux will download
this chart from and save it into our app directory:

```sh
# We'll use the 'dev' cluster; doesn't matter which since we're exporting it.
flux --context kind-cluster-dev create source helm helm-examples \
  --url https://helm.github.io/examples \
  --export > "$PWD/repo/apps/base/hello-world/source.yaml"
```

After this, we'll export a `HelmRelease` Flux object that will represent an
installation of the Helm chart, i.e. a Helm release!

```sh
# We'll use the 'dev' cluster; doesn't matter which since we're exporting it.
flux --context kind-cluster-dev create helmrelease hello-world \
  --chart hello-world \
  --source HelmRepository/helm-examples \
  --chart-version 0.1.0 \
  --interval 1m \
  --export > "$PWD/repo/apps/base/hello-world/release.yaml"
```

Finally, we'll link them together with a Kubernetes kustomize config:

```sh
cat >"$PWD/repo/apps/base/hello-world/kustomization.yaml" <<-EOF
resources:
- source.yaml
- release.yaml
EOF
```

An important distinction needs to be made here. Unlike our Guestbook app
earlier, Kustomize is _only_ used by Flux to install the Helm components that
it'll use to install our chart. It will **not** render Kubernetes objects from
the chart itself!

Commit and push your changes. Since we haven't added `hello-world` to the "dev"
and "prod" registries, nothing will get installed yet. We're just doing this to
[keep commits
atomic](https://www.aleksandrhovhannisyan.com/blog/atomic-git-commits/)!

```sh
git -C "$PWD/repo" add apps
git -C "$PWD/repo" commit -m "add hello-world app" apps
# Optionally, push up to the local Git server
git -C "$PWD/repo" push
```

#### Installing hello-world into the Kubernetes Clusters

Installing `hello-world` into our clusters is the _exact same process_ as we
followed before. Easy and auditable!

Add `hello-world` to our app "registries":

```sh
# Add 'guestbook' to dev cluster apps
cat >"$PWD/repo/apps/dev/kustomization.yaml" <<-EOF
resources:
- ../base/guestbook
- ../base/hello-world
EOF

# Add 'guestbook' to prod cluster apps
cat >"$PWD/repo/apps/prod/kustomization.yaml" <<-EOF
resources:
- ../base/guestbook
- ../base/hello-world
EOF
```

Commit and push:

```sh
git -C "$PWD/repo" add clusters &&
  git -C "$PWD/repo" commit -m "install cluster apps" &&
  git -C "$PWD/repo" push
```

Then wait for the `hello-world` Flux Kustomization and Deployment to show
up:

```sh
# Run `brew install watch` or `winget install echocat.watch` to watch the
# Kustomization and Deployment get created
watch -n 0.5 kubectl --context kind-cluster-prod get kustomization,deployment,helmrelease -A
```

Which should produce this after about a minute:

```
NAMESPACE     NAME                                                     AGE   READY   STATUS
flux-system   kustomization.kustomize.toolkit.fluxcd.io/cluster-apps   15m   True    Applied revision: mast
er@sha1:65741dfb235aa0ee78071bcc9155593ce9532835
flux-system   kustomization.kustomize.toolkit.fluxcd.io/flux-system    15m   True    Applied revision: mast
er@sha1:65741dfb235aa0ee78071bcc9155593ce9532835

NAMESPACE            NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
default              deployment.apps/frontend                  1/1     1            1           15m
default              deployment.apps/hello-world               1/1     1            1           15m
default              deployment.apps/redis-master              1/1     1            1           15m
default              deployment.apps/redis-replica             2/2     2            2           15m
flux-system          deployment.apps/helm-controller           1/1     1            1           15m
flux-system          deployment.apps/kustomize-controller      1/1     1            1           15m
flux-system          deployment.apps/notification-controller   1/1     1            1           15m
flux-system          deployment.apps/source-controller         1/1     1            1           15m
kube-system          deployment.apps/coredns                   2/2     2            2           15m
local-path-storage   deployment.apps/local-path-provisioner    1/1     1            1           15m

NAMESPACE   NAME                                             AGE   READY   STATUS
default     helmrelease.helm.toolkit.fluxcd.io/hello-world   15m   True    Helm install succeeded for relea
se default/hello-world.v1 with chart hello-world@0.1.0

```

Notice that our `hello-world` deployment is ready with `1/1` replicas running.

That's how you Flux!

### Clean Up

{{< post_image name="broom" alt="You've made it to the end! Thanks for reading." >}}

_(**Source**: iStockPhoto.)_

We're done! Let's clean up.

Delete both of our clusters:

```sh
KIND_EXPERIMENTAL_PROVIDER=podman kind delete cluster --name cluster-dev
KIND_EXPERIMENTAL_PROVIDER=podman kind delete cluster --name cluster-prod
```

Turn down the local Git server:

```sh
podman rm -f -t 1 gitserver
```

Delete the folders for our repo and SSH keys:

```sh
rm -rf $PWD/{repo,keys}
```

Delete the Podman machine you created to run everything:

```sh
podman machine rm -f flux
```

Delete the GPG key you created for encrypting your secrets:

```sh
fp=$(gpg --list-keys cluster | grep -A 1 pub | tail -1 | tr -d ' ')
gpg --delete-secret-and-public-keys --batch --yes "$fp"
```

Then, finally, and optionally, uninstall the tools you installed to do this
guide:

**Mac**: `brew uninstall kind podman gnupg sops`
**Windows**: `winget uninstall Kubernetes.Kind FluxCD.Flux GnuPG.GnuPG
Mozilla.SOPS`

## Next Steps

As you saw, Flux makes managing Kubernetes clusters with Git straightforward. I
only scratched the surface of what you can do with it, though. Here are some
next steps you can take if this was interesting to you:

- **Explore its multi-tenancy and RBAC features**. Flux assumes that it has full
  control of the cluster it's installed into by default. This obviously won't
  work if you're running clusters in more secure environments. Fortunately, you
  can modify the resources that Flux creates during bootstrap so that they are
  scoped to a single namespace. Learn more about multi-tenancy with Flux
  [here](https://fluxcd.io/flux/installation/configuration/multitenancy/).

- **Try Flux with managed Git providers**. You'll probably use Flux with GitHub,
  GitLab, or some other collaborative Git platform. It works _great_ with those
  services. Check out Flux's [official Getting Started
  guide](https://fluxcd.io/flux/get-started/) on GitHub that covers that.

- **Operators for Flux? Sure, why not?** Operators are an awesome pattern for
  installing software on Kubernetes that requires a desired state. Flux is an
  excellent candidate for being managed this way; in fact, it has its own
  operator that's worth checking out!
  [Here's](https://github.com/controlplaneio-fluxcd/flux-operator) a link to its
  GitHub Project.

## Questions? Comments? Feedabck? All are welcome!

Thanks for reading this week's CNCF Weekly on Flux! I hope you found this useful
and put it to practice!

Find me on LinkedIn at [@carlosinhtx](https://linkedin.com/in/carlosinhtx) to
let me know if there's something you really liked or something you wish you saw!
