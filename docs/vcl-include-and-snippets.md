# Snippets and VLC 🧰

It is important to know and choose when to use **VCL** vs when to use **Snippets**. This doc will explain the differences between the two and how to use them in this repo.

First, here is a common question:

**Q:** How do snippets/vcl get included into my service since they are in a different folder?

**A:** The pipeline job copies them into the folder during build. This is all done for you and you do not need to do any configuration, it will just work. It is done with two simple bash commands:

```bash
cp -r $rdir/code/vcl/. services/$FASTLY_SERVICE
cp -r $rdir/code/snippets/. services/$FASTLY_SERVICE
```

You can view a source code example [here](/code/ci/plan/plan.sh) to learn more.

## VCL vs Snippets

Key Takeaways:

* Use VCL `include` statements if exact placement of code is needed
* All Snippets for a given subroutine are placed in the same spot. *Priority* determines their order.
* Snippets **must** be attached to a subroutine.
* VCL `include` statements can be placed *anywhere*. They are not attached to a subroutine and can even be placed outside of subroutines (example: table definitions at the top).
* Changes to any files in the snippets or vcl folders trigger updates for all Fastly services through the pipeline.
* VCL and Snippets files are copied into service folders during pipeline jobs.
* Snippets use `#Fastly <sub routine>` comment tags to select their inject location.
* VCL `include` statements use `include "<vcl_name>;"` to select their inject location.

## VCL

Common (or shared) VCL files can be created and placed in the  `code/vcl/` folder. Any changes made to this folder will trigger all services to be rebuilt during the next `Merge Request`. This is expected since many services use these files.

**VCL** files can use the `include` statement to be injected anywhere into the main VCL file.

### VCL Format

When creating a **new VCL file** in the `code/vcl` folder, use the following format:

`VCL-<name_with_underscores>-<subRoutine>.vcl`

Valid `<subRoutine>` values:

* init
* recv
* hit
* miss
* pass
* fetch
* error
* deliver
* log

Example: `VCL-geo_block-recv.vcl`

## Snippets

**Snippets** are short bits of VCL that must be placed within a certain *subroutine* (recv, error, fetch, etc). Snippets are injected into the *generated* VCL at very specific locations. Any where you see `#FASTLY` comments followed by a *subroutine* (`#FASTLY <subroutine>`) in the custom VCL is where related Snippets will be injected.

Example: `#FASTLY recv` - recv subroutine Snippets will be injected over the `#FASTLY` comment during build. This is Fastly logic, not our own.

Common (or shared) snippets can be created and placed in the  `code/snippets/` folder. Any changes made to this folder will trigger all services to be rebuilt during the next `Merge Request`. This is expected since many services use these files.

### Snippet Format

When creating a **new** Snippet file in the `code/snippets` folder, use the following format:

`SNIPPET-<name_with_underscores>-<subRoutine>.vcl`

Valid `<subRoutine>` values:

* init
* recv
* hit
* miss
* pass
* fetch
* error
* deliver
* log

Example: `SNIPPET-robots_txt_block_all-recv.vcl`

## Snippet Example

The following example will show how you can use a snippet with your service. This example blocks all web crawlers via a `robots.txt` file that is served via a [synthetic request](https://developer.fastly.com/reference/vcl/statements/synthetic/) by Fastly at the edge.

This example can be viewed in the `code/snippets` folder

Snippet Name: `SNIPPET-robots_txt_block_all-recv.vcl`

Snippet contents:

```vcl
# This will block ALL crawlers
if (std.tolower(req.url.path) == "/robots.txt") {
  error 601 "robots-txt-block-all";
}
```

Snippet Name: `SNIPPET-robots_txt_block_all-error.vcl`

Snippet contents:

```vcl
# This will block ALL crawlers
if (obj.status == 601 && obj.response == "robots-txt-block-all") {
  set obj.status = 200;
  set obj.response = "OK";
  set obj.http.Content-Type = "text/plain; charset=utf8";
  set obj.http.Expires = now + 1d;
  set obj.http.Cache-Control:max-age = "86400";
  synthetic "User-agent: *" LF "Disallow: /";
  return(deliver);
}
```

fastly.tf

```hcl
resource "fastly_service_v1" "fastly-service" {
    ...
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
    ...
}
```

fastly.vcl

This bit will likely already exist in your VCL so you may not need to add it. The two #FASTLY comments are where the respective Snippets will be injected.

```vcl
...
sub vcl_recv {
    ...
    #FASTLY recv
    ...
}
...
sub vcl_error {
    ...
    #FASTLY error
    ...
}
...
```

## Using VCL

VCL comes in two flavors: Main and non-main. The main VCL file is the "base" VCL file where all other VCL files and snippets are injected into. When dealing with VCL being injected into the main VCL file this is done with `include` statements.

For example, if you have a main VCL file called `fastly.vcl` and another one called `alt.vcl` you could inject the raw VCL from `alt.vcl` into `fastly.vcl` like so:

In `fastly.vcl`

```vcl
sub vcl_recv {
    include "alt";
}
```

This would *inject* the contents of `alt.vcl` directly into `fastly.vcl`. Look below for an extended example using the `services/www.example.com` service folder.

## VCL Example

This example will demonstrate how to use a GEO Block VCL file with `include` to block unwanted countries.

vcl files to inject

VCL Name: `VCL-geo_block_list-init.vcl`

VCL contents:

```vcl
table geo_block_list {
  # Add country code here
  "CN": "blocked",
  "RU": "blocked"
}
```

VCL Name: `VCL-geo_block-recv.vcl`

VCL contents:

```vcl
if (table.lookup(geo_block_list, client.geo.country_code)) {
    error 601 "forbidden";
}
```

VCL Name: `VCL-forbidden_403-error.vcl`

VCL contents:

```vcl
# Forbidden 403
if (obj.status == 601 && obj.response == "forbidden") {
  set obj.status = 403;
  set obj.http.Content-Type = "text/plain";
  synthetic "Forbidden";
  return (deliver);
}
```

fastly.tf

```hcl
resource "fastly_service_v1" "fastly-service" {
  ...
  # ---------------- Custom VCL ----------------

  vcl {
    name    = var.vclDefaults.name
    content = file("fastly.vcl")
    main    = var.vclDefaults.main
  }

  vcl {
    name    = "VCL-geo_block_list-init"
    content = file("VCL-geo_block_list-init.vcl")
  }

  vcl {
    name    = "VCL-geo_block_recv"
    content = file("VCL-geo_block-recv.vcl")
  }

  vcl {
    name    = "VCL-forbidden_403-error"
    content = file("VCL-forbidden_403-error.vcl")
  }
  ...
}
```

fastly.vcl

```vcl
# Top of VCL file

include "VCL-geo_block_list-init";

sub vcl_recv {
    include "VCL-geo_block-recv";
    ...
}

...

sub vcl_error {
  include "VCL-forbidden_403-error";
  ...
}
...
```

## Shared VCL and Snippet Definitions

This section will go over each file located in the `code/vcl` and `code/snippets` folders.

### VCL Definitions

Shared VCL file definitions. Note, to use all these files you must include them as VCL files in your `fastly.tf` file. See the **VCL Example** section in this document to learn more.

#### VCL-forbidden_403-error

About: This file is used to serve 403s from the edge. It can be used by many other VCL files such as `VCL-geo_block-recv` or `VCL-nonprod_acl_ips-recv`.

Usage: Simply add `include "VCL-forbidden_403-error";` at the top of the `error` subroutine to inject this logic.

```vcl
sub vcl_error {
  include "VCL-forbidden_403-error";
  ...
}
```

#### VCL-geo_block_list-init

About: This is the VCL file which contains the country codes to be blocked. See the `VCL-geo_block-recv` section.

#### VCL-geo_block-recv

About: Used to block certain geographic areas from accessing public domains. This is done by matching the connecting country code to a table of country codes to "block".

Usage: Simply add `include "VCL-geo_block-recv";` at the top of the `recv` subroutine to inject this logic.

Note: You must also add `include "VCL-geo_block_list-init";` at the top of your VCL file before any subroutines.

#### VCL-nonprod_acl_ips-init

About: Initializes the IP ACL table for use in the `VCL-nonprod_acl_ips-recv` file. Used mainly to control access to nonprod/staging services.

Usage: Edit the `VCL-nonprod_acl_ips-init.vcl` file and add in a new line with the IP you wish to grant access for.

```vcl
acl nonprod_acl_ips_list {
  # Example
  "123.123.123.123";
  # Example CIDR
  "123.123.123.0"/24;
}
```

#### VCL-nonprod_acl_ips-recv

About: Used to protect nonprod/staging services from untrusted networks and clients. This is done through IP ACLs and protected headers. IPs should be used over headers where possible.

Usage:

* IP ACL: To add another IP to the `nonprod_acl_ips_list` please edit the `VCL-nonprod_acl_ips-init.vcl` file
* Header ACL: To add another header to the bypass header block, please add another line with the following format to the `if` statement:

  `req.http.<header_name> == "<header_value>"`

Note: Header values are sensitive and must be protected.
