---
title: "How To Make Enterprise Container Strategies That Last, Part 3: Orchestrators"
date: "2019-02-21 20:16:42"
draft: true
slug: "how-to-make-enterprise-container-strategies-that-last-part-iii"
image: "/images/how-to-make-enterprise-container-strategies-that-last-part-iii/header.jpg"
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

My [last
post](https://blog.carlosnunez.me/post/how-to-make-enterprise-container-strategies-that-last-part-ii),
we covered the first two steps of the Container Maturity Staircase: running
containers through Docker and running groups of containers with Docker Compose. Eventually, the need
for running containers across multiple hosts and discover what services are running where becomes
important. These are addressed by _container orchestrators_, and that's what we'll cover in this
post.

# Stair 2: Docker-based Orchestration

{{< post_image name="docker_swarm" alt="Stair 2: Docker-based Orchestration" >}}

### What is it?

Docker Compose provides a straightforward mechanism for running groups of containers as services
through a manifest. Docker-based orchestration platforms expand on this by _using, in part, the
Docker Client API to provide a management, routing and discoverability layer for groups of
containers running on disparate hosts_. There are multiple moving parts that are introduced upon
moving to a Docker-based orchestrator:

### Coordinating the "Who" and "What"

It is pretty easy to know what containers are running on a single system with Compose or raw Docker.
Everything is stored on that system! How do you do gather and maintain this information when
containers are running on multiple machines and do so without spamming the network?

Most orchestration platforms have decided on using distributed key-value store technologies for this
purpose. Distributed KV stores provide a simple document-based backing store and also handle
replication, locking, access-control and more. Different orchestrators have chosen to use different
options for various reasons: these will be covered in the "Tools" section below.

### Networking and Routing

As briefly mentioned in Part II, networking with Docker can get complicated fast. Allocating ports
one-to-one with their hosts makes scaling difficult (effectively restricting you to 64,511 networked
services less what the host is already using) and sharing ports between containers impossible.

Orchestrators solve for this by providing a _routing mesh_ underneath the hood that handles network
creation, port and IP address allocation, and other duties. This way, multiple web services can
register themselves onto port 80 and consumers of those services can get routed to the appropriate
container.

### Service Discovery

Knowing which containers are running what becomes a cocnern once enough are running at once.
_Service discovery_ platforms aim to solve this problem. Some, like
[Consul](https://hashicorp.com/consul), use a distributed backing store and manifests to provide
this. Others use proxy-based solutions that connect HTTP and TCP routes to containers that are
serving them. Others still known as _service meshes_ provide discovery along with automated [circuit
breaking](https://en.wikipedia.org/wiki/Circuit_breaker_design_pattern), load balancing, rate
limiting and more, though taking advantage of these requires a Kubernetes-based orchestrator, which
we will cover towards the end of this post.

### Healthiness, Readiness and Backoff

Being able to start and terminate containers based on when the application declares itself ready and
healthy helps prevents _restart storms_ or unexpectedly halted containers. Fortunately,
orchestrators allow applications to easily define their "healthiness" and "readiness" criteria, and
Kubernetes-based orchestrators will handle restarting containers gracefully according to a
back-off period.

### Tag-Based Placement

When running containers on multiple machines, being able to provide categories of machines with
different capabilities is hadny. Some containers require extra resources or access to special
external services; others may not be fully [12-factor](https://12factor.net) compliant and may need
to be placed alongside each other "monolithically". Orchestrators provide users with the ability to
label services and the nodes they are placed onto to enable this.
