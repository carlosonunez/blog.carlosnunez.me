---
title: "BYOD Part 1: Computers In The Cloud"
date: "2015-09-04 13:28:22"
slug: "byod-part-1-computers-in-the-cloud"
description: >-
  Can you combine the power of the cloud with the flexibility of VDI?
  Yes, you can!
  This post makes the case for VDI in the cloud and why companies should
  consider it.
keywords:
  - vdi
  - cloud
  - amazon-web-services
  - aws
  - aws-workspaces
  - ec2
  - aws-ec2
---

Computing is expensive. Desktops and laptops cost lots of money. Printers cost even more money. (Printers are really funny, actually; buying one or two isn’t so bad, but once you’re managing tens or hundreds or more laser printers and printing hundreds or thousands of pages per day, the cost of toner/ink and repair skyrocket like a SpaceX shuttle.) Desks cost even *more* money. Accessories cost even *more* money. The list goes on and on,*infinitum ad nauseum*.

![Do you like saving money and hate fixing broken computers? Read on.](http://www.funny-potato.com/blog/wp-content/uploads/2008/09/money-computers.jpg "")

Now that we live in an age where downloading high-def movies takes less time than starting up your car, leveraging the cloud and having people bring in their own devices has become a highly lucrative alternative. The bring-your-own-device, or BYOD, movement has picked up a lot of steam over the years, so much so that [Gartner expects for “half of the world’s companies” to enact it.](http://www.cio.com/article/2386248/byod/half-of-companies-will-require-byod-by-2017--gartner-says.html "") [Over a billion devices](http://www.eweek.com/mobile/byod-policies-bring-a-billion-devices-to-businesses-by-2018.html "") are expected to be using BYOD by 2018, and as more and larger companies begin to take advantage of [cloud computing](http://blog.caranna.works/2015/08/04/if-your-business-still-uses-servers-youre-probably-doing-it-wrong/ ""), this trend will only accelerate.

I’ll spend the next three posts talking about three key components of most BYOD environment:

1. Virtual desktops,
2. Laptops and desktops, and
3. Mobile phones and tablets

I’ll explain who the major players involved with each component are, their importance in BYOD and some things to watch out for during considerations.

WIth that, let’s start by talking about computers in the cloud.

# Computing. Computing Everywhere.

![Bring your own stuff](http://cdn2.hubspot.net/hub/80068/file-15697864-jpg/images/byod_(1).jpg "")

Most bring-your-own-device setups will need a virtual desktop infrastructure, or VDI for short. Without going too deep into the details (and I’ll scratch the surface of this on this week’s Technical Thursdays post), virtual desktops give you computers in the cloud that can be used from anywhere on nearly anything, even phones and tablets.

A VDI is almost always comprised of:

1. One or more servers on which these virtual machines will be hosted, which are also known as *virtual machine hosts* or *hypervisors*,
2. Management software to start, stop, create, delete and report on machines, and
3. Software installed on the virtual machines that make the experience more seamless and accessible.

This means that you’ll need the following to get started:

1. A subscription to a Cloud service like Amazon EC2 or Microsoft Azure *or*
2. Your own server(s) in house for hosting virtual machines (most computers made after 2007 should support this with no issues), and
3. Enough disk space to host the number of machines you’d like to test (1TB is a good starting point),
4. A virtual machine hypervisor like VMware ESX, Microsoft HyperV (comes with Windows 2008 R2 and up) or Xen, and
5. A trial version of Citrix XenDesktop, VMware View, Proxmox (free) or SCVMM.

## The Players

There are three major players in this space that offer all of the above with varying amounts of complexity:

1. [Citrix](http://citrix.com/xendesktop "") (XenDesktop + NetScaler, a load balancer that works really well with VDI),
2. [VMware](http://vmware.com/view "") (VMWare View), and
3. [Microsoft](http://microsoft.com/hyper-v "") (HyperV + Systems Center Virtual Machine Manager 2012, usually called SCVMM).

Free and open-source solutions also exist, but they might need more love and attention depending on your situation. We’ll go into that a bit later on in this post.

## The Upsides

VDI has a number of advantages aside from being a critical component of going full BYOD:

1. **The desktop is replaceable.** Jim’s computer broke again? With VDI, you can get him up and running in minutes instead of hours since the desktop itself is a commodity and nothing of importance gets stored on it.

2. **Decreased hardware costs.** Depending on your situation, virtual desktops make it possible to order $300 computers in bulk that can do what $2000+ computers can’t.

3. **Increased data security.** [Over **30 BILLION DOLLARS**](https://www.lookout.com/news-mobile-security/lookout-lost-phones-30-billion "") of valuable data and IP are lost every year due to stolen laptops and devices. Virtual desktops are configured by default to keep ALL of your data in your datacenter and your profits in your bank accounts.

4. **Your desktop is everywhere.** Ever wished your team could move around within minutes instead of days? Ever wished to use cheap Chromebooks to access your desktop at work? Virtual desktops make this (and more) possible.

If you’re interested and like pretty charts, here’s a cost savings white paper published by Citrix and Gartner that go into these advantages in more detail. But we all know that every rose has thorns, and VDI is no exception. In fact, if done improperly, VDI can introduce more problems than it solves.

# VDI Is A Pay To Play Sport

![Yeah...you'll still need to plan.](http://cdn.meme.am/instances/500x/55473354.jpg "")

VDI is kind-of like a new car. If you find the right one for you and take care of it, you’ll likely enjoy it significantly more than getting that used Ferrari you thought was “affordable.” (Hint: they never are.)

Deploying computers in the cloud correctly can range from “free” (but expensive on time and labor) to ridiculously expensive depending on how couplex your infrastructure will be. Here is a list of factors that determine this complexity:

1. **Number of machines** Much like their physical counterpart, managing VDIs gets increasingly complicated as you add more machines into the mix. However, *unlike* physical desktops, replacing broken machines or upgrading slow ones can be done with a few mouse clicks. Some setups even allow users to upgrade their own machines on the spot in seconds!
2. **Network bandwidth** Virtual desktops are heavily dependent on the quality of the network on which they operate. The less bandwidth they have available to them, the more tweaking you’ll need to do to make people not hate you for taking away their machines.
3. **Your company’s workload** Virtual machines on a host share computing resources with each other. Hosts will usually do everything possible to prevent one machine from hogging up resources from other machines (though this can be overridden), which means that the more intensive your use case is, the less likely VDI will work for you without significant tweaking. That said, virtual desktops work well for a **wide** set of use cases. (Some of Citrix’s clients use virtual desktops to do CAD and heavy graphics rendering, which most people would normally pass on VDI for.)
4. **Remote workers.** Users on laptops that travel a lot will often have unpredictable network conditions. While the frameworks mentioned above handle this situation really nicely, it’s important to take this into account early on in your due diligence.

There are also many little hidden costs that can turn into money pits very easily if not taken into consideration early on in the process, such as:

1. Will you engage Citrix, VMware or third-party consulting services to help you get started, or will you or one of your engineers go solo? (Here’s a hint: Citrix and VMware will *always* upsell their consulting services.)

2. Does your company use or require VPN? (The answer is usually “yes,” but most of the products mentioned above support using desktops over plain Internet.)

3. How many users will get a virtual desktop? How many of them will actually use it? How will they use it?

4. You’ll always need more storage than you think you do.

5. Does your company operate under regulatory requirements?

There’s a very easy way to come upon the answers to these questions, and it’s actually a lot easier than you think.

# Just do it…as a test

Building a proof-of-concept VDI is pretty straightforward in most cases. You or your admin can probably set one up in an hour or two. Building this and adding users **slowly** will guide you towards the answers to these questions and help you understand whether VDI is right for your company or group. More importantly, it is much easier to build VDI automation when your VDI is small than when it’s already a massive behemoth that can’t be shut down at any cost. (Why is this important? Want to roll out 10,000 virtual desktops within minutes or automatically create and remove desktops based on server conditions? You’ll need automation to do this and much more.)

[Here’s a tutorial](http://www.learnvdi.com/sites/default/files/documents/XenDesktop%207%20Install%20with%20StoreFront%202.0.pdf "") on how to set this up with Citrix XenDesktop. [Here’s another tutorial](http://www.derekseaman.com/2013/03/vmware-horizon-view-51-install-part-1.html "") for View.

Have fun!

# About Me

I'm the founder of caranna.works, an IT engineering firm in Brooklyn that builds smarter and cost-effective IT solutions that help new and growing companies grow fast. Sign up for your free consultation to find out how. http://caranna.works.
