---
title: "One weird trick that might make your MacBook less janky"
date: "2015-08-08 00:20:28"
slug: "one-weird-trick-that-might-make-your-macbook-less-janky"
description: >-
  Slow Mac? Try the tips in this post.
keywords:
  - productivity
  - macbook
---

I was trying to put a bunch of slides together today but had a lot of trouble doing it because my Mac would freeze up every minute or so for about 10-15 seconds. If you've ever tried mowing a lawn with no gas, you kind of know how this feels. It was infuriating.

In search of *anything* that might improve the state of things, I stumbled upon this interesting solution that seems to have made the slowness go away!

If your Mac is freezing up or acting slow in general, give this a try:

1. Open a Terminal by holding Command (⌘) and Space, typing "Terminal" then hitting Enter.

2. When the Terminal starts up, type in (or copy and paste): `sudo rm /Library/Preferences/com.apple.windowserver.plist`. Type in your password when prompted; this is safe.

3. When that finishes, type in (or copy and paste): `rm ~/Library/Preferences/ByHost/com.apple.windowserver*.plist`. The terminal might say that there is "no such file or directory;" that is normal (this means that it couldn't find some files).

4. When that finishes, shutdown your MacBook then turn it on again but press and hold Command (⌘), Option (⌥), P then R before the Apple logo comes up. This will reset some hardware configuration data, which isn't critical. (None of your files are affected.) If you did it right, your screen might flicker once. After that happens, press the Power button.

Try it and let me know what you think!

{{< about_me >>}
