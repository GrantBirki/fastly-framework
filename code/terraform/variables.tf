# Please reference the Fastly Provider Terraform docs if needed

# Leave this block as it is - Used for the "test" environment
variable "FastlyEnv" {
  default = ""
}


# You can use this block to configure defaults for Terraform Backends
# This is just an example and is not used in this framework
variable "configDefaults" {
  type = object(
    {
      bucket=string,
      keyStart=string,
      keyEnd=string,
      region=string,
      dynamodb_table=string,
      encrypt=bool,
      region=string
    }
  )
  default = {
    "bucket"         = "example-terraform-state-bucket" # set to your own S3 bucket name
    "keyStart"       = "fastly/services/"
    "keyEnd"         = "/terraform.tfstate"
    "region"         = "us-west-2" # put your desired region here
    "dynamodb_table" = "terraform-lock"
    "encrypt"        = true
    "region"         = "us-west-2" # put your desired region here
  }
}

# Used to configure shared logging variables - Example: An Elastic Search Cluster
variable "FastlyLogs" {
  description = "Shared Logging Configuration for Fastly"
  type = object(
    {
      name=string,
      url=string,
      request_max_entries=number,
      content_type=string,
      header_name=string,
      header_value=string,
      method=string,
      json_format=number
    }
  )
  default = {
    "name"                  = "FastlyLogs"
    "url"                   = "https://<http_logging_endpoint>/<path>" # Add your HTTP logging endpoint here
    "request_max_entries"   = 10000
    "content_type"          = "application/json"
    "header_name"           = "x-api-key"
    "header_value"          = "#ID:FastlyLogs" # You can use something like SED in Linux to inject your API key here during a CICD job
    "method"                = "POST"
    "json_format"           = 2
  }
}

# Setting up some simple variables to access for Shield locations
variable "FastlyShield" {
  type = map
  default = {
    "seattle"  = "sea-wa-us"
    "denver"   = "den-co-us"
  }
}

# Block for setting up Origin defaults - Highly recommended!
variable "OriginDefaults" {
  type = object(
    {
      port=number,
      connect_timeout=number,
      use_ssl=bool,
      min_tls_version=number,
      ssl_check_cert=bool,
      auto_loadbalance=bool,
      between_bytes_timeout=number,
      first_byte_timeout=number
    }
  )
  default = {
    "port"               = 443
    "connect_timeout"    = 5000
    "use_ssl"            = true
    "min_tls_version"    = 1.2
    "ssl_check_cert"     = true
    "auto_loadbalance"   = false
    "between_bytes_timeout" = 120000
    "first_byte_timeout" = 30000
    # Timeouts are always in MS
  }
}

# Default Origin condition to use if you have multiple backends and want to choose a default
variable "DefaultOriginConditionDefaults" {
  default = {
    name = "non-default-origin"
    statement = "false"
    type = "REQUEST"
  }
}

# HealthCheckDefaults block to use if you do the same healthcheck across backends
variable "HealthCheckDefaults" {
  description = "HealthCheckDefaults"
  type = object(
    {
      check_interval=number,
      threshold=number,
      window=number,
      timeout=number,
      initial=number,
      shape_path=string,
    }
  )
  default = {
    "check_interval"    = 2000
    "threshold"         = 7
    "window"            = 10
    "timeout"           = 5000
    "initial"           = 9
    "shape_path"        = "/<path>"
  }
}

# Default "main" VCL configuration
variable "vclDefaults" {
  type = object(
    {
      name=string,
      main=bool
    }
  )
  default = {
    "name"    = "main_vcl"
    "main"    = true
  }
}

# Default RequestSetting block for forcing SSL
variable "RequestSettingsDefaults" {
  type = object(
    {
      name=string,
      force_ssl=bool
    }
  )
  default = {
    "name"        = "tf_req_setting"
    "force_ssl"   = true
  }
}

# Default block for setting a strict HSTS policy
variable "hstsPolicyDefaults" {
  default = {
    "name"         = "tf_hsts_setting"
    "action"       = "set"
    "type"         = "response"
    "source"       = "\"max-age=300\""
    "destination"  = "http.Strict-Transport-Security"
  }
}

# ---------------- GZIP Settings ---------------- 
#
# Note: these GZIP settings are all injected into the vcl_fetch subroutine
#

# gzip Default Extensions .css, .js, etc
variable "gzipExtensionDefaults" {
  description = "List of GZIP Default Extensions"
  type        = list(string)
  default     = ["css", "js", "html", "eot", "ico", "otf", "ttf", "json", "svg"]
}

# Content types to match on for GZIP
variable "gzipContentTypeDefaults" {
  description = "List of GZIP Content Type Default"
  type        = list(string)
  default     = ["application/x-font-opentype", "text/xml", "text/javascript", "application/x-font-ttf", "font/otf", "font/eot", "image/svg+xml", "application/json", "text/plain", "font/opentype", "application/vnd.ms-fontobject", "image/vnd.microsoft.icon", "application/xml", "application/x-javascript", "application/javascript", "text/css", "text/html", "application/x-font-truetype"]
}

variable "gzipDefaults" {
  type = map
  default = {
    "name" = "gzip_setting_tf"
  }
}

# ---------------- Cache Settings ---------------- 
#
# Note: these cache settings are all injected into the vcl_fetch subroutine
#

# web assets cache condition
variable "webAssetsCacheCondition" {
  default = {
    name       = "webAssetsCacheCondition"
    type       = "CACHE"
    statement  = "req.url.ext == \"js\" || req.url.ext == \"css\" || req.url.ext == \"ttf\" || req.url.ext == \"eot\" || req.url.ext == \"woff\" || req.url.ext == \"woff2\" || req.url.ext == \"otf\""
  }
}

# web assets cache setting
variable "webAssetsCacheSetting" {
  type = object(
    {
      name=string,
      action=string,
      cache_condition=string,
      stale_ttl=number,
      ttl=number
    }
  )
  default = {
    "name"             = "webAssetsCacheSetting"
    "cache_condition"  = "webAssetsCacheCondition"
    "action"           = "cache"
    "stale_ttl"        = 86400
    "ttl"              = 86400
  }
}

# static image cache condition
variable "staticImageCacheCondition" {
  default = {
    name       = "staticImageCacheCondition"
    type       = "CACHE"
    statement  = "req.url.ext == \"apng\" || req.url.ext == \"avif\" || req.url.ext == \"gif\" || req.url.ext == \"jpg\" || req.url.ext == \"jpeg\" || req.url.ext == \"jfif\" || req.url.ext == \"pjpeg\" || req.url.ext == \"pjp\" || req.url.ext == \"png\" || req.url.ext == \"svg\" || req.url.ext == \"webp\" || req.url.ext == \"bmp\" || req.url.ext == \"ico\" || req.url.ext == \"cur\" || req.url.ext == \"tif\" || req.url.ext == \"tiff\" || req.url.ext == \"jp2\" || req.url.ext == \"exif\" || req.url.ext == \"heif\""
  }
}

# static image cache setting
variable "staticImageCacheSetting" {
  type = object(
    {
      name=string,
      action=string,
      cache_condition=string,
      stale_ttl=number,
      ttl=number
    }
  )
  default = {
    "name"             = "staticImageCacheSetting"
    "cache_condition"  = "staticImageCacheCondition"
    "action"           = "cache"
    "stale_ttl"        = 604800
    "ttl"              = 604800
  }
}

# static media cache condition
variable "staticMediaCacheCondition" {
  default = {
    name       = "staticMediaCacheCondition"
    type       = "CACHE"
    statement  = "req.url.ext == \"aif\" || req.url.ext == \"aiff\" || req.url.ext == \"au\" || req.url.ext == \"avi\" || req.url.ext == \"doc\" || req.url.ext == \"dcr\" || req.url.ext == \"dtd\" || req.url.ext == \"flv\" || req.url.ext == \"hdml\" || req.url.ext == \"mov\" || req.url.ext == \"mp3\" || req.url.ext == \"pdf\" || req.url.ext == \"swa\" || req.url.ext == \"swf\" || req.url.ext == \"txt\" || req.url.ext == \"wav\" || req.url.ext == \"zip\" || req.url.ext == \"wbmp\" || req.url.ext == \"svgz\""
  }
}

# static media cache setting
variable "staticMediaCacheSetting" {
  type = object(
    {
      name=string,
      action=string,
      cache_condition=string,
      stale_ttl=number,
      ttl=number
    }
  )
  default = {
    "name"             = "staticMediaCacheSetting"
    "cache_condition"  = "staticMediaCacheCondition"
    "action"           = "cache"
    "stale_ttl"        = 604800
    "ttl"              = 604800
  }
}