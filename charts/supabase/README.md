# Package for Supabase

# FIXME:
# TODO: BROKEN!!!
- label the vector service with `istio.io/use-waypoint: {{ printf "%s-waypoint" (include "common.names.fullname" .) | quote }}`

Supabase is an open source Firebase alternative. Provides all the necessary backend features to build your application in a scalable way. Uses PostgreSQL as datastore.

[Overview of Supabase](https://supabase.com/)

Trademarks: This software listing is packaged by Bitnami. The respective trademarks mentioned in the offering are owned by the respective companies, and use of them does not imply any affiliation or endorsement.

## TL;DR

```console
helm install my-release ??? # FIXME:
```

## Introduction

This chart bootstraps a [Supabase](https://www.supabase.com/) deployment in a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.33+
- Helm 3.18.0+
- PV provisioner support in the underlying infrastructure
- ReadWriteMany volumes for deployment scaling

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install my-release oci://REGISTRY_NAME/REPOSITORY_NAME/supabase
```
