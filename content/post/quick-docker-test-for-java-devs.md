---
title: "Is your Java app ready for Docker? Take this super quick test!"
date: "2019-03-19 00:57:07"
slug: "quick-docker-test-for-java-devs"
keywords:
  - enterprise
  - strategy
  - digital transformation
  - docker
  - java
  - software development
  - twelve factor
  - hot takes
---

Here's a really quick test to see if your enterprise Java app is ready for Docker.

**NOTE**: I am not a Java developer; more like a casual observer. Get your pitchforks ready!

If I can't do this:

```java
$> docker run --rm --volume "$PWD:/app" --volume "$HOME/.m2:/root/.m2" \
    --tty maven:3.6.0-jdk$WHICHEVER_VERSION-alpine mvn build
$> docker run --rm --volume "$PWD:/app" --tty openjdk:$WHICHEVER_VERSION-jdk-alpine  \
    java -jar /path/to/war.war
```

Then either:

- Your application is not [12-factor](https://12factor.net) and is probably not ready for Docker,
- Your source code has hidden dependencies that live outside of your `pom.xml` (or `build.gradle`),
  and your application is not yet ready for Docker, or
- Your application has dependencies on an application server like Tomcat or Weblogic, and your
  application is probably not ready for Docker.

Will it run in Docker anyway? Probably. Will you like your experience? Probably not.
