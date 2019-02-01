---
title: "Provisioning VMware Workstation Machines from Artifactory with Vagrant"
date: "2017-05-11 04:09:15"
slug: "vagrant-vmware-artifactory"
---

I wrote a small
<code>Vagrantfile</code>
and helper library for provisioning VMware VMs from boxes hosted on Artifactory. I put this together with the intent of helping us easily provision our Rancher/Cattle/Docker-based platform wholesale on our machines to test changes before pushing them up.

Here it is: https://github.com/carlosonunez/vagrant_vmware_artifactory_example

Tests are to be added soon! I'm thinking Cucumber integration tests with unit tests on the helper methods and Vagrantfile correctness.

I also tried to emphasize small, isolated and easily readable methods with short call chains and zero side effects.

The pipeline would look roughly like this:

* Clone repo containing our Terraform configurations, cookbooks and this Vagrantfile
* Make changes
* Do unit tests (syntax, linting, coverage, etc)
* Integrate by spinning up a mock Rancher/Cattle/whatever environment with Vagrant
* Run integration tests (do lb's work, are services reachable, etc)
* Vagrant destroy for teardown
* Terraform apply to push changes to production

We haven't gotten this far yet, but this Vagrantfile is a good starting point.
