/*
FASTLY TERRAFORM SERVICE CONFIGURATION
DO NOT REMOVE ANY ID COMMENTS - Example: #ID0001
*/

resource "fastly_service_v1" "fastly-service" {

  # ---------------- Config Settings ----------------

  name = "{{ s.name }}" #ID0001
  activate = false #ID0002 - #Do NOT change value 'false'
  version_comment = "commitsha" #ID0003 - #Do NOT change comment value
  
  # ---------------- Domains ----------------
  {% for domain in s.domains %}
  domain {
    name    = "${var.FastlyEnv}{{ domain.name }}"
    comment = "{{ domain.comment }}"
  }
  {% endfor %}
  # ---------------- Origins ----------------
  {% for backend in s.backends %}
  backend {
    address                  = "{{ backend.address }}"
    name                     = "{{ backend.name }}"
    ssl_cert_hostname        = "{{ backend.ssl_cert_hostname }}"
    port                     = {{ backend.port }}
    connect_timeout          = {{ backend.connect_timeout }}
    use_ssl                  = {{ backend.use_ssl }}
    min_tls_version          = {{ backend.min_tls_version }}
    ssl_check_cert           = {{ backend.ssl_check_cert }}
    auto_loadbalance         = {{ backend.auto_loadbalance }}
    between_bytes_timeout    = {{ backend.between_bytes_timeout }}
    first_byte_timeout       = {{ backend.first_byte_timeout }}
    {% if backend.is_default %}# Default Origin{% else %}request_condition        = var.DefaultOriginConditionDefaults.name
    # Non-Default Origin{% endif %}
  }
  {% endfor %}
  # ---------------- Default Origin Condition ----------------
  
  {% if s.default_origin %}condition {
    name = var.DefaultOriginConditionDefaults.name
    statement = var.DefaultOriginConditionDefaults.statement
    type = var.DefaultOriginConditionDefaults.type
  }{% else %}# Default Origin Condition Not Created - REQUIRED{% endif %}

  {% if s.default_caching %}# ---------------- Cache Conditions ----------------

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
  }{% endif %}

  {% if s.default_vcl %}# ---------------- Custom VCL ----------------

  # Default/Main VCL

  vcl {
    name    = var.vclDefaults.name
    content = file("fastly.vcl")
    main    = var.vclDefaults.main
  }{% else %}# Default VCL Not Created - REQUIRED{% endif %}

  {% if s.geo_blocking %}# Geo Blocking

  vcl {
    name    = "VCL-geo_block_list-init"
    content = file("VCL-geo_block_list-init.vcl")
  }

  vcl {
    name    = "VCL-geo_block-recv"
    content = file("VCL-geo_block-recv.vcl")
  }

  vcl {
    name    = "VCL-forbidden_403-error"
    content = file("VCL-forbidden_403-error.vcl")
  }{% endif %}

  {% if s.nonprod_acl %}# NonProd Protection ACLs
  
  vcl {
    name    = "VCL-nonprod_acl_ips-init"
    content = file("VCL-nonprod_acl_ips-init.vcl")
  }

  vcl {
    name    = "VCL-nonprod_acl-recv"
    content = file("VCL-nonprod_acl-recv.vcl")
  }{% endif %}

  # --------------------- Snippets ---------------------

  {% if s.robots_txt_block_all %}snippet {
    name     = "SNIPPET-robots_txt_block_all-recv"
    type     = "recv"
    content  = file("SNIPPET-robots_txt_block_all-recv.vcl")
  }

  snippet {
    name     = "SNIPPET-robots_txt_block_all-error"
    type     = "error"
    content  = file("SNIPPET-robots_txt_block_all-error.vcl")
  }{% endif %}

  # ---------------- Request Settings ----------------

  {% if s.force_ssl %}request_setting {
    name = var.RequestSettingsDefaults.name
    force_ssl = var.RequestSettingsDefaults.force_ssl
  }{% endif %}

  # ---------------- Headers ----------------

  {% if s.enable_hsts %}header {
    name = var.hstsPolicyDefaults.name
    action = var.hstsPolicyDefaults.action
    type = var.hstsPolicyDefaults.type
    source = var.hstsPolicyDefaults.source
    destination = var.hstsPolicyDefaults.destination
  }{% endif %}

  # ---------------- GZIP / Compression ----------------

  {% if s.enable_gzip %}gzip {
    name = var.gzipDefaults.name
    extensions = var.gzipExtensionDefaults
    content_types = var.gzipContentTypeDefaults
  }{% endif %}

}

