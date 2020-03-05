---
title: "Want to test Ansible playbooks that require systemd in Docker? Try this."
date: "2020-02-05 11:30:00"
slug: "testing-ansible-playbooks-using-systemd-in-docker"
image: "/images/testing-ansible-playbooks-using-systemd-in-docker/header.png"
keywords:
  - devops
  - configuration management
  - cloud
  - engineering
  - sre
  - site reliability engineering
  - ansible
  - docker
  - docker-compose
---

Kubernetes and other cloud-native strategies might be putting
configuration management out to pasture, but I found myself writing a playbook
recently while learning how to create
[infrastructure as code for Azure](https://github.com/contino/hello-azure). I
needed to start my Flask web server and Postgres database with systemd, which isn't
a pattern that's easily supported by Docker. I got this working with Docker
Compose, however, and this post will show you how!

1. Create a Docker Compose file with the following services:

```yaml
version: '2.2'
services:
  ansible:
    tty: true # this adds colorized output; you can disable this if you prefer
    privileged: true # required to volume-mount the cgroups pseudofile, as systemd requires it
    build:
      context: .
    volumes:
      - $PWD:/workdir:ro
      - /sys/fs/cgroup:/sys/fs/cgroup:ro # required by systemd
    working_dir: /workdir
  ansible-playbook-under-test:
    extends: ansible
```

2. Create a `Dockerfile` that installs Ansible and systemd. Your base layer
   should match the actual system onto which this playbook will be deployed.

```dockerfile
FROM ubuntu:19.04

# Install Ansible
RUN apt-get -y update && \
    apt-get -y install software-properties-common && \
    apt-add-repository --yes --update ppa:ansible/ansible && \
    apt-get -y install ansible

# Install SystemD since our app uses this upon starting up.
# Cribbed from: https://github.com/j8r/dockerfiles/blob/master/systemd/ubuntu/18.04.Dockerfile
ENV LC_ALL C
RUN apt-get update \
    && apt-get install -y systemd systemd-sysv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN cd /lib/systemd/system/sysinit.target.wants/ \
    && ls | grep -v systemd-tmpfiles-setup | xargs rm -f $1

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/basic.target.wants/* \
    /lib/systemd/system/anaconda.target.wants/* \
    /lib/systemd/system/plymouth* \
    /lib/systemd/system/systemd-update-utmp*

VOLUME [ "/sys/fs/cgroup" ]
ENTRYPOINT [ "/sbin/init" ]
```

3.  You might notice that the `ENTRYPOINT` for this container is `/sbin/init`.
    systemd requires `init` to be PID 1. This is problematic for Docker containers
    because their `ENTRYPOINT`s are the only things that can run when they start
    up and `init` cannot be backgrounded.

    To get around this, run `docker-compose up -d ansible-playbook-under-test`.
    This will "boot" the Docker container while allowing you to run something else
    against it with `docker-compose exec`.

4. Run your playbook!

   ```sh
   docker-compose exec ansible-playbook-under-test ansible-playbook-under-test \
    -vvv \
    playbook.yml
   ```

   The container under test will stay up after your playbook run completes. If your
   systemd service fails to start, you can look into it using standard tooling
   (I usually look at the systemd journal first by running `journalctl -u $name_of_service`).

5. Turn down your container under test: `docker-compose down`.

I hope this helps!
