---
title: "Winning at Ansible: How to manipulate items in a list!"
date: "2016-02-25 19:07:54"
slug: "winning-at-ansible-how-to-manipulate-items-in-a-list"
description: >-
  Trying to grok lists in Ansible, but are having a tough time? Read on!
keywords:
  - ansible
  - configuration-management
  - programming
  - automation
  - coding
---

# The Problem

[Ansible](http://www.ansible.com "") is a great configuration management platform with a very, very extensible language for expressing yoru infrastructure as code. It works really well for common workflows (deploying files, adding `authorized_keys`, creating new EC2 instances, etc), but its limitations become readily apparent as you begin embarking in more custom and complex plays.

Here's a quick example. Let's say you have a playbook that uses a variable (or `var` in Ansible-speak) that contains a list of tables, like this:<!--more-->

```
important_files:
- file_name: ssh_config
file_path: /usr/shared/ssh_keys
file_purpose: Shared SSH config for all mapped users.
- file_name: bash_profile
file_path: /usr/shared/bash_profile
file_purpose: Shared .bash_profile for all mapped users.
```

(You probably wouldn't manage files in Ansible this way, as it already comes with a [fleshed-out module](http://docs.ansible.com/ansible/list_of_files_modules.html "") for doing things with files; I just wanted to pick something that was easy to work with for this post.)

If you wanted to get a list of `file_name`s from this `var`, you can do so pretty easily with `set_fact` and `map`:

```
- name: "Get file_names."
set_fact:
file_names: "{{ important_files | map(attribute='file_name') }}"
```

This should return:

```
[ u'/usr/shared/ssh_keys', u'/usr/shared/bash_profile' ]
```

However, what if you wanted to modify every file path to add some sort of identifier, like this:

```
[ u'/usr/shared/ssh_keys_12345', u'/usr/shared/bash_profile_12345' ]
```

The answer isn't as clear. [One of the top answers](https://gist.github.com/halberom/b1f6eaed16dba1b298e8 "") for this approach suggested extending upon the `map` Jinja2 filter to make this happen, but (a) I'm too lazy for that, and (b) I don't want to depend on code that might not be on an actual production Ansible management host.

# The solution

It turns out that the solution for this is more straightforward than it seems:

```
- name: "Set file suffix"
set_fact:
file_suffix: "12345"

- name: "Get and modify file_names."
  set_fact:
  file_names: "{{ important_files | map(attribute='file_name') | list | map('regex_replace','(.*)','\\1_{{ file_suffix }}') | list }}"
```

Let's break this down and explain why (I think) this works:

* `map(attribute='file_name')` selects items in the list whose key matches the attribute given.
* `list` casts the generated data structure back into a list (I'll explain this below)
* `map('regex_replace','$1','$2')` replaces every string in the list with the pattern given. This is what actually does what you want.
* `list` casts the results back down to a list again.

The thing that's important to note about this (and the thing that had me hung up on this for a while) is that every call to `map` (or most other Jinja2 filters) returns **the raw Python objects**, **NOT** the objects that they point to!

What this means is that if you did this:

```
- name: "Set file suffix"
  set_fact:
  file_suffix: "12345"

- name: "Get and modify file_names."
  set_fact:
  file_names: "{{ important_files | map(attribute='file_name') | map('regex_replace','(.*)','\\1_{{ file_suffix }}') }}"
```

You might not get what you were expecting:

```
ok: [localhost] => {
    "msg": "Test - <generator object do_map at 0x7f9c15982e10>."
}
```

This is sort-of, kind-of explained in [this](https://github.com/mitsuhiko/jinja2/issues/288 "") bug post, but it's not very well documented.

# Conclusion

This is the first of a few blog posts on my experiences of using and failing at Ansible in real life. I hope that these save someone a few hours!

{{< about_me >}}
