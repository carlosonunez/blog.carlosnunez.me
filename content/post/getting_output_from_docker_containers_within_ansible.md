---
title: Getting output from Docker containers from within Ansible
date: "2018-07-20"
slug: "getting-output-docker-ansible"
image: "/images/ansible-docker.jpg"
---

## The Problem

You want to use Ansible’s `docker_container` module to do stuff, but want to
also perform actions based on their output without specifying a logging driver
or writing to a temp file.

## The Solution

Do this:

```
– name: Run a Docker container
  docker_container:
    image: alpine
    entrypoint: sh command: -c echo "Hello, from Docker"'!'
    detach: false
    register: container_output

– name: Get its output
  debug:
    msg: "Docker said: {{container_output.ansible_facts.`docker_container`.Output }}"
```

## WTF did you just do?

The key takeaways:

- `docker_container` runs its containers in detached mode by default. We 
   turned this off by specifying detach: false

- The container’s metadata (i.e. the stuff you get from docker output are
  exposed as Ansible facts, which are captured by registering the play first.
  `container_output.ansible_facts.docker_container`.Output captures the fact
  that contains our stdout.

Enjoy!
