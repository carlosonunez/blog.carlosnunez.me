#!/usr/bin/env sh

if [ "$VERBOSE_MODE" == "true" ]
then
  set -x
fi

usage() {
  cat <<-USAGE
create_new_post.sh [post-name]

Creates a new blog post with default Hugo front matter.

For additional verbosity, add "VERBOSE_MODE=true" to the command.
USAGE
}

_get_post_slug() {
  post_name="$1"
  echo "$post_name" | \
    tr '[:upper:]' '[:lower:]' | \
    tr ' ' '-' | \
    tr -dc '[:alnum:]\n\r-'
}

ensure_that_base_directories_are_present() {
  test -d content && \
  test -d static/images
}

create_images_dir_for_post() {
  post_name=$1
  post_slug=$(_get_post_slug "$post_name")
  mkdir "static/images/$post_slug"
}

check_if_post_already_exists() {
  test -f "content/post/$(_get_post_slug "$post_name").md"
}

create_new_post_with_front_matter() {
  post_name="$1"
  post_slug=$(_get_post_slug "$post_name")
  todays_date=$(date +"%Y-%m-%d %H:%M:%S")
  cat >"content/post/${post_slug}.md" <<-POST
---
title: "$post_name"
date: "$todays_date"
draft: true
slug: "$post_slug"
image: "/images/$post_slug/header.jpg"
keywords:
  - enterprise
  - strategy
  - digital transformation
  - add some more keywords and stuff
---
POST
}

if [ "$1" == '-h' ] || [ "$1" == '--help' ]
then
  usage
  exit 0
fi

post_name="$1"
if test -z "$post_name"
then
  usage
  >&2 echo "ERROR: Missing post name."
  exit 1
fi


if ! ensure_that_base_directories_are_present
then
  >&2 echo "ERROR: content and static/images must be present."
  exit 1
fi

if check_if_post_already_exists "$post_name"
then
  >&2 echo "ERROR: Post \"$post_name\" already exists"
  exit 2
fi

if ! {
  create_images_dir_for_post "$post_name" &&
  create_new_post_with_front_matter "$post_name" ;
}
then
  >&2 echo "ERROR: Failed to create new post."
  exit 1
fi
>&2 echo "INFO: Post created at: $(_get_post_slug "$post_name")"
exit 0
