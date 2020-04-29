#!/usr/bin/env bash

# checks whether an image:tag exists in gcloud
gcloud_image_tag_exists() {
  local image_tag="$1"

  local image="${image_tag%:*}"
  local tag="${image_tag#*:}"

  test -n "$(gcloud container images list-tags "$image" --filter=tags="$tag" 2> /dev/null)"
}
