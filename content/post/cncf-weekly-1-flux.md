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

Flux manages all of the apps in your Kubernetes clusters, and even your other
Kubernetes clusters, entirely in Git, no Jenkins required.

## Who's This For?

- Platform engineers and developers interested in maintaining clusters and
  their apps completely as code with Git
- Engineering managers looking for new tools to add to their arsenal

## Okay, so what is it?

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

> 📝 You can find the source code for all of this
> [**here**](https://github.com/carlosonunez/cncf-weekly/flux)

**Time Required**: 1-2 hours

Let's say we have two Kubernetes clusters, `dev` and `prod`, and three
applications available to them: `app-a`, `app-b` and `app-c`. Let's also say
that we have some Kubernetes Secrets in a folder called `secrets` that we want
to make available to both clusters, but we want to safely keep track of them 
in our Git repository since we want to keep our application's configuration [as
close to the app as possible](url).

We're going to use Flux to do **all** of this, entirely with Git.

## Steps

- [Create our workspace](#create-a-workspace)
- [Configure our machine to encrypt Kubernetes secrets](#configure-kubernetes-secrets-encryption)
- [Set up `dev` and `prod` Kubernetes clusters on our machine](#setting-up-our-infrastructure)
- [Start a local Git server to configure our clusters with](#setting-up-a-local-git-server)
- [Create and commit configuration for our clusters](#create-cluster-configurations)
- [Install Flux into our `dev` and `prod` clusters](#install-and-bootstrap-flux)
- [Configure our clusters](#configure-our-clusters)
- [Make a change and see it apply!](#do-the-gitops)

### Create a workspace

First things first; let's create a sandbox to experiment in:

```sh
mkdir $PWD/flux; cd $PWD/flux
```

Easy. Let's carry on!

### Setting up our infrastructure

We're going to use [Kind](https://kind.sigs.k8s.io) to create a local cluster.
I'm going to assume you have it installed. Check out [my first
post](./cncf-weekly-init) of the CNCF
Weekly series if you don't for a quick guide on doing that!

```sh
kind create cluster --name cluster-dev
kind create cluster --name cluster-prod
```

### Setting up a local Git server

Flux synchronizes Kubernetes cluster configuration with manifests in Git repos.
Now that we have our example Kubernetes clusters, let's stand up a local Git
repo to store our cluster configurations into!

> **NOTE**: Most tutorials online will have you do this on a hosted Git
> repository service like GitHub or GitLab. I definitely recommend practicing
> how to do this, as this is how Flux is more commonly used.
>
> For our little toy environment, we're using a local Git repo to save time and
> avoid creating accounts, adding SSH keys to our profile and all of the other
> chores you'll do when you do that exercise yourself!

#### Create SSH Keys

We're going to push changes to our configuration repos over SSH. While Flux
supports HTTPS, setting this up is slightly more involved, and SSH is more
secure anyway!

We'll need an SSH private key to do this, so run the below to create one without
a passphrase:

```sh
mkdir $PWD/keys
ssh-keygen -t rsa -f ./keys/id_rsa -qN''
```

Cool.

#### Start a Git server

Now let's use Docker to create a local Git server that Flux will fetch
configurations from in both of our servers.

```sh
docker run --rm --network=kind -p 2222:22 -d \
  --name gitserver \
  -v $PWD/repo:/git-server/repos/infra \
  -v $PWD/keys:/git-server/keys \
  jkarlos/git-server-docker
```

Once that's done, use the command below to confirm that our Git server is up and
running and accepts our SSH key:

```sh
# You might need to run this a few times before you see the welcome message.
ssh -i $PWD/keys/id_rsa git@127.0.0.1 -p 2222 | grep 'Welcome'
```

Optionally, you can use the command below to confirm that the Git server is
reachable from our Kind clusters:

```sh
for env in dev prod
do
    docker exec -it "cluster-${env}-control-plane" \
        curl -sS --telnet-option FAKE=1 telnet://gitserver:22;
    echo "===> ${env}: $?"
done
```

Which will produce the output below:

```
curl: (48) Unknown telnet option FAKE=1
===> dev: 48
curl: (48) Unknown telnet option FAKE=1
===> prod: 48
```

(The `Unknown telnet option` errors can be ignored.)

#### Create our configuration repo

Our Git server humming idly. Let's put it to work by creating a repo for our Git
configurations and push our changes up to it.

First, create the directory and enter it:

```sh
mkdir -p $PWD/repo; pushd $PWD/repo
```

Then use `git init` to turn it into a Git repo and add an empty commit to it to
make it official:

```sh
git init
git commit -m 'first commit' --allow-empty
```

Normally, we would run the commands below afterwards to push our changes up:

```sh
# won't work; don't run this!
git remote add origin git@gitserver:infra
git push -u origin master # might be 'main' on your machine
```

However, our Git server is running locally, which means it already has our
changes! Run the command below to make sure of that:

```sh
docker exec gitserver git -C /git-server/repos/infra log --oneline
```

This should produce something like the below:

```sh
64d49ab first commit
```

Cool, right?

### Create a Git project for our infrastructure

### Creating the directory structure

```sh
cd flux
mkdir -p clusters/{dev,prod}
mkdir -p apps/{app-a,app-b,app-c}
mkdir secrets
```

### Bootstrapping our "apps"

### Bootstrapping our "secrets"

### Installing `fluxctl`

### Bootstrapping Flux

### Creating our cluster Kustomizations

### Seeing our changes

### Making changes

## Next Steps

As you saw, Flux makes managing Kubernetes clusters with Git straightforward. I
only scratched the surface of what you can do with it, though. Here are some
next steps you can take if this was interesting to you:

- **Try its built-in Helm features**. Flux can also manage Helm repositories and
  configure apps from Helm chart. I definitely recommend checking this out if
  you use Helm charts heavily!

- **Explore its multi-tenancy and RBAC features**. Flux assumes that it has full
  control of the cluster it's installed into by default. This obviously won't
  work if you're running clusters in more secure environments. Fortunately, you
  can tell Flux to 

[^0]: Some distros, like Rancher's k3s, eliminate the forms, even! `curl k3s.io
    | bash` and you're up and running in five minutes.
