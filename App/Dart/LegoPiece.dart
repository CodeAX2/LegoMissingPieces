import 'RebrickableAccess.dart';
import 'dart:convert';
import 'package:http/http.dart';

class LegoPiece {
  String _partID;
  int _colorID;
  Future<String> _imageURL;
  String _imageURLDone;

  static Map<String, Map<int, LegoPiece>> _registeredPieces;

  /// Get a lego piece via [partID] and [colorID]
  ///
  /// Also requires an [apiAccess] in order to fetch the URL of the image
  /// Adds the LegoPiece to a map of all pieces, so there is never any duplicates
  static LegoPiece getPiece(String partID, int colorID, RebrickableAccess apiAccess) {
    if (_registeredPieces == null) {
      _registeredPieces = new Map<String, Map<int, LegoPiece>>();
    }

    if (_registeredPieces[partID] == null) {
      _registeredPieces[partID] = new Map<int, LegoPiece>();
    }

    if (_registeredPieces[partID][colorID] == null) {
      _registeredPieces[partID][colorID] = LegoPiece._(partID, colorID, apiAccess);
    }

    return _registeredPieces[partID][colorID];
  }

  static LegoPiece getPieceWithoutAPI(String partID, int colorID, String imageURL) {
    if (_registeredPieces == null) {
      _registeredPieces = new Map<String, Map<int, LegoPiece>>();
    }

    if (_registeredPieces[partID] == null) {
      _registeredPieces[partID] = new Map<int, LegoPiece>();
    }

    if (_registeredPieces[partID][colorID] == null) {
      _registeredPieces[partID][colorID] = LegoPiece._initWithoutAPI(partID, colorID, imageURL);
    }

    return _registeredPieces[partID][colorID];
  }

  /// Creates a new LegoPiece with a [partID], a [colorID], and an [apiAccess]
  /// to fetch the image URL
  LegoPiece._(String partID, int colorID, RebrickableAccess apiAccess) {
    _partID = partID;
    _colorID = colorID;
    _imageURLDone = "";

    Future<Response> jsonResponse = apiAccess.get("parts/$_partID/colors/$_colorID", "");
    _imageURL = jsonResponse.then((value) {
      if (value.statusCode != 200) return "";

      String imageURLDone = jsonDecode(value.body)["part_img_url"];
      _imageURLDone = imageURLDone;

      return imageURLDone;
    });
  }

  LegoPiece._initWithoutAPI(String partID, int colorID, String imageURL) {
    _partID = partID;
    _colorID = colorID;
    _imageURLDone = imageURL;
    _imageURL = Future<String>.value(imageURL);
  }

  Future<String> getImageURL() {
    return _imageURL;
  }

  @override
  String toString() {
    return _imageURLDone;
  }
}
