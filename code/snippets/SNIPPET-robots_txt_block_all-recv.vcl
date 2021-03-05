# Ensure the correct FASTLY comment is set at the top of your subroutine.

# This will block ALL crawlers

if (std.tolower(req.url.path) == "/robots.txt") {
  error 601 "robots-txt-block-all";
}