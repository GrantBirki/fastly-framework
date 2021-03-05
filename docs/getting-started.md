# Getting Started 📚

Brand new to CDNs, Fastly, or Pipelines? Start here!

## What is Fastly

Fastly is a CDN. It is used to cache content, run logic at the edge, and direct traffic to our origins - to put it simply.

Here is the single best page for getting familiar with Fastly
[Learning Fastly](https://docs.fastly.com/en/guides/getting-started)

## What is VCL

VCL is the Varnish Configuration Language which Fastly runs upon. Fastly forked from VCL very early on so the two are not compatible at all.
The core concepts are the same but Fastly is almost its own language at this point.
[Learning VCL](https://varnish-cache.org/docs/trunk/users-guide/vcl.html)

## What is Terraform

Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently.
With Terraform we can construct Fastly services by using "infrastructure as code".
[Terraform Docs](https://www.terraform.io/intro/index.html)

Make sure to *pin* your Terraform version to prevent breaking changes from updates to the `latest` tag.

To learn more about any of the items above, check out the learning document for additional links and resources for all things Fastly / Terraform / Gitlab CI. [Learning Doc](learning.md)

## Making your first change to this repository

Follow the steps below to be ready for your first commit to this repo.

1. Understand the basics of `Fastly`, `VCL`, `Terraform`, and `GitLab CI`.

    Understanding these technologies at a basic level is needed for using this repo. The best way to learn about them is through the links in the [learning documentation](learning.md) Here is a micro summary of each:

    * `Fastly` - The CDN service
    * `VCL` - The configuration language Fastly uses
    * `Terraform` - The technology we use to validate, plan, and deploy changes to Fastly
    * `GitLab CI` - The pipeline service from GitLab we use to deploy, test, and validate merge requests to this repo

    Having a general understanding of CDNs can be quite helpful as well. Check out this [page](https://docs.fastly.com/en/guides/how-fastlys-cdn-service-works) by Fastly.

2. Read through the [New Service](new-service.md) documentation.

    Whether you are creating a brand new service or editing one that already exists, this document will help you become familiar with Fastly and this Pipeline.

3. Asking for help

    If you are ever unsure about what you are doing or have question always feel free to reach out or ask for help.

4. Making your first change (example)

    Once you are ready to make your first change, create a new branch. Make all the edits to your hearts content and then push your changes to your new remote branch. From there you will have the option to create a merge request. Ensure you add a meaningful title and plenty of details before submitting it.

    Once your merge request is submitted it will trigger an initial pipeline. This pipeline runs `terraform plan`, tests, and generates an approval request among other things.

    Key points for making your first change:

    * Create a new branch
    * Create a [merge request | pull request]
    * [merge requests | pull requests] must be reviewed and approved by at least one team member
    * [merge requests | pull requests] must pass the 1st phase of the pipeline before being merged to [main | master]
    * Before deploying any changes to production a valid change request must be approved
