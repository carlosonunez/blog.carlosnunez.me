---
title: "Getting output from Docker containers from within Ansible"
date: "2018-07-20 17:07:20"
slug: "getting-output-from-docker-containers-from-within-ansible"
description: >-
  Deploying Docker containers through Ansible is easy.
  Getting output? Not so much. This post explains how to work around this.
---

# The Problem

You want to use Ansible's `docker_container` module to do stuff, but want to also perform actions based on their output without specifying a logging driver or writing to a temp file.

# The Solution

Do this:

```
---
- name: Run a Docker container
  docker_container:
    image: alpine
    entrypoint: sh
    command: -c echo &quot;Hello, from Docker&quot;&#039;!&#039;
    detach: false
  register: container_output

- name: Get its output
  debug:
    msg: &quot;Docker said: {{ container_output.ansible_facts.docker_container.Output }}&quot;
```

# WTF did you just do?

The key takeaways:

* `docker_container` runs its containers in detached mode by default. We turned this off by specifying `detach: false`

* The container's metadata (i.e. the stuff you get from `docker output</code> are exposed as Ansible facts, which are captured by registering the play first. <code>container_output.ansible_facts.docker_container.Output</code> captures the fact that contains our <code>stdout`.

Enjoy!
