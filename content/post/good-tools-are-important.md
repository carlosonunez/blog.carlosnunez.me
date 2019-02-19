---
title: "Good Tools Are Important. Ignore At Your Own Peril"
date: 2019-02-19
slug: "good-tools-are-important"
image: "/images/good-tools-are-important/header.jpg"
keywords:
  - enterprise
  - tech culture
  - engineering
  - tools
  - laptop
  - code
  - develop
  - macbook
  - surface
  - thinkpad
  - dell xps
---

I've been consulting for some of the world's largest companies for the last
three years and have observed three themes that worry me:

- Agile is a really controversial word, despite [the
  manifesto](http://agilemanifesto.org/) being quite clear on the matter,
- Somewhere within every company, there are many, many engineers that have been
  waiting _weeks_ for test environments, and
- **Engineers have the heaviest, plasticky-iest, and most unpleasant machines
    in the entire organization**

This (hopefully) brief post is about that third point.

# Life of an Engineer With Subpar Tools

I'm not talking about DevOps tools. Big companies have _plenty_ of that.

I'm talking about hardware. The things through engineers consume the above
tools. The things that engineers will spend eight hours (or more) per day on.
**The things that make engineers valuable enough for your company to hire
them.**

From my three years of consulting for big companies, the decision tree that
leads to subpar machine choices looks something like this:

- "Business people" mostly spend their days in Excel, Word, Outlook and Chrome.
  They don't need something that powerful or that nice. Let's get them a cheap
  Dell Latitude (example).

- "Developers" do all sorts of things that amount to needing really fast
  processors, lots of memory and lots of disk space. Dell has these really beefy
  Precisions; let's get them that.

What's problematic about this is that it satisfies engineering needs on paper,
but completely disregards life as a developer.

Here's why crappy laptops bother me.

- **We carry them.** Laptops (thankfully) seem to be more popular than the
    desktop workstation these days. But because the decision is usually one or
    the other, engineers have to carry these machines day in, day out. Heavy
    machines put additional undue back strain, and they take up a lot of space.
    (Precisions have really large chargers! Tell me that
    [this](/images/good-tools-are-important/really-big-charger.png) isn't big! And
    this is the _slim_ version!)

    Consequently, engineers have to buy bigger, heavier packs than necessary to carry
    everything and distribute load evenly to avoid nasty long-term shoulder and back
    injuries.

- **They usually have terrible screens**. I can _sort of_ (but not really)
    empathize with the idea of screens being unimportant for "business people"
    since the Office suite (and Chrome) aren't graphically demanding (except
    they definitely can be). I can _absolutely not_ buy this argument for
    engineers. We spend a _lot_ of our time in terminals and code. Being unable
    to effectively see what we're developing creates undue eye strain,
    especially since these displays usually suffer from chronic light bleed.
    Poor displays also make it hard to write or review code with other people,
    since anyone watching from the sidelines will get a fantastic glimpse of
    light bleed filter.

- **They usually have subpar keyboards.** Have you ever tried typing on oatmeal? No?
    Give it a shot when your bored. _That's what it's like to type on most crappy
    laptops._ This problem is often exacerbated by engineers receiving stock
    keyboards and having to go through arcane or confusing processes to buy a
    keyboard that isn't mounted on play-doh.

- **They usually have subpar trackpads.** I am a huge fan of the ThinkPad "nib".
    However, much like the MacBook's legendary Trackpad (and the Magic Trackpad
    from which it is based), _most laptops have significantly worse versions of
    these_. Trackpads and nibs that lose their pointers are common in crappy
    laptop land.

# Everyone should have the best tools

{{< post_image name="best-tools" alt="Good tools are key!" >}}

There is a simple solution to all of this: ***give your engineers great tools,
and let them do (almost) whatever they want on them***.

To the first point (give your engineers great tools): there is a reason why
most tech companies give _everyone_ in their company MacBooks and awesome
desk-side hardware: having better tools means less resistence in making stuff
which means _more stuff gets made_. This is especially important for engineers
since we spend the majority of our day using them. 

Engineers should receive the best laptops available on the market. No
exceptions. Despite not being a Linux machine, MacBooks make it very easy to
develop against platforms that run on Linux. For the Microsoft shops of the
world, the Microsoft Surface can't be beat. (The Dell XPS and Lenovo ThinkPad X1
Carbon are close contenders, and both companies have strong and time-tested
enterprise support options, but I think the Surface surmounts both
quality-wise.)

There are big gains that can be made from giving the best equipment to people in
non-technical roles as well (i.e. "businesspeople", which is a terrible
catch-all, in my opinion). [Behavior-driven
development](https://blog.codeship.com/behavior-driven-development/) is a great
example of this. I strongly believe that better and more reliable software is
only made possible when _everyone_ --- product, UX, engineering and business
development --- collaborates through the codebase. BDD enables this by turning
the typical requirements gathering sessions of Waterfall lore into
human-readable code living alongside application source code. The best part
about BDD is that because the requirements are code, they can be tested, as
little or as often as necessary.

Giving Product analysts or Customer Success engineers the ability to write and
test BDD just like developers would is a massive advantage, and everyone having
the same (amazing) hardware enables that.

The second point (_and let them do almost whatever they want on them_) is probably
a contentious statement for some of you. Let me clarify.

# Engineers should have full admin access on their machines.

Software development is a creative process. Writing software requires lots of
tinkering and experimenting. [Engineers are
lazy](https://blog.codinghorror.com/how-to-be-lazy-dumb-and-successful/), so
borrowing existing works is usually encouraged over writing new stuff unless the
pain from using existing solutions is so great (or the problem is so niche), that
writing new stuff is _actually easier_.

***It is nearly impossible to do any of these things if engineers cannot install
or modify things on their own machines.***

Companies where developers have to wait _over a month_ to install Git and Docker
are a real thing. Companies where developers have to go through a labyrinthian
request process to obtain `sudo` on their machines are a thing. Companies that
do this tell me two things:

1. They do not trust their developers, and
2. They do not understand what their developers do.

You wouldn't hire someone you can't trust, right? If so, why hire them, say that
you trust them and then slap on a quagmire of process and paperwork that
prevents them from doing their job most effectively?

Every large company has an Employee Handbook or Computer Use Policy that clearly
lays out what can and can't be done. Disk encryption, solid firewall policies
and the threat of a massive multi-national entity with more lawyers than anyone
thought possible should be enough to prevent _most_ people from trying to do
"bad things."

To be clear, I _do not_ think that engineers should have full access to
restricted environments. Super-tight security makes _a lot_ of sense there.

# A Quick Note on VDI

{{< post_image name="vdi" alt="Seriously, stop." >}}

Many companies employ Virtual Desktop Infrastructure, or VDI, as a cost- and
maintainence-saving alternative to managing a fleet of desktops and laptops
everywhere. They are great at the centralizing bit, but with one catch: _they
are terrible at nearly everything else_. (I say this as an ex-XenDesktop
administrator.)

While virtual desktops make it easy for people to use their own devices to do
their work, "using" is a farce. Every virtual desktop that I've used is:

- Incredibly laggy (you can't fight the network, or virtualization physics for
  that matter)

- Based on Windows (which isn't problematic in itself, but it is graphically
  demanding, which makes lag even worse)

- Locked down to the gills (because it's easier to do so, so why not?) and

- Not pleasant to use, especially on Macs and Linux desktops.

This is the holy trinity of a poor working experience for any developer. Any
team that is dealing with subpar development woes will probably see _massive_
gains from using local workstations. ***This is a hill that I die on now when I
see it.***

*NOTE*: This differs from having remote SSH access into a Linux workstation
through bastion hosts or VPN access into one's desktop at work, both of which
make a lot of sense for companies that require high security.

# In closing, an analogy

{{< post_image name="cramped" alt="This is absolutely a real thing" >}}

I'll close this post with an analogy.

The way engineers are treated at a lot of companies is kind-of like if a Fortune
100 hired an uber-expensive executive person, gave them the cheapest IKEA desk
they could find (because it does the job, right?), were told to always fly in
Economy to all of their meetings regardless of criticality (because you'll get
there either way, right?) and were told that they have to wait six weeks before
they can install LinkedIn on their corporate iPhone because it's not an
"officially-approved" app.

Sounds kind of ridiculous, right? _That's daily life for most engineers at big
companies._

It doesn't have to be this way.
