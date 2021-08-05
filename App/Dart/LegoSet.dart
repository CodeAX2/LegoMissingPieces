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

  /// Creates a new LegoSet to keep track of number of pieces and which ones are owned
  ///
  /// [setID] is the rebrickable ID of the set
  /// [parentProject] is the LegoSetProject that this set belongs to
  LegoSet(String setID, LegoSetProject parentProject) {
    _setID = setID;
    _parentProject = parentProject;
    _loaded = false;
  }

  /// Loads the information about this set from rebrickable
  ///
  /// Returns a boolean detailing if the loading was successful or not
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
    _piecesOwned = new Map<LegoPiece, int>();

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
        if (!partsList[i]["is_spare"]) {
          String partID = partsList[i]["part"]["part_num"];
          int colorID = partsList[i]["color"]["id"];
          String imageURL = partsList[i]["part"]["part_img_url"];

          LegoPiece piece = LegoPiece.getPieceWithoutAPI(partID, colorID, imageURL);

          int numInSet = partsList[i]["quantity"];

          _pieces[piece] = numInSet;
          _piecesOwned[piece] = 0;
        }
      }

      partsPage++;
    }

    return true;
  }

  /// Gets the rebrickable ID of the set
  String getSetID() {
    return _setID;
  }

  /// Gets the product name of the set
  String getName() {
    return _name;
  }

  /// Gets the year the set was produced
  int getYear() {
    return _year;
  }

  /// Gets the rebrickable ID of the set's theme
  int getThemeID() {
    return _themeID;
  }

  /// Gets the URL of the image of the set
  String getImageURL() {
    return _imageURL;
  }

  /// Get the total number of pieces in the set
  int getNumPieces() {
    return _numPieces;
  }

  /// Returns if the set has been loaded from rebrickable or not
  bool isLoaded() {
    return _loaded;
  }

  /// Gets a map of all the pieces in the set
  ///
  /// The keys of the map are the pieces, the values are their amount in the set
  Map<LegoPiece, int> getPieces() {
    return _pieces;
  }

  /// Gets a map of all the pieces owned in the set
  ///
  /// The keys of the map are the pieces, the values are their amount owned
  Map<LegoPiece, int> getPiecesOwned() {
    return _piecesOwned;
  }

  /// Returns the LegoSetProject that this set belongs to
  LegoSetProject getParentProject() {
    return _parentProject;
  }

  /// Get the number of a given [piece] in a set
  ///
  /// If [piece] is not a piece in the set, this will return null
  int getAmountInSet(LegoPiece piece) {
    return _pieces[piece];
  }

  /// Gets the amount of a given [piece] that is owned for this set
  ///
  /// If [piece] is not in the set, this returns null
  int getAmountOwned(LegoPiece piece) {
    return _piecesOwned[piece];
  }

  /// Sets the number of pieces owned for a given [piece] to be [amount] for this set
  ///
  /// If [piece] is not in the set, this will not set the amount
  void setAmountOwned(LegoPiece piece, int amount) {
    if (_pieces[piece] != null) _piecesOwned[piece] = amount;
  }

  /// Returns a map representing the pieces that are missing from a set
  ///
  /// The keys of the map are the Lego pieces, the values are the number missing
  Map<LegoPiece, int> getMissingPieces() {
    Map<LegoPiece, int> missing = new Map<LegoPiece, int>();
    for (LegoPiece key in _pieces.keys) {
      missing[key] = _pieces[key] - _piecesOwned[key];
    }
    return missing;
  }

  /// Searches rebrickabe for sets
  ///
  /// [search] can be any keywords used to find a set
  /// Returns a list of sets in JSON format from rebrickable according to their API
  static Future<dynamic> searchSets(String search, RebrickableAccess apiAccess) async {
    Response response = await apiAccess.get("sets", "search=$search");
    if (response.statusCode != 200) return null;

    dynamic jsonData = jsonDecode(response.body);
    return jsonData;
  }

  /// Searches rebrickable for the imageURL of a set based on the [setID]
  ///
  /// This should only be used for when a set is not loaded in its entirety
  static Future<String> getSetImageURL(String setID, RebrickableAccess apiAccess) async {
    Response response = await apiAccess.get("sets/$setID", "");
    if (response.statusCode != 200) return "";

    dynamic jsonData = jsonDecode(response.body);
    return jsonData["set_img_url"];
  }

  /// Searches rebrickable for the name of a set based on the [setID]
  ///
  /// This should only be used for when a set is not loaded in its entirety
  static Future<String> getSetName(String setID, RebrickableAccess apiAccess) async {
    Response response = await apiAccess.get("sets/$setID", "");
    if (response.statusCode != 200) return "";

    dynamic jsonData = jsonDecode(response.body);
    return jsonData["name"];
  }
}
