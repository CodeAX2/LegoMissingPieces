import 'dart:convert';

import 'LegoPiece.dart';
import 'LegoSetProject.dart';
import 'RebrickableAccess.dart';
import 'package:http/http.dart';

class LegoSet {
  String _setID;
  String _name;
  int _year;
  int _themeID;

  String _imageURL;

  Map<LegoPiece, int> _pieces;
  int _numPieces;

  Map<LegoPiece, int> _piecesOwned;

  LegoSetProject _parentProject;
  bool _loaded;

  LegoSet(String setID, LegoSetProject parentProject) {
    _setID = setID;
    _parentProject = parentProject;
    _loaded = false;
  }

  Future<bool> loadSet(RebrickableAccess apiAccess) async {
    Response basicInfo = await apiAccess.get("sets/$_setID", "");
    if (basicInfo.statusCode != 200) {
      _loaded = false;
      return false;
    }

    dynamic jsonData = jsonDecode(basicInfo.body);
    _name = jsonData["name"];
    _year = jsonData["year"];
    _themeID = jsonData["theme_id"];
    _imageURL = jsonData["set_img_url"];
    _numPieces = jsonData["num_parts"];
    _pieces = new Map<LegoPiece, int>();

    int partsPage = 1;
    bool hasNextPage = true;

    while (hasNextPage) {
      Response partsInfo = await apiAccess.get("sets/$_setID/parts", "page=$partsPage");
      if (partsInfo.statusCode != 200) {
        hasNextPage = false;
        break;
      }

      dynamic partsJsonData = jsonDecode(partsInfo.body);

      if (partsJsonData["next"] == null) {
        hasNextPage = false;
      }

      List<dynamic> partsList = partsJsonData["results"];
      for (int i = 0; i < partsList.length; i++) {
        String partID = partsList[i]["part"]["part_num"];
        int colorID = partsList[i]["color"]["id"];
        String imageURL = partsList[i]["part"]["part_img_url"];

        LegoPiece piece = LegoPiece.getPieceWithoutAPI(partID, colorID, imageURL);

        int numInSet = partsList[i]["quantity"];

        _pieces[piece] = numInSet;

      }

      partsPage++;
    }

    return true;
  }

  String getSetID() {
    return _setID;
  }

  String getName() {
    return _name;
  }

  int getYear() {
    return _year;
  }

  int getThemeID() {
    return _themeID;
  }

  String getImageURL() {
    return _imageURL;
  }

  int getNumPieces() {
    return _numPieces;
  }

  bool isLoaded() {
    return _loaded;
  }

  Map<LegoPiece, int> getPieces() {
    return _pieces;
  }

  Map<LegoPiece, int> getPiecesOwned() {
    return _piecesOwned;
  }

  LegoSetProject getParentProject() {
    return _parentProject;
  }

  static Future<dynamic> searchSets(String search, RebrickableAccess apiAccess) async {
    Response response = await apiAccess.get("sets", "search=$search");
    if (response.statusCode != 200) return null;

    dynamic jsonData = jsonDecode(response.body);
    return jsonData;
  }

  static Future<String> getSetImageURL(String setID, RebrickableAccess apiAccess) async {
    Response response = await apiAccess.get("sets/$setID", "");
    if (response.statusCode != 200) return "";

    dynamic jsonData = jsonDecode(response.body);
    return jsonData["set_img_url"];
  }

  static Future<String> getSetName(String setID, RebrickableAccess apiAccess) async {
    Response response = await apiAccess.get("sets/$setID", "");
    if (response.statusCode != 200) return "";

    dynamic jsonData = jsonDecode(response.body);
    return jsonData["name"];
  }
}
