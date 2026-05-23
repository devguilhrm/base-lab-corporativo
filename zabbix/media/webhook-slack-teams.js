var params = JSON.parse(value);
var payload = {
  "text": "*[" + params.severity + "]* " + params.subject + "\n" + params.message
};
var req = new HttpRequest();
req.addHeader("Content-Type: application/json");
var resp = req.post(params.webhook_url, JSON.stringify(payload));
if (req.getStatus() != 200) {
  throw "HTTP request failed: " + resp;
}
return resp;

