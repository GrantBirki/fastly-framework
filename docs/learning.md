# Learning Fastly 📚

This document will provide information on learning Fastly, Terraform, VCL, and more

## What is Fastly

[Fastly](https://www.fastly.com) is a CDN. It is used to cache content, run logic at the edge, and direct traffic to our origins - to put it simply.

## What is VCL

VCL is the [Varnish Configuration Language](https://varnish-cache.org/docs/trunk/users-guide/vcl.html) which Fastly runs upon. Fastly forked from VCL very early on so the two are not compatible at all.

The core concepts are the same but Fastly is almost its own language at this point as it was forked a long time ago.

## What is Terraform

[Terraform](https://www.terraform.io/intro/index.html) is a tool for building, changing, and versioning infrastructure safely and efficiently.

With Terraform we can construct Fastly services by using "infrastructure as code".

## What is GitLab CICD

GitLab CI/CD is a powerful tool built into GitLab that allows you to apply all the continuous methods (Continuous Integration, Delivery, and Deployment) to your software with no third-party application or integration needed.

## Links

### Getting Started with Fastly

* https://docs.fastly.com/en/guides/start-here

### Fastly Configurations

* https://docs.fastly.com/en/guides/configuration

### Fastly IP Addresses

* https://docs.fastly.com/en/guides/accessing-fastlys-ip-ranges

### Learning VCL

* https://developer.fastly.com/learning/vcl/using/

### HTTP Status Codes and Fastly

* https://developer.fastly.com/reference/http-statuses

### Fastly API Reference

* https://developer.fastly.com/reference/api/

### Fastly Services

* https://developer.fastly.com/reference/api/services/

### Fastly Purging

* https://developer.fastly.com/reference/api/purging/

### Fastly Recipes

* https://developer.fastly.com/solutions/recipes/

### Fastly Solutions (Redirects, Geofencing, A/B testing, and more)

* https://developer.fastly.com/solutions/patterns/

### Fastly Fiddle

* https://fiddle.fastlydemo.net/

### Fastly Logging

* https://docs.fastly.com/en/guides/useful-log-formats
* https://docs.fastly.com/en/guides/custom-log-formats
* https://docs.fastly.com/en/guides/about-fastlys-realtime-log-streaming-features
* https://docs.fastly.com/en/guides/log-streaming-https

### Fastly HTTP Header References

* https://developer.fastly.com/reference/http-headers/

### Fastly Terraform

* https://registry.terraform.io/providers/fastly/fastly/latest/docs
* https://github.com/fastly/terraform-provider-fastly
* https://vimeo.com/330887344

### GitLab CICD

* https://docs.gitlab.com/ee/ci/

### GitLab CICD Pipeline Configuration Guide

* https://docs.gitlab.com/ee/ci/yaml/