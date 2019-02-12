---
title: "Winning At Your Enterprise Container Strategy, Part 2"
draft: true
date: 2019-02-10
slug: "winning-at-your-enterprise-container-strategy-part-ii"
image: "/images/winning-at-your-enterprise-container-strategy-part-ii/header.png"
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

## Code Samples

### A sample `Dockerfile`

#### Code
{{< highlight "dockerfile" >}}
```
# The "parent" layer onto which the commands below should be applied.
FROM alpine

# The maintainer of this container image.
MAINTAINER Carlos Nunez <carlos@contino.io>

# The user to run this "part" of the Dockerfile as.
USER 1001
RUN echo "Building your container image; \
You will not see this message when your container runs."

# The command that containers created from this image will
# run when started. Any arguments provided to those
# containers will be appended to this command.
ENTRYPOINT ["sh","-c"]
```

#### Building it
{{< highlight "sh" >}}
```
$> docker build -t my_awesome_image .
Sending build context to Docker daemon  31.74kB
Step 1/5 : FROM alpine
 ---> 3f53bb00af94
Step 2/5 : MAINTAINER Carlos Nunez <carlos@contino.io>
 ---> Running in 61f4d8b67cc6
Removing intermediate container 61f4d8b67cc6
 ---> 6acb8d49fadd
Step 3/5 : USER 1001
 ---> Running in 66787d181aa5
Removing intermediate container 66787d181aa5
 ---> a47a211937a3
Step 4/5 : RUN echo "Building your container image; You will not see this message when your container runs."
 ---> Running in 725bc91be508
Building your container image; You will not see this message when your container runs.
Removing intermediate container 725bc91be508
 ---> f9764cb7663b
Step 5/5 : ENTRYPOINT ["sh"]
 ---> Running in 311d965dd028
Removing intermediate container 311d965dd028
 ---> 6645847bece5
Successfully built 6645847bece5
Successfully tagged my_awesome_image:latest
```

#### Running it

{{< highlight "sh" >}}
```
$> docker run temporary_image "echo 'hello'"
hello
```

## Outline

- Part One overview:
  - "Enterprise container strategies" are so hot right now
  - So many go for a big bang and fail
  - Finding the right problems and the right opps for learning are how you avoid
      doing it wrong
- Part Two preview:
  - Introduce the container technology ladder
    - The tech
    - What it does
    - Who it's for
    - Caveats
    - Where to go next

## Raw Docker

### What is it?
  - Docker is a platform for building and running containers on anything.
  - Provisioning containers "images" are done through a markup/shell script
    hybrid file called a `Dockerfile`.
      - Each instruction in a `Dockerfile` is an immutable file system "layer"
      - Docker unifies all of these layers into one file system through the
        _Union File System_.
  - The Docker engine turns container images into small, isolated processes
    that are _containers_.
      - Other container engines that can "speak" _Dockerfile_ also exist (e.g.
        `containerd`, `crio`), but we will use Docker for this article for
        simplicity.
  - The Docker engine also handles mounting external storage, log aggregation,
    networking and more.

### Who is it intended for?
  - Local development, mostly
    - Does my application _actually work_ in Docker?
    - If it doesn't, what will I need to do to make it work?
    - Examples
      - *Security*: Does my application assume that we need _root_?
      - *Statefulness*: Does my application make assumptions about directories
        or hardware being present?
      - *Configuration*: Does my application require configuration that is
          difficult to reason about?
  - Teams completely new to containerization
    - "While it is possible to go from nothing to Kubernetes, I think that teams
      that are just getting started with containers would benefit from spending
      time understanding how containers work and whether containers are right
      for them and their problem domain."
      - Fewer moving parts
      - Focuses more on the value proposition of containers instead of making it
        "Yet Another New Technology"
      - Provides a better chance at a successful adoption of containers at
        scale.

### Caveats
  - About running your app whole hog on Docker
    - "I've seen and read about companies that use raw Docker commands to run
      their app. This is a mistake."
        - *Scale*: Managing containers as your application scales will become
          _very_ hard to do. ***Containers are not VMs***. Their lifetimes are
          much, much shorter.
        - *Relationships*
          - Managing groups of containerized applications that are related to
            each other is hard with Docker
          - Software exists to help patch this problem (e.g. Containerpilot,
            Consul), but there are better and lower maintenance ways of
            dealing with this problem.
        - *Scale*: Docker is _terrible_ at networking and external storage.
          - While Docker supports these things, it does _exactly that_
          - Controlling who uses what volume or which networks are in use
            where is up to the developer (or platform team)
          - This becomes a real problem when discovering which applications
            are running on what containers (i.e. service discovery) 

## Docker Compose

### What is it?

- Docker Compose is a service that makes it easy to associate multiple Docker
  containers with each other.
  - It handles networking, shared volumes, name resolution and more for your
    sets of containers.
- Defining your services
  - "Services," or groups of containerized applications, are defined through
    YAML templates called "Compose files" or "Compose templates".
  - Older versions of Compose support "parent" services that child services can
    descend from.
  - Containers provisioned by each service can access each other by their
    service name.
      - e.g. Containers created by `service-b` service can access `service-a`
        via DNS.

### Who is it intended for?

- Local development, mostly
  - Very good introduction to how your applications will behave with a network
    overlay

### Caveats

## Docker Swarm, HashiCorp Nomad

### What is it?

### Who is it intended for?

### Caveats

## Kubernetes, Mesosphere

The section you scrolled down to.

### What is it?

### Who is it intended for?

### Caveats

This could be part three?

## In-house vs managed

- Questions to ask:
  - Does knowing this skill in-house give me a market advantage?
  - Can I get people to maintain and grow this skill set easily?
  - Will it cost me more money to maintain this skill in house?

# Winning signs, i.e. "How do I know I'm going the right way?

- Developers start asking questions
  - "Do these big shared environments make sense? Why can't we run the entire
    app on our computers with Docker?"
  - "Is there an easier way of configuring this app?"
  - "Why does it take so long to get a test environment?"
  - "Why is there so much custom stuff in our pipeline? ***Why can't I test
    these things on my machine? Docker can do it, right?***"
- Quality and speed go up
  - Developers push more, smaller commits because testing them is easier
  - Quality increases because clean test environments expose flaws more quickly
  - Platform reliability goes up because there is fewer infrastructure to manage
    despite more "stuff" running
  - Product and business are happier because they can be leaner and experiment
    more often, helping them connect with their customres better in the process
- Engineering becomes fun again
  - More code, fewer Word documents
  - Platform, security and change control become helpers instead of blockers
  - 20% time can become a thing, and [20% time is really
    important](https://citation-needed)

# How do I know if I'm going the wrong way?

- Iteration on tooling > iteration on things customers care about
  - "Saying this is ironic given that I just spent an entire section talking
    about tools, but hear me out for a bit."
  - Containers are meant to make the operation and packaging of applications as
    singular and consistent as possible
  - It's okay to focus on tooling, **but focussing on reaching and engaging customers is
    better**
    - Kubernetes is advancing at a pace that's difficult to comprehend
    - "Focussing on keeping up with the Kubernetes community could be a full
      time job, but focussing on using Kubernetes in a way that translates to
      revenue will help fund more Kubernetes exploration."
  - "If you're spending more time on tooling than on application development,
    then it might be time to re-evaluate your choice in tools."
- Platform administration costs/time goes up
  - This happens almost invisibly after adopting containers
  - If managing containers and container sprawl is more difficult than managing
    VMs, then **this might be a sign that your tools are process need
    re-evaluation**
  - How to course-correct:
    - _Keep a log of problems that keep coming up_. JIRA can be good for this,
      but the signal-to-noise ratio will probably be high. A simple notepad
      can work too. Two weeks will produce a good-enough sample size.
    - _Jot down what ideal solutions to those problems looks like_. Don't hold
      back on this! This could also be a good team activity to do.
    - _Do some research_. Maybe Kubernetes is too complicated or expensive for
      your team, and something like Nomad is a better solution. Or maybe your
      having trouble coalescing an insane amount of logs and need something like
      Prometheus to assist wtih this. The container-native community is
      extremely active right now; there's something for _almost_ everyone.
    - _Time-box some experiments!_
      - Trying new tools could be a full-time job (and is at some places...don't
        be one of those places)
      - _Use one application or service_. Treat it like a very small and
        exclusive beta. Your company is probably large enough to have many,
        many options; make it invite-only!
      - _Keep it short_and focussed._ Have a start and end date for your program. 
        Ensure that it has outcomes that you would like to see at its ends.
        ***BE A STICKLER ABOUT THIS IF YOU HAVE TO.***
      - _Don't disrupt operations_. If your operational metrics start slipping
        due to these experiments, then you might be running too many at once
        (or might need more headcount). You should be able to run experiments
        without disrupting daily operations.
