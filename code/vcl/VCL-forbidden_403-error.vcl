# Forbidden 403
if (obj.status == 601 && obj.response == "forbidden") {
  set obj.status = 403;
  set obj.http.Content-Type = "text/plain";
  synthetic "Forbidden";
  return (deliver);
}