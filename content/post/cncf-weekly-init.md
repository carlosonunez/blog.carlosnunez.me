---
title: CNCF Weekly
date: 2025-10-28T12:07:33-05:00
draft: false
image: "/images/cncf-weekly-init/header.png"
categories: 
  - kubernetes
  - cncf-weekly
tags: 
  - kubernetes
  - cncf-weekly
  - cloud-native
---

I was thinking about the projects in the CNCF the other day.

{{< post_image name="cncf" alt="Cloud-native tools for days!" >}}

I've shown some variant of this image countless times in customer calls, demos,
and presentations, but never really stopped to think about how _hilariously
vast_ this landscape is.

As anyone who's used Kubernetes for more than two weeks will tell you, you don't
keep up --- you just pick the same five tools that everyone else did and make a
career out of it.

There's **thousands** of tools, though.

So I got to thinking. "I have this blog. I've been struggling to find
inspiring things to talk about in it. What if I just tried every single tool in
the CNCF community, talked about it a bit and gave a quick getting started
guide?"

And that's how CNCF Weekly was born.

## Try all the tools!

My goal for CNCF weekly will be to provide a high-level overview of every tool
in the CNCF landscape. You'll get:

- A one-sentence explainer of what the the tool is,
- A high-level summary of what it is and why you'd want to use it, and
- A quick guide on getting started with it.

## A note about the quick start guides

Most of my getting started guides will use [Kind](https://kind.sigs.k8s.io) to
create local clusters. It's a great tool to get Kubernetes clusters locally on
your machine.

On the Mac, you can use [Homebrew](https://brew.sh) and
the `brew install kind` command to install it. You can use
[winget](https://winget.io) and the `winget install Kind.kind` command to do the
same on Windows. Finally, you can use `dnf/yum install` or `apt install` to
install Kind on Linux or download the binary directly from
[GitHub](https://github.com/kubernetes-sigs/kind).

Some of the tools in the landscape require clusters
managed by cloud providers; I'll provide instructions on how to set those up in
those weeklies. 

Check out my videos on [LinkedIn Learning](url) if you'd like more visual guides
on setting all of this up!
