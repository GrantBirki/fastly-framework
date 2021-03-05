# Used to lock down nonprod Fastly services
acl nonprod_acl_ips_list {
  # Single IP
  "1.1.1.1";
  "123.123.123.0"/24;
}