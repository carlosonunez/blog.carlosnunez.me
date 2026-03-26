---
title: Using Lima and Bash dotfiles to go fast with Claude Code
date: 2026-03-26T15:30:36-05:00
draft: false
image: /images/using-lima-and-bash-dotfiles-to-go-fast-with-claude-code/header.png
categories: 
  - agentic development
  - agent isolation
tags: 
  - ai
  - agentic
  - llm
  - claude-code
  - vm
  - lima
  - docker
  - kubernetes
---

I've been using [Lima](https://github.com/lima-vm/lima) for years to run Docker
and Podman on the Mac. This setup has given me a lot of control over how I set
up my VMs that the "Desktop" tools often obscure. I also like being able to
store my VMs in my eternally-growing [dotfiles
repo](https://github.com/carlosonunez/bash-dotfiles).

Though I started [messing with Claude Code last
year](https://blog.carlosnunez.me/post/vibe-code-day-1/), between not being
happy with how purely vibe-coding my Status tool was going and, as usual, Life
Getting In The Way™, I ended up scrapping it.

Claude Code got a lot better since then, so during my annual week-long coding
sabbatical this year, I thought to give it another try, but, instead, using it as a
pair-programming partner instead of a "do it for me" easy button.

It's well known that running Claude with `--dangerously-skip-permissions` is the
least annoying way of using it (unless you like being asked to confirm every
little thing it does, and Claude LOVES doing lots of little things!). It's also
well known that doing this on your own computer is [an express train to
pain](https://old.reddit.com/r/ClaudeCode/comments/1ry0s5u/oops_i_delete_the_database/).

"Docker and dotfiles to the rescue, I thought."

## Attempt 1: Claude via Docker (spoiler alert: not recommended)

My first attempt at doing this (which I, of course, forgot to commit; yay, me!)
looked something like this pseudocode:

```sh
# .bash_ai_specific
claude() {
    { _build_claude_dockerfile &&
      _create_claude_docker_volume &&
      _sync_workdir_to_volume &&
      _start_claude_container } || return 1
      _run_claude
      rc=$?
      _review_changes
      _sync_workdir_from_volume
      _rm_claude_container
      return "$rc"
}
```

I decided to copy the contents of my workdir to and from Claude's container
volume so that I could review changes in a safe location before overwriting my
(potentially not yet committed) work tree.

This worked alright at first but became untenable much more quickly than I
anticipated.

The latency syncing data to and from the volume felt like a papercut that grew
larger every time I invoked `claude`. A minor annoyance, but something that was
always there.

I always run tests in containers to help provide some sort of consistency across
platforms. You already know where this is going.

Docker in Docker, as it's most commonly executed, requires containers to have
privileged permissions via the `--privileged` flag so that they can access the
Docker socket. Claude will eventually figure out that it start a root container
through the socket; once it does, getting pwned is only a matter of time. So
Claude via Docker isn't the move.

Then I had a shower thought, during the day, not in the shower. "But, hold up. I
use Lima. It's stupid easy to create a VM and SSH into it with Lima. Maybe???"

## Attempt 2: Claude via Lima. (spoiler alert: DO IT!)

I went back to the drawing board and created a Lima VM config for Claude, which
[I remembered to commit this
time](https://github.com/carlosonunez/bash-dotfiles/blob/5601b06ec7fab0fecc61bd37b12a7634b7ea0879/lima-machines/claude.yaml).

This was basically a copy of the VM I created for my Docker VM with three
differences:

### Mounting default rules and skills

```yaml
mounts:
  - location: "~/src/setup/ai/claude/skills"
    mountPoint: "{{.Home}}/.claude/skills"
    writable: false
  - location: "~/src/setup/ai/claude/default_rules"
    mountPoint: "{{.Home}}/.claude/rules"
    writable: false
  - location: "~/src/setup/ai/claude/markdowns"
    mountPoint: "{{.Home}}/.claude/markdowns"
    writable: false
```

These mounts will make sure that my default set of rules and skills for Claude
are always available. Since I also manage these in [my
dotfiles](https://github.com/carlosonunez/bash-dotfiles/tree/5601b06ec7fab0fecc61bd37b12a7634b7ea0879/ai/claude)
which [are
always](https://github.com/carlosonunez/bash-dotfiles/blob/main/setup.sh)
located at `$HOME/src/setup`, this makes it really easy for me to keep my
preferences for Claude up to date.

### Really simple provision steps

```yaml
provision:
- mode: system
  script:
    apt -y update && apt -y install git rsync ssh bash
- mode: user
  script: |
    cat >{{.Home}}/.bash_profile <<-EOF
    export PATH="$PATH:$HOME/.local/bin"
    export GPG_TTY=$(tty)
    EOF
    gpg-connect-agent reloadagent /bye
- mode: user
  script: |
    curl -fsSL https://claude.ai/install.sh | bash -x
- mode: user
  script: |
    cp ~/.claude/markdowns/CLAUDE.md ~/.claude/CLAUDE.md
```

I only install just enough stuff to get Claude and `gpg` working. (`gpg` is
important since [one of my
rules](https://github.com/carlosonunez/bash-dotfiles/blob/main/ai/claude/default_rules/____read_these_first.md)
mandates that my GPG keys be present on the system before doing _literally
anything_; this worked surprisingly well in practice.)

I'm fine with Claude installing anything it needs to install to get the job
done, since my dotfile for Claude makes it super easy to trash the VM and create
another one without losing my authentication information and settings.

### Wait for `claude` to become available

```yaml
probes:
- script: |
    #!/bin/bash
    timeout 180s bash -c 'while true; do >/dev/null which $HOME/.local/bin/claude && exit 0; done; sleep 1'
```

Speaks for itself. It waits for Claude to become available. That's all it does.

After creating the VM, I created [a
dotfile](https://github.com/carlosonunez/bash-dotfiles/blob/5601b06ec7fab0fecc61bd37b12a7634b7ea0879/.bash_ai_specific)
to contain my Claude wrapper.

As you can see
[here](https://github.com/carlosonunez/bash-dotfiles/blob/5601b06ec7fab0fecc61bd37b12a7634b7ea0879/.bash_ai_specific#L76-L82),
it's not too similar from how I did it with Docker:

```sh
  local rc
  _create_and_start_claude_vm
  _sync_config_dir_to_claude_vm
  _set_up_gpg_keys
  _mark_claude_ready
  _run_claude "$@"
  rc="$?"
  _sync_config_dir_from_claude_vm
  return "$rc"
```

There are a few changes, however:

- I don't need to sync my working directory since that's handled by Lima.  (I'm
  using a writable mount to keep my changes synchronized. This isn't ideal, but,
  fortunately, Lima also has the ability to [sync
  folders](https://lima-vm.io/docs/examples/ai/#syncing-working-directory) for
  additional safety, so I might transition to that at some point).

- Since some of my GPG keys have passphrases, I have a `_set_up_gpg_keys` step
  that prompts me to enter my passphrase beforehand so that [Claude doesn't get
  tripped up while creating
  commits](https://github.com/anthropics/claude-code/issues/118).

This approach has been very successful thus far. Claude runs mostly like it's on
my own system, and it's mostly respected the guardrails I put up through my
rules. It still gets tripped up over my commit rules, so I'll need to tweak them
some more.

## The Verdict

- Use `claude` through Docker if you're not going to be interacting with your
  system's Docker daemon. If you are, switch to Podman and create a
  runtime socket. Make sure that Podman is running in rootless mode!

- Use `claude` through a VM if you want to give Claude more leeway to do things
  without affecting your host system. Consider using wrapper functions to
  ensure that your VM is initialized before `claude` starts.

- In either case, definitely invest time creating default rules and skills for
  Claude. Not too much time, though; you'll discover new things to add along the
  way!
