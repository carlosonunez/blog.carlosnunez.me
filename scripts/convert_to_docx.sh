#!/usr/bin/env sh

if [ "$VERBOSE_MODE" == "true" ]
then
  set -x
fi

_get_post_slug() {
  post_name="$1"
  echo "$post_name" | \
    tr '[:upper:]' '[:lower:]' | \
    tr ' ' '-' | \
    tr -dc '[:alnum:]\n\r-'
}


post_name="$1"
if test -z "$post_name"
then
  >&2 echo "ERROR: Missing post name."
  exit 1
fi

if ! docker run -v "$PWD:/work" -w /work conoria/alpine-pandoc \
  pandoc -s content/post/$(_get_post_slug "$post_name").md \
  -o "${post_name}.docx"
then
  >&2 echo "ERROR: Failed to convert post."
  exit 1
fi
