import 'package:http/http.dart';

class RebrickableAccess {
  String _apiKey;
  Client _client;

  RebrickableAccess(String apiKey) {
    _apiKey = apiKey;
    _client = Client();
  }

  /// Performs a GET request to rebrickable.com
  ///
  /// [section] denotes what section of rebrickable's API to make the call to
  /// [params] should take the form of URL query strings
  ///
  /// EX 1. section = "sets", params = "search=turbo car chase"
  /// EX 2. section = "sets/8634-1", params = ""
  Future<Response> get(String section, String params) async {
    Uri requestURL = Uri.parse("https://rebrickable.com/api/v3/lego/$section/?key=$_apiKey&$params");
    return _client.get(requestURL);
  }
}
