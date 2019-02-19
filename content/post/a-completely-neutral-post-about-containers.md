---
title: "A completely neutral post about containers."
date: "2015-11-30 20:36:01"
slug: "a-completely-neutral-post-about-containers"
image: "/images/a-completely-neutral-post-about-containers/a-completely-neutral-header.jpg"
description: >-
  Containers are an exciting technology, but there are many misconceptions about
  them. This post aims to explain containers and Docker in more detail and
  provide some examples on when they might prove useful.
keywords:
  - docker
  - containers
  - lxc
  - linux
  - containerization
---

* **Edit 2**: I've made a few small changes to the way I've described Docker architecture. Thanks, [/u/jmtd](https://www.reddit.com/r/sysadmin/comments/3uxwwn/i_wrote_a_intro_post_for_containers_and_docker/cxj3oqd0 "")!

* **Edit**: I mentioned below that Docker containers can only run a single process. While that is true by default, it is actually not the rule. You can use Docker Supervisor to manage multiple processes within a container. [Here](https://docs.docker.com/engine/articles/using_supervisord/ "") is how you do that. Thanks, [/u/carlivar!](https://reddit.com/r/sysadmin/comments/3uxwwn/i_wrote_a_intro_post_for_containers_and_docker/cxiwddc "")

*Fact:* There are at least 22 conversations arguing about the usefulness/uselessness of containers happening right now. For every person arguing about them, at least three blog articles will shortly appear telling you why containers are going to be bigger than the Super Bowl or how they are the worst thing to happen to computing since [web scale](https://www.youtube.com/watch?v=b2F-DItXtZs "") became a thing.

This short post will not be any of those.

I believe in using the right tool for the job and I hate fads. I've also been learning about containers for the last few months and am becoming incredibly interested in figuring out how to bring them to Windows 2012 and below (Windows Server 2016+ will have them, but Microsoft will be lucky and *probably* scared if they saw anything above 20-30% uptake within its first two years), so here's a short post describing what I've learned about them, how they work, and why they might or might not be useful for you and/or your business.<!--more-->

# Here's A Scenario

![The slow route](/images/a-completely-neutral-post-about-containers/slow-website.jpg)

You're a developer for an eCommerce website and are responsible for maintaining the order management system (let's call it an "OMS"). The user-facing shopping cart and checkout processes are tied into the OMS, and these are updated more frequently than the service that handles order transactions. You'd like to be able to quickly test new shopping cart features to respond to market competition more quickly.

One way of doing this is to build virtual machines that mimic your production environment. Depending on the size of your technology team, either you or your sysadmins will set this up for you (if it isn't already so). Once the machines are ready, either you or your fellow sysadmins will update their underlying operating systems, install and configure the sites dependencies, clone the branch in which you do your development (or somehow get the files across to your sparkling-new staging environment), and, finally, run a few incantations to get everything moving.

# Reasons This Could Suck

This is pretty straightforward for some (many?) teams, but much easier said than done for larger ones for a few reasons:

* **Red tape**: The bigger the organization is, the more likely there exists lots of complexity (and siloing to match) that makes things like creating new VMs a multi-hour/multi-day effort.
* **Patching is...patching**: Patching operating systems can take a long time and introduce unforeseen regressions that might not be part of your spot test(s).
* **Golden images get complicated**: Maintaining images gets increasingly complicated fast, especially as your site gains more moving parts.
* **Money**: Most "enterprise-" grade virtualization or cloud platforms cost money, and more instances = more compute, networking and storage = more 💰💰.
* **Overhead**: Instead of worrying about whether your new shopping cart feature works, you have to worry about whether things like whether `/etc/networks` is set up right or whether your host has the right Windows license applied to it.

What was originally an "easy" feature test has now become this monolith of an environment fraught with overhead that you'd rather not deal with. This is one of the many reasons why testing isn't given the due diligence that it often needs.

# Meet Containers

![The fast route](/images/a-completely-neutral-post-about-containers/meet-containers.jpg)

A *container*, also commonly known as a *jail*, is an isolated copy of an operating system's user space within which processes can be executed independently from its parent. What this *actually* means is that you can fork off a "copy" of Linux or Windows...within Linux or Windows. These copies use all of the same hardware as the host they live on, but as far as your network or storage is concerned, they are all independent systems. As a result, containers don't need their own bank of memory or disk space like a virtual machine would.

With containers, you can do things like:

* Run a web server, a database and a message queue...without virtual machines,
  * Create restricted login environments for remote users that, to them, looks and feels like the actual system, and

  * Spin up thousands of "instances"...on a regular MacBook.

  If you're thinking "wow; that's amazing," you are not wrong.

# Containers are not new.

  Despite the recent press (and VC-backed funding) that Docker (and, in turn, containers) have been getting, containers are far from a new concept.

  The earliest, and most common, form of containers were `chroot`s and/or BSD jails. These first appeared in [Version 7 UNIX and 4.2BSD](https://en.wikipedia.org/wiki/Chroot "") in 1979 and 1982 by way of the `chroot` syscall and binary and has been used on a daily basis since to restrict the scope of access that users have on UNIX-based systems when they log in. When a user logs into a `chroot` jail, they will appear to have root access to the entire system (and might even be able to write to anything within the root partition) but, in actuality, will only have access to a volume or directory within the actual system it lives under. This gives the user the ability to do whatever they want on a system without actually destroying anything important within it.

  Additionally, hosting providers have been providing virtual private servers since well before AWS was a thing. These VPSes were either virtual machines or chroots depending on the type system requested. Google has also been using (and are still using!) containers internally for executing, maintaining and easily failing over ad-hoc jobs and services since ~2006. They recently made parts of their implementation (called "Borg") public; check out the [research paper](http://research.google.com/pubs/pub43438.html "") if you're interested. (Googlers take advantage of Borg all of the time for nearly anything and all of their production services run on it. It's unbelievably reliable and ridiculously high-scale.)

# Okay, so why Docker?

![Why Docker?](/images/a-completely-neutral-post-about-containers/why-docker.png)

  So if containers aren't a new concept, then why is Docker getting all of the attention and being hailed the Second Coming of computing?

  What Docker excels in that lxc sort-of doesn't is in ease-of-use. Docker's guiding philosophy is that its containers should be used to do a single thing and a single thing only and that containers should be able to run on any host, anywhere. This allows Docker containers to be extremely lightweight and its underlying architecture comparatively simple. This manifests itself in several ways:

  * Every container is composed of a read-only base *image* that defines its base and additional writable images that overlay it. The base image is kind-of like a classic operating system golden image with the big difference being in it lacking an operating system. Typically, the additional images that overlay it are built using *Dockerfiles*, but they can also be built via the `docker` binary.
  * Images are stored in an image registry called the [Docker Hub](https://hub.docker.com/ "") where they can be downloaded from anywhere and versioned to make rollbacks easy. Committing to and pulling from Docker Hub is built into the `docker` binary. Images can also be stored in private hubs if needed.

  * Docker also includes a [RESTful API](https://docs.docker.com/engine/reference/api/docker_remote_api/ "") that makes it very easy to build tooling around.

  * Docker is FREE!

  **TL;DR**: Docker makes it very easy and cheap to build up a containerized environment in very little time.

# Why not Docker (or containers)?

  While Docker is an amazing tool for getting containers up and running quickly, it doesn't come without its limitations:

  * Docker containers can only run one process at a time. This means that services that are typically co-located on a traditional host will have to be on separate containers with Docker and the onus for getting them to communicate with each other falls on you.

  For running a container with multiple processes at once, a Linux Container (or LXC container) or a VM is probably more appropriate.

  * Since Docker virtualizes the operating system within the operating system ([yo dawg](http://cdn.meme.am/instances/500x/60864927.jpg "")), it is theoretically easier for a process running within a container [to escape out into its parent operating system](http://www.projectatomic.io/blog/2014/08/is-it-safe-a-look-at-docker-and-security-from-linuxcon/ ""). A (modern) virtual machine is much less susceptible to an attack like this since the hypervisor under which it runs runs within a different protection ring inside of the processor, which protects rogue processes within machines from being able to access real hardware on the host.

  That said, most security researchers consider Docker to be pretty safe at the moment, so the likelihood of this happening is low enough to mitigate concerns.

  * For the same reason as above, you can't run different operating systems within containers. This means that Windows containers on a Linux host is out of the question...for now. Additionally, Docker uses Linux-specific features in its core, meaning Windows and OS X hosts need to use a virtual machine and a lightweight service called Boot2Docker to take advantage of it. Windows Server 2016 will bring support for containers to the forefront, but that's still a few months out.

  It should be noted that **containers are NOT replacements for virtual machines**. Virtual machines are better solutions for heavy, monolithic apps or systems that are difficult to break apart or anything that requires an entire operating system stack. However, people have been finding containers to be pretty good replacements for small apps or services within apps (or enough motivation to break those big, heavy apps down into pieces using a [service-oriented architecture](https://www.opengroup.org/soa/source-book/soa/soa.htm "")).

# Our Scenario...With Containers

![Fast apps are awesome](/images/a-completely-neutral-post-about-containers/so-much-faster.jpg)

  With that, let's go back to our expedient web dev that's eager to test that new shopping cart feature. Taking the VM approach described above might be difficult and time-consuming. If she were to use containers, the process would be a little different:

  * Install Docker (and Boot2Docker if needed) onto their system.
  * Create Dockerfiles describing the containers needed to re-build a local instance of production or [create images](https://docs.docker.com/engine/articles/baseimages/ "") if needed
  * Define your environment using [Docker Compose](https://docs.docker.com/compose/ "")
  * `docker-compose up`

  That's mostly it! All of this can be done on localhost, and all of it is (relatively) easy.


