---
title: Troubleshooting Kubernetes Namespaces That Won't Delete
date: 2023-10-26T11:00:00Z
slug: 'troubleshooting-namespaces-stuck-deleting'
description: >-
    Having trouble deleting a Kubernetes namespace? Try these tricks!
categories:
    - deep-dives-in-kiddie-pools
    - kubernetes
tags:
    - kubernetes
    - containers
    - devops
    - platform engineering
    - sre
---

Usually, deleting Kubernetes namespaces is easy:

```sh
kubectl delete ns delete-me
```

Sometimes, however, deleting them takes way longer than expected...

```sh
kubectl delete ns delete-me
# still deleting, two months later...
```

This ~~quick~~ "way longer than I acutally ever thought possible" post shows you a
few troubleshooting tricks for dealing with this.


### Forget everything you know about the word "all"

```sh
kubectl delete --all -n delete-me
```

is a lie.

While the `kubectl delete` man page suggests that "--all" means "all":

```text
$: kubectl delete --help | grep -A 3 -B 3 -- '--all=false'
  kubectl delete pods --all

Options:
    --all=false:
        Delete all resources, in the namespace of the specified resource types.

    -A, --all-namespaces=false:
```

It turns out that "all", in fact, meant two different things throughout the
history of Kubernetes, neither of which mean what you think "all" actually
means.

### "all" v0: "all" == "Initialized"

In 2017, the Kubernetes maintainers introduced the concept of
[Initializers](https://medium.com/ibm-cloud/kubernetes-initializers-deep-dive-and-tutorial-3bc416e4e13e).
This allows [admission
controllers](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)
to add routines that execute when they generate, or "initialize", new objects.
Since there is almost no documentation on this feature gate anymore, here's the
[original pull request](https://github.com/kubernetes/kubernetes/pull/36721)
proposing the feature.

Back then, `--all` [did not
include](https://github.com/kubernetes/kubectl/issues/151) "uninitialized"
objects, or objects that were either created by controllers without initializers
or objects that were marked as uninitialized in their `metadata`.

A [pull request](https://github.com/kubernetes/kubernetes/pull/50497) was
created that introduced `--include-uninitialized` to fix this problem.

If you search for troubleshooting tips to fix hung namespaces, you'll likely see
a reference to this flag towards the top of your results. Which is great,
except...

```sh
$: kubectl get --help | grep uninitialized ; echo $?
1
```

It doesn't exist!

Why?

As it happens, "Initializers" were "finalized" from the Internet in two steps:

- The first act was
  [feature-gating](https://github.com/kubernetes/kubernetes/pull/51436)
  Initializers as an alpha feature and and disabling by default due to it
  depending on a cluster plugin that wasn't installed on most clusters at that
  time. (Interestingly, this meant that any solutions suggesting
  `--include-uninitialized` were incorrect for most people!)
- The final act was, unceremoniously, [erasing the
  feature](https://github.com/kubernetes/kubernetes/issues/67113) in favor of
  [webhook
  admission](https://kubernetes.io/docs/reference/access-authn-authz/extensible-admission-controllers/),
  which does everything Initializers do and more.

### "all" v1: "all" is, actually, a construct

At around the same time as "Initializers" were being introduced,
[Custom
Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
gained the ability to be put into "categories".

Categories allow users to `get` multiple resources in a cluster or namespace
with a single type.

For example, if you have two resources in your cluster, like, say, a `Pod` and a
`Service`, whose `categories` both include, say, `all`, you could do this:

```sh
kubectl get all
```

or, more importantly to us here:

```sh
kubectl delete all
```

and get or delete both of these resources in the output:

```text
NAME                                READY   STATUS    RESTARTS   AGE
pod/external-dns-84ffbcc88d-84zj6   1/1     Running   0          44h

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/external-dns   1/1     1            1           3d
```

But what you _won't_ get are resources that aren't a part of the `all` category,
which in a brand, spanking new cluster is **MOST OF THEM**:

```sh
kind create cluster --name why-are-you-like-this-kubectl
comm \
    <(kubectl api-resources --categories all --no-headers | sort) \
    <(kubectl api-resources --no-headers | sort) -1
```

```text
apiservices                                  apiregistration.k8s.io/v1              false   APIService
bindings                                     v1                                     true    Binding
certificatesigningrequests        csr        certificates.k8s.io/v1                 false   CertificateSigningRequest
clusterrolebindings                          rbac.authorization.k8s.io/v1           false   ClusterRoleBinding
clusterroles                                 rbac.authorization.k8s.io/v1           false   ClusterRole
componentstatuses                 cs         v1                                     false   ComponentStatus
configmaps                        cm         v1                                     true    ConfigMap
controllerrevisions                          apps/v1                                true    ControllerRevision
cronjobs                          cj         batch/v1                               true    CronJob
csidrivers                                   storage.k8s.io/v1                      false   CSIDriver
csinodes                                     storage.k8s.io/v1                      false   CSINode
csistoragecapacities                         storage.k8s.io/v1                      true    CSIStorageCapacity
customresourcedefinitions         crd,crds   apiextensions.k8s.io/v1                false   CustomResourceDefinition
daemonsets                        ds         apps/v1                                true    DaemonSet
deployments                       deploy     apps/v1                                true    Deployment
endpoints                         ep         v1                                     true    Endpoints
endpointslices                               discovery.k8s.io/v1                    true    EndpointSlice
events                            ev         events.k8s.io/v1                       true    Event
events                            ev         v1                                     true    Event
flowschemas                                  flowcontrol.apiserver.k8s.io/v1beta3   false   FlowSchema
horizontalpodautoscalers          hpa        autoscaling/v2                         true    HorizontalPodAutoscaler
ingressclasses                               networking.k8s.io/v1                   false   IngressClass
ingresses                         ing        networking.k8s.io/v1                   true    Ingress
jobs                                         batch/v1                               true    Job
leases                                       coordination.k8s.io/v1                 true    Lease
limitranges                       limits     v1                                     true    LimitRange
localsubjectaccessreviews                    authorization.k8s.io/v1                true    LocalSubjectAccessReview
mutatingwebhookconfigurations                admissionregistration.k8s.io/v1        false   MutatingWebhookConfiguration
namespaces                        ns         v1                                     false   Namespace
networkpolicies                   netpol     networking.k8s.io/v1                   true    NetworkPolicy
nodes                             no         v1                                     false   Node
persistentvolumeclaims            pvc        v1                                     true    PersistentVolumeClaim
persistentvolumes                 pv         v1                                     false   PersistentVolume
poddisruptionbudgets              pdb        policy/v1                              true    PodDisruptionBudget
pods                              po         v1                                     true    Pod
podtemplates                                 v1                                     true    PodTemplate
priorityclasses                   pc         scheduling.k8s.io/v1                   false   PriorityClass
prioritylevelconfigurations                  flowcontrol.apiserver.k8s.io/v1beta3   false   PriorityLevelConfiguration
replicasets                       rs         apps/v1                                true    ReplicaSet
replicationcontrollers            rc         v1                                     true    ReplicationController
resourcequotas                    quota      v1                                     true    ResourceQuota
rolebindings                                 rbac.authorization.k8s.io/v1           true    RoleBinding
roles                                        rbac.authorization.k8s.io/v1           true    Role
runtimeclasses                               node.k8s.io/v1                         false   RuntimeClass
secrets                                      v1                                     true    Secret
selfsubjectaccessreviews                     authorization.k8s.io/v1                false   SelfSubjectAccessReview
selfsubjectrulesreviews                      authorization.k8s.io/v1                false   SelfSubjectRulesReview
serviceaccounts                   sa         v1                                     true    ServiceAccount
services                          svc        v1                                     true    Service
statefulsets                      sts        apps/v1                                true    StatefulSet
storageclasses                    sc         storage.k8s.io/v1                      false   StorageClass
subjectaccessreviews                         authorization.k8s.io/v1                false   SubjectAccessReview
tokenreviews                                 authentication.k8s.io/v1               false   TokenReview
validatingwebhookconfigurations              admissionregistration.k8s.io/v1        false   ValidatingWebhookConfiguration
volumeattachments                            storage.k8s.io/v1                      false   VolumeAttachment
```

### this is actually a huge issue

Let's go back to why I started writing this:

```sh
kubectl delete ns delete-me
```

When a namespace is deleted, a termination request is submitted for every
resource within it. Two things happen when these request are submitted:

- The object's `deletionTimestamp` is set to the time of the request, and
- Kubernetes waits for the object's `finalizers` to be empty before finally
  purging the object from `etcd` and moving on with life.

[Finalizers](https://kubernetes.io/docs/concepts/overview/working-with-objects/finalizers/)
are a list of annotations that controllers listen to when objects get deleted.
This allows controllers to perform clean-up duties that must happen before the
object goes poof.

They look like this:

```sh
kubectl get ns delete-me -o jsonpath={.spec.finalizers}
```

```text
{"finalizers":["kubernetes"]}
```

An object's list of `finalizers` must be empty before Kubernetes will proceed
with deleting the object.

This applies for all objects.

Unfortunately, because all != all in Kubernetes-land, there are many objects in
your namespace that you won't see that have finalizers on them that never get
cleared for a number of reasons that, in pure Kubernetes form, you will never
see or know are happening:

- The `Pod`s for the controller that acknowledges that finalizer were deleted
  before it could be acknowledged
- There's a bug in the controller preventing the `finalizer` from being cleared
- An error occurred while the finalizer was acknowledged that prevents the
  controller from removing it

Becuase _everything_ under a namespace must be gone before Kubernetes can
_begin_ deleting the namespace, your namespace gets stuck in limbo forever and
forever waiting for things that won't happen.

SIGH. We're FINALLY ready to talk about troubleshooting this situation.

## Troubleshooting stuck namespace deletions

### Delete _actually all_ resources in the namespace

Use `kubectl api-resources` and `kubectl delete` to wipe out all resources in
the cluster.

```sh
kubectl api-resources --namespaced \
  ---verbs get \
  -o name | xargs -n 1 kubectl delete -n [NAMESPACE]
```

> ⚠️  Make sure that you include `--namespaced`! This is really important. If you
> don't include it, you'll delete cluster-scope resources, like that fancy Istio
> service mesh you just spent 35 straight hours configuring!!!

### Remove all finalizers from all resources in the namespace

When the above inevitably hangs, you can use the same tactic above
with `kubectl patch` to remove every object's `finalizers` and try to kick the
deletion along:

```sh
kubectl api-resources --namespaced \
  ---verbs get \
  -o name | xargs -n 1 xargs -n 1 kubectl patch \
    --type json \
    --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]' \
    -n [NAMESPACE]
```

You can, then, bulk-run `kubectl get` to make sure the resources were
deleted. You should get an empty response if so.

```sh
kubectl api-resources --namespaced \
  ---verbs get \
  -o name | xargs -n 1 xargs -n 1 kubectl get \
    -n [NAMESPACE] \
    --ignore-not-found
```

### Delete unhealthy API Services in the namespace

Some resources might be hanging on an API service that is no longer reachable.
You'll usually be able to see this as a Kubernetes event when you run `kubectl
describe` against it.

This will happen if you delete the `Pod` running the API Service's controller
before you delete the API service.

You can find these unhealthy API services by running this:

```sh
kubectl get apiresources -n [NAMESPACE] | grep False
```

Delete any that show up. Any stuck resources should get deleted shortly after.

### Delete the namespace in `etcd` with `etcdctl`

While I **absolutely, 100% do not recommend doing this**, I'm including it for
completeness.

Since every object is persisted to `etcd` (or whichever database backend your
cluster is using, which is `etcd` 99.9% of the time), you can manually drop it
with `etcdctl` if you have access to the control plane (i.e. not EKS, AKS, GKE,
etc.)

```sh
ETCDCTL_API=3 etcdctl \
    --endpoint=http://[ETCD_HOST]:[ETCD_PORT] \
    --cert=/path/to/etcd/cert \
    --key=/path/to/etcd/key \
    --cacert=/path/to/etcd/cacert \
    rm /namespaces/delete-me
```

Take a look at the `--etcd-servers` flag provided to `kube-apiserver` to get
`ETCD_HOST` and `ETCD_PORT`. Since `etcd` is a distributed database, you can use
any of the servers.
