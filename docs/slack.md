# Slack 💬

To use this integration simply setup a [Incoming Webhook](https://api.slack.com/messaging/webhooks) with Slack and set a CICD environment variable in your pipeline like so.

`SLACK_URL=https://hooks.slack.com/services/<your-endpoint>`

## Messages

The following types of messages are examples of notifications that are posted to your configured Slack channel via pipeline automation:

* Warnings
* Failures
* Deployments
* ServiceNow Change Requests
* Rollbacks
