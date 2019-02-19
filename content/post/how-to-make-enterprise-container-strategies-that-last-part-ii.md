---
title: "How To Make Enterprise Container Strategies That Last, Part 2: Docker and Docker Compose"
draft: true
date: 2019-02-16
slug: "how-to-make-enterprise-container-strategies-that-last-part-ii"
image: "/images/how-to-make-enterprise-container-strategies-that-last-part-ii/header.jpg"
keywords:
  - aws
  - docker
  - kubernetes
  - mesosphere
  - openshift
  - rancher
  - rkt
  - containers
  - enterprise
  - strategy
  - digital transformation
---

# Leaving off...

Hello, again!

In my [last
post](https://blog.carlosnunez.me/how-to-make-enterprise-container-strategies-that-last-part-i),
I wrote about the perils of taking "big-bang" approaches towards adopting
containers at scale within the enterprise. I also introduced some techniques
teams can apply as alternatives.[^1]

The next two posts follow on these talking points by introducing the "Stairs to
Container Maturity," an opinionated maturity ranking of popular container-enabling tools and
platforms used by teams and companies worldwide. This post will introduce Docker
and Docker-based orchestration platforms. The next section will focus on what
you really want to hear about: Kubernetes and k8s-driven orchestration
platofrms. I originally thought of putting these two sections together and
making one big Container Stairs post, but I found myself spending so much time
on the fundamentals (Docker), I thought that splitting them up this way made
more sense.

# The Stairs to Container Maturity

{{< post_image name="container_stairs" alt="A hopefully helpful ranking of container tech." >}}

The goals of the Stairs are two-fold.

The first goal of the Stairs is to help teams that are brand-new to containers get
an idea of what an ideal journey should look like as they execute upon their
enterprise container strategy. If you've heard of Docker but
haven't seen or applied it in practice, or if your teams are currently
experimenting with the tool but don't know where to go next, then you might find
the Stairs helpful. You might find the Stairs less helpful if your team has
already been "container-native" for some time, though it could serve as a good
gut check to reaffirm that your still heading in the right direction.

The Stairs's second goal is to help engineering managers understand the
"container-native" landscape to make better product and project-level decisions.
One can think of it as a directed and container-native-specific Magic Quadrant
of sorts. You might find this helpful if your organization is trying to decide
between multiple platforms but is having trouble making a decision.

I will not provide in-depth coverage into each tool. Doing so will create a
dangerously long and hard-to-follow post and detracts from the purpose of the
Stairs: to help teams figure out where to go next. However, I'll provide links
containing more info so you can peruse them at your own leisure.

## Stair 0: Getting Started with Docker

{{< post_image name="docker" alt="stair 1: getting started with docker" >}}

### What is it?

[Docker](https://docker.com) is a service that gives developers the ability to
package and run their applications into isolated compute units, or _containers_.
Unlike virtual machines, Docker containers are isolated at the kernel-level, not
at the processor-level. Additionally, Docker also provides support for
templates, or `Dockerfiles`, that developers can use to describe everything
that's needed for their applications to run. The instructions from these
`Dockerfile`s are used to generate _container images_ from which containers can
be created. Both of these features enable consistency in application behavior
wherever the application's container lives.

Put more simply, if you've ever heard the phrase "but it worked on _my_
machine," then Docker is the solution to that problem.

### An Example

Let's say that I wanted to run an application that looks for and prints a word
in a very large text file. I could write this with a shell script like this one:

{{< highlight "sh" >}}
#!/usr/bin/env bash
#my_app.sh <SEARCH_TERM> <FILE>
word_to_find="${1?Please provide the word to find.}"
file_to_read="${2?Please provide the file to read.}"
grep -i "$word_to_find" "$file_to_read"
{{< /highlight >}}

This would work great on my machine, as I have `bash` and `grep` installed. But
what if I gave this to someone who didn't use `bash` by default?  What if I gave
this to someone that's running a very old version of `bash` that doesn't support
the variable substitution that I'm using here to require certain parameters?
What if I ran this on an extremely limited system that doesn't have `grep`
installed? I have a Mac, which uses the BSD version of `grep` by default. What
if I gave this to someone running Linux which uses the GNU version of `grep` by
default?

Traditionally, I would have to use configuration management tools like
[Ansible](https://ansible.io), [Chef](https://chef.io) or
[Puppet](https://puppet.com) to ensure that these dependencies are met on any
machine this script runs on. This can become a large management overhead
requiring the use of centralized configuration management solutions like Chef
Server or Ansible Tower to remediate.

The `Dockerfile` solves for this, as I (the developer) can express everything that
my application needs to run (including my application) and have Docker take care
of the rest. Here's an example for our simple word-finding application:

{{< highlight "dockerfile" >}}
FROM alpine
MAINTAINER Carlos Nunez <dev@carlosnunez.me>

RUN apk install bash=3.2,grep=2.5.1
COPY my_app.sh /my_app.sh

USER 1001
ENTRYPOINT /my_app.sh
{{< /highlight >}}

On any machine that can support Docker, I would do the following to run this:

1. Build the image: `docker build -t my_app .`
2. Run the app: `docker run my_app "my_search_term" "file_to_search_in"`

Though this seems like very little changed on the surface, there is a lot going
on underneath:

1. Our `Dockerfile` ensures that the version of `bash` and `grep` that we need
   is the same on every container created from this container image.
2. Any container that starts from this image will _only_ run `my_app.sh` by
   default.
3. The filesystem used by the container will only have the libraries and
   packages the script needs and nothing else, greatly reducing your container's
   attack surface and system overhead.
4. Because we provide a `USER` directive, the application will always use the
   user ID provided instead of some random account.

What previous required a cache of cookbooks or recipes and servers can now be
reduced to a file and a few commands. Pretty impressive.

### Use Cases

#### Local Development.

{{< post_image name="local_dev_with_docker" alt="local dev with Docker"
height="50%" width="50%" >}}

If you asked me where Docker fit into enterprise container strategies in 2014, I
would've said "everywhere." Today, I feel that "raw Docker" is best suited for
local development.

While Docker itself is very powerful, it is also
very lacking in areas that matter at large scale. Container networking with raw
Docker is a great example of this.

Docker provides [a few modes](https://docs.docker.com/network/) for enabling
container networking. The most common mode, bridge networking, makes it very
easy for containers to receive a host-local, non-routable IP address. This
combined with [exposing
ports](https://docs.docker.com/config/containers/container-networking/#published-ports)
makes it easy for developers to host network- and web-services right from
Docker.

The biggest issue with this is that binding a port to a container requires a
free port on the host. If you want to run a website from within Docker and port
80 is taken on your host already, you're out of luck. Keeping track of used
ports on every host running your containerized web site becomes a massive
chore. Imagine doing this with 1000 containers running in production!

[Docker Swarm](https://docs.docker.com/engine/swarm/), which we'll discuss as we
move up the Stairs, uses overlay networking and Layer 7 routing (i.e. "service
meshes") to address these concerns. However, these concerns are almost never
concerns when developing locally.

#### Pre-Onboarding Legacy Applications

{{< post_image name="onboarding" alt="Onboarding legacy apps" >}}

Your organization maintains an important and _large_ web portal backed by Java
1.6 and hosted on WebLogic. It relies on, oh, let's say, 70 billion Enterprise
Java Beans (EJB), and many of them have to be co-located on the same WebLogic
server for your portal to run.

As an engineering manager, you _could_ decide to immediately adopt [Red Hat's
OpenShift](https://openshift.com) and use its Source-2-Image functionality to
migrate each Bean one-by-one in massive waves. Taking this approach usually
results in Enterprise IT setting up OpenShift in a hurry, everyone in your
Technology Group having to learn OpenShift and _also_ combing through many,
many, _many_ years of late night production release duct tape in hopes that
everything will _just work_ before deadline.

Another, less stressful, alternative, is putting timeboxes around seeing how a
few important, but not show-stopping, EJBs work when put into Docker images.

Selecting this alternative yields a few advantages:

- **Muscle memory**. Your teams can learn how to develop in and use Docker
    before moving onto an orchestrator without having to learn everything at
    once.
- **Reduces problem scope**. Experimenting with raw Docker first gives your team
    time to work through the core problems that prevent your application from
    running in containers, many of which are likely to get lost in a massive
    migration to OpenShift.
- **Better long-term stability**. My experience has shown that migrating
    applications to Docker with raw Docker forces many hard architectural
    conversations, as many patterns that worked in the application server model
    [fall over](https://12factor.net) when containers come into the picture.

### Things To Watch Out For

#### Kernel Gotchas

{{< post_image name="gotcha" alt="kernel virt. It's a trap!" >}}

As mentioned earlier, Docker virtualizes the operating system's _kernel_, not
the hardware the operating system runs on. This means that you cannot run
Windows applications in Linux containers, and you cannot run Linux applications
in (relatively new) Windows containers.

Prior to Windows 10 and Windows Server 2016, this meant that Windows developers
had to install Docker Machine or provision their own virtual machine with
[Vagrant](https://hashicorp.com/vagrant) or a similar tool to toy with it. This
also made Docker a non-starter for Microsoft-heavy shops, with SQL Server, .NET
4.x and IIS being (recent) exceptions.

Now that the Windows 10 and Server 2016 kernels natively support containers,
Windows developers can use the Docker for Windows service to containerize their
Windows applications. Microsoft has several container images available for IIS,
SQL Server and the .NET framework. The only caveat is that Windows containers
use Windows Server 2016 Nano as the base operating system, which is about 9GB
large. Consequently, all Windows container images will be _at least that large_,
which can make cold start times slower to a lot slower depending on your network
connection.


#### Adding unnecessary complexity

When you find your team implementing automated deployment strategies, service
discovery features or easier ways of integrating logs from your Docker
containers into centralized logging facilities, you are probably ready for
an orchestrator.

#### Treating containers like VMs.

Do you find yourself `ssh`'ing into your containers to start various processes,
or feeling the desire to install a service manager like `systemd` or
`supervisord` to run a bunch of processes at once? If so, ***you are probably
over-complicating things.***. Containers are <u>not</u> VMs.  Everything that
your application needs to start itself should be in the `Dockerfile`, and any
changes that you need to make to your containers should make it back in there.
As well, ***containers are meant to run one thing***. Having containers run
multiple processes at once creates a single-point-of-failure that makes
discoverability _really_ hard, especially at large scale.

Here's an example. Let's say that you have a Docker image that installs
Postgres and NodeJS to host a two-tier web app. It uses `supervisord` to run
both `npm` and `postgres` at invocation time via the container's
`ENTRYPOINT`. This container will run an important web application for your
company.

What happens if developers try to run this container thinking that it's just
a web app? When they stop the container, they will be surprised that data
is, at best corrupted (if using a volume mount) or, at worst, completely
gone (if not) because _they had no idea that the container also hosted its
database_.

The desire to run multiple applications at once is usually an indicator that
you are ready for the next Stair: _multi-application containerization_.

### Alternatives

#### containerd and runc

Docker separated the runtime from the Docker client and server sometime in 2016.
This was done to prevent vendor lock-in, establish an industry standard for
future container runtimes to adhere to and enable alternative clients to emerge.
Docker also did this to allow themselves to produce an enterprise Docker
offering.

[`containerd`](https://github.com/containerd/containerd) is the agnostic,
industry-standard runtime that came from this initiative.
[`runc`](https://github.com/opencontainers/runc) is an example of an open-source
client. These are the default on modern Kubernetes installations.

#### rkt

{{< post_image name="rkt" >}}

[`rkt`](https://coreos.com/rkt) is a security-conscious container runtime from
CoreOS that aims to address some of Docker's security pitfalls. Despite this
clearly-obvious benefit, it hasn't received a lot of momentium in the community.

##### Jails, Zones, LXC containers and Canonical LXD

{{< post_image name="lxd" >}}

Despite the massive hype around Docker and containers in general, containers are
not a new concept! The need to create sandboxes for users to run applications or
do other work in without compromising its host has been around for a long time.
BSD developers solved this by implementing
[jails](https://www.freebsd.org/doc/handbook/jails.html) and the `chroot` system
call. `chroot` changes the root directory of a given process to some other
directory, and a BSD jail provides an IP address and an entrypoint from which an
appllication can be invoked. Solaris provided a similar concept through Zones.

Google and others extended on this circa 2007 by authoring Linux Containers, or
[LXC](https://linuxcontainers.org/). Unlike BSD jails, Linux containers use
_namespaces_ to provide isolated resources to each containerized process and
_control groups_ to, well, _control_ resources consumed by them. In fact, Docker
is mostly LXC containers with a Union File System to enable container images and
image layers and an API.

Canonical provides a LXC-based alternative called
[LXD](https://linuxcontainers.org/lxd/introduction/). It provides a similar
feature set to Docker. I personally haven't used it; I'm curious to hear about
your experiences with it, however!

#### Chef Habitat

{{< post_image name="habitat" >}} 

Chef released [Chef Habitat](https://habitat.sh) in 2016 to provide developers a
way of packaging and running multi-process applications in a consistent way.
It uses an infrastructure very similar to Docker Swarm (discussed later)
underneath the hood, and it also provides a templating system for developers to
express the automation required to install and start their applications.

I can't speak to how Habitat works, as I haven't used it myself. I also haven't
found many people that use it either, which is part of my problem with it. I
tend to trust technologies with a large community backing over products that,
for better or worse, are mostly used by large enterprises that can afford
support contracts. I have three reasons for operating this way:

1. It is much easier to give and receive help for a product that has a large
   community behind it.
2. For engineering managers, a large community behind a product means
   easier-to-find candidates when the team needs to be scaled.
3. Products with large communities are more vulnerable. Many of its bugs are out
   in the open, so there are fewer surprises. With support-based products with
   small (or no) communities backing them, you are the mercy of your own
   knowledge and your TAM being honest.

That said, the people I've met that _have_ used `hab` seem to be happy with it!
Its integration with Chef cookbooks and recipes also seems to provide a much
easier migration story for organizations deeply seeped in Chef than Docker does.
(You can use Chef to provision container images, and you can use Chef in Docker
to build your application, but both _feel_ like smells of unnecessary complexity
to me.)

## Stair 1: Multi-container Applications with Docker Compose

{{< post_image name="compose" alt="Multi-container apps with Compose" >}}

The next step that most teams quickly find themselves in is needing to run
applications that span more than one container. This use case presents itself
with n-tiered web applications or client-server applications, for example.

This section describes ***Docker Compose***, a popular tool that enables this
functionality.

### What is it?

[Docker Compose](https://docs.docker.com/compose/) is a tool that enables
developers to run multi-container applications. It accomplishes this by using:

- A YAML-based template or _manifest_ used for describing container images and
  options for each application, or _service_, along with their options,

- A container network to allow each container to talk to each other, and

- Modifications to `/etc/hosts` on each container that allows them to reach each
  other by service name.

For example, if I wanted to use Docker Compose to provision a NodeJS web
application with a database, I would probably write a Compose manifest that
looks like this:

{{< highlight "yaml" >}}
---
version: "3.7"
services:
  app:
    image: nodejs:alpine
    volumes:
      - "$PWD:/app"
      - "$PWD/node_modules:/root/node_modules"
    command: npm start
  db:
    image: postgres
    environment:
      - PG_USERNAME=db_user
      - PG_PASSWORD=supersecret
    volumes:
      - "$PWD/data:/var/lib/postgresql/data"
    ports:
      - 5432:5432
{{< /highlight >}}

This way, my app can reach the database by using the FQDN `db:5432`.

### Use Cases

#### Local Development (again)

Legacy applications tend to require multiple processes on the same system for
them to work. This architecture is problematic in containerized environments, as the
container _is_ the process and running multiple processes in a single container
yields unpredictable behavior. Subsequently, I've found Docker Compose to be an
_excellent_ tool for helping teams responsible for developing and maintaining
applications like these:

- Better understand the work and cost involved in getting their application
  successfully running in containers[^2],

- Better understand and express boundaries in their applications, which often
  times are murky due to many years of lost knowledge, and

- Have hard conversations around refactoring architecture and design patterns
  that made more sense in 1999 than in 2019.

These crucial conversations are difficult to have during the big-bang
migrations. Moving onto a large-scale orchestrator _while migrating applications
onto it_ typically requires engineers to split their time between understanding
how the orchestrator works, understanding how their application works within the
orchestor and understanding how their applications work within containers in the
first place. The high context switching cost that comes with this often yields
poor engineering decisions that become difficult to fix long-term. (Assuming
that the application is running on OpenShift and optimizing for that, for
example, can hinder a team's ability to move onto a managed Kubernetes offering
from Amazon or Google in the future. This also negates the flexibility and
consistency benefits that come with running applications in containers, which
_kind of defeats the point._

### Things To Watch Out For

#### Reinventing the wheel

{{< post_image name="wheel" alt="Don't reinvent the wheel." >}}

While Compose can easily run groups of containerized applications and support
orchestrator-like features such as external volumes and networks, it's not
really meant to be an orchestrator. If you find yourself trying to shoe-horn
things like readiness/healthiness checks or running a service discovery tool
like [HashiCorp's Nomad](http://hashicorp.com/nomad) in your cluster, you might
have more success with a small-scale orchestrator like [Docker
Swarm](http://docker.com/swarm), which I'll discuss in more depth soon.

#### Don't Repeat Yourself

{{< post_image name="dry" alt="Don't repeat yourself" height="50%" width="50%" >}}

A cool feature that Docker Compose used to have was the ability to reuse service
definitions through the `extend` keyword. This was a convenient way of
encouraging reuse throughout your Compose services.

Say that you had a Compose manifest that defines two `service`s, one for each
application. Both of them share the same `Dockerfile` since they are both
written in the same language. You might define your `docker-compose.yaml` like
this:

{{< highlight "yaml" >}}
---
version: "2.6"
services:
  first_app:
    build:
      context: .
      args:
        - APP_TO_BUILD=first_app
    volumes:
      - $PWD/this_volume:/app
      - $PWD/some_other_volume:/data
      - $PWD/that_volume:/conf
    working_dir: /app
    networks:
      - fake_network
    command: ./run.sh first_app 
  second_app:
    build:
      context: .
      args:
        - APP_TO_BUILD=second_app
    volumes:
      - $PWD/this_volume:/app
      - $PWD/some_other_volume:/data
      - $PWD/that_volume:/conf
    working_dir: /app
    networks:
      - fake_network
    command: "./run.sh second_app"
---
{{< /highlight >}}

That's a huge reduction!

My readers with better attention to detail than me might notice that the
`version` keywords between the first and second code snippets are mismatched.
This is intentional. Docker dropped support for the `extends` keyword in version
"3" of the format to encourage users to use Docker Swarm instead. Actually, I
think that was the original reason, but Swarm [doesn't seem to have a viable
alternative](https://github.com/moby/moby/issues/31101#issuecomment-329527600)
either. In any case, this feature has been removed, and its reincarnation is
[still a hot
topic](https://github.com/moby/moby/issues/31101#issuecomment-329527600) in the Docker community.

### Alternatives

There aren't really alternatives to Docker Compose that do not provide
orchestration features. This makes sense, as the gap between "I want to run
mulitple applications in Docker that talk to each other" and "I want to
orchestrate these applications across many hosts" is really small.

The most tenable alternative, Docker Swarm, uses the Compose format for
describing services and provides orchestration features on top to enable
containers to run out of multiple hosts. The most tenable non-Docker
alternative, HashiCorp's [Nomad](https://hashicorp.com/nomad), provides a
similar feature-set. Both will be covered in depth in the next post.

## Intermission: A Real-Life Example

{{< post_image name="real_life_example" alt="Container strategies at work!" >}}

We recently helped a Fortune 100 financial services provider that was eager to
move its entire customer-facing web portal onto a containerized platform. They
were considering and experimenting with multiple platform options in hopes of
moving all of its 1000+ Java-based applications onto one of them within two
years. They were already a year into fulfilling this mandate, so crunch time was
near.

During our initial assessment of their "lighthouse" application, an account
management portal, we saw that their developers had already spent several months
learning about Docker and integrating it into their SDLC. They even built an
Eclipse plugin that automatically provisioned a Java Docker container at build
time that developers could use to run further tests.

However, the rush to move their applications left little time to truly look at
_how_ their applications (and their development lifecycles) would work after
throwing an orchestrator into the mix. Here are some problems that we found
during our initial discovery period with them:

- The Docker image our lifecycle
application used was stored on someone's computer. After digging a bit inside of
their Artifactory-based Docker registry, that image's parent image (i.e. the
image specified on the `FROM` line) had _multiple_ doppelegängers, _none_ of
whom were _actually_ used for this application's image. (We ultimately concluded
that the author of this Docker image downloaded its parent image onto their
computer and sourced from that.)

- The application itself sourced its configuration data from different locations
depending on where in the release lifecycle the application was being built.
Worse, the application contained many hardcoded URL addresses, credentials,
database connection strings and other configuration information that really
should've been stored elsewhere.

- While the Java container built by their plugin
included the application under test, because the application was served by
WebLogic, the developer had to log into the container via `docker exec` to copy
over configuration data and start the application before they could begin
testing.

Everything that we found were all signs of a nightmarish and likely abortive
migration effort.

We spent several months working through these and many other issues with the
application team. We also worked together to implement the *Build-Test-Deploy*
workflow that I introduced in Part One. We anticipated having the lighthouse
application running out of one of the orchestrators they were experimenting with
before our time together was over, but found that starting from the ground up ---
getting their application working without human intervention through Docker and
Docker Compose --- was _significantly_ more valuable. By the end of our time
there, the application team was able to move _all_ hardcoded data into
configuration manifests, leverage
[`confd`](https://github.com/kelseyhightower/confd) for injecting this
configuration at run-time, define the "base" and "middleware" images they
required and, most importantly, be able to build, test and run their application
securely without a single additional command. This application will run
beautifully and consistently whether it's on their development machines or in a
massive Kubernetes cluster, and, more importantly, the team left with a
framework that will make it easy to build production-ready applications right
from their laptops.

# What's Next?

In this post, we covered the first two stairs of the Container Platform Maturity
Stairs, single-application containers with Docker and multi-application
container groups with Docker Compose. We discussed the pros and cons of each,
and used a real-life example of these stairs at work for a real Fortune 100
financial services provider undergoing an adoption of containers at scale for
more than 1,000 Java-based web applications.

At a large enough size, being able to discover applications, define their
"healthiness" and "readiness" criteria and have more control over how they are
exposed on the network and into the Internet become important. Container
orchestration platforms provide all of these features (and more), but knowing
whether to stick to a Docker-based orchestration platform or begin using a
non-Docker-based platform depends on your desired outcomes. Our next post will
discuss the next steps of the Stairs, all of which focus on container
_orchestrators_. Like this post, I will focus on a real-life example of how
moving to orchestrators from raw Docker produced big gains for a large
enterprise.

I will wrap this series with a brief discussion of when jumping between the
Stairs makes sense and peripheral concerns to think about that come with running
containers at enterprise scale.

# Footnotes

[^1] For Bridget: Replace this for the Contino version of this blog

[^2] Not a fan of the way that this is worded.

