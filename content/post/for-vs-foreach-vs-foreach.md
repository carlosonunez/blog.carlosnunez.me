---
title: "for vs foreach vs \"foreach\""
date: "2015-09-14 16:29:55"
slug: "for-vs-foreach-vs-foreach"
images: "/images/for-vs-foreach-vs-foreach/header.png"
---

Many developers and sysadmins starting out with Powershell will assume that this:

```
$arr = 1..10
$arr2 = @()
foreach ($num in $arr) { $arr2 += $num + 1 }
write-output $arr2
```

is the same as this:

```
$arr = 1..10
$arr2 = @()
for ($i = 0; $i -lt $arr.length; $i++) { $arr2 += $arr[$i] + $i }
write-output $arr2
```

or this:

```
$arr = 1..10
$arr2 = @()
$arr | foreach { $arr2 += $_ + 1 }
```

Just like those [Farmers Insurance commercials](https://www.youtube.com/watch?v=s-Lu40LRBDU "") demonstrate, **they are not the same.** It’s not as critical of an error as, say, mixing up `Write-Output` with `Write-Host` (which I’ll explain in another post), but knowing the difference between the two might help your scripts perform better and give you more flexibility in how you do certain things within them.

You’ll also get some neat street cred. You can never get enough street cred.<!--more-->

## **`for` is a keyword. `foreach` is an alias...until it's not.**

Developers coming from other languages might assume that `foreach` is native to the interpreter. Unfortunately, this is not the case **if it's used during the pipeline.** In that case, `foreach` is an alias to the `ForEach-Object` cmdlet, a cmdlet that iterates over a collection *passed into the pipeline* while keeping an enumerator internally (much like how `foreach` works in other languages). Every `PSCmdlet` incurs a small performance penalty relative to interpreter keywords as does reading from the pipeline, so if script performance is critical, you might be better off with a traditional loop invariant.

To see what I mean, consider the amount of time it takes `foreach` and `for` to perform 100k loops (in milliseconds):

```
PS C:&gt; $st = get-date ; 1..100000 | foreach { } ; $et = get-date ; ($et-$st).TotalMilliseconds
2761.4339

PS C:&gt; $st = get-date ; for ($i = 0 ; $i -lt 100000; $i++) {} ; $et = get-date ; ($et-$st).TotalMilliseconds
**279.2439**
```

```
PS C:&gt; $st = get-date ; foreach ($i in (1..100000)) { } ; $et = get-date ; ($et-$st).TotalMilliseconds
**128.1159**
```

`for` was almost 10x faster, and the `foreach` *keyword* was 2x as fast as `for`! Words *do* matter!

## **foreach (the alias) supports BEGIN, PROCESS, and END**

If you look at the help documentation for `ForEach-Object`, you’ll see that it accepts `-Begin`, `-Process` and `-End` script blocks as anonymous parameters. These parameters give you the ability to run code at the beginning and end of pipeline input, so instead of having to manually check your start condition at the beginning of every iteration, you can run it once and be done with it.

For example, let's say you wanted to write something to the console at the beginning and end of your loop. With a `for` statement, you would do it like this:

```
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
```

This will have the interpreter check the value of `$i` and compare it against `$maxNumber` twice before doing anything. This isn't wrong *per se* but it does make your code a little less readable and is subject to bugs if the value of `$i` is messed with within the loop somewhere.

Now, compare that to this:

```
1..100 | foreach `
-Begin { write-host &quot;We&#039;re starting now&quot; } `
-Process { # do stuff here } `
-End { write-host &quot;We&#039;re ending!&quot; }
```

Not only is this much cleaner and easier to read (in my opinion), it also removes the risk of the initialization and termination code running prematurely since `BEGIN` and `END` **always** execute at the beginning or end of the pipeline.

Notice how you can't do this with the `foreach` keyword:

```
PS C:\&gt; foreach ($i in 1..10) -Begin {} -Process {echo $_} -End {}
At line:1 char:22
+ foreach ($i in 1..10) -Begin {} -Process {echo $_} -End {}
+ ~
Missing statement body in foreach loop.
+ CategoryInfo : ParserError: (:) [], ParentContainsErrorRecordException
+ FullyQualifiedErrorId : MissingForeachStatement
```

In this case, `foreach` has no concept of `BEGIN`, `PROCESS` or `END`; it's just like the `foreach` you're used to using with other languages.

![](http://www.bright-tiger.asia/wp-content/uploads/2015/03/Fun_1_Wonka.jpg)

{{< about_me >}}
