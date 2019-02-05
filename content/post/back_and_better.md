---
title: "neutrons are firing again! How I eat my own dogfood with my blog."
draft: true
slug: "neutrons-are-firing-again"
image: "/images/neutrons-are-firing-again/header.jpg"
description: >-
  How I migrated from WordPress to Hugo on AWS and saved >$10/month in the
  process.
keywords:
  - aws
  - hugo
  - blog
  - eat-your-own-dogfood
  - terraform
  - provisioning
  - infrastructure
---

Outline:

- The Problem
  - I ran on WordPress for a while
  - Hated that writing Markdown was harder than it should ever be
  - I'm a developer, dammit; I should be using Git for everything.
  - I'm not paying $13/month for a custom domain with HTTPS.
  - Thus the idea of moving to a statically-generated blog was born!
- The Goals
  - An easily-deployable blog with a custom domain and HTTPS
  - A pipeline for deploying blog posts, complete with unit and integration
    testing
  - A platform that makes search engine discoverability easy.
- Hugo
  - You can host your blog or statically generate it
  - Golang is best lang
  - Free and open source
  - Awesome contribution team
- Serverless idea
  - Quickly shot down
  - Blog is static; serverless is additional overhead
  - I might use serverless for maintenance tasks, though!
- S3
  - Much better solution
  - Easy to sync and easy to host a website out of
  - But I wanted HTTPS; not possible with S3 hosting alone
- CloudFront
  - Didn't really want it, but it does enable HTTPS
  - It also enables super fast access anywhere in NA or Europe
  - Also pretty easy to deploy
- Integration Testing Sucks
  - Takes 20 minutes to turn a distribution up or down
  - No way to test the certificates I create since they are appended to CF
    and not S3
  - Integration testing really ensures that the blog renders on S3 and is
    accessible from the Internet
  - Not ideal, however; I'd like a super small CF distribution for integration
    tests!
- Certificates
  - Started with Let's Encrypt
  - Provisioning was easy with Terraform, but...
    - LE rate-limits certificate provisioning, but the error shown from 
      Terraform is a generic 403
    - This limit applies to both the staging and production ACME repos
    - Configuring staging and production parameters required WAY more
      Terraform code
  - Decided to use AWS ACM certificates instead
    - This makes multi-cloud more difficult
    - But it makes provisioning HTTP on CF easier
- CI
  - Originally wanted to make bloggen for my blog only
  - Decided later on that this might be useful for other people that want
    a cheap, global-scalable Hugo blog on the internet super easily
  - Separating my work into a separate project was difficult
  - Lessons learned
    - Always design as if someone else will use it from the onset
    - Docker in Docker reduces portability, so proceed with caution
    - A CI build system that's easy to test with locally is very, very valuable
- I'm happy
  - Blog is available and easily accessible from my own address
  - I can configure as much or as little SEO as I want
  - No ads, ever
  - BIG: I have full CI for my posts, and they are all in Git!
That's how I ate my own dogfood!
