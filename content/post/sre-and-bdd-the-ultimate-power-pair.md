---
title: "SRE and BDD: The Ultimate Power Pair"
date: "2019-04-12 23:50:00"
slug: "sre-and-bdd-the-ultimate-power-pair"
image: "/images/sre-and-bdd-the-ultimate-power-pair/header.jpg"
keywords:
  - enterprise
  - strategy
  - digital transformation
  - sre
  - reliability
  - devops
  - cloud
  - engineering
  - culture
  - communities
  - centers of excellence
  - agile
  - bdd
  - product development
  - cucumber
---

The responsibilities of a Reliability Engineer are well understood: maintain a high degree of
service availability so that customers can have a consistently enjoyable and predictable experience.
How these goals are accomplished --- establishing SLOs with customers, enforcing them through
monitoring SLIs and exercising the platform against failure through Game Days --- is also well
understood. Much of the literature that exists on SRE goes into great
depths talking about these concepts, and for good reason: failing to establish a contract with the
customer on availability expectations for the service that they are paying for is a great way for
its engineers to spend their entire careers fire-fighting.

However, there are times in which the definiton of availability is not as clear cut. If a
web service responds correctly within its availability SLO guidelines (say, 99.95%), but the content
that's actually served by that service is incorrect 30% of the time, then your engineers will likely
still spend a large portion of their time fire-fighting despite their Reliability dashboards
looking good.

There are various ways of capturing these details through black-box monitoring techniques such as
the Prometheus `blackbox_exporter` or using synthetic testing services from [Sauce
Labs](https://github.com/prometheus/blackbox_exporter) or [New
Relic](https://docs.newrelic.com/docs/synthetics), for example. (My personal favorite is using
[Cachet](https://cachethq.com) with the (Cachet
Monitor)[https://github.com/castawaylabs/cachet-monitor] running alongside it.). The Google Customer
Reliability team [mentions a great
example](https://cloud.google.com/blog/products/gcp/available-or-not-that-is-the-question-cre-life-lessons)
of a prober they added to an example Shakespeare searching service to measure malformed queries.
However, one simpler and more transparent method that I don't often see discussed is leveraging
acceptance tests and behavior-driven development.  That's what I'll discuss in this post.

# BDD and SRE: An Unexpected Power Pair

_Behavior-Driven Development_, or BDD, helps provide a continuous interface through which product teams and
engineering can collaborate and iterate on feature development. On healthy product teams, feature
development through BDD looks something like this:

- Product teams begin the conversation for a new feature with an acceptance test: a file written in
  English that describes what the feature is and how it should behave.
- Engineering writes a failing implementation for that acceptance test by way of
  _step definitions_, then writes code that, ultimately, makes those step definitions pass.
- Once the acceptance test for that feature passes, the code for that feature enters the release
  process through to production via continuous integration.

# An Example of BDD in action

Here's a simple example of this in action. Your company maintains a sharp-looking to-do list
product. Customer feedback collected from surveys has demonstrated a clear need for integrating your
login workflow with third-party OAuth providers, namely Google and Facebook. In preparation for your
bi-weekly story grooming session, a product owner might author a acceptance test with Cucumber that
looks like this:

{{< highlight "cucumber" >}}
# features/login/third_party_auth.feature
Feature: Logging in with Third-Party Providers

  While many of our customers are happy with our login flow,
  surveys are showing a clear need for authenticating via third-parties like Google
  and Facebook.

  Scenario: Logging in with Google
    Given an instance of our to-do app
    And a valid Google Account
    When I navigate to the login page at "/login"
    Then I see a button that lets me log in with Google
    And I enter the Google authentication flow once it is clicked
    And I can successfully log into our to-do app with our account
{{< / highlight >}}

Ideally, these acceptance tests would live in a separate repository since they are closer to
integration tests than service-level tests. It also makes continuous acceptance testing easier to
accomplish since the pipeline running the tests will only need to operate against a single
repository instead of potentially-many repositories. However, using a monorepo for acceptance tests
can complicate pull requests for service repositories since running an entire suite of acceptance
tests for a single PR is expensive and probably unnecessary. This can be engineered around, but it
requires a bit of work.

After Product and Engineering agree on the scope of this feature and its timing in the backlog, an
Engineer might author a failing series of step definitions for this feature, one of which might look
something like this:

{{< highlight "ruby" >}}
# features/step_definitions/third_party_auth.rb
require 'todo-app'
require 'vault'

Given("an instance of our to-do app") do
  @todo_app = TodoApp::Client.new
end

Given("a valid Google Account") do
  @google_account = {
    username: test@gmail.com,
    password: Vault::Client.get_value_for(key: test@gmail.com,
                                          path: '/todo/testing/accounts',
                                          token: ENV['VAULT_TOKEN'])
  }
end

When("I navigate to the login page at {string}") do |url|
  @todo.visit url
end

Then("I see a button that lets me log in with Google") do
  expect(page).to have_element("//button[id='google_login']")
end
{{< / highlight >}}

Once the engineer playing this story is able to make this series of step definitions pass,
Engineering and Product can play the acceptance test end-to-end to confirm that the feature implemented
is in the ballpark of what they were looking for. (Yay for automating QA!) Once this is agreed upon,
the feature gets released into Production through their CI/CD pipelines.

# An Example of BDD for Site Reliability in Action

We can employ the same tactics outlined above to define availability constraints. However, in this
instance, the Reliability team would be submitting these acceptance tests instead of Product.

Let's say that data collected from user session tracking shows that out of the 100,000 users that
use our todo app on any given month, 85% of them that wait for the login page for more than five
seconds leave our app, presumably to a competitor like Todoist. Because our company is backed by
venture capital, growth is our company's primary metric. Obtaining growth at any cost helps with
future funding rounds that will help the company explore more expensive market plays and fund a
potential IPO in the future. Thus, capturing as many of the fleeting 85% is pretty critical.

To that end, the Reliability team can write a acceptance test that looks like this:

{{< highlight "cucumber" >}}
@reliability
Feature: Timely logins

  Prevent users from bouncing early by ensuring that we can hit the login page in a timely manner.

  Scenario: Login page within five seconds
    Given an instance of the to-do app
    When I navigate to the login page
    Then the login page loads in five seconds or less at least ten times in succession.
{{< /highlight >}}

Notice the `@reliability` tag at the top of this acceptance test. This tag is important, as it allows
us to run our series of acceptance tests with a specific focus on reliability. Since these tests are
intended to be quick, we can run them on a schedule several times per hour. If the failure rate for
these tests is too high (as this rate would be a metric captured by your observability stack), then
Reliability can decide to roll back or fail forward. Additionally, developers can run these tests
during their local testing to gain greater confidence in releasing a reliable product and having a
better sense of what "reliability" actually means.

# Reliability Tests Don't Replace Observability!

Feature testing tools like Cucumber are often used well-beyond their initial scope, largely due to
how flexible they are. That said, _I am not arguing for removing observability tools_! Quite the
contrary, in fact: I think that reliability tests compliment more granular and data-driven
monitoring techniques quite nicely.

Going back to our `/login` example, setting a service-level objective around liveliness
--- whether `/login` returns `HTTP 200/OK` or not --- still helps a lot in giving customers a
general expectation of how available this service will be during a given period. Using feature tests
to drive that will be complicated and slow, and slow metrics are guaranteed to prevent teams from
hitting their SLO targets. Using near-realtime monitoring against the `/login` service and providing
a dashboard showing this service's uptime and remaining error budget along with a widget showing the
rate at which this service's reliability tests are passing tells a fuller story of its healthiness.

# Wrapping Up

Setting SLOs and chasing SLIs are tenets most Reliability Engineers understand well. However, these
metrics alone may not paint a complete picture of what it means for a service to be "up."
Additionally, these metrics are pretty opaque: developers, product or anyone else outside of the
Reliability team that wants to know how things work so well all of the time might have a dashboard
or two as their only recourse.

Reliability tests use behavior-driven development and acceptance testing principles to bridge this
gap. Authoring reliability tests gives non-Reliability engineers a better understanding of
availability expectations, and it shifts some of the onus of making sure that the code is reliable
onto the developer. Additionally, because they are written in plain English, everyone can understand
them, which means that everyone can talk about and iterate on them.

Give it a try!
