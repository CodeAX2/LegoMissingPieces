import 'RebrickableAccess.dart';
import 'dart:convert';
import 'package:http/http.dart';

class LegoPiece {
  String _partID;
  int _colorID;
  Future<String> _imageURL;
  String _imageURLDone;
  Future<String> _partDesc;
  String _colorName;

  static Map<String, Map<int, LegoPiece>> _registeredPieces;

  /// Get a lego piece via [partID] and [colorID]
  ///
  /// Also requires an [apiAccess] in order to fetch the URL of the image
  /// Adds the LegoPiece to a map of all pieces, so there is never any duplicates
  /// If [apiAccess] is null, and the piece does not exist, this returns null
  static LegoPiece getPiece(
      String partID, int colorID, RebrickableAccess apiAccess) {
    if (_registeredPieces == null) {
      _registeredPieces = new Map<String, Map<int, LegoPiece>>();
    }

    if (_registeredPieces[partID] == null) {
      _registeredPieces[partID] = new Map<int, LegoPiece>();
    }

    if (_registeredPieces[partID][colorID] == null) {
      if (apiAccess == null) return null;
      _registeredPieces[partID][colorID] =
          LegoPiece._(partID, colorID, apiAccess);
    }

    return _registeredPieces[partID][colorID];
  }

  static LegoPiece getPieceWithoutAPI(String partID, int colorID,
      String imageURL, String partDesc, String colorName) {
    if (_registeredPieces == null) {
      _registeredPieces = new Map<String, Map<int, LegoPiece>>();
    }

    if (_registeredPieces[partID] == null) {
      _registeredPieces[partID] = new Map<int, LegoPiece>();
    }

    if (_registeredPieces[partID][colorID] == null) {
      _registeredPieces[partID][colorID] = LegoPiece._initWithoutAPI(
          partID, colorID, imageURL, partDesc, colorName);
    }

    return _registeredPieces[partID][colorID];
  }

  /// Creates a new LegoPiece with a [partID], a [colorID], and an [apiAccess]
  /// to fetch the image URL
  LegoPiece._(String partID, int colorID, RebrickableAccess apiAccess) {
    _partID = partID;
    _colorID = colorID;
    _imageURLDone = "";

    Future<Response> jsonImageResponse =
        apiAccess.get("parts/$_partID/colors/$_colorID", "");
    _imageURL = jsonImageResponse.then((value) {
      if (value.statusCode != 200) return "";

      String imageURLDone = jsonDecode(value.body)["part_img_url"];
      _imageURLDone = imageURLDone;

      return imageURLDone;
    });

    Future<Response> jsonDescResponse = apiAccess.get("parts/$_partID", "");
    _partDesc = jsonDescResponse.then((value) {
      if (value.statusCode != 200) return "";

      return jsonDecode(value.body)["name"];
    });
  }

  LegoPiece._initWithoutAPI(String partID, int colorID, String imageURL,
      String partDesc, String colorName) {
    _partID = partID;
    _colorID = colorID;
    _imageURLDone = imageURL;
    _imageURL = Future<String>.value(imageURL);
    _partDesc = Future<String>.value(partDesc);
    _colorName = colorName;
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
