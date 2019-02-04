---
title: "Start small; move fast"
date: "2016-10-14 01:04:29"
slug: "start-small-move-fast"
description: >-
  Many teams are eager to get to a better, future goal as fast as they can.
  This post explains how slowing down can, surprisingly, product results in a
  faster, safer and more fun way.
keywords:
  - productivity
  - teams
  - culture
---

*Seinfeld* wasn't always the heavily-syndicated network cash cow it is today. The hit show started as an experiment for Jerry and Larry David. They wanted to write a show to describe the life of a comedian in New York, namely, Jerry's. Despite Jerry's limited acting and writing experience, they wrote their pilot in the late 1980's and sold it as "The Jerry Chronicles," which NBC made its first national appearance of on July 1989.

I'll spare you the [details](http://www.hitfix.com/whats-alan-watching/seinfeld-at-25-how-the-show-about-nothing-became-a-huge-hit ""), but eventually the crew found their beat and, shortly afterwards, historic levels of success. but I will say this: every episode of Seinfeld was based off of, and written by, a personal story from someone on its writing staff. Compared to the sitcom-by-committee shows that prevailed during the time, this was a small, but drastic, change that eventually made its way into the mainstream. (For example, every cast member on *The Office*, a favorite of mine, wrote their own episode; some more than once.) <!--more-->

# Moving fast; not as fast as you might think

I don't know much else about sitcoms, but I do know this: DevOps is chock-full of hype that's very easy to get lost in. Super-fast 15 minute standups across teams that magically get things done. Lightweight Python or Ruby apps that *somehow* manage to converge thousands of servers to relentless uniformity. Everything about the cloud. Immutable infrastructure that wipes instead of updates. It's very tempting to want to go fast in a world full of slow, but doing so without really thinking about it can lead to fracturing, confusion and, ironically, even more slowness.

Configuration management is a pertinent example of this. Before the days of Chef, Puppet or even CFEngine, most enterprises depended on huge, complex configuration management databases (CMDBs), ad-hoc scripts and mountains of paperwork, documentation and physical run-books to manage their "estate" or "fleet." It was very easy for CFOs to justify the installation and maintenance of these systems: audits were expensive, violating the rules that audits usually exposed was even more expensive, and the insanely-complex CMDBs that required leagues of consultants to provision were cheap in comparison.

Many of these money-rich companies are still using these systems to manage their many thousands of servers and devices. Additionally, many of them also have intricate and possibly stifling processes for introducing new software (think: six months, at minimum, to install something like Sublime Text). Introducing Chef to the organization without a plan sounds awesome in theory but can easily lead to non-trivial amounts of sadness in reality.

# The anatomy of the status quo

There are many reasons behind why I think this is, at least from what I've noticed during my time at large orgs. Here are the top two that I've observed with more frequency:

* **People fear/avoid things that they don't understand.** HufPo ran an article [about this](http://www.huffingtonpost.com/heidi-grant-halvorson-phd/why-we-dont-like-change_b_1072702.html "") in 2011. They found that most people feel more comfortable with things that have been around longer than those that haven't. The same goes for much of what goes on at work. New things means new processes, new training, and new complexities.
* **Some things actually exist for a reason.**Many people using change management tools for the first time deride them to being useless formalities of yesteryear when systems were mainframes and engineers required slide rules. However, much of their value actually stems from complying to and being flexible with similarly-complicated regulations to which those companies are beholden. Consequently, trying to replace all of that with [JIRA](https://www.atlassian.com/software/jira ""), while not impossible, will be an incredibly-epic uphill battle.

# Slow is smooth; smooth is fast.

Now, I'm not saying all of this to say that imposing change in the enterprise is impossible. Nordstrom, for instance, went from a stolid retail corporation to a purveyor of open source tech. NCR, GE and other corporate Goliaths that you might recognize are doing the same.

What I am saying, however, is to do something like what Jerry Seinfeld did: start small, and start [lean](https://www.amazon.com/Lean-Enterprise-Performance-Organizations-Innovate/dp/1449368425 ""). If you've been itching to bring Ansible to your company in a big way, perhaps it might be worthwhile to tap into the company's next wonder-child investment and use it for a small section of the project. Passionate about replacing `scp` scripts with Github? It might be worthwhile to find a prominent project that's using this approach and implement it for them. (Concessions are actually a very powerful way of introducing change when done right. In fact, doing favors for people is an old sales trick, as [experiments](https://www2.bc.edu/robert-radin/Administration/Persuasion.htm "") have shown that people feel beholden to other people that do favors for them).

Finding a pain point, acting on it in a smart way and failing fast are the principal tenets of doing things the "lean" way, and you don't even need to create your own LLC to do it! In fact, to me, this is what DevOps is really about: using technology in smart ways to get business done by getting everyone on the same page.

{{< about_me >}}
