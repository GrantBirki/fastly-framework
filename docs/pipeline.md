# CICD Pipeline Information ⏩

This page will cover information about the Fastly CICD pipeline and its stages.

## 10,000 Foot Overview

1. An Engineer pushes a new branch with updates
2. The Engineer submits a merge request | pull request
3. Initial Pipeline is triggered
4. Pipeline must complete successfully
5. Team member approves the merge request | pull request
6. Change is merged to main | master
7. Deploy Pipeline is initiated
8. The Engineer uses the Pipeline to deploy their changes
9. The Engineer has the *break glass* option to `Rapid Rollback` if something goes wrong

## Before you begin

The pipeline expects the following variables to be set in order to run:

* `FASTLY_API_KEY` - **Required** - So the pipeline can authenticate Terraform to your Fastly account
* `AWS VARS...` - **Required** - You will need to configure variables to authenticate with AWS if you choose to use an S3/DynamoDB backend for your Terraform state. Note that once you setup these variables you will need to use them correctly in the `plan`, `test`, and `apply` stages of the pipeline. Look for the comment block in each talking about this.
* `SLACK_URL` - **Optional** - So the pipeline can POST Slack messages to a channel of your choice
* `SERVICENOW_PROD_PASSWORD` - **Optional** - So the pipeline can publish approval requests to ServiceNow
* `SERVICENOW_PROD_USER` - **Optional** - So the pipeline can publish approval requests to ServiceNow

## Approval

Before **any** change is made to a production service it must be reviewed by a team member **and** have an approved change request.

## Pipeline Stages Described

The CICD Pipeline is broken down into two main sections. The `merge` (or pull) phase and the `deploy` phase. The merge (or pull) phase occurs when a merge request (or pull request) is submitted. This phase checks for errors and plans the change. The deploy phase only runs once the merge stage (or pull request) passes and a team member approval has been aquired. This phase allows for a deployment.

From GitLabs perspective these two "phases" are actually two seperate pipelines. So keep that in mind as you cannot pass artifacts between the two easily.

### Merge Phase

1. Repo-check 🗺️ - This phase checks the repo for basic issues. It also exists so that an MR pipeline can pass and deploy simple changes like documentation updates.

    Note: This framework does not implement anything is this phase.

2. Plan 📝 - During the plan phase a job is created for each new service or services which have been updated/changed. The `Terraform Plan` command is run for each job.
3. Test 🧪 - Creates an ephemeral Fastly Service. In the real world you could run tests against this service to ensure your changes are working as expected. Once this phase is finished the test service is destroyed by Terraform.
4. Metrics build-and-push 📊 - Builds the `Fastly-to-Insights` Docker image and pushes to GitLab/AWS-ECR. **Optional**: Use only if you are using the Fastly-to-Insights project for aggregated service metric collection to New Relic.
5. Approval 📯 - This phase create a change request in ServiceNow and publishes a message into a given Slack channel. It is entirely **optional**.

### Deploy Phase

1. Apply ⚙️ - The apply phase pushes up an **inactive** service which you can review in the console. This is useful for a final review before deploying to production.
2. Deploy 🚀 - This phase **activates** the service via an API call to Fastly.
3. Metrics Deploy 📊 - This phase is used to push serviceIds to the `fastly-to-insights` ECS cluster so we can get real time metrics into New Relic.
4. Rapid Rollback 🔄 - This phase is a *break glass* option to **rollback** the change made to a service. It should be used only if needed.

For more detail on the `Rapid Rollback` Phase, check out the [documentation](rapid-rollback.md).

### Cancelling a Job

You can cancel a job in the pipeline at any time and for any reason. However, this may cause unexpected issues that you may need to fix. For this reason it is **highly** suggested to **not** cancel any jobs that have started running, especially if they are running Terraform commands. This is because when jobs are cancelled they cannot release TF state locks.

The most common issue is cancelling a job that is part-way through running a Terraform command. This is most often an issue with the following stages: `plan`, `deploy`, `rapid-rollback`, `metrics`, `plan`, or `test` (there may be others in the future). When you cancel a GitLab CI job it kills the runner right away. This prevents the job from releasing the Terraform state lock gracefully. When you do a `ctrl+c` on a Terraform command locally you will notice it gracefully exits and releases the state lock so you don't have to worry.

Here is how you can release the Terraform state lock manually if you run into this issue:

1. Navigate to the AWS account which contains the `terraform-lock` DynamoDB table for Fastly and this repo.
2. Open the DynamoDB table and make note of the LOCK_IDs which you wish to release. They should be in the third column for a given item and have a format like so: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`.
3. Locally: Enter the `service/<servicename>` directory in this repo for the service you wish to do a lock release on.
4. Locally: Run the command `terraform init`. Ensure that you are using the correct Terraform version and have provided the correct Fastly API Key + AWS keys as environment variables.
5. Locally: Run the command `terraform force-unlock LOCK_ID`.
6. Repeat steps 4-7 with the LOCK_IDs of the items you need to release.
7. Done!

NOTE: Do **not** delete any items from the `terraform-lock` table or the table itself for any reason.

## Secrets

Secrets should not be commited to this repository in any way. This includes:

* API keys
* Private keys
* Passwords
