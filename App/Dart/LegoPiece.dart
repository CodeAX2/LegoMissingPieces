import 'RebrickableAccess.dart';
import 'dart:convert';
import 'package:http/http.dart';

class LegoPiece {
  String _partID;
  int _colorID;
  late Future<String> _imageURL;
  late Future<String> _partDesc;
  late String _colorName;
  late Future<Map<String, String>> _externalPartIDs;
  late Future<Map<String, int>> _externalColorIDs;

  static Map<String, Map<int, LegoPiece>>? _registeredPieces;

  /// Get a lego piece via [partID] and [colorID]
  ///
  /// Also requires an [apiAccess] in order to fetch the URL of the image
  /// Adds the LegoPiece to a map of all pieces, so there is never any duplicates
  /// If [apiAccess] is null, and the piece does not exist, this returns null
  static LegoPiece? getPiece(String partID, int colorID, RebrickableAccess? apiAccess) {
    if (_registeredPieces == null) {
      _registeredPieces = new Map<String, Map<int, LegoPiece>>();
    }

    if (_registeredPieces?[partID] == null) {
      _registeredPieces![partID] = new Map<int, LegoPiece>();
    }

    if (_registeredPieces?[partID]?[colorID] == null) {
      if (apiAccess == null) return null;
      _registeredPieces![partID]![colorID] = LegoPiece._(partID, colorID, apiAccess);
    }

    return _registeredPieces![partID]![colorID];
  }

  static LegoPiece getPieceWithoutAPI(String partID, int colorID, String imageURL, String partDesc, String colorName,
      dynamic externalPartIDs, dynamic externalColorIDs) {
    if (_registeredPieces == null) {
      _registeredPieces = new Map<String, Map<int, LegoPiece>>();
    }

    if (_registeredPieces?[partID] == null) {
      _registeredPieces![partID] = new Map<int, LegoPiece>();
    }

    if (_registeredPieces?[partID]?[colorID] == null) {
      _registeredPieces![partID]![colorID] =
          LegoPiece._initWithoutAPI(partID, colorID, imageURL, partDesc, colorName, externalPartIDs, externalColorIDs);
    }

    return _registeredPieces![partID]![colorID]!;
  }

  /// Creates a new LegoPiece with a [partID], a [colorID], and an [apiAccess]
  /// to fetch the image URL
  LegoPiece._(this._partID, this._colorID, RebrickableAccess apiAccess) {
    Future<Response> jsonImageResponse = apiAccess.get("parts/$_partID/colors/$_colorID", "");
    _imageURL = jsonImageResponse.then((value) {
      if (value.statusCode != 200) return "";

      String imageURLDone = jsonDecode(value.body)["part_img_url"];

      return imageURLDone;
    });

    Future<Response> jsonDescResponse = apiAccess.get("parts/$_partID", "");

    _partDesc = jsonDescResponse.then((value) {
      if (value.statusCode != 200) return "";

      return jsonDecode(value.body)["name"];
    });
    _externalPartIDs = jsonDescResponse.then((value) {
      Map<String, String> externalIDs = new Map<String, String>();

      dynamic externalIDJson = jsonDecode(value.body)["external_ids"];
      // For now, we are only using bricklink
      externalIDs["BrickLink"] = externalIDJson["BrickLink"][0];

      return externalIDs;
    });

    Future<Response> jsonColorResponse = apiAccess.get("colors/$_colorID", "");

    _externalColorIDs = jsonColorResponse.then((value) {
      Map<String, int> externalIDs = new Map<String, int>();

      dynamic externalIDJson = jsonDecode(value.body)["external_ids"];
      // For now, we are only using bricklink
      externalIDs["BrickLink"] = externalIDJson["BrickLink"]["ext_ids"][0];

      return externalIDs;
    });
  }

  LegoPiece._initWithoutAPI(this._partID, this._colorID, String imageURL, String partDesc, String colorName,
      dynamic externalPartIDs, dynamic externalColorIDs) {
    _imageURL = Future<String>.value(imageURL);
    _partDesc = Future<String>.value(partDesc);
    _colorName = colorName;

    Map<String, String> externalPartIDMap = new Map<String, String>();
    Map<String, int> externalColorIDMap = new Map<String, int>();

    externalPartIDMap["BrickLink"] = externalPartIDs["BrickLink"][0];
    externalColorIDMap["BrickLink"] = externalColorIDs["BrickLink"]["ext_ids"][0];

    _externalPartIDs = Future<Map<String, String>>.value(externalPartIDMap);
    _externalColorIDs = Future<Map<String, int>>.value(externalColorIDMap);
  }

  Future<String> getImageURL() {
    return _imageURL;
  }

  String getPartID() {
    return _partID;
  }

  int getColorID() {
    return _colorID;
  }

  Future<String> getBricklinkID() async {
    return (await _externalPartIDs)["BrickLink"] ?? "";
  }

  Future<int> getBricklinkColorID() async {
    return (await _externalColorIDs)["BrickLink"] ?? 0;
  }

  Future<String> getDescription() {
    return _partDesc;
  }

  @override
  String toString() {
    return _partID;
  }

  String getColorName() {
    return _colorName;
  }
}
