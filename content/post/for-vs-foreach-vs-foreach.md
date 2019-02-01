---
title: "for vs foreach vs "foreach""
date: "2015-09-14 16:29:55"
slug: "for-vs-foreach-vs-foreach"
---

Many developers and sysadmins starting out with Powershell will assume that this:

[code lang=text]
$arr = 1..10
$arr2 = @()
foreach ($num in $arr) { $arr2 += $num + 1 }
write-output $arr2
[/code]

is the same as this:

[code lang=text]
$arr = 1..10
$arr2 = @()
for ($i = 0; $i -lt $arr.length; $i++) { $arr2 += $arr[$i] + $i }
write-output $arr2
[/code]

or this:

[code lang=text]
$arr = 1..10
$arr2 = @()
$arr | foreach { $arr2 += $_ + 1 }
[/code]

Just like those [Farmers Insurance commercials](https://www.youtube.com/watch?v=s-Lu40LRBDU "") demonstrate, **they are not the same.** It’s not as critical of an error as, say, mixing up <code>Write-Output</code> with <code>Write-Host</code> (which I’ll explain in another post), but knowing the difference between the two might help your scripts perform better and give you more flexibility in how you do certain things within them.

You’ll also get some neat street cred. You can never get enough street cred.

## **<code>for</code> is a keyword. <code>foreach</code> is an alias...until it's not.**

Developers coming from other languages might assume that <code>foreach</code> is native to the interpreter. Unfortunately, this is not the case **if it's used during the pipeline.** In that case, <code>foreach</code> is an alias to the <code>ForEach-Object</code> cmdlet, a cmdlet that iterates over a collection *passed into the pipeline* while keeping an enumerator internally (much like how <code>foreach</code> works in other languages). Every <code>PSCmdlet</code> incurs a small performance penalty relative to interpreter keywords as does reading from the pipeline, so if script performance is critical, you might be better off with a traditional loop invariant.

To see what I mean, consider the amount of time it takes <code>foreach</code> and <code>for</code> to perform 100k loops (in milliseconds):

[code lang=text]
PS C:&gt; $st = get-date ; 1..100000 | foreach { } ; $et = get-date ; ($et-$st).TotalMilliseconds
2761.4339

PS C:&gt; $st = get-date ; for ($i = 0 ; $i -lt 100000; $i++) {} ; $et = get-date ; ($et-$st).TotalMilliseconds
**279.2439**
[/code]

[code lang=text]
PS C:&gt; $st = get-date ; foreach ($i in (1..100000)) { } ; $et = get-date ; ($et-$st).TotalMilliseconds
**128.1159**
[/code]

<code>for</code> was almost 10x faster, and the <code>foreach</code> *keyword* was 2x as fast as <code>for</code>! Words *do* matter!

## **foreach (the alias) supports BEGIN, PROCESS, and END**

If you look at the help documentation for <code>ForEach-Object</code>, you’ll see that it accepts <code>-Begin</code>, <code>-Process</code> and <code>-End</code> script blocks as anonymous parameters. These parameters give you the ability to run code at the beginning and end of pipeline input, so instead of having to manually check your start condition at the beginning of every iteration, you can run it once and be done with it.

For example, let's say you wanted to write something to the console at the beginning and end of your loop. With a <code>for</code> statement, you would do it like this:

[code lang=text]
$maxNumber = 100
for ($i=0; $i -lt $maxNumber; $i++) {
if ($i -eq 0) {
write-host &quot;We&#039;re starting!&quot;
}
elseif ($i -eq $maxNumber-1) {
write-host &quot;We&#039;re ending!&quot;
}
# do stuff here
}
[/code]

This will have the interpreter check the value of <code>$i</code> and compare it against <code>$maxNumber</code> twice before doing anything. This isn't wrong *per se* but it does make your code a little less readable and is subject to bugs if the value of <code>$i</code> is messed with within the loop somewhere.

Now, compare that to this:

[code lang=text]
1..100 | foreach `
-Begin { write-host &quot;We&#039;re starting now&quot; } `
-Process { # do stuff here } `
-End { write-host &quot;We&#039;re ending!&quot; }
[/code]

Not only is this much cleaner and easier to read (in my opinion), it also removes the risk of the initialization and termination code running prematurely since <code>BEGIN</code> and <code>END</code> **always** execute at the beginning or end of the pipeline.

Notice how you can't do this with the <code>foreach</code> keyword:

[code lang=text]
PS C:\&gt; foreach ($i in 1..10) -Begin {} -Process {echo $_} -End {}
At line:1 char:22
+ foreach ($i in 1..10) -Begin {} -Process {echo $_} -End {}
+ ~
Missing statement body in foreach loop.
+ CategoryInfo : ParserError: (:) [], ParentContainsErrorRecordException
+ FullyQualifiedErrorId : MissingForeachStatement
[/code]

In this case, <code>foreach</code> has no concept of <code>BEGIN</code>, <code>PROCESS</code> or <code>END</code>; it's just like the <code>foreach</code> you're used to using with other languages.

![[]](http://www.bright-tiger.asia/wp-content/uploads/2015/03/Fun_1_Wonka.jpg "")

# About Me

I’m the founder of caranna.works, an IT engineering firm in Brooklyn that builds smarter and cost-effective IT solutions that help new and growing companies grow fast. Sign up for your free consultation to find out how. http://caranna.works.
