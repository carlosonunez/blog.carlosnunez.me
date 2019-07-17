---
title: "Story Points Aren't Units of Time"
date: "2019-07-16 23:45:29"
slug: "story-points-arent-units-of-time"
image: "/images/story-points-arent-units-of-time/header.jpg"
keywords:
  - enterprise
  - strategy
  - digital transformation
  - agile
  - rants
  - software development
---

They just aren't.

# WHY

Search for "story points agile" on Google. [Try
it](https://www.google.com/search?q=story+points+agile). You don't even have to type it into Google;
click the link!

You'll get, at this time of writing, approximately _12 million_ results. Accouting for the
8 million results are bots promoting something that requires your wallet, that leaves
_four million_ web pages, many of which will go on to describe story points to the letter
and how they aren't about estimation.

Here are a few:

From [To The New](http://www.tothenew.com/blog/how-to-estimate-story-points-in-agile/)

> A story point is an abstract measure of effort required to implement a user story. In simple
> terms, it is a number that tells the team about the difficulty level of the story. Difficulty
> could be related to complexities, risks, and efforts involved.

From [Agile
Alliance](https://www.agilealliance.org/resources/experience-reports/improving-estimation-story-points/)

> Story points are relative measurement of the size and complexity of the user stories wherein a
> base story is assigned some story point/s to start with and rest of the stories are estimated in
> story points based on its size and complexity compared to the base story.

From [Plataformtec](http://blog.plataformatec.com.br/2018/02/do-we-need-story-points/), a result
I pulled from the _eighth_ page of search results:

> Story points were developed because human beings lack abilities to forecast the future. Our bosses
> were saying “ok, ok… you wanna use this ‘agile’ thing, but I still wanna know at least when you
> are gonna finish this new feature!”, and we had to improve our forecasting beyond the “well it
> will be ready when it gets done” phrase.

(Sorry, Plataformtec. Google's a harsh mistress. Don't worry; this post will be on page 15.)

If I can go to the eighth page of search results and still find articles telling me how story points
are about complexity and not time, then why are _so_ many companies still using estimates as units
of time?

"You're the consultant, Carlos! You should know," you're probably thinking.

And you're right. I should. But I really don't.

I've previously thought that this was an easy way for those with the purse-strings to better
forecast their spending so they can know their budget burndown. But then I ran into groups that
estimated based on time for no other reason than 
["because we always
have."](https://carlosonunez.wordpress.com/2016/10/17/driving-technical-change-isnt-always-technical/).

I previously thought that this was an artifact of [scientific
management](https://www.wikiwand.com/en/Scientific_management) that enforce and
encourages managers to have tight control over their rank and file, or labor. But then I ran into
engineers that were actually fine with time-based estimates, even if they had to work nights and
weekends to uphold those estimates.

So I don't know. My best guess is that when an authoritarian figure asks you, the engineer, "How
long will this take?," responding with "about a Medium tee-shirt size" is a hard answer to give. But
is that really better than saying "It'll be done tomorrow!" when you know that there's this bug that
you've been wrestling with for the last sprint that Google has nothing on that might or might not be
squashed before then?

# Story Points Are Not Units Of Time

They aren't. The reason why story points exist is to acknowledge the fact that [humans are really
bad at estimating things.](https://chacocanyon.com/essays/projectslate.shtml). We just are. However,
we are much, much better at _comparing_ things.

It's really easy to say that a feature is shippable in two days...until you hit a really nasty bug
with dateimes that you didn't anticipate because you've only used that datetime library once or
twice before. Or you get wrecked by your dependency manager (or, more commonly, a development
environment), going down and hard-blocking you for a day.

On the other hand, it is _much_ easier to say that a feature feels like a large effort because you've
done projects that _feel_ similar to it and they usually took a while to complete. 

Why am I ranting about this? The motivation behind my rant is three-fold:

1. Because I've seen so many projects slip or fail/get cancelled despite project managers having
   dedicated Marie Kondo-level efforts to updating Gantt charts, creating elaborate sub-tasks to
   stories, following up on variances and delicately managing
   ["resource"](https://www.benlinders.com/2018/dont-call-people-resources/) time, amongst other
   efforts.

2. I've also seen so many engineers (including myself) get beat up over deadlines and estimates that
   got blown due to factors outside of their control. In a world where every company is looking for
   the best engineers because they are so hard to find, why burn your engineers out this way?

3. Trying to estimate on time is just _so_ much work (and wasted labor costs) over using past
   experiences to judge the complexity of something.

   If you've never done planning poker during your backlog grooming meetings, try it! It is fun,
   easy, makes engineers feel more highly valued and can actually _improve_ the quality of your
   estimates over time (because we are better at comparing than precise estimating).

That is all.
