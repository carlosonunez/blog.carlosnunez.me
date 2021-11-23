---
title: "Using a Mac and burned by Docker Desktop? Use Lima instead!"
date: "2021-11-22 15:12:00"
slug: "docker-desktop-alternative-for-mac"
image: "/images/getting-into-devops/header.jpg"
description: >-
  Docker's recent changes to their Docker Desktop license might now
  cost you money. Read this blog post for a free and easy alternative
  with Lima.
keywords:
  - lima
  - limactl
  - containerd
  - docker
---

In August, Docker/Mirantis has changed their [licensing
model](https://www.docker.com/blog/updating-product-subscriptions/) to require
businesses with more than 250 employees and $10M in revenue to pay for Docker Desktop.
This might not be suitable or desirable for qualifying businesses.

I've long been curious of a way to run Docker without needing Docker Desktop.
I'm not a huge fan of GUIs, and I'm _especially_ not a fan of Electron
(a smaller instance of Chromium that is popular for cross-platform
applications like Docker Desktop's GUI). This change has accelerated that
curiosity, since I _knew_ there had to be a lightweight alternative for
creating small Linux VMs with host-mode networking and easy volume mounting.

## Enter Lima

[Lima](https://github.com/lima-vm/lima) is an easy way to provision lightweight
headless QEMU virtual machines. You simply create a YAML file based on
[their
template](https://github.com/lima-vm/lima/blob/master/pkg/limayaml/default.yaml)
or one of [their
examples](https://github.com/lima-vm/lima/blob/master/examples/) and run
`limactl start /path/to/YAML/file.` That's it!

Lima also has built-in support for containerd, the open-source container
runtime used by Kubernetes.

Finally, Lima is also compatible with Apple's new, ultra-fast M1 ARM MacBooks
and Macs.

It's not going to replace Fusion Desktop or Vagrant, but it's excellent
for what we're trying to accomplish.

## Let's Do It!

First, open a Terminal and install Lima and the Docker CLI.

```sh
brew install lima docker
```

After installing Lima, make sure that your installation of Lima is version 0.7.3
or higher:

```sh
limactl --version
# limactl version 0.7.3
```

Run `brew update` if your output doesn't look like the above.

Next, create a directory to store your machine configurations. Let's put
it inside of your `$HOME` directory and call it `lima-machines`:

```sh
mkdir $HOME/lima_machines
```

Next, copy my Lima template into this directory:

```sh
curl -sSLo $HOME/lima_machines/docker.yaml \
  https://raw.githubusercontent.com/carlosonunez/bash-dotfiles/main/lima_machine.yaml
```

Since we're pointing to the `main` branch of my `bash-dotfiles` repository and
I use Docker almost every day, this file will always be current. 😊

Let's now start our Docker VM:

```sh
limactl start $HOME/lima_machines/docker.yaml --tty=false
```

You'll get a bunch of output after running this, but the key here is to check
that this line appears at the end of it:

```
INFO[0020] READY. Run `limactl shell docker` to open the shell.
```

Make sure that your installation of Lima is up-to-date if it doesn't.

Finally, let's tell Docker to use our VM instead of the default VM that comes
with Docker Desktop:

```sh
export DOCKER_HOST="unix://$HOME/.lima/docker.sock"
```

If everything checks out, you should be able to list Docker containers
with `docker ps`:

```sh
docker ps
# CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

## I've updated my Lima Machine YAML. How do I update my VM with my new
## settings?

Just copy the path to your Lima machine's YAML to
`$HOME/.lima/[MACHINE_NAME]/lima.yaml`. Given the `docker` machine that we
created earlier, this will look like:

```sh
cp $HOME/lima_machines/docker.yaml $HOME/.lima/docker/lima.yaml
```

Stop and start the VM for your changes to take effect:

```sh
limactl stop docker && limactl start docker
```

**NOTE**: Any changes inside of the `provision` keyword will require you to
re-create your VM.

## Gotchas

While Lima is a super-handy way to run Docker VMs without Docker Desktop,
it's not bulletproof. Here are a few things I've noticed.

### You'll still need to mount your directories explicitly

In my YAML, I automatically mount a few directories that I commonly use.
For example, I mounted `~/src`, where all of my source code lives, as a
writable directory since I volume-mount my containers often.

You might want to change this. To do that, you'll need to update your
Lima machine's YAML per the instructions above then restart your VM.

While you'd have to do this with Docker Desktop anyway, it's a little more
involved than going through a GUI (which is great if you're like me
and hate GUIs anyway!).

### Using an M1 Mac? You'll need to explicitly specify your default architecture

While this VM supports running ARM and Intel Docker containers, the Docker CLI
always assumes that all containers are AMD64 by default..._unless you're using
Docker Desktop_.

To work around this, simply add this to your `.bashrc` or `.bash_profile`:

```sh
export DOCKER_DEFAULT_PLATFORM="linux/arm64"
```

then log out and back in.

## But what if I _really really really_ want a GUI?

Then give [Portainer](https://github.com/portainer/portainer) a try!

{{< post_image name="portainer" alt="Portainer!" >}}

Portainer is a full-fledged GUI for Docker, Docker Swarm, and Kubernetes. It
runs in your browser and gives you most of the functionality that you'd
get from running Desktop.

To run Portainer, simply run:

```sh
docker run -d \
  -p 8000:8000 -p 9443:9443 \
  --name portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  cr.portainer.io/portainer/portainer-ce:2.9.3
```

Then visit https://localhost:9443 and follow the instructions!
