---
title: "SRE Communities vs SRE Centers of Excellence"
date: "2019-03-19 01:23:00"
slug: "sre-communities-vs-sre-centers-of-excellence"
image: "/images/sre-communities-vs-sre-centers-of-excellence/header.jpg"
keywords:
  - enterprise
  - strategy
  - digital transformation
  - sre
  - reliability
  - devops
  - cloud
  - engineering
  - culture
  - communities
  - centers of excellence
  - agile
---

I read Google's _Site Reliability Engineering Workbook_ on a flight to New York the other day. I
read their [original book](insert-sre-book-link) when it came out two years ago and was curious to
see how much of it mirrored my own (brief) experience as a Google SRE. Given that it's been a while
since I did pure SRE work, I wanted to keep my skills caught up, and the Workbook seemed like a more
accurate reference to follow. (Techncially, I was a Systems Administrator in a Corporate Engineering
SRE team that I don't think exists anymore.  While titles never mattered during my time at Google,
and us SA's did the same work as SREs on that team, I wouldn't feel honest with myself without
making that distinction.)

Upon reading Home Depot's story of their journey to SRE (which is a really interesting read, btw!),
I briefly remembered a short conversation I had with a Senior Enterprise Architect at a
multinational automotive brand at a DevOpsDays event I spoke at two years ago. He was undergoing a
transition to the SRE mentality, but was having trouble deciding whether he should create a
Reliability Center of Excellence, or whether he should distribute that company's reliability
principles amongst their hundreds of development teams across the world. Tough position, and a big
job indeed.

I am a strong advocate of empowering development teams and letting communities form naturally (since
us engineers tend to be good at that) and explained my stance to him. In hindsight, though, I feel
like I didn't do a great job of articulating _why_ I felt that way, perhaps because I didn't fully
know myself.

I feel like I have a better understanding of my feelings now. Here's why I feel that communities
will _always_ produce better outcomes and better cultures than centers of excellence.

{{< post_image name="silo" alt="Silos are bad" >}}

# Centers of Excellence Are Silos, And Silos Are Bad

Centers of excellence, or "CoEs," are a good idea in theory. You recruit the best engineers
throughout your organization into the CoE, and give them the power to not only set the tone and
reference for how things should be done at your organization, but to also travel from team to team
and ensure that those standards are socialized and enforced. This makes sense: reliability is a new
thing for a lot of enterprise application teams, and having a group of highly-respected people tell
teams how to do things is a good way to make new things stick.

The problem with this is that _*CoEs always devolve into support silos, and silos are almost always
a bad thing_*. What usually happens with reliability CoEs is something like this:

1. They create reference architectures for reliability tooling, such as ELK logging clusters and
   Prometheus or Splunk monitoring stacks. They design them with loose connections to real-world
   problems, post the Terraform/Ansible code on GitHub, say "Let it be so" and call it a day.
2. Application teams adapt the reference architectures, usually with some handholding from the CoE.
   Initially, everything works great.
3. After a while, the problems start rolling in. Logs get missed; monitors need updating; dashboards
   need dashboarding; etc. Because application teams often do not have the bandwidth to address
   these issues themselves, they ask the CoE for help, often with an action that highly resembles
   objects being thrown over walls.
4. Once the problem queue gets long enough, more and more teams begin to blame the CoE for blocked
   releases and "the reason why we have weak DevOps." The CoE gets dedicated headcount just for
   support.
5. The CoE spends more time supporting massive amounts of teams than keeping standards up-to-date
   and socialized. Toil increases in tandem with burnout. Morale decreases and the organization's
   previously-best engineers polish the resume and look for other opportunities.

{{< post_image name="engineers" alt="Engineers are hard to find." >}}

# Engineers Are Hard To Find

If you are an engineering manager, "I can't find enough good engineers" is probably something that
you've said at least once this year (and, yes, I'm talking about 2019!). You're not wrong; most of
the "good" engineers are either allergic to recruiters or very, very happy with their current
situation.

If you believe this, then why would you move your precious engineers into a silo outside of their
expertise? Would it not it make more sense to have those good engineers spearhead high reliability
within their own teams and do their own evangelizing onto others?

{{< post_image name="teamwork" alt="Teamwork makes SRE work" >}}

# Reliability Is Everyone's Job; How It's Done Doesn't Matter

The sole reason for creating highly-reliable products is to keep your customers happy and wanting to
come back. Knowing your customers and keeping them happy is _everyone's_ job. Therefore,
reliability, too, is _everyone's_ job.

CoEs are often formed with the idea of having "right ways" of enabling the "right tools" throughout
an organization. However, the tools and the ways don't really matter. There are tons of ways of
capturing, recording and display HTTP response codes and service latency, but none of those help
when your teams spend hours upon hours troubleshooting medium-severity tickets. What matters is:

- Knowing what customers actually care about, Knowing the metrics that tell you when customers might
- not be happy, and Knowing how long your customers expect your service to be available before the
- complaints roll in.

Your organization probably doesn't need a CoE to show people how to care about their customers.
What most application teams would greatly prefer instead is _the breathing room required to take a
break from building features and use that space to focus on reliability._

Sometimes, this can be accomplished with more headcount. Other times, this can be accomplished by
using highly-focussed on call strategies such as Google's [Interrupts](link-to-interrupts-pdf)
approach. Regardless of the method, *executive sponsorship is always a must.*

{{< post_image name="naturally" alt="Communities are natural." >}}

# SRE Commuinities Will Form Naturally; Let Them!

There has always been one thing in common amongst all of the enterprises I have consulted for:
_hungry teams._ Usually few and far between, hungry teams are the ones living on the bleeding edge.
While an enterprise moves towards adopting Kubernetes, the hungry teams are experimenting with
unikernels or finding ways of contributing solutions to their problems to open source. hungry teams
find ways of working around perceivably-draconian enterprise processes while still, somehow, playing
by the rules.

Hungry teams are almost always the progenitors of practice _communities._

While centers of excellence attempt to transform an organization through a rigid hub-and-spoke
model, communities are more mesh-like. While they often come about informally, _their members are
usually highly-respected engineers that are highly passionate about the cause._ Unlike centers of
excellence, reinventing the wheel _is not always a bad thing_ within communities for a few reasons:

1. Reinventing the wheel is how engineers learn, and learning leads to better tools,
2. No two teams are the same, and tools should subscribe to the UNIX philosophy of doing one thing
and doing it well, and
3. Communities will self-select the best tools, and the adoption of those tools will happen
naturally (think: GitHub stars).

Communities are especially advantageous when it comes to service reliability. Many organizations are
moving to or considering adopting the [squad model](insert-squad-link). Popularized by Spotify,
squads aim to align product ideation to development by moving product development, design,
engineering and operations into singular organizational units. In this model, _reliability means
different things to different people._ Centers of excellence have no chance of obtaining context for
every squad in an organization. Shifting reliability (and infrastructure concerns) left to the
squads and letting reliability engineers self-organize and discuss what's worked for them is much
easier to scale.

{{< post_image name="try_it" alt="Try SRE communities today!" >}}

# You Probably Already Have Communities. Empower Them!

If you're building a SRE "center of excellence," stop. You probably already have the excellence
you're looking for! Finding "hungry" teams that are already living on the wild side (by embracing
site reliability principles) and giving them support to proliferate their learnings throughout your
organization will not only lead to a more organic uptake in your SRE journey, but it will also lead
to higher quality software and better engineering culture that will last.
