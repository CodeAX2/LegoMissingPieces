import 'package:http/http.dart';

class RebrickableAccess {
  String _apiKey;
  Client _client;
  Map<Response, int> _responseTimes;

  RebrickableAccess(String apiKey) {
    _apiKey = apiKey;
    _client = Client();
    _responseTimes = new Map();
  }

  /// Performs a GET request to rebrickable.com
  ///
  /// [section] denotes what section of rebrickable's API to make the call to
  /// [params] should take the form of URL query strings
  ///
  /// EX 1. section = "sets", params = "search=turbo car chase"
  /// EX 2. section = "sets/8634-1", params = ""
  Future<Response> get(String section, String params) async {
    int start = DateTime.now().millisecondsSinceEpoch;
    Uri requestURL = Uri.parse("https://rebrickable.com/api/v3/lego/$section/?key=$_apiKey&$params");
    Future<Response> resp = _client.get(requestURL);
    resp.then((value) => {_responseTimes[value] = DateTime.now().millisecondsSinceEpoch - start});
    return resp;
  }

  int getResponseTime(Response resp) {
    return _responseTimes[resp];
  }

  String getAPIKey() {
    return _apiKey;
  }
}
