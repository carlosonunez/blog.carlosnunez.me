---
title: "Technical Thursdays: DNS, or why using the Internet is kind of like going to Starbucks"
date: "2015-08-21 17:51:38"
slug: "technical-thursdays-dns-or-why-using-the-internet-is-kind-of-like-going-to-starbucks"
description: "A coffee-fueled introduction to the domain name system."
keywords:
  - dns
  - starbucks
---

This Thursday, we'll talk about a system that has been extremely critical (and extremely taken for granted) for shaping the Internet as we know it: the domain name system, or DNS for short.

Before I explain what DNS is, I'll talk about something I try really hard to hate but ultimately can't: Starbucks.

I go to Starbucks at least once a day. Given that Google has more coffee machines (and baristas!) sitting idle than my handy downstairs Starbucks does on even their busiest days, this is slightly embarrassing to admit. I love their drinks, but as a recovering coffee snob, I passive-aggressively hate that I love their drinks. My relationship with that Seattle staple is kind of like how a lot of people feel about Taylor Swift: they'll hate on her forever but will never admit to playing *1989* on repeat.

Wait, that's just me?

Okay. I can live with that.

Anyway, what I find fascinating about Starbucks aside from their many variants of non-coffee coffee drinks (that are so good but *so bad*) is how baristas communicate drinks to each other. Somehow, someway, your order for a tall caramel-flavored latte with soy milk, whip cream and a double-shot of espresso is always a *tall caramel whip redeye latte* to *every Starbucks barista on the planet*, but trying that on a barista at Cafe Grumpy will usually get you banned for life.

What's even more fascinating about this is that DNS works "exactly" the same way when you go to BuzzFeed.com on your phone or computer to endlessly browse lists of cat pictures and gifs of people doing funny things.

(Don't pretend like you don't.)

You probably know that underneath the the lists and relationship videos, BuzzFeed is really a ton of servers doing lots of hard work to deliver this quality content, and buzzfeed.com is just one of the servers that shows them to you.

What you might not know is that the name of that server isn't buzzfeed.com; it's actually: 54.241.35.79. That's it's *IP address*.

If you type in those four (or eight) numbers into Chrome (or whatever your browser of choice is; I use Safari for reasons that won't be discussed here to avoid an intense holy war), it'll take you right to BuzzFeed.

How does your computer know that these two things go to the same place? The answer is DNS.

# What Is This DNS Magic That You Speak Of?

DNS is a system that maps names like buzzfeed.com or Wikipedia.org to IP addresses. It was created in the early 1980s when the Internet was much much MUCH smaller and has been iterated and improved upon significantly since then. [Here’s the original RFC that describes how it works](http:// ""), and surprisingly, a lot of it has held up over time!

These mappings are stored in *records.* There are several kinds of them. The name-to-IP mapping that I described earlier is stored in an **A record,** but a DNS can also have records for other mappings to things like shortcuts to A records (**CNAME records**), mail servers on the network to which that IP address belongs (**MX** records) or random data (**TXT** records).

When your computer attempts to find the IP address for a web site, its DNS client (also called a *resolver*) performs a *DNS query.* The response it gets back is the *DNS response.*

So original, I know.

# Dots and zones

The dots in a website URL are very important. Every word behind each dot is called a *DNS domain*, and every one of those words maps to something.

The last word in the URL, i.e. the <code>.com</code>, <code>.org</code> and [<code>.football</code>](https://en.wikipedia.org/wiki/Donuts_(corporation) ""), is called a top-level domain or TLD. Every single one is maintained by the Internet Assigned Numbers Authority, or the IANA. In the early days of simple Internet, this used to give you an idea of what the website was for. <code>.com</code>s were for commercial use or companies, <code>.org</code>s were for non-profits and foundations, <code>.net</code> were for personal websites and country-specific TLDs like <code>.us</code> or <code>.it</code> were for government-run websites.

However, like most things from that time period, that’s gone completely out the window (do you think bit.ly is in Libya?).

Records within a DNS are broken up into zones, and servers within the DNS are responsible for upholding their zone. These zones are usually HUGE text files that get stored completely within that server’s memory for really fast access. When your computer sends a DNS query, the DNS server you’re configured to use will ask for this server if it doesn’t have the record it’s looking for stored anywhere. It does this by asking for a special record called the *State-Of-Authority*, or *SOA*, which tells it where to go next in its search.

# DNS is so hot right now

Almost every single web site you’ve visited within the last 20 years or so has likely taken advantage of DNS. If you’re like me, that’s probably *a lot* of websites! Furthermore, many of the assets on those web sites (think: images and code for all of those fancy site effects) are referred to by name and resolved by DNS.

The Internet as we know it would not function without DNS. As of yesterday, the size of the entire Internet was just over [1 BILLION](http://www.internetlivestats.com/total-number-of-websites/ "") unique web sites (and growing! exponentially!) and used by [over 3 BILLION people](http://www.internetworldstats.com/stats.htm "").

Now imagine all of that traffic being handled by a single Dell server somewhere in this vast sea of Internet.

You can’t? Good. Me neither.

# DNS at WEB SCALE

So how does DNS manage to work for all of these people for all of these web sites? When it comes to matters of scale, the answer is usually: throw a metric crap ton of servers at it.

DNS is no exception.

## The Root

There are a few layers of servers involved in your typical DNS query. The first and top-most layer starts at the DNS root servers. These servers are ran by the [Internic](http://www.internic.com "") and are used to tell you which servers own what TLDs (see below).

There are 13 root servers throughout the world, {A through M}.root-servers.net. As you can imagine, they are very, very, very powerful clusters of servers.

## The TLD companies

Every TLD is managed by a company. The DNS servers run by these companies contain the records for every website that uses those TLDs. In the case of bit.ly, for example, the records for bit.ly will live on a DNS server managed by the IANA, whereas the records for stupidsiteabout.football will be managed by Donuts.

Whenever you buy a domain with GoDaddy, (a) you are doing yourself a disservice and need to get on [Gandi](http://www.gandi.net "") or [Hover](http://www.hover.co "") right now, and (b) your payment gives you the ability to create records that eventually land up on these servers.

## The Public Servers

The next layer of servers in the query are the public DNS servers. These are usually hosted by either your ISP, Google or DNS companies like Dyn or OpenDNS, but there are MANY DNS servers available out there. These are almost always the DNS servers that you use on a daily basis.

While they usually have the same set of records that the root servers have, they’ll refer to the root servers above if they’re missing anything. Also, because they are used more frequently than the root servers above, they are often more susceptible to people doing [bad things](https://securelist.com/blog/incidents/31628/massive-dns-poisoning-attacks-in-brazil-31/ ""), so the good DNS servers will implement lots of security enhancements to prevent these things from happening. Finally, the really big DNS services usually have MANY more servers available than the root servers, so your query will always be responded to quickly.

## Your Dinky Linksys

The third layer of servers involved in the queries most people make aren’t actually servers at all! Your home router most likely runs a small DNS server to help make responses to queries a lot faster. They don’t store a lot of records, and they are typically written pretty badly, so I often reconfigure these routers for my clients so that use Google or OpenDNS instead.

Your job probably has DNS servers of their own to improve performance and also upkeep internal and private records.

## Your iPhone

The final layer of a query ends (well, starts) right at your phone or computer. Your computer’s DNS resolver will often store responses to common queries for a short period of time to avoid having to use DNS servers as often as possible.

While this is often a very good thing, this often causes problems when records change. If you’ve ever tried to go onto a website and were unable to, this is often one reason why. Fortunately, fixing this is as simple as clearing your DNS cache. In Windows, you can do this by clicking Start, then typing <code>cmd /c ipconfig /flushdns</code> into your search bar. [Use these instructions](https://support.apple.com/en-us/HT202516 "") to do this on your Mac or [these instructions](http://osxdaily.com/2015/03/31/clear-dns-cache-ios/ "") to do this on your iPhone or iPad.

This is starting to get long and I’m in the mood for a caramel frap now, so I’m going to stop while I’m ahead here!

*Did you learn something today? Did I miss something? Let me know in the comments!*

{{< about_me >}}
