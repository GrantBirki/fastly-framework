# fastly-framework ⏰

A Framework for Using Fastly with Terraform, Automation, and CICD

## About 💡

This project is an open source framework for creating a CICD pipeline with Terraform that builds Fastly services.

Benefits:

* Using Git as a version control system for all Fastly changes
* Eliminate code reuse through shared VCL files, Snippets, and Terraform configuration blocks
* Test your services through a CICD pipeline before deploying them
* Integrate with chatops for deployments (Example: Slack)
* Quickly create new services from templates with `make service` - Using Jinja and Python
* Adopt *Infrastructure as Code* methodologies with Terraform
* Create your own pipeline stages for robust testing, alerts, approval, and much more

## Demo

![dev-and-prod-pipeline](docs/assets/dev-and-prod-pipeline.png)

## Documentation 📚

### Table of Contents

Here is the table of contents for the documentation folder. See below for other doc links.

New to Fastly? The [Getting Started](docs/getting-started.md) doc is your place to start.

View the following documents for specific details around each subject:

* [getting-started](docs/getting-started.md) - The best place for newcomers
* [learning](docs/learning.md) - A guide for learning all things Fastly
* [fastly-to-insights](code/logs/fastly-to-insights/README.md) - Aggregated metrics collection from Fastly to New Relic
* [new-service](docs/new-service.md) - A guide for creating a new service in Fastly using this repo
* [pipeline](docs/pipeline.md) - General Pipeline framework information
* [rapid-rollback](docs/rapid-rollback.md) - Information about the rapid-rollback stage of the pipeline
* [slack](docs/slack.md) - For setting up Slack integrations with this pipeline
* [terraform-reference](docs/terraform-reference.md) - How to use common Terraform blocks to configure your Fastly service
* [vcl-include-and-snippets](docs/vcl-include-and-snippets.md) - Details about VCL include statements vs snippets. This guide has examples about how to use both and the key differences between them.

### Additional Documentation

The following links are to other doc pages and READMEs in this repo that are not in this specific folder.

* [ci folder details readme](/code/ci/README.md) - Details about the `/code/ci` folder
* [fastly-ci readme](/code/ci/docker/README.md) - Details about the stock CICD image with Terraform
* [logs folder readme](/code/logs/README.md) - Details about the logs folder
