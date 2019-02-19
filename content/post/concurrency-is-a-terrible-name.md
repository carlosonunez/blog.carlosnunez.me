---
title: "Concurrency is a terrible name."
date: "2015-11-28 19:12:45"
slug: "concurrency-is-a-terrible-name"
description: "Concurrency and parallelism are easy to confuse."
keywords:
  - computer-science
  - threading
  - parallelism
---

I was discussing the power of Goroutines a few days ago with a fellow co-worker. Naturally, the topic of "doing things at the same time in fancy ways" came up. In code, this is usually expressed by the `async` or `await` keywords depending on your language of choice. I told him that I really liked how Goroutines abstracts much of the grunt work in sharing state across multiple threads. As nicely as he possibly could, he responded with:

> *You know nothing! Goroutines don't fork threads!*

This sounded ludicrous to me. I (mistakenly) thought that concurrency == parallelism because doing things "concurrently" usually means doing them at the same time simultaneously, i.e. what is typically described as being run in parallel.
Nobody ever says "I made a grilled cheese sandwich in parallel to waiting for x." So I argued how concurrency is all about multithreading while he argued that concurrency is all about context switching. This small, but friendly, argument invited a few co-workers surrounding us, and much ado about event pumps were made.<!--more-->

After a few minutes of me being proven deeply wrong, one of our nearby coworkers mentioned this tidbit of knowledge:

> *Concurrency is a terrible name for this.*

I couldn't agree more, and my small post will talk about why.

In computer science, *concurrency* is the term used to describe the state in which multiple things are done at the same time within the same "thread" of execution. In contrast, *parallelism* is used to describe the state in which multiple things are done at the same time across multiple "threads" of execution.
The biggest difference between the two is being able to do multiple units of work simultaneously across multiple *processors*.

"What about multithreading," you might ask. "I thought that the whole point of doing things across multiple threads was to do multiple things at once!"

Here's the thing: today's processors can only do things one instruction at a time. The massive amount of engineering, silicon and transistors that they have are built to execute one instruction at a time really really really quickly and accurately. What gets executed and when is up to the operating system queueing up work for the processor to do. Operating systems deal with this by giving every process (and their threads) a pre-defined amount of time with the processor called a *time slice* or *quantum.*

The processor is even processing instructions when the operating system has nothing for it to do; these instructions are called NOOPs in x86 assembly. (Fun fact: whenever you open up Task Manager or Activity Monitor and see the % of CPU being used, what you're actually looking at is the ratio of instructions being executed to NOOPs.) Process scheduling is quite the loaded topic that I'm almost certain that I'm not doing justice to; if you're interested in learning more about it, [these slides](http://web.cs.ucdavis.edu/~pandey/Teaching/ECS150/Lects/05scheduling.pdf "") from an operating systems course from UC Davis describe this really well.

Even though operating systems typically schedule work from processes to be done serially on one processor, the programmer
can tell it to divide the work amongst multiple or all processors on the system. So instead of work from this process being done one instruction at a time, it can be done *n* instructions at a time, where *n* is the number of processors installed on a system. What's more is that since most operating systems typically slam the first processor for everything, processes that take advantage of this can typically get more done faster since they are not competing for as time on the main processor. This approach is called *symmetric multiprocessing*, or SMP, and Windows has supported it since Windows NT and Linux since 2.4. In other words, this is nothing new.

To make matters more confusing, these days, [operating systems will often automatically schedule threads across multiple processors automatically if the application uses multiple threads](http://programmers.stackexchange.com/questions/165424/net-mulithreading-and-quad-core-processors ""), so for practicality's sake, concurrent programming == parallel programming.

# TL;DR

Concurrency and parallelism aren't the same, except when they are. Sort of.


