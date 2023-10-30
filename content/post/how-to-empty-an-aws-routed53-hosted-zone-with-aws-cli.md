---
title: How to empty an AWS Routed53 Hosted Zone with AWS CLI
date: 2023-10-30T11:48:47-05:00
draft: false
categories: 
  - aws
  - route53
  - dns
  - cli
tags: 
  - aws
  - deep-dives-in-kiddie-pools
---

So you're managing an AWS VPC with Terraform or something like that, but some
other pesky thing decided to add Route53 records that Terraform doesn't know
about.

As a result, when you try to delete the zone with Terraform, you're no longer
able to because of this:

```text
│ Error: deleting Route53 Hosted Zone (REDACTED): HostedZoneNotEmpty: The specified hosted zone contains non-required resource record sets and so cannot be deleted.
│       status code: 400, request id: REDACTED
```

Ughh. Now you've gotta log into the AWS Console, go to Route53, drill into the
Hosted Zone and delete all of those pesky records.

_Or do you?_

You're reading my blog. Of course you don't.

Here's a one-liner for the AWS CLI that easily takes care of that for you.

## Tools Needed

- The AWS CLI, obviously
- `jq`, the Swiss Army Knife of shell-based JSON manipulation. Check out the
  [docs](https://jqlang.github.io] to learn how to install it.

## The One-Liner

```sh
id=$(aws route53 list-hosted-zones --query 'HostedZones[?Name==`$YOUR_HOSTED_ZONE_HERE.`].Id' --output text); \
aws route53 change-resource-record-sets --hosted-zone-id "$id" --change-batch "$(aws route53 list-resource-record-sets --hosted-zone-id "$id" | jq -c '{Changes: ([.ResourceRecordSets[]|select(.Type != "SOA" and .Type != "NS")|{Action: "DELETE", ResourceRecordSet: .}])}')"
```

This will delete ALL non-essential resource records in a zone. Replace
`$YOUR_HOSTED_ZONE_HERE` with the name of the zone to modify. Leave the period.

Not tested with Private Hosted Zones.

## Breaking it down

```sh
id=$(aws route53 list-hosted-zones --query 'HostedZones[?Name==`$YOUR_HOSTED_ZONE_HERE.`].Id' --output text);
```

This uses `aws route53 list-hosted-zones` and a `JMESPath` query to find your
hosted zone in Route53 and sets it to `$id` so that we can use it throughout
our operation.

```sh
jq -c '{Changes: ([.ResourceRecordSets[]|select(.Type != "SOA" and .Type != "NS")|{Action: "DELETE", ResourceRecordSet: .}])}
```

searches for all resource record sets returned by:

```sh
aws route53 list-resource-record-sets --hosted-zone-id "$id"
```

whose types are neither `NS` or `SOA` records (the resource record sets required
within a Route53 zone), creates a new JSON object for each result that looks
like this:

```json
{
    "Action": "DELETE",
    "ResourceRecordSet": {
        "Name": "rrname.$YOUR_HOSTED_ZONE_HERE.",
        "Type": "A",
        "TTL": 60,
        "ResourceRecords": [{
            "Value": "1.2.3.4"
        }]
    }
}
```

and adds these results to a top-level array object called "Changes".

The final result of that looks like this:

```json
{
    "Changes": [{
        "Action": "DELETE",
        "ResourceRecordSet": {
            "Name": "rrname.$YOUR_HOSTED_ZONE_HERE.",
            "Type": "A",
            "TTL": 60,
            "ResourceRecords": [{
                "Value": "1.2.3.4"
            }]
        },
        "Changes": ...
    ] 
}
```

Which `jq -c` compacts into a single line that's easier for the shell to work
with.

All of that is fed into the `--change-batch` flag of the command

```sh
aws route53 change-resource-record-sets
```

to indicate that we want to change all of these RRSets in bulk. (AWS Route53
does things this way because there are multiple things you can do to RRsets
other than deleting them, and because the CLI tends to be a one-to-one mapping to API
calls within AWS, including a `delete-resource-record-sets` subcommand would
break convention.

I hope this helps someone!
