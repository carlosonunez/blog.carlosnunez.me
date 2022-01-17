---
title: "Scraping without JavaScript using Chromium on AWS Lambda: The Novel"
date: "2022-01-10 22:07:00"
slug: "scraping-chromium-lambda-nodeless-zerostress"
keywords:
  - deep dives
  - node
  - ruby
  - python
  - web scraping
  - chrome
  - chromium
  - aws
  - lambda
  - serverless
---

## UPDATE: 2022-01-17 16:33 CST

Forget the below. [Just do
this](../run-arm-docker-images-in-github-actions-runners)
instead!

## UPDATE: 2022-01-15 16:43 CST

~~It appears that Docker as configured within the runners provided by GitHub
Actions do not native support building ARM images. However, you can use
`qemu-user-static` to emulate instructions for other CPU architectures to get
around this. This image uses
[`binfmt_misc`](https://en.wikipedia.org/wiki/Binfmt_misc) to tell the host's
Linux kernel to tell a third-party application (in this case, `qemu`) to execute
binaries in formats that it doesn't recognize.~~

~~In our case, we are using `qemu` to tell the `x86_64` GitHub Actions hosts to
send executables built for `arm64` or `aarch64` to `qemu` to run in a
virtualized environment.~~

~~You can see this behavior happen
[here](https://github.com/multiarch/qemu-user-static/blob/master/containers/latest/register.sh#L23)~~.

~~It is definitely slower, but it is fairly reliable!~~

~~To enable this functionality, do the following:~~

~~1. Add `binfmt_misc` and `qemu-user-static` to your Docker image. With an~~
~~   Ubuntu or Debian base image, you'd add this to your `Dockerfile`:~~

   ~~```dockerfile~~
   ~~RUN apt -y install qemu binfmt-support qemu-user-static~~
   ~~```~~

~~2. **Before** you build your `arm64` Docker image, add this command to your~~
~~    deploy script to enable this translation:~~

  ~~```sh~~
  ~~docker run --rm --privileged multiarch/qemu-user-static --reset -p yes~~
  ~~```~~

## TL;DR

At >1,700 words, this is a _long_ post. Here's a summary if you're short on
time!

- Lambda layers are too big to fit Chrome unless it's compressed with Brotli.
  You'll need to write your own decompression logic if you're not using Node.
- If you don't want to do that, you'll need to create your own
  [custom Docker
  image](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html).
- The AWS-provided base images do not play nicely with Chromium on M1 MacBooks.
  You'll need to use your own base image and ensure that it handles
  loading the AWS Lambda Runtime Interface Client correctly; see the link above
  for more.
- Ensure that Chromium is started with these flags: `--single-process`,
  `--disable-gpu`, `--disable-dev-shm-usage`, `--no-sandbox`

## Setting the Scene

Say that you're a developer in 2022 that is looking to scrape your favorite
website for interesting data. Since you weren't doing anything terribly heavy,
you used [PhantomJS](https://phantomjs.org) to take advantage of a
truly-headless browser that was ultra lightweight and ran on WebKit (i.e. most
sites would work with it like they would a normal browser).

Let's, further, assume that PhantomJS stopped working with your favorite website
sometime in 2020 because the web moves on [while PhantomJS did
not](https://groups.google.com/g/phantomjs/c/9aI5d-LDuNE).

Next, let's assume that you wrote [a non-JavaScript 
app](https://github.com/carlosonunez/travel-update-bot) to scrape that website.
That app ran on AWS Lambda via API Gateway so that you could use it conveniently
by way of your favorite web browser or iOS Shortcut. When PhantomJS stopped
working, so, too, did your app and its creature comforts.

Finally, let's say that you purchased an ultra-fast M1 MacBook Pro and are
now doing all of your development against ARM64-compiled binaries and
toolchains.

## What are your options?

- Use Chromium Headless, or
- Abandon your project.

No, really, those are your options.

You _could_ use Firefox and Marionette/geckodriver. Good luck finding a
pre-existing ARM-compiled geckodriver, though! You'll need _even more luck_ if
you run into problems during initialization or rendering since the "open web"
has mostly decided to gravitate to Chromium/Google Chrome for everything.

[No other headless WebKit browsers
exist](https://github.com/dhamaniasad/HeadlessBrowsers). So, yeah, Chrome is
your only option unless your site is lucky enough to expose its API traffic.

## But there's a problem...

**Chrome is big.**

Okay, Chrome isn't really that big. As of this time of writing, the
[latest Chromium build](https://chromium.woolyss.com/) is about 100MB
compressed and about 150-200 MB uncompressed. For most computers, this won't be
a problem.

Unfortunately, Lambda is not "most" computers.

In order to have Lambda serve your code, you need to compress your ZIP file,
upload it into AWS S3, then tell Lambda where it is through its function
definition. The filesystem onto which your ZIP is decompressed is called a
"layer".

**Lambda layers can't be more than 50 MB.**

This is, obviously, an issue for what we're trying to do.

Some projects, such as
[`chrome-aws-lambda`](https://github.com/alixaxel/chrome-aws-lambda), a popular
package for NodeJS that simplifies all of this (more on that later), vendor a
special build of Chrome with lots of stuff removed compressed with
[Google Brotli](https://github.com/google/brotli). This nets you a ~46MB archive
that fits nicely into the Lambda runtime with some space left over for other
stuff.

However, our app wasn't written in JavaScript and doesn't run in Node. Since
Lambda doesn't support Brotli-compressed archives out of the box, you'll need to
write a function that
[decompresses](https://github.com/alixaxel/chrome-aws-lambda/blob/78fdbf1b9b9a439883dc2fe747171a765b835031/source/index.ts#L163-L165)
this archive on function startup and, ideally, caches it somewhere (in S3) for
faster retrieval in the future, compromising cold-start times in the process.

This is a huge downer if you're like our hypothetical developer (definitely 100%
NOT ME) who just wants to get their previously-working app working again.

## Docker to the rescue!

It's easy to think that there _is no solution_ and give up at this point.
Fortunately, the AWS Lambda engineering team knew that this was a huge
restriction for many workflows that were well-suited for the serverless
revolution.

In December 2020, AWS
[announced](https://aws.amazon.com/blogs/aws/new-for-aws-lambda-container-image-support/)
support for running Docker containers from [OCI](https://opencontainers.org/)
images hosted in AWS Elastic Container Registry (ECR) inside of Lambda.
Moreover, Lambda supports Docker images up to 20GB, which is fit for just
about anything!

The power and ephemerality of Lambda with the flexibility of Docker. Best of
both worlds, and, most importantly, a perfect solution for this exact problem!

## Let's do it!

~~I~~ Our imaginary developer loves to use [Serverless
Framework](https://serverless.io) for doing anything with AWS Lambda, Azure
Functions, or any of the serverless platforms out there. Let's use that in our
micro-tutorial here.

> This demo isn't guaranteed to work. I wrote this to demonstrate
> the plight of trying to scrape with headless Chromium without
> becoming a JavaScript developer.

First, I'm going to create a `Dockerfile` that will run my Ruby function.
I'm going to use the images provided by AWS since they are already configured
to wire up to Lambda:

```dockerfile
FROM public.ecr.aws/lambda/ruby:2.7

RUN yum -y install amazon-linux-extras
RUN amazon-linux-extras install epel -y
RUN yum -y install chromium chromedriver

COPY . "${LAMBDA_TASK_ROOT}"
RUN bundle install

ENTRYPOINT ["my_app.my_function"]
```

I'm, then, going to create a `Gemfile` that will install Capybara and
Selenium so that I can scrape my web page:

```ruby
source 'https://rubygems.org'

gem 'capybara'
gem 'selenium-webdriver'
```

Finally, let's create our app at `my_app.rb`:

```ruby
# my_app.rb
# frozen_string_literal: true
require 'capybara'
require 'capybara/dsl'
require 'selenium-webdriver'
require 'json'

# yes, you need ALL of these options. None of them are typos.
CHROMIUM_ARGS = %w[headless
                   enable-features=NetworkService,NetworkServiceInProcess
                   no-sandbox
                   disable-dev-shm-usage
                   disable-gpu]

def my_function
  session = init_capybara
  # always prints 'success'
  session.visit('http://detectportal.firefox.com')
  {
    statusCode: 200,
    body: { message: session.body }.to_json
  }
end

def init_capybara
    Capybara.register_driver :headless_chrome do |app|
      caps = ::Selenium::WebDriver::Remote::Capabilities.chrome(
        "goog:chromeOptions": {
          args: CHROMIUM_ARGS
        }
      )

      Capybara::Selenium::Driver.new(app,
                                     browser: :chrome,
                                     capabilities: caps)
    end

    Capybara.default_driver = :headless_chrome
    Capybara.javascript_driver = :headless_chrome
    Capybara::Session.new :headless_chrome
end
```

Next, I'm going to tell serverless how to deploy this with a
`serverless.yml` file:

```yaml
provider:
  name: aws
  runtime: ruby2.7
  region: us-east-2
  deploymentBucket:
    name: my-serverless-bucket
  deploymentPrefix: serverless
  # This is what tells Serverless about what images to build.
  # It even builds them for you...kind of. More on that later.
  ecr:
    images:
      app:
        path: .
  functions:
    my_function:
      image:
        name: app
        command: my-app.my_function
      events:
        - http:
            path: myApp
            method: get
```

Next, I create my bucket with the AWS CLI

```sh
aws s3 mb s3://my-serverless-bucket # Highly unlikely to work, as names are global
```

And then I'm off to the races!

```sh
docker run -v $PWD:/app -w /app carlosnunez/serverless:latest deploy --stage v1
```

## But wait! I can test locally! Because Docker! Or can I?

Well...that depends.

If you're using an Intel Mac or an Intel machine in general, everything works
fine.

However, our hypothetical developer is fancy schmancy and is using an M1
MacBook.

This is where things get a little complicated.

Let's revisit our Dockerfile:

```dockerfile
FROM public.ecr.aws/lambda/ruby:2.7

RUN yum -y install amazon-linux-extras
RUN amazon-linux-extras install epel -y
RUN yum -y install chromium chromedriver # LIES!

COPY . "${LAMBDA_TASK_ROOT}"
RUN bundle install

ENTRYPOINT ["my_app.my_function"]
```

If you `docker build` this Dockerfile right now, you'll likely get something
like this:

```sh
sh-4.2# yum -y install chromium chromedriver
Loaded plugins: ovl
epel/aarch64/metalink                                                                                 |  17 kB  00:00:00
epel                                                                                                  | 5.4 kB  00:00:00
(1/3): epel/aarch64/group_gz                                                                          |  88 kB  00:00:00
(2/3): epel/aarch64/updateinfo                                                                        | 1.0 MB  00:00:00
(3/3): epel/aarch64/primary_db                                                                        | 6.6 MB  00:00:01
No package chromium available.
No package chromedriver available.
Error: Nothing to do
sh-4.2#
```

WTF?

Here's the deal. The pre-baked images provided by Amazon inherit from Amazon
Linux 2, which is derived from Red Hat Enterprise Linux (RHEL) 7.5, released in
2018. If you [look at](http://mirror.centos.org/centos/7/os/) the default
repository for CentOS 7 (the FOSS equivalent of RHEL 7.5), you'll see that
it only offers `x86_64` packages. Since the Extra Packages for Enterprise
Linux (EPEL) repository follows the OS release, it, too, will only offer
`x86_64` binaries.

This means that neither repository host any `arm64` compatible binaries of
Chromium or Chromedriver, hence this error.

**But RHEL 8/CentOS 8 do have arm64 binaries? What if I just use that?**

Then you'll enter the _second_ trap door: `glibc`.

Amazon Linux 2 ships with glibc 2.26. If you look at the
[list of
dependencies](https://centos.pkgs.org/8/epel-aarch64/chromium-common-96.0.4664.110-2.el8.aarch64.rpm.html)
for Chromium 96 (which is outdated at this time of writing), you'll see that
some of its libraries require glibc 2.27 or higher. You'll discover as much if
you try to install the RPM directly:

```sh
Error: Package: chromium-common-96.0.4664.110-2.el8.aarch64 (/chromium-common-96.0.4664.110-2.el8.aarch64)
           Requires: libm.so.6(GLIBC_2.27)(64bit)
Error: Package: chromium-common-96.0.4664.110-2.el8.aarch64 (/chromium-common-96.0.4664.110-2.el8.aarch64)
           Requires: libz.so.1(ZLIB_1.2.9)(64bit)
Error: Package: chromium-common-96.0.4664.110-2.el8.aarch64 (/chromium-common-96.0.4664.110-2.el8.aarch64)
           Requires: libc.so.6(GLIBC_2.28)(64bit)
```

Since upgrading `glibc` [isn't
easy](https://serverfault.com/questions/894625/safely-upgrade-glibc-on-centos-7)
or recommended, this approach is a non-starter.

## Custom Docker images and AWS RIC/RIE to the rescue!

If you're like our poor developer here, you're ready to throw in the towel and
never browse the web again. Unfortunately, he discovered that Lambda also
supports [running custom Docker
images](https://docs.aws.amazon.com/lambda/latest/dg/images-create.html). Our
journey isn't over yet!

AWS open-sourced both the
[client](https://github.com/aws/aws-lambda-ruby-runtime-interface-client) that's
used by the Lambda runtime and [an
emulator](https://github.com/aws/aws-lambda-runtime-interface-emulator) that
emulates a Lambda runtime environment. Subsequently, this makes it _very_ easy
to create Docker containers on your machine that behave as if they're running on
Lambda.

This is **massive**. Previously, the only way to do this was to use
the `lambci/lambda` Docker image (which is, also, only `x86_64` compatible).
This image was GIGANTIC and was a best-guess approximation of the Lambda runtime
environment.

This is almost the exact same thing. Almost. Unfortunately. More on that later.

What does this look like in practice? All of the langauges that Lambda supports
have their own runtime clients (RICs). Therefore, your Dockerfile will need to
download the appropriate RIC and use an entrypoint script to determine whether
it needs to run the client inside of an emulated Lambda runtime (if you're
running it on your own machine) or standalone (if you're running it in Lambda).

The link above gives a good example of how to do this. For Ruby, it would look
something like this:

```sh
# entrypoint.sh
#!/usr/bin/env sh
if test -z "$AWS_LAMBDA_RUNTIME_API"
then
  exec /usr/local/bin/aws_lambda_rie aws_lambda_ric "$@"
else
  aws_lambda_ric "$@"
fi
```

```dockerfile
# Dockerfile
FROM ruby:2.7-alpine3.15
ENV AWS_LAMBDA_RIE_URL_ARM64=https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie-arm64
ENV AWS_LAMBDA_RIE_URL_AMD64=https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie

RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk update

RUN apk add libffi-dev readline sqlite build-base\
    libc-dev linux-headers libxml2-dev libxslt-dev readline-dev gcc libc-dev \
    freetype fontconfig gcompat chromium@testing chromium-chromedriver@testing

RUN mkdir /app
COPY Gemfile /app
WORKDIR /app
RUN bundle install

RUN gem install aws_lambda_ric
RUN apk add curl
RUN if uname -m | grep -Eiq 'arm|aarch'; \
    then curl -Lo /usr/local/bin/aws_lambda_rie "$AWS_LAMBDA_RIE_URL_ARM64"; \
    else curl -Lo /usr/local/bin/aws_lambda_rie "$AWS_LAMBDA_RIE_URL_AMD64"; \
    fi && chmod +x /usr/local/bin/aws_lambda_rie

RUN mkdir /app
COPY . /app
RUN bundle install
COPY include/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
```

This is awesome because we can now download and install a modern version of
Chromium on our own terms and our own operating system!

Testing your function in your local Lambda environment is easy. First, start
the container in the background (with the `-d` switch)...

```sh
docker build -t local-lambda . &&
  docker run -d --rm -it --publish 8080:8080 local-lambda my_app.my_function
```

...then invoke a new function run:

```sh
curl -X POST -d '{}' localhost:8080/2015-03-31/functions/function/invocations
```

Make sure that you don't forget `-X POST -d '{}'`. Lambda functions are always
provided with a payload (even if the API Gateway endpoint from which they are
called only takes `GET` requests). Failing to provide one will crash the
runtime client, which you won't know happened because the RIE will continue
to send back 200s regardless.

## Well, almost to the rescue.

What, you thought we were done?!

Our developer got their custom Docker image written. They're able to build it,
and they've confirmed that it can spin up Chromium and talk to Selenium locally.
It's super fast because the M1 is [super
fast](https://browser.geekbench.com/v5/cpu/search?q=Apple+M1). They deploy it up
into Lambda with Serverless. Serverless builds the image, stores it in ECR, and
pushes the function into S3 and its definition into Lambda. All is good.

They try to run their function through API Gateway with a shiver of
anticipation...and they get this:

```sh
'{"message":"Internal server error"}'
```

YOU'VE GOT TO BE KIDDING ME!

Why does a Docker container that works locally not work in Lambda? The whole
point of Docker is to obtain consistent behavior regardless of where the
container's running! This doesn't make any sense!

Since there isn't an easy way to SSH into a Lambda instance to debug
Chromium directly, one (slow) way to debug this would be to create a simple
function that simply invokes `chromium` with the same flags that Selenium
uses, like this:

```ruby
# my_app.rb
# Rest of the code
def test_chromium
  args = CHROMIUM_ARGS.map { |arg| arg.prepend('--') }
                      .map { |arg| arg.gsub('----', '--') }
                      .join(' ')
  output = `2>&1 chromium #{args} https://example.website`
  rc = $CHILD_STATUS
  { statusCode: 200, body: { message: "rc: #{rc}, opts: #{args}, output: #{output}" }.to_json }
end 
```

...and then in `serverless.yml`:

```yaml
provider:
  name: aws
  runtime: ruby2.7
  region: us-east-2
  deploymentBucket:
    name: my-serverless-bucket
  deploymentPrefix: serverless
  # This is what tells Serverless about what images to build.
  # It even builds them for you...kind of. More on that later.
  ecr:
    images:
      app:
        path: .
  functions:
    debug_chromium:
      image:
        name: app
        command: my_app.test_chromium
    my_function:
      image:
        name: app
        command: my-app.my_function
      events:
        - http:
            path: myApp
            method: get
```

Upon doing this, I (okay, IT WAS ME ALL ALONG!) found that Chromium was
crashing due to this error:

```
[35941:0821/171720.038162:FATAL:gpu_data_manager_impl_private.cc(415)] GPU process isn't usable. Goodbye.
```

This is odd, given that Docker containers don't normally gain access to GPUs
unless you use `--privileged` or manually specify its capabilities. As it
happens, the Chromium team [all but
deprecated](https://support.google.com/chrome/thread/41722791/google-chrome-81-0-4044-122-remote-not-starting?hl=en)
the `--disable-gpu` switch (to improve performance), so Chromium will try
to find a usable GPU on startup anyway.

For reasons unclear to me, the only way around this is to use the
`--single-process` switch. (The reasons are unclear to me because
the [docs](https://www.chromium.org/developers/design-documents/process-models)
make it clear that the browser and the GPU run in a single process, but
I would think that this would still require a GPU to be present, which would
force the check that's failing.) Once I added that to my list of flags, the
crashes stopped and rendering worked once again!

## THE FINAL BOSS: mismatched architectures

Now that our app is working, since we intend on ~~never scraping websites
again~~ updating this app when our website changes, we want to have CI that
deploys our function:

```yaml
# .github/workflows/main.yml
---
name: Deploy function
on:
  schedule:
    - cron: "0 13 * * *"

jobs:
  sanity:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1

      - name: Deploy!
        run: >-
          docker run --rm carlosnunez/serverless:v2.69.1 \
            -v $PWD:/app \
            -w /app \
            -e ARCHITECTURE=linux/arm64 \
            serverless deploy 
```

You commit the workflow, push, then set and forget...until GitHub tells you
that it failed.

{{< post_image name="github-actions-failure" height="30%" >}}

After quickly going into your Terminal to see what happened, you see this
in your CloudWatch logs:

```
exec format error
```

Welp.

At this point we know that our computer and our Lambda function are
both running on ARM CPUs. However, GitHub Actions
[only provides `x86_64`
runners](https://github.community/t/does-github-actions-cloud-allow-running-of-arm-based-instances/119319/5).
Consequently, because of this code snippet in our Dockerfile:

```dockerfile
# Dockerfile
FROM ruby:2.7-alpine3.15
ENV AWS_LAMBDA_RIE_URL_ARM64=https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie-arm64
ENV AWS_LAMBDA_RIE_URL_AMD64=https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie

# Rest of code

RUN if uname -m | grep -Eiq 'arm|aarch'; \
    then curl -Lo /usr/local/bin/aws_lambda_rie "$AWS_LAMBDA_RIE_URL_ARM64"; \
    else curl -Lo /usr/local/bin/aws_lambda_rie "$AWS_LAMBDA_RIE_URL_AMD64"; \
    fi && chmod +x /usr/local/bin/aws_lambda_rie
```

The architecture of our Lambda Runtime Client depends on the architecture
of the Docker container that built it. By default, Docker will create
containers with the same platform as their host. (It
[is
possible](https://blog.carlosnunez.me/post/docker-desktop-alternative-for-mac/)
to run Docker containers with other platforms, but it's not the default
behavior.) When you build images manually with `docker build`, you can
work around this by providing the `--platform` option:

```sh
docker build --platform linux/arm64 ...
```

Fortunately, Serverless also supports this flag:

```yaml
# rest of config
  ecr:
    images:
      app:
        platform: linux/arm64
        path: .
```

So to work around this, we can change our platform to be
an environment variable:

```yaml
# serverless.yml

# rest of config
  ecr:
    images:
      app:
        platform: "${env:ARCHITECTURE}"
        path: .
```

Then modify our CI to 


## Lessons Learned

This was a heck of a journey. It took me days to work through all of this, and
there were several moments where I contemplated giving up on using Lambda for
web scraping like this. However, just like a steep climb on a bike ride or a
super heavy lift, finishing is always worth the struggle.

Here's what I learned from all of this:

- Getting Chromium working on Lambda is a gigantic pain in the rear.
- The _only_ way to get this working with the least amount of pain and without
  picking up JavaScript is to run Docker containers inside of Lambda and roll
  your own base images.
- Make sure that your function uses at least 2GB RAM. (Anything less will cause
  random timeouts.)
- Also make sure that you use `--no-sandbox`, `--disable-dev-shm-usage`,
  `--disable-gpu`, and `--single-process`.
