---
title: "How to SRE-ify your React app with Prometheus"
date: "2020-04-14 20:41:34"
slug: "how-to-sre-ify-your-react-app-with-prometheus"
image: "/images/how-to-sre-ify-your-react-app-with-prometheus/header.jpg"
description: "Up your monitoring game by hooking up React with Prometheus in a few easy steps."
keywords:
  - enterprise
  - strategy
  - digital transformation
  - sre
  - devops
  - reliability
  - reliability engineering
  - observability
  - instrumentation
  - slo
  - sli
  - prometheus
  - grafana
  - react
  - javascript
  - express
  - nodejs
  - node
  - create-react-app
---

I am not a JavaScript developer. However, I was given a task [at work](https://contino.io)
recently that forced me to enter the abyss and get good at keeping my `Promise`s.

I was asked to create a webinar on helping developers become better SREs through observability
and instrumentation. The objective was to take a broken web app and add enough monitoring
and logging to it to make troubleshooting its brokenness easier. (I'll update this post
with a link when we broadcast it on April 22nd!)

The web app under repair was a React app with a Rails backend. JavaScript time.

While getting Prometheus wired up with the Rails backend was pretty easy, I had a
_shockingly_ difficult time getting it working with Node and React. The web app was created
with [Create React App](https://github.com/facebook/create-react-app), which makes it
stupidly easy to get started with React with the help of thousands of lines of black magic
(no, seriously; look at the codebase if you don't believe me). While Create React App handles
starting the Express web server for you, it doesn't provide a whole lot in the way of
configuring that server.

I spent several hours figuring out how to get React and Prom talking to each other
(and finding surprisingly little in instrumenting a React app with Prom). I succeeded! It was
WAY easier than I thought.

I hope this blog post saves you hours of pain. Apologies for any JavaScript errors or misgivings;
JS isn't my bag!

# Assumptions

I'm going to assume that you have a Prometheus server already configured, so I won't cover
getting started with Prometheus. Read [the
excellent](https://prometheus.io/docs/prometheus/latest/configuration/configuration/)
configuration documentation if you're interested in learning more.

I'm also going to assume that your app was created with Create React App and is using the
built-in Express server that comes with `react-scripts`.

{{< post_image name="lol_js" alt="Just when I thought I could write code." >}}

# How to Avoid Pain and Suffering

1. Add a Prometheus target to `prometheus.yml` for the metrics that you're about to expose:

```yaml
---
global:
  # rest of the damn owl

  - job_name: frontend
    scrape_interval: 5s
    scrape_timeout: 2s
    honor_labels: true
    static_configs:
      - targets: ['frontend:5000'] # Change to your app's URL
```

2. Restart your Prom server. The target should register and be down.

{{< post_image name="down_target" alt="Result after adding Prom target."   >}}

3. In your React app's repository, add `express-prom-bundle` and `prom-client` to your
   `dependencies` node in `package.json` and change your `start` script to
   `node server.js`:

```json
{
  "name": "project_organizer_front_end",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "prom-client": "12.0.0",
    "express-prom-bundle": "6.0.0",
    ... rest of dependencies
  },
  "scripts": {
    "start": "node server.js", <-- change this
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },

```

4. At the root of your React app's repository, create a new file called
   `server.js`: `touch server.js`

5. In your editor of choice, copy and paste the following:

```javascript
const express = require('express');
const favicon = require('express-favicon');
const path = require('path');
const port = process.env.PORT || 8080;
const prometheus = require('express-prom-bundle')

// This will create the /metrics endpoint for you and expose Node default
// metrics.
const metricsMiddleware = prometheus({
  includeMethod: true,
  includePath: true,
  promClient: { collectDefaultMetrics: {} }
})
const app = express();
app.use(favicon(__dirname + '/build/favicon.ico'));
// the __dirname is the current directory from where the script is running
app.use(express.static(__dirname));
app.use(express.static(path.join(__dirname, 'build')));
app.use(metricsMiddleware);
app.get('/*', function (req, res) {
  res.sendFile(path.join(__dirname, 'build', 'index.html')); // <-- change if not using index.html
});
app.listen(port);
```

6. Restart Node _but make sure that you build your app first_: `npm build && npm start`

7. Go back into Prometheus. Within a few seconds, the target should be up:

{{< post_image name="up_target" alt="Result after adding Prom target and exporter."   >}}

8. You're done!
