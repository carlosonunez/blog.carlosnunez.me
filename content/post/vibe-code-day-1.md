---
title: "Carlos learns to vibe code, Day 1: real humans only"
date: 2025-08-09T20:36:00-05:00
draft: false
slug: "vibe-code-day-1"
image: "/images/vibe-code-day-1/blocked.png"
categories: 
  - software
  - ai
  - llm
  - vibe code series
tags: 
  - software
  - vibe coding
  - ai
  - llm
  - claude
  - claude code
---

* [Day 0](../vibe-code-day-0)
* [Day 1](../vibe-code-day-1) **⬅️ you are here**

So, Day 1 was super productive! I signed up for Claude! Yay!

## Signing Up

{{< post_image name="phone-number" alt="This manuever will take your entire day and $20." >}}

Signing up was a process.

To minimize the number of times my personal data gets sold and, unavoidably,
leaked to search engines, I use a combination of
[Ironvest](https://ironvest.com) or [Fastmail's](https://fastmail.com) Masked
Email feature, throwaway phone numbers from [SMSpool](https://smspool.com) and
[Privacy](https://privacy.com) cards to sign up for services I might not keep
long term. (I actually use Privacy cards for all of my online services, as it is
_so much easier_ to keep track of recurring costs this way.)

Anthropic...had opinions about that. Mostly "yeah, but no" opinions.

Ironvest emails worked fine as long as I used one of their custom domains.
Providing a phone number was a different story.

I tried using the default Masked Phone number from IronVest that I use for most
services. Claude straight up rejected it. This was surprising, as most services
(including Google, who is known for having strict phone number verification)
have accepted this number in the past.

Time for plan B. I created a throwaway account on SMSpool, gave it $5 through a
one-time Privacy card with a $5 cap, created a number that was compatible with
Anthropic and tried again.

This worked! Sort of.

Anthropic accepted the number, but its SMS verification code never arrived, even
after waiting the three minutes SMSpool recommends for activation and such. The
second number I created _did_ receive an SMS, which was great.

Or so I thought.

{{< post_image name="blocked" >}}

I went back into the terminal to finish authenticating the `claude` CLI. It had
me go back into the browser to get an auth code. Surprisingly, I discovered that
my account was blocked!

The speed at which Anthropic's abuse system disabled this account was actually
quite impressive.

There was no way I was giving Anthropic my real number. I didn't want to do it,
but I had to engage Plan C.

{{< post_image name="esim" alt="so pissed i had to do this" >}}

It was time to buy a prepaid eSIM.

I definitely didn't want to do this, though with more online services cracking
down on VoIP phone numbers, it was only a matter of time.

Airalo was my first choice. I've heard of this service from the
[`/r/onebag`](https://old.reddit.com/r/onebag) community. Many people seem to
like it for getting eSIMs quickly on international trips. I wasn't traveling
beyond my couch, but it'll work all the same.

Signing up and registering the eSIM to my phone was easy. 10 minutes and $10
later, I had a phone number and was on my way.

{{< post_image name="blocked" alt="ARE YOU KIDDING ME">}}

Anthropic blocks Airalo numbers!

I was floored. It's a real phone number on T-Mobile's network! How did they even
know?! DO THEY NOT LIKE MONEY?

Fine, so Airalo won't work. I wasn't going to give up yet.

What about US Mobile, the carrier I use for my work phone, whose number hasn't
been blocked by any online services to date?

**Success.**

It took a little while to get my number activated, but once that finished, I was
_FINALLY_ able to register with _yet another_ masked email and give Anthropic my
damn money.

{{< post_image name="requirements" alt="it's all about requirements, really" >}}

In a way, I was actually thankful for going through this whole ordeal. It made
me realize that the prompt I wanted to create wasn't detailed enough to describe
what I wanted to build.

Thus, I used the downtime to spend time on tuning my prompt. I added a
description of what I wanted to achieve, the modules I wanted Claude to build
for this app, schemas for the objects used throughout my status app,...

...which is when I saw it.

Years ago, in prehistoric times, I used Cucumber-style BDD tests to describe
what I wanted my applications to achieve. While these often changed
significantly as I iterated, this really helped me figure out _what I actually
wanted._

And here I was doing that again!

It seems that spending time writing _and thinking_ about what you want is still
critical, vibe coding or otherwise.

This, I posit, gives senior engineers a substantial edge in the all-AI, all the
time future we're converging to...but that's a post for day 2!
