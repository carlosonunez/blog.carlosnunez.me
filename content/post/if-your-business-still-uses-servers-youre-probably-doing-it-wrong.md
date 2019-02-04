---
title: "If Your Business Still Uses Servers, You’re (Probably) Doing It Wrong"
date: "2015-08-04 17:55:43"
slug: "if-your-business-still-uses-servers-youre-probably-doing-it-wrong"
description: >-
  This post makes the case for using public cloud for people that are
  gung-ho about preserving their bare metal compute.
keywords:
  - aws
  - amazon
  - google
  - google-cloud
  - azure
  - microsoft
  - cloud
  - hardware
---

# **Your servers are useless, and you should sell them.**
Many businesses small and large buy servers for many wrong reasons. Some businesses want a server for an application they wrote. Some others want to keep their data “private.” Others still want servers for “better speed.”
All of these reasons are wrong. There are only three reasons that I can think of that justify the purchase of physical servers (feel free to list more in the comments!):
1. A regulator your business is beholden to requires it,
2. Your app really does need that kind of performance (read on to find out if this is you), and
3. You have a strong passion for burning money. <!--more-->

![[]](https://media.licdn.com/mpr/mpr/AAEAAQAAAAAAAAUiAAAAJDE1MjQxZTdmLWVhZmQtNDg0OS1iYTFmLTJhMzFmMDU1ZjhhNA.jpg "")
You see, when you buy servers from Dell or the like, you’re not *just* buying servers. Servers come with a ton of overhead that’s hard to see coming if you don’t buy them often enough:
1. You’ll need to buy a support plan for when those servers decide to go on vacation during your business hours (which they will), or you pay people like me to support them (which I’m happy to do! http://caranna.works for a free consultation!),
2. Servers need to be stored in a cool place that isn’t too dusty, and, more importantly, they need to be kept cool if you get several of them.
3. Servers need A LOT of power (though they use less power than they used to), and ideally that power is clean (which most office buildings have, which is good)

![[]](https://media.licdn.com/mpr/mpr/AAEAAQAAAAAAAAI5AAAAJDUzNDNmYzEyLThhNDctNDI1MC04NjFlLWE1ZjgyYjJkMTBkNQ.jpg "")

## **The Cloud is not a fad.**
A lot of people make fun of “the cloud,” and rightfully so; drinking games have been made out of keynotes that abused the word endlessly. Debauchery aside, “the cloud” as we know it is, from a 35,000 foot view, a collective of servers that themselves host hundreds of virtualized servers of varying sizes created by millions of people and companies. (Curious about virtualization? Keep an eye out for my post “Yes, you can have a computer in your computer” coming out tomorrow!). Instead of buying a server from Dell or HP and worrying about the above, you create a virtual server on a cloud, do what you need to do and pay for the time, storage and network bandwidth that you use.
Servers in a cloud usually cost between $0.02/hr for really basic machines to over $2/hr for really, really fast workhorses with tons of memory. What’s more incredible than these incredibly-generously prices is what you get with your purchase:
* Your servers are backed up and “copied” between many other servers in the same region (nearly every cloud service has datacenters spread out across the world), which nearly guarantees that it will always be available when you need it,
* 24/7 monitoring of nearly anything you can think of,
* Programming libraries that make it extremely easy for your developers to create new servers in minutes instead of days,
* Extremely fast networking that you never need to worry about or take care of, and
* Handfuls of additional services that save you a LOT of time and money, like
* Create databases for your app or business that are instantly available 24/7,
* Create web services for hosting your apps on that can handle one user or 10 million users with ease, or
* Create clusters of extremely fast storage for things like photos and videos that will nearly always be available

![[]](https://media.licdn.com/mpr/mpr/AAEAAQAAAAAAAALpAAAAJDFhODdlYmFiLTM4N2YtNDExNi04ZWViLTA2N2NmMDUwMGU1OQ.jpg "")

## **The Cloud Saves You Money**
To drive the point home, let’s run through a real-life example of a use case where the cloud might be an appropriate fit.
Let’s say that you run a small individual accounting firm. Your six accountants are dependent on QuickBooks, TurboTax, Office and Windows. Business is doing well and you’d like to plan for an upcoming expansion.
In most cases, this will require putting all of the machines behind Active Directory (it is significantly difficult to manage individual Windows machines without it), putting your printer(s) behind a print server and putting your TurboTax and QuickBooks customer files on some kind of storage that’s easy for everyone to access.
To do everything in house, you’ll need:
* One machine to serve as a domain controller and key management (license) server for new Windows installations,
* One machine to serve as the print server (you could use the domain controller as the print server, but this will cause problems later down the road), and
* Two cheap (but not too cheap) network-accessed storage (NAS) devices for that shared storage (one for backup)

To do this, you should plan on spending, at minimum:
* $1500 for a Dell PowerEdge R220 (which will host the domain controller and your print server) +
* $200 for a switch to connect those servers and your machines to (your $50 Linksys will not cut it for your expansion) +
* $600 for one Windows Server 2012 standard license (which will cover the server and the two virtual machines hosted on top of it) +
* $800 for the two NAS devices =
* **$3100 total + power costs**

 This doesn’t factor the costs of email or computers; we’ll assume that the computers are sunk costs and you’re already paying for Google Apps or Office 365.
This may not be a lot depending on how well your business is doing, but let’s compare the cost of doing this on Microsoft Azure or Amazon Web Services:
* $30/month for the domain controller (assuming an A3 instance, which should be enough for a domain controller and a few hundred machines in a single site) +
* $15/month for the print server (assuming an A1 instance, since print servers don’t require +
* $25/month for 1TB cloud storage +
* $400 for one NAS device =
* **$70/month ($840/year) + $400 one-time cost**

(Prices for resources on Amazon Web Services are similar.)

Moving this business into the cloud will not only save them **hundreds **of dollars per month in power costs, but will also save them **thousands** of dollars per year in hardware repair and depreciation costs! Another good thing about cloud services is that they are all pay-as-you-go; if you ever decide that cloud isn’t for you, you can cancel whenever you want with no early termination fees.
## **Trying It Out Is Risk-Free**
Microsoft and Google give new users $200 and $300 in credits to try their services out with no limitations. Amazon offers a year-long free trial, but only for their most basic service level (which I’ve found inadequate for all but the most basic workloads). All of them are great, and getting started on any of them is pretty easy.

**Try Azure here:** [https://azure.microsoft.com/en-us/pricing/free-trial/](https://azure.microsoft.com/en-us/pricing/free-trial/ "")
**Try AWS here:** [http://aws.amazon.com/free/](http://aws.amazon.com/free/ "")
**Try Google Cloud Platform here:** [https://cloud.google.com/free-trial/index](https://cloud.google.com/free-trial/index "")

*What was your physical to cloud transition story? Is there anything holding you back from trying the cloud? Leave a comment below!*

{{< about_me >}}
