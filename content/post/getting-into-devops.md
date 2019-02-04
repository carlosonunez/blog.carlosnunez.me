---
title: "Getting Into DevOps."
date: "2017-03-02 03:58:15"
slug: "getting-into-devops"
image: "/images/getting-into-devops/header.jpg"
description: >-
  DevOps is one of the hottest professions in tech today, and for good reason:
  bridging the gap between tech and business is an incredibly important job!
  However, getting into this work can seem daunting for people on the outside.
  This post provides some suggestions on where to start.
keywords:
  - devops
  - career
  - culture
  - jobs
---

I've observed a sharp uptick of developers and systems administrators interested in "getting into DevOps" within the last year or so. This pattern makes sense, too: in an age where a single developer can spin up a globally-distributed infrastructure for an application with a few dollars and a few API calls, the gap between development and systems administration is closer than ever. While I've seen plenty of blog posts and articles about cool DevOps tools and thoughts to think about, I've seen fewer content on pointers and suggestions for people looking to get into this work.

My goal with this article is to, hopefully, draw what that path looks like. My thoughts are based upon several interviews, chats, late-night discussions on reddit.com/r/devops and random conversation, likely over beer and delicious food. I'm also interested in hearing feedback from those that have made the jump; if you have, please email me. I'd love to hear your thoughts and stories.<!--more-->

# Olde World IT

![](/images/getting-into-devops/olde-world.jpg)

Understading history is key to understanding the future, and DevOps is no exception. To understand the pervasiveness and popularity of the DevOps movement, it's helpful to understand what IT was like in the late-90's and most of the '00s. This was my experience.

I started my career as a Windows systems administrator in a large multi-national financial services firm in late 2006. In those days, adding new compute involved calling Dell (or, in our case, CDW) and placing a multi-hundred-thousand dollar order of servers, networking equipment, cables, and software, all destined for your on- and off-site datacenters. While VMware was still convincing companies that using virtual machines was, indeed, a cost-effective way of hosting their "performance-sensitive" application, many companies, including mine, pledged allegiance to running applications on their physical hardware. Our Technology department had an entire group dedicated to Datacenter Engineering and Operations, and their job was to negotiate our leasing rates down to some slightly-less-absurd monthly rate, ensure that our systems were being cooled properly (an exponentially difficult problem if you have enough equipment) and, if you were lucky/wealthy enough, that your off-shored datacenter crew knew enough about all of your server models to not accidentally pull the wrong thing during after-hours trading.

Amazon Web Services and Rackspace were slowly beginning to pick up steam, but were far from critical mass.

In these days, we also had teams dedicated to ensuring that the operating systems and software running on top of that hardware worked when they were supposed to. The engineers were responsible for architecting reliable architectures for patching, monitoring, and alerting these systems as well as define what the "gold image" looked like. Most of this work was done with much manual experimentation, and the extent of most tests was writing a runbook describing what you did, and ensuring that what you did did what you expected it to do after following said runbook. This was important in a large organization like ours, since most of the level 1 and 2 support was offshore, and the extent of their training ended with those runbooks.

(This is the world that your author lived in for the first three years of his career. My dream back then was to be the one who made the gold standard!)

Software releases were another beast altogether. Admittedly, I didn't gain a lot of experience working on this side of the fence. However, from stories that I've gathered (and recent experience), much fo the daily grind for software development during this time went something like this:

* Developers wrote code as specified by the technical and functional requirements laid out by business analysts from meetings they weren't invited to,

* Optionally, developers wrote unit tests for their code to ensure that it didn't do anything obviously crazy, like try to divide over zero without throwing an exception.

* When done, developers would mark their code as "Ready for QA". A QA would pick up the code and run it in their own environment, which might or might not be like production or, even, the environment the developer used to test their own code against.

* Failures would get sent back to the developers within "a few days or weeks" depending on other business activities and where priorities fell.

While sysadmins and developers didn't see eye to eye often, the one thing they shared a common hatred for was "change management." This was a composition of highly-regulated, and in the case of my employer at the time, highly necessary, rules and procedures governing when and how technical changes happened in a company. Most companies followed the Information Technology Infrastructure Library, or ITIL, process, which, in a nutshell, asked a lot of questions around why, when, where and how things happened along with a process for establishing an audit trail of the decisions that lead up to those answers.

As you could probably gather from my short snippet of history above, many, many things within IT were done manually. This lead to a lot of mistakes. Lots of mistakes lead up to lots of lost revenues. Change management's job was to minimize those lost revenues, and this usually came in the form of releases only being done every two weeks and changes to servers, regardless of their impact or size, being queued up to be done sometime between Friday, 4pm and Monday, 5:59am.

(Ironically, this batching of work lead to even *more* mistakes, usually more serious ones.)

# DevOps Isn't A Tiger Team

![](/images/getting-into-devops/tiger-team.jpg)

You might be thinking "What is Carlos going on about, and when is he going to talk about Ansible playbooks?" I love Ansible tons, but hang on; this is important.

Have you been assigned to a project and ever had to interact with the "DevOps" team? Or did you have to rely on a "Configuraiton Management" or "CI/CD" team to ensure that your pipeline was set up properly? Were you ever beholden to attending meetings about your release and what it pertains to weeks after the work was marked "Code Complete?"

If so, then you're re-living history. All of that comes from all of the above.

Silos form out of an instinctual draw to working with people like ourselves.[1] Naturally, it's no surprise that this human trait also manifests in the workplace. I even saw this play out at a 250-person startup I worked at prior to joining ThoughtWorks. When I started, developers all worked in common pods and worked heavily with each other. As the codebase grew in complexity, developers who worked on common features naturally aligned with each other to try and tackle the complexity within their own feature. Soon afterwards, feature teams were offically formed.

Sysadmins and developers at many of the companies I worked at not only formed natural silos like this, but also fiercely competed and listened over each other. Developers were mad at sysadmins when their environments were broken. Developers were mad at sysadmins when their environments were too locked down. Sysadmins were mad that developers were breaking their environments in arbitrary ways all of teh time. Sysadmins were mad at developers for asking for way more computing power than they needed.

Neither side understood each other, and worse yet, neither side *wanted* to.

Most developers were uninterested in the basics of operating systems, kernels or, in some cases, computer hardware. As well, most sysadmins, even Linux sysadmins, avoided learning how to code with a ten foot pole. They tried a bit of C in college, hated it and never wanted to touch an IDE again. Consequently, developers threw their environment problems over the wall to sysadmins, sysadmins prioritized it with the hundreds of other things that were through over the wall to them, and everyone busy-waited angrily while hating each other.

The purpose of DevOps was to put an end to this.

DevOps isn't a team. CI/CD isn't a group in JIRA. DevOps is a *way of thinking.* According to the momvement, in an ideal world, developers, sysadmins and business stakeholders would be working as one team, and while they might not know about everything about each other's worlds, they not only all know enough to understand each other and their backlogs, but they can, for the most part, *speak the same language*.

This is the basis behind having all infrastructure and business logic be in code and subject to the same deployment pipelines as the software that sits on top of it. Everybody is winning because everyone understands each other. This is also the basis behind the rise of other tools like chatbots and easily-accessible monitoring and graphing.

Adam Jacobs said it best: "DevOps is the word we use to describe the operational side of the transition to enterprises being software-led."

# Skills

![](/images/getting-into-devops/skills.jpg)

A common question I've gotten asked is "What do I need to know to get into DevOps?" The answer, like most open-ended questions like this, is "it depends."

At the moment, the "DevOps engineer" varies from company to company. Smaller companies that have plenty of software developers but fewer folks that understand infrastructure will likely look for people with more experience administrating systems. Other, usually larger and/or older companies, that have a solid sysadmin organization will likely optimize for something closer to a Google SRE, i.e. "a software engineer to design an operations function."[2] This isn't written in stone, however, as, like any technology job, the decision largely depends on the hiring manager sponsoring it.

That said, we typically look for engineers who are interested in learning more about:

* How to administrate and architect secure and scalable cloud platforms (usually on AWS, but Azure, Google Cloud Platform and PaaS providers like DigitalOcean and Heroku are popular too),

* How to build and optimize deployment pipelines and deployment strategies on popular CI/CD tools like Jenkins, GoCD and cloud-based ones like Travis CI or CircleCI,

* How to monitor, log and alert on changes in your system with timeseries-based tools like Kibana, Grafana or Splunk and Loggly or Logstash, and

* How to maintain infrastructure as code with configuration management tools like Chef, Puppet or Ansible, as well as deploy said infrastructure with tools like Terraform or CloudFormation.

Containers are becoming increasingly popular as well. Despite the beef against the status quo surrounding Docker at scale [3], containers are quickly becoming a great way of achieving extremely high density of services and applications running on fewer systems while increasing their reliability. (Orchestration tools like Kubernetes or Mesos can spin up new containers in seconds if the host they're being served by fails.) Given this, having knowledge with Docker or rkt (no, it is not short for "Rocket") and an orchestration platform like those aforementioned will go a long way.

If you're a systems administrator that's looking to make this change, you will also need to know how to write code. Python and Ruby are popular languages used for this purpose, as they are portable (can be used on any operating system), fast and easily to read and learn. They also form the underpinnings of the industry's most popular configuration management tools (Python for Ansible, Ruby for Chef and Puppet) and cloud API clients (Python and Ruby are commonly used for AWS, Azure and GCP clients).

If you're a developer that's looking to make this change, I highly recommend learning more about UNIX, Windows and networking fundamentals. Even though the cloud abstracts away many of the complications of administrating a system, debugging slow application performance is aided greatly by knowing how these things work. I've included a few books on this topic in the next section.

If this sounds overwhelming, you aren't alone. Fortunately, there are plenty of small projects to dip your feet into. One such toy project is Gary Stafford's Voter Service, a simple Java-based voting platform. [4] We ask our candidates to take the service from Github to production infrastructure through a pipeline. One can combine that with Rob Mile's awesome DevOps Tutorial repository [5] to learn about ways of doing this.

Another great way of becoming familiar with these tools is taking popular services and setting up an infrastructure for them using nothing but AWS and configuration management. Set it up manually first to get a good idea of what to do, and then replicate what you just did using nothing but CloudFormation (or Terraform) and Ansible. Surprisingly, this is a large part of the work that we Infrastructure Devs do for our clients on a daily basis. Our clients find this work to be highly valuable!

![](/images/getting-into-devops/books.jpg)

# Theory Books

So you've probably read *The Phoenix Project* by Gene Kim. It covers much of the history I explained earlier (with much more color) and describes their journey to a lean company running on Agile and DevOps. It's a great book.

Here are some others that are worth a read:

* *Driving Technical Change* by Terrance Ryan. Awesome little book on common personalities within most technology organizations and how to deal with them. This helped me out more than I expected.

* *PeopleWare* by Tom DeMarco and Tim Lister. A classic on managing engineering organizations. A bit dated, but still relevant.

* *Time Management for System Administrators* by Tom Limoncelli from Stack Overflow. While this is heavily geared towards sysadmins, it provides great insight into the life of a systems administrator at most large organizations. If you want to learn more about the war between sysadmins and developers, this book might explain more.

* *The Lean Startup* by Eric Ries. Describes how Eric's 3D avatar company, IMVU, discovered how to work lean, fail fast and find profit faster. *Lean Enterprise* by Jez Humble and friends is an adaption of this book for the enterprise. Both are great reads and do a good job of explaining the business motivation behind DevOps.

* *Infrastructure As Code* by our very own Kief Morris. Awesome primer on, well, infrastructure as code! Does a great job of describing why it's essential for *any* business to adopt this for their infrastructure.

* *Site Reliability Engineering* by Betsy Beyer, Chris Jones and others. A book explaining how Google does SRE, or also known as "DevOps before DevOps was a thing." Provides interesting opinions on how to handle uptime, latency and keeping engineers happy.

# Technical Books

If you're looking for books that'll take you straight to code, you've come to the right section.

* *TCP/IP Illustrated* by the late W. Richard Stevens. This is the classic (and, arguably, complete) tome on the fundamental networking protocols, with special emphasis on TCP/IP. If you've heard of Layers 1, 2, 3 and 4 and are interested in learning more, you'll need this book.

* *UNIX and Linux System Administration Handbook* by Ben Whaley and Evi Nemeth. A great primer into how Linux and UNIX works and how to navigate around them.

* *Learn Windows Powershell In A Month of Lunches* by Don Jones and Jeffrey Hicks. If you're doing anything automated with Windows, you will need to learn how to use Powershell. This is the book that will help you do that. Don Jones is a well-known MVP in this space.

* Practically anything by James Turnbull. He puts out great technical primers on popular DevOps-related tools.

# In Closing

From companies deploying everything to bare metal (there are plenty that still do, for good reasons) to trail blazers doing everything serverless, DevOps is likely here to stay for a while. The work is interesting, the results are impactful, and, most important, it helps bridge the gap between technology and business.

It's a wonderful thing to see.

Good luck!

# References

[1] https://www.psychologytoday.com/blog/time-out/201401/getting-out-your-silo

[2] https://landing.google.com/sre/interview/ben-treynor.html

[3] https://thehftguy.com/2016/11/01/docker-in-production-an-history-of-failure/

{{< about_me >}}
