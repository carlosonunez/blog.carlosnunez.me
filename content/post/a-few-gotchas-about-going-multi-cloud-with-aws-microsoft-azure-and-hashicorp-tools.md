---
title: "A Few Gotchas About Going Multi-Cloud with AWS, Microsoft Azure and HashiCorp tools."
date: "2017-11-21 00:53:14"
slug: "a-few-gotchas-about-going-multi-cloud-with-aws-microsoft-azure-and-hashicorp-tools"
image: "images/a-few-gotchas-about-going-multi-cloud-with-aws-microsoft-azure-and-hashicorp-tools/header.jpg"
description: >-
  Every CIO in the enterprise is gung-ho for multicloud.
  But is going multicloud a trap in disguise?
  This post looks into an aspect of going multicloud whose devils are in
  the details: infrastructure provisioning.
keywords:
  - multicloud
  - terraform
  - provisioning
---

One of the more interesting types of work we do at [Contino](https://contino.io) is help our clients make sense of the differences between AWS and Microsoft Azure. While the HashiCorp toolchain (Packer, Terraform, Vault, Vagrant, Consul and Nomad) have made provisioning infrastructure a breeze compared to writing hundreds of lines of Python, they almost make achieving a multi-cloud infrastructure deployment seem *too* easy.

This post will outline some of the differences I've observed with using these tools against both cloud platforms. As well, since I used the word "multi-cloud" in my first paragraph, I'll briefly discuss some general talking points on "things to consider" before embarking on a multi-cloud journey at the end.<!--more-->

# Azure and ARM Are Inseparable

One of the core features that make Terraform and Packer tick are providers and builders, respectively. These allow third-parties to write their own "glue" code that tells Terraform how to create VMs or Packer how to create machine images. This way, Terraform and Packer simply become "thin-clients" for your desired platform. HashiCorp's recent move of [moving provider code out of the Terraform binary](https://www.terraform.io/upgrade-guides/0-10.html "") in version 0.10 emphasizes this.

Alas, when you create VMs with Terraform or machine images with Packer, you're really asking the AWS Golang SDK to do those things. This is mostly the case with Azure, with one big exception: the [Azure Resource Manager, or ARM](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview "").

ARM is more-or-less like AWS CloudFormation. You create a JSON template of the resources that you'd like to deploy into a single resource group along with the relationships that should exist between those resources and submit that into ARM as a deployment. It's pretty nifty stuff.

However, instead of Terraform or Packer using the Azure Go SDK directly to create these resources, they both rely on ARM *through* the Azure Go SDK to do that job for them. I'm guessing that HashiCorp chose to do it this way to avoid rework (i.e. "why create a resource object in our provider or builder when ARM already does most of that work?") While this doesn't have *too* many implications in how you actually use these tools against Azure, there are some notable differences in what happens at runtime.

# Azure Deployments Are Slower

My experience has shown me that the Azure ARM Terraform provider and Packer builder takes slightly more time to "get going" than the AWS provider does, especially when using `Standard_A` class VMs. This can make testing code changes quite tedious.

Consider the template below. This uses a `t2.micro` instance to provision a Red Hat image with no customizations.

```
{
  "description": "Basic RHEL image.",
  "variables": {
  "access_key": null,
  "secret_key": null
  },
  "builders": [
    {
    "type": "amazon-ebs",
    "access_key": "{{ user `access_key` }}",
    "secret_key": "{{ user `secret_key` }}",
    "region": "us-east-1",
    "instance_type": "t2.micro",
    "source_ami": "ami-c998b6b2",
    "ami_name": "test_ami",
    "ssh_username": "ec2-user",
    "vpc_id": "vpc-8a2dbbf2",
    "subnet_id": "subnet-306b673c"
    }
  ],
  "provisioners": [
    {
    "type": "shell",
    "inline": [
      "#This is required to allow us to use `sudo` from our Packer provisioner.",
      "#This is enabled by default on all RHEL images for \"security.\"",
      "sudo sed -i.bak -e ';/Defaults.*requiretty/s/^/#/'; /etc/sudoers"
    ]
  },
  {
    "type": "shell",
    "inline": ["echo Hey there"]
  }
  ]
}
```

Assuming a fast internet connection (I did this test with a ~6 Mbit connection), it doesn't take too much time for Packer to generate an AMI for us.

```
$ time packer build -var ';access_key=REDACTED'; -var ';secret_key=REDACTED'; aws.json
==> amazon-ebs: Creating temporary security group for this instance: packer_5a136414-1ba5-7c7d-890c-697a8563d4be
==> amazon-ebs: Authorizing access to port 22 from 0.0.0.0/0 in the temporary security group...
==> amazon-ebs: Launching a source AWS instance...
==> amazon-ebs: Adding tags to source instance
amazon-ebs: Adding tag: "Name": "Packer Builder"
...
amazon-ebs: Hey there
==> amazon-ebs: Stopping the source instance...
amazon-ebs: Stopping instance, attempt 1
==> amazon-ebs: Waiting for the instance to stop...
==> amazon-ebs: Creating the AMI: test_ami
amazon-ebs: AMI: ami-20ff765a
...
Build ';amazon-ebs'; finished.

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs: AMIs were created:
us-east-1: ami-20ff765a

real 1m50.900s
user 0m0.020s
sys 0m0.008s
```

Let's repeat this exercise with Azure. Here's that template again, but Azure-ified:

```
{
  "description": "Basic RHEL image.",
  "variables": {
    "client_id": null,
    "client_secret": null,
    "subscription_id": null,
    "azure_location": null,
    "azure_resource_group_name": null
  },
  "builders": [
    {
      "type": "azure-arm",
      "communicator": "ssh",
      "ssh_pty": true,
      "managed_image_name": "rhel-{{ user `base_rhel_version` }}-rabbitmq-x86_64",
      "managed_image_resource_group_name": "{{ user `azure_resource_group_name` }}",
      "os_type": "Linux",
      "vm_size": "Standard_B1",
      "client_id": "{{ user `client_id` }}",
      "client_secret": "{{ user `client_secret` }}",
      "subscription_id": "{{ user `subscription_id` }}",
      "location": "{{ user `azure_location` }}",
      "image_publisher": "RedHat",
      "image_offer": "RHEL",
      "image_sku": "7.3",
      "image_version": "latest"
    }
  ],
  "provisioners": [
    {
      "type": "shell",
      "inline": [
        "#This is required to allow us to use `sudo` from our Packer provisioner.",
        "#This is enabled by default on all RHEL images for \"security.\"",
        "sudo sed -i.bak -e ';/Defaults.*requiretty/s/^/#/'; /etc/sudoers"
      ]
    },
    {
      "type": "shell",
      "inline": ["echo Hey there"]
    }
  ]
}
```

And here's us running this Packer build. I decided to use a `Basic_A0</code> instance size, as that is the closest thing that Azure has to a <code>t2.micro</code> instance that was available for my subscription. (The <code>Standard_B</code> series is what I originally intended to use, as, like the <code>t2` line, those are burstable.)

Notice that it takes almost **TEN times** as long with the same Linux distribution and similar instance sizes!

```
$ packer build -var ';client_id=REDACTED'; -var ';client_secret=REDACTED'; -var ';subscription_id=REDACTED'; -var ';tenant_id=REDACTED'; -var ';resource_group=REDACTED'; -var ';location=East US'; azure.json
azure-arm output will be in this color.

==> azure-arm: Running builder ...
azure-arm: Creating Azure Resource Manager (ARM) client ...
==> azure-arm: Creating resource group ...
==> azure-arm: -> ResourceGroupName : ';packer-Resource-Group-s6sj74tdvk';
==> azure-arm: -> Location : ';East US';
...
azure-arm: Hey there
==> azure-arm: Querying the machine';s properties ...
==> azure-arm: -> ResourceGroupName : ';packer-Resource-Group-s6sj74tdvk';
==> azure-arm: -> ComputeName : ';pkrvms6sj74tdvk';
==> azure-arm: -> Managed OS Disk : ';/subscriptions/8bbbc92b-6d16-4eb2-8f95-7a0769748c8d/resourceGroups/packer-Resource-Group-s6sj74tdvk/providers/Microsoft.Compute/disks/osdisk';
==> azure-arm: Powering off machine ...
==> azure-arm: -> ResourceGroupName : ';packer-Resource-Group-s6sj74tdvk';
==> azure-arm: -> ComputeName : ';pkrvms6sj74tdvk';
==> azure-arm: Capturing image ...
==> azure-arm: -> Compute ResourceGroupName : ';packer-Resource-Group-s6sj74tdvk';
==> azure-arm: -> Compute Name : ';pkrvms6sj74tdvk';
==> azure-arm: -> Compute Location : ';East US';
==> azure-arm: -> Image ResourceGroupName : ';REDACTED';
==> azure-arm: -> Image Name : ';IMAGE_NAME';
==> azure-arm: -> Image Location : ';eastus';
<strong>==> azure-arm: Deleting resource group ...</strong>
==> azure-arm: -> ResourceGroupName : ';packer-Resource-Group-s6sj74tdvk';
==> azure-arm: Deleting the temporary OS disk ...
==> azure-arm: -> OS Disk : skipping, managed disk was used...
Build ';azure-arm'; finished.

==> Builds finished. The artifacts of successful builds are:
--> azure-arm: Azure.ResourceManagement.VMImage:

ManagedImageResourceGroupName: REDACTED
ManagedImageName: IMAGE_NAME
ManagedImageLocation: eastus

<strong>real 10m27.036s
user 0m0.056s
sys 0m0.020s</strong>

```

The worst part about this is that it takes this long *even when it fails!*

Notice the "Deleting resource group..." line I highlighted. You'll likely spend a lot of time looking at that line. For some reason, cleanup after an ARM deployment can take a while. I'm guessing that this is due to three things:

1. Azure creating intermediate resources, such as virtual networks (VNets), subnets and compute, all of which can take time,
2. ARM waiting for downstream SDKs to finish deleting resources and/or any associated metadata, and
3. Packer issuing [asynchronous operations](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-manager-async-operations "") to the Azure ARM service, which requires polling the `operationResult` endpoint every so often to see how things played out.

## Pro-Tip: Use the `az` Python CLI before running things!

As recovering from Packer failures can be quite time-consuming, you might want to consider leveraging the Azure command-line clients to ensure that inputs into Packer templates are correct. Here's quick example: if you want to confirm that the service principal `client_id</code> and <code>client_secret` are correct, you might want to add something like this into your pipeline:

```
#!/usr/bin/env bash
client_id=$1
client_secret=$2
tenant_id=$3

if ! az login --service-principal -u "$client_id" -p "$client_secret" --tenant "$tenant_id"
then
  echo "ERROR: Invalid credentials." >&amp;2
  exit 1
fi
```

This will save you at least three minutes during exection...as well as something else that's a little more frustrating.

# The AWS provider and builder are more actively consumed

Both the AWS and Azure Terraform providers and Packer builders are mostly maintained internally by HashiCorp. However, what you'll find out after using the Azure ARM provider for a short while is that its usage within the community *pales* in comparison.

I ran into an issue with the `azure-arm</code> builder whereby it failed to find a resource group that I created for an image I was trying to build. Locating that resource group with <code>az groups list` and the same client_id and secret worked fine, and I was able to find the resource group in the console. As well, I gave the service principal "Owner" permission, so there were no access limitations preventing it from finding this resource group.

After spending some time going into the builder source code and firing up [Charles Web Proxy](https://charlesproxy.com ""), it turned out that my error had nothing to do with resource groups! It turns out that [the credentials I was passing into Packer from my Makefile were incorrect](https://github.com/hashicorp/packer/issues/5610 "").

What was more frustrating is that [I couldn't find anything on the web about this problem](https://encrypted.google.com/search?q=%22Build+%27azure-arm%27+errored%3A+Cannot+locate+the+managed+image+resource+group%22 ""). One would think that someone else using this builder would have discovered this before I did, especially after this builder having been available for at least 6 months since this time of writing.

It also seems that there are, by far, more internal commits and contributors to the [Amazon builders](https://github.com/hashicorp/packer/commits/master/builder/amazon "") than those [for Azure](https://github.com/hashicorp/packer/commits/master/builder/azure ""), which seem to largely be maintained by Microsoft folks. Despite this disparity, the Azure contributors are quite fast and are very responsive (or at least they were to me!).

# Getting Started Is Slightly More Involved on Azure

In the early days of cloud computing, Amazon's EC2 service focused entirely on VMs. Their MVP at the time was: we'll make creating, maintaining and destroying VMs fast, easy and painless. Aside from subnets and some routing details, much of the networking overhead was abstracted away. Most of the self-service offerings that Amazon currently has weren't around, or at least not yet. Deploying an app onto AWS still required knowledge on how to set up EC2 instances and deploy onto them, which allowed companies like Digital Ocean and Heroku to rise into prominence. Over time, this premise seems to have held up, as most of AWS's other offerings heavily revolve around EC2 in various forms.

Microsoft took the opposite direction with Azure. Azure's mission statement was to deploy apps onto the cloud as quickly as possible without users having to worry about the details. This is still largely the case, especially if one is deploying an application from Visual Studio. Infrastructure-as-a-Service was more-or-less an afterthought, which led to some industry confusion over where Azure "fit" in the cloud computing spectrum. Consequently, while Microsoft added and expanded their infrastructure offerings over time, the abstractions that were long taken for granted in AWS haven't been "ported over" as quickly.

This is most evident when one is just getting started with AWS and the HashiCorp suite for the first time versus starting up on Azure. These are the steps that one needs to take in order to get a working Packer image into AWS:

1. Sign up for AWS.
2. Log into AWS.
3. Go to [IAM](https://console.aws.amazon.com/iam "") and create a new user.
4. Download the access and secret keys that Amazon gives you.
5. Assign that user Admin privileges over all AWS services.
6. Download the AWS CLI (or install Docker and use the `anigeo/awscli` image)
7. Configure your client: `aws configure`
8. Create a VPC: `aws ec2 create-vpc --cidr-block 10.0.0.0/16`
9. Create an Internet Gateway: `aws ec2 create-internet-gateway`
10. Attach the gateway to your VPC so that your machines can Internet: `aws ec2 attach-internet-gateway --internet-gateway-id $id_from_step_9 --vpc-id $vpc_id_from_step_8`
11. Create a subnet: `aws ec2 create-subnet --vpc-id $vpc_id_from_step_8 --cidr-block 10.0.1.0/24`
12. Update that subnet so that it can issue publicly accessible IP addresses to VMs created within it: `aws ec2 modify-subnet-attribute --subnet-id $subnet_id_from_step_11 --map-public-ip-on-launch`
13. Download Packer (or use the `hashicorp/packer` Docker image)
14. Create a [Packer template](https://www.packer.io/docs/builders/amazon-ebs.html "") for Amazon EBS.
15. Deploy! `packer build -var 'access_key=$access_key' -var 'secret_key=$secret_key' your_template.json

If you want to understand why an AWS VPC requires an internet gateway or how IAM works, finding whitepapers on these topics is a fairly straightforward Google search.

Getting started on Azure, on the other hand, is slightly more laborious as [documented here](https://www.packer.io/docs/builders/azure-setup.html ""). Finding in-depth answers about Azure primitives has also been slightly more difficult, in my experience. Most of what's available are Microsoft Docs entries about how to do certain things and non-technical whitepapers. Finding a Developer Guide like those available in AWS was difficult.

# In Conclusion

Using multiple cloud providers is a smart way of leveraging different pricing schemes between two providers. It is also an interesting way of adding more DR than a single cloud provider can provide alone (which is kind-of a farce, as AWS spans dozens of datacenters across the world, many of which are in the US, though [region-wide outages have happened before, albeit rarely](http://www.datacenterdynamics.com/content-tracks/colo-cloud/aws-suffers-a-five-hour-outage-in-the-us/94841.fullarticle "").

HashiCorp tools like Terraform and Packer make managing this sort of infrastructure much easier to do. However, both providers aren't created equal, and the AWS support that exists is, at this time of writing, significantly more extensive. While this certainly doesn't make using Azure with Terraform or Packer impossible, you might find yourself doing more homework than initially expected!


