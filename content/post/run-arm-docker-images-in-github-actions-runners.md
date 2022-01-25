---
title: "Run ARM Docker images in GitHub Actions runners!"
date: "2022-01-17 16:53:00"
slug: "run-arm-docker-images-in-github-actions-runners"
image: "/images/translation.jpg"
description: >-
  Want to build ARM-compatible Docker images in GitHub Actions without banging
  against a wall? Read this post for the fix.
keywords:
  - docker
  - containers
  - lxc
  - linux
  - containerization
  - devops
  - github
  - github actions
  - devops
  - ci/cd
  - ci
  - cd
---

This is so easy to do, I think I can describe it in less than 150 words!

**Problem**: You want to run Docker images from Docker images that target ARM,
or you want to build images for ARM platforms.

**Solution**: Add this to `.github/workflows/main.yml` (or whichever YAML file
you'd like to enable ARM support for):

```yaml
jobs:
  your-job-name:
    steps:
      # Add this to the top of your `steps`
      - name: Set up QEMU - arm
        if: ${{ runner.arch == 'X86' || runner.arch == 'X64' }}
        id: qemu-arm64
        uses: docker/setup-qemu-action@v1
        with:
          image: tonistiigi/binfmt:latest
          platforms: arm64

      - name: Set up QEMU - x86
        if: ${{ runner.arch == 'ARM64'  }}
        id: qemu-x86_64
        uses: docker/setup-qemu-action@v1
        with:
          image: tonistiigi/binfmt:latest
          platforms: x86_64
```

That's it!
