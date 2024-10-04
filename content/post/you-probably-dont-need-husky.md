---
title: "You probably don't need Husky"
date: "2024-10-04 09:43:20"
draft: false
slug: "you-probably-dont-need-husky"
image: "/images/you-probably-dont-need-husky/header.png"
keywords:
  - devops
  - software
  - git
---

[Git hooks](https://git-scm.com/docs/githooks) are an incredible and incredibly
simple way of fixing loose ends before you commit and/or push your code without
installing additional software.

Unfortunately, like most of the Git CLI, they can appear difficult and
un-approachable at first glance. For one, they assume that you're storing your
scripts within the hidden and un-tracked `.git` directory! I hope you like
symlinks!

Lots of projects use tools like [Husky](https://github.com/typicode/husky) as an
easier-to-use alternative that's easy to scale across teams and very friendly
within CI.

I considered going down this route for a personal project that I maintain, but
backed out of it once I realized that I'd have to install `npm` to get it
working. Something about having to install Node and deal with `node_modules`
to, ultimately, do symlinks with extra steps rubbed me the wrong way.

Fortunately, I found a [much
easier](https://stackoverflow.com/questions/39332407/git-hooks-applying-git-config-core-hookspath)
alternative that's easy to set up and scale: `git.hooksPath`!

## Getting started with `git.hooksPath`: the easy way

`git.hooksPath` allows you to tell Git where your hooks path lives relative to
the repository's root. While I haven't tested it, you can,
[theoretically](https://github.com/git/git/blob/867ad08a2610526edb5723804723d371136fc643/run-command.c#L819), set it
to a directory outside of your repository with dots.

This awesome quality-of-life feature requires Git 2.9 to be installed on your
machine. If you're on a Mac, you probably have Git v2.39 out of the box, which
has this feature.

Check out [the next section](#git-hookspath-the-hard-way) if you have an older
version of Git or would prefer to manage your hooks with symlinks,

To set this up easily for every repo you'll add to your machine, add this
to your `.bashrc` or `.bash_profile`:

```sh
git config --global core.hooksPath='.githooks';
```

(Just for fun: [here's the
difference](https://stackoverflow.com/questions/415403/whats-the-difference-between-bashrc-bash-profile-and-environment)
between these two files!)

Then, in your repository, create a directory called `.githooks` and add an empty
file into it to ensure that it's tracked by Git:

```sh
# in your repository...
mkdir .githooks && touch .githooks/.gitkeep
```

`git add`, `git commit`, and `git push` these changes, as usual.

Congrats! Your Git client-side hooks are now tracked in version control!

## `git.hooksPath`: the hard way

You can also emulate this capability with symlinks with a slightly higher
performance penalty if you use Bash or `zsh` as your default shell.

Add this to your `.bashrc` or `.bash_profile` instead:

```sh
symlink_git_hooks() {
  test -d ".git" || return 0
  test "$(readlink -f $PWD/.git/hooks)" == "$PWD/.githooks" && return 0
  mv $PWD/.git/hooks $PWD/.git/hooks.old &&
    ln -s "$PWD/.githooks" "$PWD/.git/hooks"
}

PROMPT_COMMAND='symlink_git_hooks;'
```

This uses Bash and `zsh`'s excellent
[`PROMPT_COMMAND`](https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html)
feature to check that Git's default hooks directory, `.git/hooks`, points to
whatever directory you want in your codebase, like `.githooks`.

Since this fails-fast if `.git` isn't present in the directory, this should
incur a minimal performance hit whenever you execute commands. However, you'll
experience a tiny bit of slowness when you enter Git repos for the first time.


## `make`: The secret weapon for Git hooks

Congrats! You can now easily do things you always forget to do before you push
your code, like bumping the project's version, running tests or updating
configs. (If you're not tracking your projects/infrastructure config in source
code, [you're missing
out!](https://harrisonpim.com/blog/you-should-commit-your-env-files-to-version-control))

You can supercharge your Git hooks by combining them with your local build
system like Make/CMake or, ironically, `npm`.

This way, you can use your build system as a one-stop shop for all of the
actions that are done in your repository.

[New
contributors](https://letterstoanewdeveloper.com/2020/11/23/always-leave-the-code-better-than-you-found-it/)
to your project will thank you! That includes you, six months from now!

---

There you have it! Git hooks for fun and profit. Happy hacking!
