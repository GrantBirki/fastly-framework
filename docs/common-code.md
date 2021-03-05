# Common Code Introduction

To make life easier and to avoid code reuse, you can use the "Common Code" templates. These "Common Code" templates include frameworks and variables for logging, Terraform versions/variables, VCL logic, and VCL snippets. "Common Code" can be used in Fastly services to accomplish certain tasks.

## Example

You are creating a new Fastly service and want logging setup. Rather than reinvent the wheel you can simply include the following into your `fastly.tf` file and your logging will be taken care of. This assumes you have an HTTP Fastly logging endpoint configured and the variables defined in `code/terraform/variables.tf`

```vcl
# ---------------- Logging ----------------

httpslogging {
    request_max_entries   = var.FastlyLogs.request_max_entries
    header_value          = var.FastlyLogs.header_value
    content_type          = var.FastlyLogs.content_type
    header_name           = var.FastlyLogs.header_name
    json_format           = var.FastlyLogs.json_format
    method                = var.FastlyLogs.method
    name                  = var.FastlyLogs.name
    url                   = var.FastlyLogs.url
    format                = file("log_format.json")
}
```

The variables seen above are pulled from `code/terraform/variables.tf` during build. The JSON logging structure is also pulled from `code/logs/log_format.json` during build.

## Common Code

Here are the following folders where "common code" can be found and reused:

* `code/vcl` - VCL definitions
* `code/terraform` - Terraform versions and variables
* `code/logs` - Log format for `fastly.tf` shared logging functionality
* `code/snippets` - Shared VCL snippets for reuse
* [terraform-reference](/docs/terraform-reference.md) docs (best)

## Common Code in the CICD Pipeline

If you are using any of the following folders it is best practice to include the following lines in your `.gitlab-ci.yml` definitions. This way, if any changes are made to the shared files, your services get updated as well.

```yaml
only:
    refs:
      - [master | merge_requests] # master or merge, depends on the stage
    changes:
      - services/example/* # Change example to your service name
      - code/logs/* # For Common Code
      - code/snippets/* # For Common Code
      - code/terraform/* # For Common Code
      - code/vcl/* # For Common Code
```

If you are only using the Common Code for `logs` and do not use any `snippets` than you may omit the `snippets` line in the example above. This will prevent your service from being rebuilt when changes are made to the snippets folder.

## Deploy Example

Lets say you make a change to the common logging configuration. In this example 50 services are using the common logging config. Once the merge request is approved, 50 service will be pre-staged and then you have the option to deploy each one. You can either deploy one at a time or deploy all at once. Once all changes have been successfully deployed, your new common logging configuration is now active in all services where it is used.

## Warning

These common files are used by many services. A change to any common file will cause all services using these common files to be rebuilt. Likewise, an error in any common file will spread to all services and could potentially cause a widespread outage.
