# Terraform Reference 📘

This document will explain how to use common Terraform blocks to define your Fastly Service.

## Starting Notes

This guide will be using the files in `services/...example...` as a reference.

All `var.<Defaults>.<LeafVariable>` variables seen below can be edited to better suit your service unless explicity stated otherwise.

Example: You can change `port = var.OriginDefaults.port` (443) to `port = 80` if your heart desires.

In order for your service to work correctly, please ensure you do the following when editing your `fastly.tf` file:

* Do NOT remove "ID COMMENTS". Example: `#ID0001`. You may and are recommended to change the value preceding them however. See below, you can change the name value to whatever you wish but you must keep the ID COMMENT untouched afterwards

    ```hcl
    name = "www.example.com" #ID0001
    ```

* Keep the resource name as it is: `resource "fastly_service_v1" "fastly-service"`
* Don't change either of these lines:

    ```hcl
    activate = false #ID0002 - #Do NOT change value 'false'
    version_comment = "commitsha" #ID0003 - #Do NOT change comment value
    ```

* Do NOT commit or add api keys to your `.tf` files as it is easy to accidently forget and push these to the repo.

## Configuring Domains

The first step to configuring your `fastly.tf` file is to add the domains that will be used by your Fastly Service.

If you have multiple domains they can be added like so:

```hcl
  # ---------------- Domains ----------------

  domain {
    name    = "${var.FastlyEnv}www.example.com"
    comment = "Example domain"
  }

  domain {
    name    = "${var.FastlyEnv}app.example.com"
    comment = "Alternate Example domain"
  }
```

**NOTE**: Make sure to keep `${var.FastlyEnv}` as the prefix of your domain. This is used for smoke testing in the pipeline with temporary Fastly services.

## Configuring Origins

Once you have your domains setup it is time to add origins. There are many preset variables configured for you to use when it comes to origins. It is recommended to use them. If you would like to see what the values are, check them out in the `code/terraform/variables.tf` file.

Note (name): The `name` value must use `_`s in place of `-`s and `.`s. Compare the `address` and `name` variables below to see this in action.

```hcl
  # ---------------- Origins ----------------
  
  backend {
    address                  = "backend.webservice.example.com"
    name                     = "backend_webservice_example_com_443"
    ssl_cert_hostname        = "backend.webservice.example.com"
    port                     = var.OriginDefaults.port
    connect_timeout          = var.OriginDefaults.connect_timeout
    use_ssl                  = var.OriginDefaults.use_ssl
    min_tls_version          = var.OriginDefaults.min_tls_version
    ssl_check_cert           = var.OriginDefaults.ssl_check_cert
    auto_loadbalance         = var.OriginDefaults.auto_loadbalance
    between_bytes_timeout    = var.OriginDefaults.between_bytes_timeout
    first_byte_timeout       = var.OriginDefaults.first_byte_timeout
  }
  
  backend {
    address                 = "backend.appservice.example.com"
    name                    = "backend_appservice_example_com_443"
    ssl_cert_hostname       = "backend.appservice.example.com"
    port                    = var.OriginDefaults.port
    connect_timeout         = var.OriginDefaults.connect_timeout
    use_ssl                 = var.OriginDefaults.use_ssl
    min_tls_version         = var.OriginDefaults.min_tls_version
    ssl_check_cert          = var.OriginDefaults.ssl_check_cert
    auto_loadbalance        = var.OriginDefaults.auto_loadbalance
    between_bytes_timeout   = var.OriginDefaults.between_bytes_timeout
    first_byte_timeout      = var.OriginDefaults.first_byte_timeout
    request_condition       = var.DefaultOriginConditionDefaults.name
  }

  # ---------------- Default Origin Condition ----------------

  condition {
    name = var.DefaultOriginConditionDefaults.name
    statement = var.DefaultOriginConditionDefaults.statement
    type = var.DefaultOriginConditionDefaults.type
  }
```

**Q: How do I set a default Origin?**

**A:** Great question. You may notice something different about the last line of second backend defined above. It has the `request_condition = var.DefaultOriginConditionDefaults.name` variable attached to it. Fastly works different from other CDNs in the sense that default origins are "ruled out" rather than "ruled in". This means that you must explicitly define which origins are **not** the default rather than the typical method of picking the default one. So that is exaclty what the `request_condition` variable does. It tells Fastly that when the `request_condition = var.DefaultOriginConditionDefaults.name` is attached to a backend that it is **not** the default origin. Example: if you have 10 backends and you want to select 1 default origin, you must attached this `request_condition` to the other 9 that are **not** the default.

## Configuring Caching

Caching can be configured in a LOT of different ways in Fastly. Here are just a few examples in no particular order:

* In the `main.vcl` file
* Shared Snippets
* With Shared VCL files and using `include` statements
* Dynamic Snippets
* Cache Conditions
* By Origin and then respect cache settings via Fastly

There is no *best* method. The *best* method is usually the one that works for your use case.

For many use cases the shared variables in `code/terraform/variables.tf` will work just fine for caching a broad spectrum of static assets.

The shared caching variables are broken up into three groups:

* Web Assets (JS, CSS, Fonts, etc)
* Images (JPEG, PNG, SVG, etc)
* Media (MOV, MP4, PDF, TXT, etc)

Here is how you can use them easily in your `fastly.tf` file:

1. Add the `condition` block to your `fastly.tf` file
2. Add the `cache_setting` block with a reference to the `condition` block t your `fastly.tf` file

Example:

```hcl
# ---------------- Cache Conditions ----------------

  # web assets condition
  condition {
    name       = var.webAssetsCacheCondition.name
    statement  = var.webAssetsCacheCondition.statement
    type       = var.webAssetsCacheCondition.type
  }

  # images condition
  condition {
    name       = var.staticImageCacheCondition.name
    statement  = var.staticImageCacheCondition.statement
    type       = var.staticImageCacheCondition.type
  }

  # media files condition
  condition {
    name       = var.staticMediaCacheCondition.name
    statement  = var.staticMediaCacheCondition.statement
    type       = var.staticMediaCacheCondition.type
  }

  # ---------------- Cache Settings ---------------- 

  # caching web assets
  cache_setting {
    name             = var.webAssetsCacheSetting.name
    action           = var.webAssetsCacheSetting.action
    cache_condition  = var.webAssetsCacheSetting.cache_condition
    stale_ttl        = var.webAssetsCacheSetting.stale_ttl
    ttl              = var.webAssetsCacheSetting.ttl
  }

  # caching images
  cache_setting {
    name             = var.staticImageCacheSetting.name
    action           = var.staticImageCacheSetting.action
    cache_condition  = var.staticImageCacheSetting.cache_condition
    stale_ttl        = var.staticImageCacheSetting.stale_ttl
    ttl              = var.staticImageCacheSetting.ttl
  }

  # caching media files
  cache_setting {
    name             = var.staticMediaCacheSetting.name
    action           = var.staticMediaCacheSetting.action
    cache_condition  = var.staticMediaCacheSetting.cache_condition
    stale_ttl        = var.staticMediaCacheSetting.stale_ttl
    ttl              = var.staticMediaCacheSetting.ttl
  }
```

NOTE: Check out the source variable file `code/terraform/variables.tf` to see what the values of these variables are. If you need to adjust things like `ttl` please do so in your `fastly.tf` file directly rather than editing the shared `variables.tf` file.

## Configuring Custom VCL

VCL is the core of Fastly. Here is how you can configured it via the `fastly.tf` file:

```hcl
  # ---------------- Custom VCL ----------------

  # The required "main" VCL file
  vcl {
    name    = var.vclDefaults.name
    content = file("fastly.vcl")
    main    = var.vclDefaults.main
  }

  # Optional VCL files to be "included" into the "main" file...
  #
  # Optional
  vcl {
    name    = "VCL-geo_block_list-init"
    content = file("VCL-geo_block_list-init.vcl")
  }

  # Optional
  vcl {
    name    = "VCL-geo_block-recv"
    content = file("VCL-geo_block-recv.vcl")
  }

  # Optional
  vcl {
    name    = "VCL-forbidden_403-error"
    content = file("VCL-forbidden_403-error.vcl")
  }
```

This is an exampel of a Fastly service with four VCL files. The first one is the "main" VCL file and it is required. The other three are optional and are just examples for how you can use more than just one VCL file. The other three show how you can enable basic `GEO Blocking` functionality for your service. In order to use `GEO Blocking`, simply add VCL includes statements for the three VCL files show above. Example:

* `include "VCL_geo-block-list_init";` - Add to very top of fastly.vcl file
* `include "VCL_geo-block_recv";` - Add to very top of `recv` subroutine
* `include "VCL_forbidden-403_error";` - Add to very top of `error` subroutine

You can view these *extra* VCL files in the `code/vcl` folder in this repo. The advantage to putting logic into seperate VCL files is that they can be reused with different services and reduce the reuse of code. Think of these *extra* VCL files like functions that can be *included* into many Fastly services for use in a shared manner.

For more information, please view the [vcl-include-and-snippets](vcl-include-and-snippets.md) documentation.

## Configuring Request Settings

Want to force SSL/TLS via a common request setting?

```hcl
  # ---------------- Request Settings ----------------

  request_setting {
    name = var.RequestSettingsDefaults.name
    force_ssl = var.RequestSettingsDefaults.force_ssl
  }

```

## Configuring Custom Headers

Need to add a HSTS policy via headers? Here is how with the common header variables.

```hcl
  # ---------------- Headers ----------------

  header {
    name = var.hstsPolicyDefaults.name
    action = var.hstsPolicyDefaults.action
    type = var.hstsPolicyDefaults.type
    source = var.hstsPolicyDefaults.source
    destination = var.hstsPolicyDefaults.destination
  }
```

## Configuring Custom Snippets

A very common situation you may encounter is wanting to "templatize" a certain section of VCL to use again in other services. Here is how you can incorporate an existing VCL Snippet into your service. Common/Shared Snippets are located in the `code/snippets/` folder in this repo.

```hcl
  # --------------------- Snippets ---------------------

  snippet {
    name     = "SNIPPET-robots_txt_block_all-recv"
    type     = "recv"
    content  = file("SNIPPET-robots_txt_block_all-recv.vcl")
  }

  snippet {
    name     = "SNIPPET-robots_txt_block_all-error"
    type     = "error"
    content  = file("SNIPPET-robots_txt_block_all-error.vcl")
  }
```

**Hint:** To see what subroutine a given Snippet will be using just look at the end of the Snippet filename. It should end with a subroutine: `recv`, `error`, `pass`, `miss`, `hit`, etc...

**Note:** Remember that Snippets are injected into the fastly.vcl file where ever the special `#FASTLY <subroutine>` comments are places. For example, the above two Snippets will each be injected at their respective places: `#FASTLY recv` and `#FASTLY error`. You can see this take action when you view the `Generated VCL` in the Fastly Console for your service.

For more information, please view the [vcl-include-and-snippets](vcl-include-and-snippets.md) documentation.

## Configuring GZIP / Compression

All services should be using compression where possible to save on network bandwidth and latency. Using the common GZIP variables will use the defaults by Fastly.

```hcl
  # ---------------- GZIP / Compression ----------------

  gzip {
    name = var.gzipDefaults.name
    extensions = var.gzipExtensionDefaults
  }
```

## Configuring Logging

Logging is not something that is covered well by this Framework as each organization will have a very different approach to logging. Here is just a simple example about how you can enable logging on your service through an HTTPS POST endpoint. This could ingest logs to something like ElasticSearch.

```hcl
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
