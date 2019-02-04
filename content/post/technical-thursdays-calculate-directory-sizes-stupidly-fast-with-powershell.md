---
title: "Technical Thursdays: Calculate Directory Sizes Stupidly Fast With PowerShell."
date: "2015-08-14 00:03:40"
slug: "technical-thursdays-calculate-directory-sizes-stupidly-fast-with-powershell"
description: Calculate directory sizes with ease in PowerShell with this post.
keywords:
  - powershell
  - windows
  - microsoft
  - coding
---

# Scenario

A file share that a group in your business is dependent on is running out of space. As usual, they have no idea why they’re running out of space, but they need you, the sysadmin, to fix it, and they need it done yesterday.

This has been really easy for Linux admins for a long time now: Do this

```
du -h / | sort -nr
```

and delete folders or files from folders at the top that look like they want to be deleted.

Windows admins haven’t been so lucky…at least those that wanted to do it on the command-line (which is becoming increasingly important as Microsoft focuses more on promoting Windows Server Core and PowerShell). `

`dir` sort-of works, but it only prints sizes on files, not directories. This gets tiring really fast, since many big files are system files, and you don’t want to be *that guy* that deletes everything in `C:\windows\system32\winsxs` again.

Doing it in PowerShell is a lot better in this regard (as written by Ed Wilson from [The Scripting Guys](http://blogs.technet.com/b/heyscriptingguy/archive/2012/05/25/getting-directory-sizes-in-powershell.aspx ""))

```
function Get-DirectorySize ($directory) {
Get-ChildItem $directory -Recurse | Measure-Object -Sum Length | Select-Object `
    @{Name=&quot;Path&quot;; Expression={$directory.FullName}},
    @{Name=&quot;Files&quot;; Expression={$_.Count}},
    @{Name=&quot;Size&quot;; Expression={$_.Sum}}
}

```

This code works really well in getting you a folder report..until you try it on a folder like, say, `C:\Windows\System32`, where you have lots and lots of little files that PowerShell needs to (a) measure, (b) wait for .NET to marshal the `Win32.File` system object into an `System.IO.FIle` object, then (c) wrap into the fancy `PSObject` we know and love.

This is exacerbated further upon running this against a remote SMB or CIFS file share, which is the more likely scenario these days. In this case, Windows needs to make a SMB call to tell the endpoint on which the file share is hosted to measure the size of the directories you’re looking to report on. With CMD, once WIndows gets this information back, CMD pretty much dumps the result onto the console and goes away. .NET, unfortunately, has to create `System.IO.File` objects for every single file in that remote directory, and in order to do that, it needs to retrieve extended file information.

By default, it does this for *every single file*. This isn’t a huge overhead when the share is on the same network or a network with a low-latency/high-bandwidth path. This is a **huge** problem when this is not the case. (I discovered this early in my career when I needed to calculate folder sizes on shares in Sydney from New York. Australia’s internet is slow and generally awful. I was not a happy man that day.)

Lee Holmes, a founding father of Powershell, wrote about this [here](http://blogs.msdn.com/b/powershell/archive/2009/11/04/why-is-get-childitem-so-slow.aspx ""). It looks like this is still an issue in Powershell v5 and, based on his blog post, will continue to remain an issue for some time.

This post will show you some optimizations that you can try that might improve the performance of your directory sizing scripts. All of this code will be available on my [GitHub repo](https://github.com/carlosonunez/codefromblogposts "").

# Our First Trick: Use CMD

One common way of sidestepping this issue is by using a hidden `cmd` window running `dir /s /b` and doing some light string parsing like this:

```
function Get-DirectorySizeWithCmd {
    param (
        [Parameter(Mandatory=$true)]
        [string]$folder
    )

    $lines = &amp; cmd /c dir /s $folder /a:-d # Run dir in a hidden cmd.exe prompt and return stdout.

    $key = &quot;&quot; ; # We’ll use this to store our subdirectories.
    $fileCount = 0
    $dict = @{} ; # We’ll use this hashtable to hold our directory to size values.
    $lines | ?{$_} | %{
        # These lines have the directory names we’re looking for. When we see them,
        # Remove the “Directory of” part and save the directory name.
        if ( $_ -match &quot; Directory of.*&quot; ) {
            $key = $_ -replace &quot; Directory of &quot;,”&quot;
            $dict[$key.Trim()] = 0
        }
        # Unless we encounter lines with the size of the folder, which always looks like &quot;0+ Files, 0+ bytes”
        # In this case, take this and set that as the size of the directory we found before, then clear it to avoid
        # overwriting this value later on.
        elseif ( $_ -match &quot;\d{1,} File\(s\).*\d{1,} bytes&quot; ) {
            $val = $_ -replace &quot;.* ([0-9,]{1,}) bytes.*&quot;,&quot;`$1”
            $dict[$key.Trim()] = $val ;
            $key = “&quot;
        }
        # Every other line is a file entry, so we’ll add it to our sum.
        else {
            $fileCount++
        }

    }
    $sum = 0
    foreach ( $val in $dict.Values ) {
        $sum += $val
    }
    New-Object -Type PSObject -Property @{
        Path = $folder;
        Files = $fileCount;
        Size = $sum
    }

}
```

It’s not true Powershell, but it might save you a lot of time over high-latency connections. (It is usually slower on local or nearby storage.

# Our Second Trick: Use Robocopy

Most Windows sysadmins know about the usefulness of `robocopy` during file migrations. What you might **not** know is how good it is at sizing directories. Unlike `dir`, `robocopy /l /nfl /ndl`:

1. It won’t list every file or directory it finds in its path, and
2. It provides a little more control over the output, which makes it easier for you to parse when the output makes it way to your Powershell session.

Here’s some sample code that demonstrates this approach:

```
function Get-DirectorySizeWithRobocopy {
    param (
        [Parameter(Mandatory=$true)]
        [string]$folder
    )

    $fileCount = 0 ;
    $totalBytes = 0 ;
    robocopy /l /nfl /ndl $folder \localhostC$nul /e /bytes | ?{
        $_ -match &quot;^[ t]+(Files|Bytes) :[ ]+d&quot;
    } | %{
        $line = $_.Trim() -replace &#039;[ ]{2,}&#039;,&#039;,&#039; -replace &#039; :&#039;,&#039;:&#039; ;
        $value = $line.split(&#039;,&#039;)[1] ;
        if ( $line -match &quot;Files:&quot; ) {
            $fileCount = $value } else { $totalBytes = $value }
        } ;
        [pscustomobject]@{Path=&#039;,&#039;;Files=$fileCount;Bytes=$totalBytes}
    }
}

```

# The Target

For this post, we’ll be using a local directory with ~10,000 files that were about 1 to 10k in length (the cluster size on the server I used is ~8k, so they’re really about 8-80k in size) and spread out across 200 directories. The code written below will generate this for you:

```
$maxNumberOfDirectories = 20

$maxNumberOfFiles = 10
$minFileSizeInBytes = 1024
$maxFileSizeInBytes = 1024*10
$maxNumberOfFilesPerDirectory = [Math]::Round($maxNumberOfFiles/$maxNumberOfDirectories)

for ($i=0; $i -lt $maxNumberOfDirectories; $i++) {
    mkdir “./dir-$i” -force

    for ($j=0; $j -lt $maxNumberOfFilesPerDirectory; $j++) {
        $fileSize = Get-Random -Min $minFileSizeInBytes -Max $maxFileSizeInBytes
        $str = ‘a’*$fileSize
        echo $str | out-file “./file-$j” -encoding ascii
        mv “./file-$j” “./dir-$i&quot;

}
}
```

I used values of 1000 and 10000 for $maxNumberOfFiles while keeping the number of directories at 20.

Here’s how we did:

1k files
10k files

Get-DIrectorySize
~60ms
~2500ms

Get-DirectorySizeWithCmd
~110ms
~3600ms

Get-DIrectorySizeWithRobocopy
~45ms
~85ms

I was actually really surprised to see how performant `robocopy` was. I believe that `cmd` would be just as performant if not more so if it didn’t have to do as much printing to the console as it does.

# /MT isn’t a panacea

The /MT switch tells robocopy to split off the copy job given amongst several child `robocopy` instances. One would think that this would speed things up, since the only thing faster than `robocopy` is more `robocopy.` It turns out that this was actually NOT the case, as its times ballooned up to around what we saw with `cmd.` I presume that this has something to do with the way that those jobs are being pooled, or that each process is actually logging to their own stdout buffers.

TL;DR: Don’t use it.

# A note about Jobs

PowerShell Jobs seem like a lucrative option. Jobs make it very easy to run several pieces of code concurrently. For long-running scriptblocks, Jobs are actually an awesome approach.

Unfortunately, Jobs will work against you for a problem like this. Every Powershell Job invokes a new Powershell session with their own Powershell processes. Each runspace within that session will use *at least* 20MB of memory, and that’s without modules! Additionally, you’ll need to invoke every Job serially, which means that the time spent in just *starting* each job could very well exceed the amount of time it takes robocopy to compute your directory sizes. Finally, if you use `cmd` or `robocopy` to compute your directory sizes, every job will invoke their own copies of `cmd` and `robocopy`, which will further increase your memory usage for, potentially, very little benefit.

TL;DR: Don’t use Jobs either.

That’s all I’ve got! I hope this helps!

*Do you have another solution that works? Has this helped you size directories a lot faster than before? Let’s talk about it in the comments!*

{{< about_me >}}
