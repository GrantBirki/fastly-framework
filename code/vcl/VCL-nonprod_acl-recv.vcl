# NONPROD ACL VLC Logic (vcl_recv)
if (
  # If IP address is in ACL table - pass
  (req.http.Fastly-Client-IP ~ nonprod_acl_ips_list) ||

  # Or if bypass headers are found - pass
  req.http.UNIQUE-BYPASS-HEADER == "AAABBBCCCDDDEEEFFF" ||
  req.http.UNIQUE-BYPASS-HEADER == "JJJKKKLLLPPPOOOIII"
  ){}

# Else - block
else {
  error 601 "forbidden";
}