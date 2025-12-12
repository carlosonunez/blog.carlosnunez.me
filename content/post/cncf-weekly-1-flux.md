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

Flux enables Kubernetes clusters and their apps to be configured with Git. Time
to retire your Jenkins pipelines.

## Who's This For?

- Platform engineers and developers interested in maintaining clusters and
  their apps completely as code with Git
- Engineering managers looking for new tools to add to their arsenal

## Okay, so what is it?

{{< post_image name="k8s_made_easy" alt="kubeadm never had it so good." >}}

Say you just spun up a brand-spankin' new Kubernetes cluster. `kubectl`
works, and you can _feel_ the power hiding underneath it. All is good.

It's time to install some stuff into it. [Probably something AI
related](https://github.com/kserve/kserve) to satisfy your company's "enterprise
AI strategy."

This is easy work: grab (or make) its Helm chart, `helm upgrade --install` it
and you're off to the races.

This will _not_ be easy work when your AI-related thing finds its
[PMF](https://en.wikipedia.org/wiki/Product-market_fit) and now needs 10
Kubernetes clusters with hundreds of apps to keep up.

You'll need to automate. And you'll be overwhelmed by your options!

You could `kubectl` your way to a desired state, but that'll be a lot of work at
a small scale and basically impossible at "webscale™", as you'll observe when
you spin up cluster #2.

You could also use Terraform/OpenTofu or Ansible (or both!), like many people
do! Both of those tools are excellent for declaring and configuring infra like
Kubernetes clusters, especially when combined with Kubernetes package managers
like [Helm](https://helm.sh) or [kApp](https://carvel.dev/kapp).

{{< post_image name="gitops" alt="build the world one git commit at a time" >}}

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

|                   |                                                                             |
| :-----            | :-----                                                                      |
| **Time Required** | 1-2 hours                                                                   |
| **Source**        | [GitHub](https://github.com/carlosonunez/cncf-weekly-guides/tree/main/flux) |

You're going to use Flux to configure three apps --- `app-a`, `app-b`, and
`app-c` --- into two local Kubernetes clusters, `dev` and `prod`, entirely with
Git.

We're also going to see how Flux works with
[`sops`](https://github.com/getsops/sops), an excellent encryption tool, to
make storing Kubernetes Secrets in your Git repository safe and secure.

Let's jump in.

### Steps

- [Create our workspace](#create-a-workspace)
- [Set up `dev` and `prod` Kubernetes clusters on our machine](#setting-up-our-infrastructure)
- [Start a local Git server to configure our clusters with](#setting-up-a-local-git-server)
- [Create a configuration repo](#create-a-configuration-repo)
- [Configure our machine to encrypt Kubernetes secrets](#configure-kubernetes-secrets-encryption)
- [Add encrypted Kubernetes secrets](#add-encrypted-kubernetes-secrets)
- [Install Flux into our `dev` and `prod` clusters](#install-and-bootstrap-flux)
- [Configure our clusters](#configure-our-clusters)
- [Make a change and see it apply!](#do-the-gitops)

#### Install tools

Let's install the tools we'll use in this guide.

##### Podman

{{< post_image name="containers" alt="Containers. Containers everywhere." >}}

**Mac**: `brew install podman`
**Windows**: `winget install RedHat.Podman`

Run the command below after installing Podman to set up a machine that will run
the Podman container engine:

```sh
cat >$HOME/.config/containers/containers.conf <<-EOF
[machine]
rosetta=false
EOF
podman machine init flux
podman machine start flux
```

Finally, confirm that Podman's installed:

```sh
podman run --rm hello
```

You're good to go when you see friendly seals welcome you to Podman.

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

##### Kind

We'll use this to create our Kubernetes clusters in Docker.

**Mac**: `brew install kind`
**Windows**: `winget install Kubernetes.kind`

##### Flux

**Mac**: `brew install fluxcd/tap/flux`
**Windows**: `winget install FluxCD.Flux`

##### sOps and GnuPG

We'll use these tools together, so it makes sense to install them together!

**Mac**: `brew install gnupg sops`
**Windows**: `winget install GnuPG.GnuPG Mozilla.SOPS`

#### Create a workspace

First things first; let's create a sandbox to experiment in:

```sh
mkdir $PWD/flux; cd $PWD/flux
```

Easy. One down; seven more steps to go!

#### Setting up our infrastructure

We're going to use [Kind](https://kind.sigs.k8s.io) to create a local cluster.
I'm going to assume you have it installed. Check out [my first
post](./cncf-weekly-init) of the CNCF
Weekly series if you don't for a quick guide on doing that!

```sh
kind create cluster --name cluster-dev
kind create cluster --name cluster-prod
```

#### Setting up a local Git server

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

#### Create a configuration repo

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

#### Add encrypted Kubernetes secrets

Now that our repo is set up, we're going to set ourselves up to store some
Kubernetes Secrets into it securely.

##### Install tools

We'll need two tools to do this: `sops` and GnuPG. Both are easy to install.


##### Create a GPG key

Next, use the command below to create a GPG key that we'll use to encrypt our
Kubernetes secrets with.

```sh
gpg --quick-generate-key --passphrase='' --batch cluster
```

Run the command below to confirm that your key was created and is being tracked
by GnuGPG:

```sh
gpg --list-keys cluster
```

You should get something like the result below:

```
gpg: checking the trustdb
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   3  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 3u
pub   ed25519 2025-12-12 [SC] [expires: 2028-12-11]
      3BD08674578887B3BE5F6A62AA344CC889F611DC
uid           [ultimate] cluster
sub   cv25519 2025-12-12 [E]
```

#### Configure sOps




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
