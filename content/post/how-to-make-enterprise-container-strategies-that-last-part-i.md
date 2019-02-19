---
title: "How To Make Enterprise Container Strategies That Last, Part I"
date: 2018-11-26
slug: "how-to-make-enterprise-container-strategies-that-last-part-i"
image: "/images/how-to-make-enterprise-container-strategies-that-last-part-i/header.jpg"
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

## Intro

I was in high school when I got introduced to this weird app called _VMware
Workstation_. I thought the idea of using your Windows machine to run other
machines was really compelling - a perfect fit of my younger and geekier self.
You couldn't pay me enough back then to believe that [almost
all](https://www.networkworld.com/article/3253113/data-center/cisco-says-almost-all-workloads-will-be-cloud-based-within-3-years.html)[^1]
of the world's most important applications would eventually run on virtual
machines...on someone else's computers! I really liked the idea, but Workstation
was a bit of a bear to use at the time and the virtual machines it created were
quite slow.

Fortunately, many realized that making those machines faster and easier to
create would revolutionize the way IT was done while making IT _way_ cheaper. It
didn't take long before paravirtualization, processor-native extensions, VM
orchestration, software-defined networking and API-driven compute made running
virtual machines at enterprise scale a reality. Thanks to these and other
innovations, teams small and large can now create and deploy global-scale
applications within minutes with very little effort.

Given all of this and the experience I've gained over the years, I'm thoroughly
enjoying today's revolution in modern computing that makes deploying big apps
even easier - the container.

This two-part series will talk about the increasing popularity of the
_enterprise container strategy_, This post will focus on some anti-patterns that
I've seen in building these strategies and ways of avoiding them. My next post
will focus on picking the right tools for the job.


## If You're Moving to Containers, Then You Are Doing the Right Thing

Virtual machines used a thin bridge between real hardware and a host operating
system called a _virtual machine monitor, _or _hypervisor_, to emulate
everything it takes to run a real computer inside of your computer. Similarly,
containers use [kernel namespaces](https://www.wikiwand.com/en/Linux_namespaces)
to emulate the operating system within a single process. To the host, a
container is "just" like any other app like
Chrome or Outlook and gets managed like such.

There are several [container
runtimes](https://www.ianlewis.org/en/container-runtimes-part-1-introduction-container-r)
available today that enable these things, but since your mind already probably
thought "Are you talking about that Docker thing," we'll stick to Docker here.

There are four big advantages that make containers different enough to drive
[32% of companies](https://portworx.com/2017-container-adoption-survey/) to
spend over $500,000 annually on licenses for container management solutions in
2017 alone:


1. Unlike VMs that still need operating system ISOs and complicated
   configuration management, provisioning an application onto a container is as
   simple as writing a container manifest describing what the application needs
   and building a _container image_ from it.
2. VMs require a lot of boilerplate, require lots of space and can take a while
   to start. Since containers just emulate the operating system and their apps,
   they only occupy a few megabytes and can start in seconds.
3. VMs aren't very portable. They are quite large and carry a lot of metadata
   with them. Container images can live in public or private repositories, and
   the containers they create can run on almost anything, even Raspberry Pi's,
   and will look and behave the same, no matter where they run.
4. VM clusters are expensive and require a lot of infrastructure to get going.
   Container orchestration systems can run on anything, from laptops to large
   data centers.

What do these advantages enable? Lots!

*   Completely-local development environments that nearly mimic production.
*   Truly granular and independent processes instead of huge monolithic
*   applications.  Smaller, faster and tighter releases that are fast and easy
*   to rollback and recover from.  **The ability to focus on things that makes
*   your business money** **and less on things that don't.**

Moving a monolithic Java app on WebLogic into Docker is relatively easy.
Unfortunately, my experience consulting large and heavily-regulated industries
on this matter has shown me that the real challenges in creating large-scale
container platforms aren't technical.


## Laptop to Production is Key

**If developers cannot run the <span
style="text-decoration:underline;">same</span> version of an application that
will run in production, then your enterprise container strategy will fail.**

This might be a shocking statement to some. Let me explain.

The biggest benefit of running applications inside of containers is their
portability. A Linux container doesn't care that it's running on a
memory-constrained VirtualBox VM inside of a MacBook or a `cc2.8xlarge` AWS
instance; as long as that machine is running Linux and Docker, that container
will run.


### How Fast and Safe Releases Happen

Ideally, with container-driven development, whenever a developer writes a bugfix
or new feature code, assuming that they have their [pipelines written in
code](https://blog.rackspace.com/cicd-pipelines-as-code), she should be able
to use it to run unit, security and style tests, package the new version of
their app into a container image after they pass, create a Docker container from
that image, run integration tests against that container and, most importantly,
know with _nearly complete confidence_, that any containers created from that
image will work in production, _all from their laptop or workstation._ The
workflow below illustrates this process:

{{< post_image name="workflow" alt="An example of laptop to production" >}}


When done correctly, assuming safe deployment procedures, this enables
development teams to release new code into production several times per day,
safely, with the ability to roll back if needed.


### Why Slow and Error-Prone Releases Happen

{{< post_image name="slow" alt="Great communication saves trees." >}}

Most software deployment lifecycles that I've seen in the enterprise have a lot
of steps that separate local builds from what actually runs in production. What
I've seen usually looks something like this:


1. Developers (optionally) run unit tests and style checks on their laptop or
workstations. Since the tests are written by them alone, the quality and
coverage of those tests are directly proportional to that team's ability (and
time) to write good tests.
2. Upon checking in the code, a pipeline somewhere runs additional tests that
the developer did not run earlier. This code gets built in a heavily-modified
dev environment that's often held up by prayers and duct tape. They may or may
not be notified if these tests break the build.
3. Once that pipeline passes, QA runs even more tests that the developers don't
know about. The QA environment is less heavily-modified but still needs some
sort of divine intervention to keep it up and running. Since these tests are
queued, QA is always under pressure to get these tests done. Furthermore, since
QA and development are usually siloed, the quality of those tests is highly
variable.
4. Once QA certifies this code as good, the Performance team runs stress tests
(in a separate environment) that development teams, again, don't know about.
(Are you seeing a pattern?) Since they are also on a queue, they are also
whipped into getting stuff done quickly, further compromising quality.
5. Once the Performance test marks this code as good, then one or more Change
Management meeting happens to gather approvals and corral teams into a good time
(usually during the weekend) when everyone involved can do a production release.
6. Release day happens. After a few final UAT and smoke tests in a
pre-production environment, the release crew pushes the new build into
Production. However, since the build that the developer made in step 1 is
_wholly and unpredictably different _from the build that is being released in
step 6, there's no telling whether the build will actually work there.
Sometimes, issues are discovered on release day and can be rolled back. Most
times, however, customers are the ones that find these issues. When this
happens, people get yelled at, more weekends get disrupted, _companies lose good
employees_ and quality ultimately suffers until [something big
happens](https://www.theregister.co.uk/2018/08/15/tsb_hires_250_complaints_handlers_after_outage/).

Some enterprises have more testing in this workflow. Others have the less. The
problems with all of this are usually the same however: highly-disparate
environments, extreme variations in testing quality, tons of silos and,
ultimately, glacially slow and highly-tense release cycles that **prevent
enterprises from reaching more customers and making more money.**


### Fix The Process First; Awesome Technology Will Follow

Often CIOs and CTOs think that moving to containers is the silver bullet that
fixes all of this, and understandably so. "They're smaller VMs that run anywhere
and start up in five seconds? Let's move everything!" is often the rallying cry
that begets multi-million dollar enterprise container strategies and
global-scale OpenShift and ECS deployments. It's an understandable response -
the cost-savings and simplification of operations seem evident.

While the latter is a lot of fun (especially for nerds like me), most companies
start here and never question the processes that drive their slow release
processes in the first place. The result? Infrastructures explode in complexity,
releases get even slower and more process-driven, _companies still lose good
employees_, quality doesn't change and startups (or the
Facebook/Amazon/Netflix/Google cabal) eat your lunch.

The only way to solve this is to _remove the barriers_ between production and
the developer's laptop. As you can see from the aforementioned workflow, doing
all of this is quite involved. \ \


{{< post_image name="topple_the_monolith" alt="Break down the corn silos!" >}}

Let's take our QA testing environment for example. An increasing number of QA
departments are using browser automation tools like Selenium and Cucumber with
WebDrivers to verify that UIs are behaving properly. However, many QA
departments still use a bevy of manual runbooks to drive important chunks of
this testing, further slowing down releases and increasing pressure on QA
engineers. If all of those runbooks were done during the pipeline, and if that
pipeline were written as code, then developers can spend less time waiting on QA
by running QA tests during the local development process, and QA can spend more
of their time helping developers write better tests. Win-win!


## The Path to Containers at Scale is a Lot Like Building a Home

{{< post_image name="home" alt="The path to containers is a lot like home laying." >}}

Have you ever driven by a street and seen a big hole in the ground that's
obviously for a house or building for months? "When are they going to actually
start working on that house," you've thought.

If you had a custom house built or have friends in the construction business,
you know where I'm going with this. Getting the foundation for the house right
is the difference between a house that stands for 100 years and a house that
becomes a maintenance nightmare at year five. Part of getting those fundamentals
right involves doing each step carefully, one at a time.

Most of the enterprises I've helped build enterprise container strategies for
wanted to start with moving all of their key applications onto their
orchestrator of choice within a relatively short period of time, largely for the
reasons I've mentioned in the previous section. Many consider moving the
monolith into the container the finish line, but doing this is often just table
stakes. Without considering the "people and process" challenges mentioned in the
previous section, there are several engineering concerns that come after moving
the monolith to the container:



*   Containers are meant to be short-lived. Can the monolithic application
*   handle running multiple instances of itself?  Does the application rely on
*   the network and host its running on being perfect? Can it handle network
*   routes getting disconnected or being killed due to being on an overloaded
*   host?  Does the application rely on underlying storage to hold state? What
*   happens if that storage becomes unavailable?  Does the application server
*   the application runs on assume that its running multiple applications as
*   well? Does the application server make assumptions about networking and
*   underlying host resources?  Does the licensing model for that application
*   server support running potentially hundreds of instances of itself without
*   costing an arm and a leg?

Some of the answers to these questions are pretty easy to uncover during the
proof-of-concept stage. Others, such as underlying licensing or replication
concerns, can only really be answered after the "go-live." The issue with
"lifting-and-shifting" a bunch of applications in one go is that engineering
teams will be burdened with tons of go-live surprises, potentially all at once,
_while also learning how to do things in a post-container world._

To stick to the construction analogy: lifting-and-shifting an entire enterprise
at once is like building a house in one shot while making educated guesses on
when and how the structure will collapse.

Choosing a single application as the candidate for building an enterprise-scale
containerized platform is key to driving a winning enterprise container
strategy. Focusing on building a containerized platform for that single
application gives every team involved the opportunity to learn how to operate a
containerized platform and a smaller and more controllable space for uncovering
these surprises both before and after onboarding customers. As well, focusing on
single applications at a time builds institutional knowledge that greatly helps
in simplifying future migrations onto containerized workloads and decreasing
operational risk.

"You're telling me to move one app at a time? That will take forever," you're
probably thinking. It's easy to think this way since one _anything_ at a time
feels like a slog. However, much like our empty lot, the cool thing about this
approach is that moving and learning this way creates a snowball effect whereby
onboarding new apps (and their customers) into the platform becomes easier and
easier without increasing operational overhead. The crude chart below
demonstrates this.

{{< post_image name="pain-vs-toil" alt="It pays to go slow sometimes." >}}

It pays to go slow sometimes.


## Conclusion

Many enterprises are making the right choice in leveraging containerized
platforms for their digital transformations. However, choosing to "boil the
ocean" by moving entire suites of applications at once is planning to fail. The
journey to containers at enterprise scale is much like building a house, and
like a house, the journey is best done one brick at a time. By starting this
journey with moving as much of the SDLC process back to the developer as
possible, and by focusing on transforming a single application and gaining
institutional knowledge slowly, enterprises stand a better chance at creating a
modern architecture that lasts.


