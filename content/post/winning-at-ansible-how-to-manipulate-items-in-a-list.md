---
title: "Winning at Ansible: How to manipulate items in a list!"
date: "2016-02-25 19:07:54"
slug: "winning-at-ansible-how-to-manipulate-items-in-a-list"
---

# The Problem

[Ansible](http://www.ansible.com "") is a great configuration management platform with a very, very extensible language for expressing yoru infrastructure as code. It works really well for common workflows (deploying files, adding <code>authorized_keys</code>, creating new EC2 instances, etc), but its limitations become readily apparent as you begin embarking in more custom and complex plays.

Here's a quick example. Let's say you have a playbook that uses a variable (or <code>var</code> in Ansible-speak) that contains a list of tables, like this:

[code lang="text"]
important_files:
- file_name: ssh_config
file_path: /usr/shared/ssh_keys
file_purpose: Shared SSH config for all mapped users.
- file_name: bash_profile
file_path: /usr/shared/bash_profile
file_purpose: Shared .bash_profile for all mapped users.
[/code]

(You probably wouldn't manage files in Ansible this way, as it already comes with a [fleshed-out module](http://docs.ansible.com/ansible/list_of_files_modules.html "") for doing things with files; I just wanted to pick something that was easy to work with for this post.)

If you wanted to get a list of <code>file_name</code>s from this <code>var</code>, you can do so pretty easily with <code>set_fact</code> and <code>map</code>:

[code lang="text"]
- name: &quot;Get file_names.&quot;
set_fact:
file_names: &quot;{{ important_files | map(attribute='file_name') }}&quot;
[/code]

This should return:

[code lang="text"]
[ u'/usr/shared/ssh_keys', u'/usr/shared/bash_profile' ]
[/code]

However, what if you wanted to modify every file path to add some sort of identifier, like this:

[code lang="text"]
[ u'/usr/shared/ssh_keys_12345', u'/usr/shared/bash_profile_12345' ]
[/code]

The answer isn't as clear. [One of the top answers](https://gist.github.com/halberom/b1f6eaed16dba1b298e8 "") for this approach suggested extending upon the <code>map</code> Jinja2 filter to make this happen, but (a) I'm too lazy for that, and (b) I don't want to depend on code that might not be on an actual production Ansible management host.

# The solution

It turns out that the solution for this is more straightforward than it seems:

[code lang="text"]
- name: &quot;Set file suffix&quot;
set_fact:
file_suffix: &quot;12345&quot;

- name: &amp;quot;Get and modify file_names.&amp;quot;
set_fact:
file_names: &quot;{{ important_files | map(attribute='file_name') | list | map('regex_replace','(.*)','\\1_{{ file_suffix }}') | list }}&quot;
[/code]

Let's break this down and explain why (I think) this works:

* <code>map(attribute='file_name')</code> selects items in the list whose key matches the attribute given.
* <code>list</code> casts the generated data structure back into a list (I'll explain this below)
* <code>map('regex_replace','$1','$2')</code> replaces every string in the list with the pattern given. This is what actually does what you want.
* <code>list</code> casts the results back down to a list again.

The thing that's important to note about this (and the thing that had me hung up on this for a while) is that every call to <code>map</code> (or most other Jinja2 filters) returns **the raw Python objects**, **NOT** the objects that they point to!

What this means is that if you did this:

[code lang="text"]
- name: &quot;Set file suffix&quot;
set_fact:
file_suffix: &quot;12345&quot;

- name: &quot;Get and modify file_names.&quot;
set_fact:
file_names: &quot;{{ important_files | map(attribute='file_name') | map('regex_replace','(.*)','\\1_{{ file_suffix }}') }}&quot;
[/code]

You might not get what you were expecting:

[code lang="text"]
ok: [localhost] =&gt; {
    &quot;msg&quot;: &quot;Test - &lt;generator object do_map at 0x7f9c15982e10&gt;.&quot;
}
[/code]

This is sort-of, kind-of explained in [this](https://github.com/mitsuhiko/jinja2/issues/288 "") bug post, but it's not very well documented.

# Conclusion

This is the first of a few blog posts on my experiences of using and failing at Ansible in real life. I hope that these save someone a few hours!

# About Me

*Carlos Nunez is a site reliability engineer for [Namely](https://www.namely.com ""), a modern take on human capital management, benefits and payroll. He loves bikes, brews and all things Windows DevOps and occasionally helps companies plan and execute their technology strategies.*
