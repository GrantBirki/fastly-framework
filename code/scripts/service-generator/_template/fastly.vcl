#  ------------------------------ FASTLY FRAMEWORK BOILERPLATE ------------------------------
# This file was based on the FASTLY FRAMEWORK BOILERPLATE and had variables injected
# from the "make service" command. Feel free to adapt this file.
# -------------------------------------------------------------------------------------------


{% if s.geo_blocking %}include "VCL-geo_block_list-init";{% endif %}
{% if s.nonprod_acl %}include "VCL-nonprod_acl_ips-init";{% endif %}

sub vcl_recv {

  {% if s.geo_blocking %}include "VCL-geo_block-recv";{% endif %}
  {% if s.nonprod_acl %}include "VCL-nonprod_acl-recv";{% endif %}
  
  #FASTLY recv

  # Normally, you should consider requests other than GET and HEAD to be uncacheable
  # (to this we add the special FASTLYPURGE method)
  if (req.method != "HEAD" && req.method != "GET" && req.method != "FASTLYPURGE") {
    return(pass);
  }

  # HTTP -> HTTPS Redirect
  declare local var.redirected BOOL;
  declare local var.redirect_location STRING;

  if (!req.is_ssl) {
  set req.http.X-Response-Code = "301";
  set var.redirect_location = "https://" + req.http.host + req.url;
  set var.redirected = true;
  }

  return(lookup);
}

sub vcl_hash {
  #FASTLY hash
  set req.hash += req.http.host;
  set req.hash += req.url;
  return(hash);
}

sub vcl_hit {
  #FASTLY hit
  return(deliver);
}

sub vcl_miss {
  #FASTLY miss
  return(fetch);
}

sub vcl_pass {
  #FASTLY pass
  return(pass);
}

sub vcl_fetch {
  #FASTLY fetch

  # Unset headers that reduce cacheability for images processed using the Fastly image optimizer
  if (req.http.X-Fastly-Imageopto-Api) {
    unset beresp.http.Set-Cookie;
    unset beresp.http.Vary;
  }

  # In the event of a server-failure response from origin, retry once more
  if ((beresp.status == 500 || beresp.status == 503) && req.restarts < 1 && (req.method == "GET" || req.method == "HEAD") && !req.http.X-Fastly-Imageopto-Api) {
    restart;
  }

  # Log the number of restarts for debugging purposes
  if (req.restarts > 0) {
    set beresp.http.Fastly-Restarts = req.restarts;
  }

  # If the response is setting a cookie, make sure it is not cached
  if (beresp.http.Set-Cookie) {
    return(pass);
  }

  # By default we set a TTL based on the `Cache-Control` header but we don't parse additional directives
  # like `private` and `no-store`.  Private in particular should be respected at the edge:
  if (beresp.http.Cache-Control ~ "(private|no-store)") {
    return(pass);
  }

  # If no TTL has been provided in the response headers, set a default
  if (!beresp.http.Expires && !beresp.http.Surrogate-Control ~ "max-age" && !beresp.http.Cache-Control ~ "(s-maxage|max-age)") {
    set beresp.ttl = 3600s;

    # Apply a longer default TTL for images processed using Image Optimizer
    if (req.http.X-Fastly-Imageopto-Api) {
      set beresp.ttl = 2592000s; # 30 days
      set beresp.http.Cache-Control = "max-age=2592000, public";
    }
  }

  return(deliver);
}

sub vcl_error {

  {% if s.geo_blocking %}include "VCL-forbidden_403-error";{% endif %}

  #FASTLY error

}

sub vcl_log {
  #FASTLY log
}
