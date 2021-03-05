# Ensure the correct FASTLY comment is set at the top of your subroutine.

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