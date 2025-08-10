---
title: "Carlos learns to vibe code, Day 0: i succumb to the slop"
date: 2025-08-09T13:06:58-05:00
draft: false
slug: "vibe-code-day-0"
image: "/images/vibe-code-day-0/ALL_THE_VIBES_DOT_JPEG.PNG"
categories: 
  - software
  - ai
  - llm
  - vibe code series
tags: 
  - software
  - vibe coding
  - ai
  - llm
  - claude
  - claude code
---

* [Day 0](../vibe-code-day-0) **⬅️ you are here**
* [Day 1](../vibe-code-day-1)

So, [I don't like](https://news.ycombinator.com/item?id=44822258#44825797) LLMs.
I'm optimistically terrified of their long-term impact to society.

I also know that I've grown to like stuff that I've held
strongly-negative opinions on, like `vim`, Ruby, Kubernetes (I was a huge
Kubernetes hater when it first got popular!) and Golang after forcing myself to
use them for two weeks or so.

Given how you can count on finding _somebody_ using ChatGPT to look something up
on any given day in some public space, I determined that it was time to give Big
AI™ it's two weeks.

I've been introducing ChatGPT and Kagi Assistant into my web search workflow.
It's going okay, though it still gets things wrong a fair amount of the time.

But you're not here to read about that.

I've decided to trust fall my way into letting LLMs into my
professional life. I'm [putting on my
Oakleys](https://www.youtube.com/watch?v=JeNS1ZNHQs8&pp=ygUPdmliZSBjb2Rpbmcga2Fp)
and going full speed into Vibe Coding.™

This post series will document using Claude Code to author
an app I've been wanting for myself for a long time: an IFTTT-like app for
syncing my online presence based on external events.

Best case: Claude Code becomes life and I spend the rest of my six-month career as an AI
influencer.

Worst case: I have some shiny stuff to put on my
[resume](https://eng.resume.carlosnunez.me).

## The App

{{< post_image name="status-app" alt="My first vibe code experiment" >}}

Many years ago, [I wrote](https://github.com/carlosonunez/slack-status-bot) a
simple Ruby app that changes my Slack status based on the names of trips in my
TripIt account. As a DevOps consultant that traveled every week, I needed a
service like this to tell other people where I was without having to do so
manually in Slack.

The app relied on two other services that I also wrote:

- [A service](https://github.com/carlosonunez/slack-apis) that authenticated
  into my employer's Slack workspace and handled status getting and setting, and

- [Another service](https://github.com/carlosonunez/tripit-apis) that
  authenticated into my TripIt account and retrieved trip details.

My Ruby app hit scaling limitations fairly quickly. Adding new event sources and
status handlers, like Google Calendar and WhatsApp, became cumbersome
to impossible. Life and work hampered progress, too. Over time, my app became more
crusty, more outdated, and, most importantly, more unscalable.

I took a week-long solo vacation to Portland many years ago to
[rewrite](https://github.com/carlosonunez/status) my status handling app into
something more event-based. While I learned a lot about `sync.WaitGroup`s and
the limitations of goroutines and channels, I only got as far as building the
framework for the app. I didn't have enough time to write the listeners and
handlers. Life and work took ofter again, and the rewrite staled once again.

Anyway, I'm going to build the rewrite, come hell or high water! And I'm going
to outsource the task to my new mandatory best friend, Claude.

## Approach

This is the roadmap for how I'm going to do this:

- [ ] Go almost all in and purchase a $20/month Anthropic subscription (I'll
upgrade to the $200/month Max subscription if this goes really well)

- [ ] Use a basic prompt describing my design, requirements and acceptance
criteria

- [ ] Use another prompt to write code to deploy infra components into AWS.

- [ ] Slowly incorporate agentic capabilities by adding some tools to handle
deployment.

If this goes well, I'll re-attempt all of this with another project I have in my
to-do list, but with a local LLM running on a beefy Mac studio that I'll
acquire.

Alright! Enough stage setting! Let's get to work.

