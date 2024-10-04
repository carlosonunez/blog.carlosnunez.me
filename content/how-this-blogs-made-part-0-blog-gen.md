---
title: "How This Blog's Made, Part 0: blog-gen and AWS"
date: 2023-10-22T11:01:59-05:00
draft: true
categories: 
  - deep-dives-in-kiddie-pools
tags: 
  - meta
  - ci/cd
  - devops
  - automation
---

{{< post_image name="meta" alt="A blog post about this blog." >}}

I've been writing about techy stuff in this blog for a surprisingly long time!
This blog and I have grown together in a sort of ways.

[Jump to recipe](#blog-gen-architecture)

## My Growth

When I first created this blog, I was a Windows systems engineer
spending hardcore amounts of time writing tons and tons of PowerShell to build
various odds-and-ends that the companies I worked for needed.

While I knew how to use Mercurial (lol) and the wonders of versioning and source
control, I knew nothing about how to actually test and release software. I
didn't even think I _wrote_ software. I spent too long thinking that I wasn't
a software developer because I wasn't compiling stuff (I definitely abused C#
for some of my PowerShell scripts, and I wrote a ton of F#) or "actually
releasing software" (despite my stuff being used quite a lot!)

These days, I'm a get-shit-done engineer/consultant/salesperson thing that knows
a lot more about a lot of stuff. I've mostly traded in my Windows knowledge for
*nix experience, though I can still navigate my way through a Windows box (once
I [dodge all of the built-in
ads!](https://www.pcworld.com/article/1668041/ads-in-the-windows-11-start-menu-are-definitely-coming.html)).
I've toured the US talking about [how
awesome](https://carlosnunez.me/talks) DevOps makes building and shipping
software become, helped some of the world's largest companies practice what I
preach, and, of course, have gone _all the way in_ on Kubernetes and Platform
Engineering.

People thought that I was nuts for wanting to colocate closer to engineering
and really understand the businesses we were supporting despite being a
sysadmin. It's awesome to see devs and ops all over finally agree that this is,
in fact, a good idea.

## My Blog's Growth

{{< post_image name="growth" >}}

This blog originally [started its
life](https://www.linkedin.com/pulse/five-reasons-why-you-need-windows-10-your-life-right-now-carlos-nunez/?trackingId=Q7Lbhcu6QzK9YcPT6SIbeQ%3D%3D)
as posts on LinkedIn I wrote while trying to grow my consulting business.

LinkedIn's WYSIWYG editor was fine...until you wanted to write your posts as
code. There weren't (aren't?) any good tools to do this, LinkedIn's Posts
API (now Pulse) wasn't easy to use outside of the website, and the markup format
was _definitely_ not meant to be used by anything except the editor.

After one bad night of writing a post in the editor and having it lose all of my
changes after an accidental refresh, I decided I had enough and moved the blog
to WordPress.

This worked well. It even supported Markdown, though it only supported it within
the wizzywig editor. After a while, though, it felt disingenuous to talk about
DevOps as a new-and-shiny DevOps consultant while paying Automattic $12/month to
host my blog. I was also growing allergic to slow loading times from WordPress's
ultra-heavyweight JavaScript and having to use their portal for analytics
instead of using something more industry-standard, like Google Analytics.

So I spent a weekend (or three) moving all of my posts to GitHub, using
[Hugo](https://gohugo.io) to convert my Markdown (_finally_ written in a
**real** text editor, i.e. `vim`) into something presentable, and writing
Terraform to deploy the site into AWS.

## DRY

{{< post_image name="dry" >}}

I'm a huge advocate of [Don't Repeat
Yourself](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself0. I'll usually
turn my code into a function or module after I feel like I've repeated myself
three or so times.

Given how easy Hugo made (and still makes) writing and mainaining my blog, I
knew I wanted to use it for other blogs. But there was no way I was gonna
copypasta my Terraform and stuff into those code bases. Maintaining my god-awful
code in one place is already a ton of work as it is!

I could have outsourced building and deploying my blog to [Netlify](https://www.netlify.com)
or something like that. However, outsourcing something that I _should_ be able
to maintain myself as a True DevOps Believer™ felt..._wrong_? I also didn't want
to outsource these functions to a friendly startup with more integrations and
Cleaner Code™ like Netlify, only to eventually [fall victim to
enshittification](https://www.wired.com/story/tiktok-platforms-cory-doctorow/0)
by being told to stop freeloading and pay up.

So I hastily wrote [`blog-gen`](https://github.com/carlosonunez/blog-gen), which
is the _real_ topic of this post. (Thanks for reading this far!)

## The Journey to Webscale

I'm going to spend the next few posts talking about how I use `blog-gen` to
deploy my app into Docker, Kubernetes and AWS.

In this post, I'll describe how my blog is conpost_imaged and how it works with
`blog-gen` to get deployed into AWS S3 and CloudFront.

In the next post, I'll talk about how I use `blog-gen` to generate containerized
images of my blog in case I decide to divest from (or supplement) AWS and host
my blog in a conatiner orchestrator like Digital Ocean, Nomad or...

Kubernetes! Which the post after that will focus on. There, I'll outline how
this blog can be hosted within Kubernetes start to finish.

Today, new versions of my blog are shipped with GitHub Actions. But what if I
get tired of that and want to use Kubernetes for everything? Enter part four of
my journey to webscale. Here, I'll talk about how I can use Tekton to CI/CD my
blog entirely within Kubernetes and have my blog be entirely self-sufficient.

This all works super well for this blog. However, `blog-gen` really shines for
deploying multiple blogs! It'll churn out and deploy blogs all day, no matter
the content, as long as their repos are set up correctly. In the final post of
this journey, I'll talk about how I can use
[Cartographer](https://github.com/vmware-tanzu/cartographer) to re-use Tekton
resources for multiple blogs with a single manifest.

Let's go!

## `blog-gen` architecture

{{< post_image name="architecture" >}}

The heart of `blog-gen` is in its [deploy
script](https://github.com/carlosonunez/https-hugo-bloggen/blob/main/scripts/deploy).

Blogs that are managed by `blog-gen` only need three things:

- `env.gpg`: A file encrypted with a PGP passphrase that contains a dotenv file
  called `.env` that follows `blog-gen`'s [dotenv configuration
  format](https://github.com/carlosonunez/https-hugo-bloggen/blob/main/.env.example)
- `params.toml`: An additional set of Hugo configuration properties for your
  Hugo theme to merge with `blog-gen`'s [default
  config](https://github.com/carlosonunez/https-hugo-bloggen/blob/main/config.toml.tmpl)
- Some kind of CI/CD manifest that pulls in `blog-gen` into a top-level folder
  called `blog-gen` and runs `scripts/deploy`, like
  my GitHub Actions manifest [here](https://github.com/carlosonunez/blog.carlosnunez.me/blob/main/.github/workflows/main.yml)

