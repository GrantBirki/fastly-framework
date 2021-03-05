/*
FASTLY TERRAFORM SERVICE CONFIGURATION
DO NOT REMOVE ANY ID COMMENTS - Example: #ID0001
You MAY remove the TIP: comments
Before you begin please ensure you have correctly edited your config.tf file.
*/

resource "fastly_service_v1" "fastly-service" {

  # ---------------- Config Settings ----------------
  /*
  TIP: All you need to do in the Config Settings block is set the [name] variable to the
  name of your service.
  */

  name = "www.example.com" #ID0001
  activate = false #ID0002 - #Do NOT change value 'false'
  version_comment = "commitsha" #ID0003 - #Do NOT change comment value
  
  # ---------------- Domains ----------------
  /*
  TIP: Many services only have one domain. If that is your case you may remove the extra domain block.
  Simply insert your domain name right after the "${var.FastlyEnv}" expression and add a meaningful comment.
  */

  domain {
    name    = "${var.FastlyEnv}www.example.com"
    comment = "Example domain"
  }

  domain {
    name    = "${var.FastlyEnv}app.example.com"
    comment = "Alternate Example domain"
  }

  # ---------------- Origins ----------------
  /* 
  TIP: This section defines two example backend blocks
  These blocks are preconfigured using variables. It is
  recommended that you use these variables as they follow
  best practices. You may set your own if you wish.
  At a minimum you will need to set [address, name, ssl_cert_hostname]
  */
  
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
    # Default Origin
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
    request_condition       = var.DefaultOriginConditionDefaults.name #Non Default Origin
  }

  # ---------------- Default Origin Condition ----------------
  /*
  TIP: If you have more than one option for your origin you will need to attach
  a request condition that tells Fastly which one is the default. You can see that
  [request_condition = var.DefaultOriginConditionDefaults.name] is attached to the
  [backend_appservice_example_com_443] backend block above. In order to use
  this [request_condition] you will need to define it below.
  IMPORTANT TIP: Attach the [request_condition] to the backend block that you do
  NOT want to be the default origin.
  */

  condition {
    name = var.DefaultOriginConditionDefaults.name
    statement = var.DefaultOriginConditionDefaults.statement
    type = var.DefaultOriginConditionDefaults.type
  }

  # ---------------- Cache Conditions ----------------
  /*
  TIP: The blocks below define Cache Conditions that may be used to cache
  common static assets.
  */

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
  /*
  TIP: Cache Settings are the details for how Cache Conditions are applied.
  */

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

  # ---------------- Custom VCL ----------------
  /*
  TIP: Custom VCL is the bread and butter of Fastly. At a minimum you will need one VCL file (fastly.vcl).
  The fastly.vcl file is based on the Fastly Boilerplate adapted by this framework and will be the base to get
  you up and running. You may attach additional VCL files here and use include "<vcl_filename>"; in your
  fastly.vcl file to inject their contents.
  */

  vcl {
    name    = var.vclDefaults.name
    content = file("fastly.vcl")
    main    = var.vclDefaults.main
  }

  vcl { # TIP: instantiates the GEO block list
    name    = "VCL-geo_block_list-init"
    content = file("VCL-geo_block_list-init.vcl")
  }

  vcl { # TIP: Checks the GEO blocks list on all incoming connections in the recv subroutine
    name    = "VCL-geo_block-recv"
    content = file("VCL-geo_block-recv.vcl")
  }

  vcl { # TIP: Returns 403s for certain conditions (used by GEO blocking above)
    name    = "VCL-forbidden_403-error"
    content = file("VCL-forbidden_403-error.vcl")
  }

  # --------------------- Snippets ---------------------
  /*
  TIP: Snippets are mini VCL functions that are injected into the main fastly.vcl file. For example a recv subroutine
  snippet would be injected into the [sub vcl_recv {}] subroutine where the #FASTLY recv comment is.
  */

  # snippet {
  #   name     = "SNIPPET-robots_txt_block_all-recv"
  #   type     = "recv"
  #   content  = file("SNIPPET-foobar_redirect-recv.vcl")
  # }

  # snippet {
  #   name     = "SNIPPET-robots_txt_block_all-error"
  #   type     = "error"
  #   content  = file("SNIPPET-foobar_redirect-error.vcl")
  # }

  # ---------------- Request Settings ----------------
  /*
  TIP: Request settings blocks can be used in many ways. The block below shows how to force SSL/TLS.
  */

  request_setting {
    name = var.RequestSettingsDefaults.name
    force_ssl = var.RequestSettingsDefaults.force_ssl
  }

  # ---------------- Headers ----------------
  /*
  TIP: Headers blocks can be used as a simple alternative to VCL for adding or modifying headers.
  */

  header {
    name = var.hstsPolicyDefaults.name
    action = var.hstsPolicyDefaults.action
    type = var.hstsPolicyDefaults.type
    source = var.hstsPolicyDefaults.source
    destination = var.hstsPolicyDefaults.destination
  }

  # ---------------- GZIP / Compression ----------------
  /*
  TIP: The GZIP block is a highly suggested for all Fastly services. It enables compression.
  */

  gzip {
    name = var.gzipDefaults.name
    extensions = var.gzipExtensionDefaults
    content_types = var.gzipContentTypeDefaults
  }

  # ---------------- Logging ----------------
  /*
  TIP: Logging is not required for all Fastly Services but it is HIGHLY recommended.
  Logging is an option configuration and can be implemented in many different ways.
  You can view the code/terraform/variables.tf file to see how this can be configured.
  */

  # httpslogging {
  #   request_max_entries   = var.FastlyLogs.request_max_entries
  #   header_value          = var.FastlyLogs.header_value
  #   content_type          = var.FastlyLogs.content_type
  #   header_name           = var.FastlyLogs.header_name
  #   json_format           = var.FastlyLogs.json_format
  #   method                = var.FastlyLogs.method
  #   name                  = var.FastlyLogs.name
  #   url                   = var.FastlyLogs.url
  #   format                = file("log_format.json")
  # }

}

