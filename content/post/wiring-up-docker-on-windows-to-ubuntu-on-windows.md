---
title: "Wiring up Docker on Windows to Ubuntu on Windows"
date: "2016-12-12 18:05:37"
slug: "wiring-up-docker-on-windows-to-ubuntu-on-windows"
---

Getting docker running on Ubuntu on Windows is pretty simple. After [installing the Docker Windows engine](https://docs.docker.com/engine/getstarted/step_one/ "") and restarting, run this in a <code>bash</code> session to bind the two together:

<pre><code>
export DOCKER_HOST=tcp://0.0.0.0:2375
</code></pre>

Pop this into your <code>.bashrc</code> and never think about it again.

Thanks to [this](http://stackoverflow.com/questions/38859145/detect-ubuntu-on-windows-vs-native-ubuntu-from-bash-script "") StackOverflow post for the tip.
