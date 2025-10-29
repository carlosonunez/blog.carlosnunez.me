---
title: "CNCF Weekly #1: Flux"
date: 2025-10-29T13:41:00-06:00
draft: true
image: "/images/cncf-weekly-1/header.png"
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
---

Hello!

I'm starting off CNCF Weekly with Flux, a pretty popular tool in the
cloud-native community.

## CNCF Status

Graduated

## Flux in a nutshell

Manage all of the apps in your Kubernetes clusters, and even your other
Kubernetes clusters, entirely in Git, no Jenkins required.

## Cool, but why Flux?

{{< post_image name="k8s_made_easy" alt="kubeadm never had it so good." >}}

Spinning up Kubernetes clusters is pretty easy these days. Fill out some text
fields, click a few buttons, and boom, you're cloud-native and ready to run ALL
the apps! [^0]

Managing applications and services on those clusters is a little more involved
though.

For one, there's lots of ways of doing it!

You could `kubectl` your way to a desired state, but that'll be a lot of work at
a small scale and basically impossible at "webscale™".

You could also use Terraform or Ansible (or both!) to achieve Day 2...and many people
do! Both of those tools are excellent for declaring and configuring infra like
Kubernetes clusters, especially when combined with Kubernetes package managers
like [Helm](https://helm.sh) or [kApp](https://carvel.dev/kapp).

Speaking of package managers, you could even manage all of your apps entirely
with Helm and a series of ~~tubes~~ pipelines!

{{< post_image name="gitops" alt="build the world one git commit at a time" >}}

Then you have to keep up with changes.

All of these options (and more!) are totally-valid ways of configuring apps in
clusters...but what do you do when you want to, say, update an application in
one cluster while removing another application in a different one? How do you
keep track of these changes as they happen?

This is what "GitOps", and tools like Flux, were meant to solve.

GitOps basically defines itself: operations via Git commits. It gives you the
best of both worlds: audit trails tracked by a super-well-known decentralized
version control system in near real time.

GitOps _tools_ like Flux and [ArgoCD](https://argo-cd.readthedocs.io/), a tool
I'll cover in another CNCF Weekly, make it really easy to put this into
practice. This way, you won't have to build a series of pipelines that kick off
Terraform and Ansible against your Kubernetes clusters whenever you change a
config value somewhere.

## Things I Like About Flux

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

## Things I Don't Like About Flux

- Apps with Flux are managed with `Kustomizations`, which are turned into
  Kubernetes resources by way of their requisite Kubernetes `Kustomizations`
  _which are not the same thing._ It's an unfortunate name choice that can
  really hang up some people that are new to Flux and Kubernetes.

- Some errors can be difficult to reason about, though this isn't a _Flux_
  problem as much as it's a Kubernetes side effect. Their `fluxctl` binary makes
  it easier to see where problems form, but delving into Flux `Kustomization`
  reconciliation errors can be challenging.

## Getting Started

> 📝 You can find the source code for all of this
> [**here**](https://github.com/carlosonunez/cncf-weekly/flux)

Let's say we have two Kubernetes clusters, `dev` and `prod`, and three
applications available to them: `app-a`, `app-b` and `app-c`. Let's also say
that we have some Kubernetes Secrets in a folder called `secrets` that we want
to make available to both clusters, but we want to safely keep track of them 
in our Git repository since we want to keep our application's configuration [as
close to the app as possible](url).

We're going to use Flux to do **all** of this, entirely with Git.

### Setting up our infrastructure

We're going to use [Kind](https://kind.sigs.k8s.io) to create a local cluster.
I'm going to assume you have it installed. Check out [my first
post](./cncf-weekly-init) of the CNCF
Weekly series if you don't for a quick guide on doing that!



### Creating the directory structure

First, we're going to create a new directory as well as the directory structure
within:

```sh
mkdir flux
cd flux
mkdir -p clusters/{dev,prod}
mkdir -p apps/{app-a,app-b,app-c}
mkdir secrets
```


[^0]: Some distros, like Rancher's k3s, eliminate the forms, even! `curl k3s.io
    | bash` and you're up and running in five minutes.
