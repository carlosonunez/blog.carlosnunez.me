---
title: "Technical Tuesdays: Powershell Pipelines vs Socks on Amazon"
date: "2015-08-05 04:50:53"
slug: "technical-tuesdays-powershell-pipelines-vs-socks-on-amazon"
description: >-
  Confused about Powershell pipelines? Love buying socks on Amazon?
  This post is for you!
keywords:
  - amazon
  - powershell
  - windows
  - microsoft
  - automation
---

In Powershell, a typical, run-of-the-mill pipeline looks something like this:

```
Get-ChlidItem ~ | ?{$_.LastWriteTime -lt $(Get-Date 1/1/2015)} | Format-List -Auto
```

but really looks like this when written in .NET (C# in this example): <!--more-->

```
Powershell powershellInstance = new Powershell()
RunspaceConfiguration runspaceConfig = RunspaceConfiguration.Create()
Runspace runspace = RunspaceFactory.CreateRunspace(runspaceConfig)
powershellInstance.Runspace = runspace
try {
    runspace.Open();
    IList errors;

    Command getChildItem = new Command(&quot;Get-ChildItem&quot;);
    Command whereObjectWithFilter = new Command(&quot;Where-Object&quot;);

    ScriptBlock whereObjectFilterScript = new ScriptBlock(&quot;$_.LastWriteTime -lt $(Get-Date 1/1/2015)&quot;);
    whereObjectFilter.Parameters.Add(&quot;FilterScript&quot;, $whereObjectFilterScript);

    Command formatList = new Command(&quot;Format-List&quot;);
    formatList.Parameters.Add(&quot;Auto&quot;, &quot;true&quot;);

    Pipeline pipeline = runspace.CreatePipeline();
    pipeline.Commands.Add(getChildItem);
    pipeline.Commands.Add(whereObjectFilter);
    pipeline.Commands.Add(formatList);

    Collection results = pipeline.Invoke(out errors)
    if (results.Count &amp; gt; 0) {
        foreach(result in results) {
            Console.WriteLine(result.Properties[&quot;FullName&quot;].toString());
        }
    }
} catch {
    foreach(error in errors) {
        PSObject perror = error;
        if (error != null) {
            ErrorRecord record = error.BaseObject as ErrorRecord;
            Console.WriteLine(record.Exception.Message);
            Console.WriteLine(record.FullyQualifiedErrorId);
        }
    }
}
```

Was your reaction something like:

![WUT](http://media.giphy.com/media/WgTuK0I84mEEw/giphy.gif "")

Yeah, mine was too.

Let's try to break down what's happening here in a few tweets.

Running commands in Powershell is very much like buying stuff from Amazon. At a really high level, you can think of the life of a command in Powershell like this:

* You're in the mood for fancy socks and go to Amazon.com. (This would be equivalent to the runspace in which Powershell commands are run.)

* You find a few pairs that you like (most of them fuzzy and warm) and order them. (This would be the cmdlet that you type into your Powershell host (command prompt).)

![](http://www.families.com/wp-content/uploads/media/416dUwMHvNL.jpg "")

* Amazon finds those socks in their massive warehouse and begins packaging them. (This is akin to finding the definition of Get-Command in a .NET library loaded into your runspace and, when found, wrapping it into a <code>Command</code> object, with the fuzziness and color of those socks being its <code>Parameter</code> properties.)
* Amazon then puts that package into a queue in preparation for shipment. (In Powershell, this would be like adding the <code>Command</code> into a <code>Pipeline</code>.)

* Amazon ships your super fuzzy socks when ready. (<code>Pipeline.Invoke()</code>).

* You open the box the next day (you DO have Prime, right?!) and enjoy your snazzy feet gloves. (The results of the <code>Pipeline</code> get written to the host attached to its runspace, which in this case would be the Powershell host/command prompt.)

* If Amazon had issues getting the socks to you, you would have gotten an email of some sort with a refund + free money and an explanation of what happened (In Powershell, this is known as an <code>ErrorRecord</code>.)

And that's how Microsoft put the power of Amazon on your desktop!

*Has the Powershell pipeline ever saved your life? Have you ever had to roll your own runspaces and lived to talk about it? (Did you know you can use runspaces to make multithreaded Powershell scripts? Not saying that *you would*...) Let's talk about it in the comments below!*

{{< about_me >}}
