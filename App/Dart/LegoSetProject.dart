import 'dart:convert';

import 'package:node_interop/path.dart';

import 'LegoSet.dart';
import 'RebrickableAccess.dart';
import 'package:node_interop/fs.dart';
import 'LegoPiece.dart';

class LegoSetProject {
  List<LegoSet> _sets = [];
  late String _filePath;
  bool _loaded = false;
  late RebrickableAccess _apiAccess;

  LegoSetProject(this._filePath);

  LegoSetProject.CreateEmpty(String apiKey, String directory, String fileName) {
    _apiAccess = new RebrickableAccess(apiKey);
    _sets = [];
    _loaded = false;
    _filePath = path.join(directory, fileName);

    saveProject();
  }

  Future<bool> loadProject() async {
    try {
      dynamic fileContentsJson = jsonDecode(fs.readFileSync(_filePath, "utf-8"));

      _apiAccess = new RebrickableAccess(fileContentsJson["apiKey"]);

      List<Future<dynamic>> loadedAwaits = <Future>[];
      List<dynamic> setsJson = fileContentsJson["sets"];
      for (int i = 0; i < setsJson.length; i++) {
        dynamic curSetJson = setsJson[i];
        LegoSet curSet = new LegoSet(curSetJson["setID"], this);
        loadedAwaits.add(curSet.loadSet(_apiAccess).then((value) {
          if (value) {
            _sets.add(curSet);

            List<dynamic> piecesOwnedJson = curSetJson["piecesOwned"];
            for (int j = 0; j < piecesOwnedJson.length; j++) {
              dynamic curPieceJson = piecesOwnedJson[j];
              LegoPiece curPiece = LegoPiece.getPiece(curPieceJson["partID"], curPieceJson["colorID"], _apiAccess)!;
              curSet.setAmountOwned(curPiece, curPieceJson["amountOwned"]);
            }
          }
        }));
      }

      // Wait for all the sets to load
      await Future.wait(loadedAwaits);

      _loaded = true;
    } catch (e) {
      print(e);
      return false;
    }

    return true;
  }

  bool isLoaded() {
    return _loaded;
  }

  List<LegoSet> getSets() {
    return _sets;
  }

  Map<LegoPiece, int> getAllMissingPieces() {
    Map<LegoPiece, int> missing = new Map<LegoPiece, int>();

    for (int i = 0; i < _sets.length; i++) {
      LegoSet curSet = _sets[i];
      Map<LegoPiece, int> curSetMissing = curSet.getMissingPieces();

      for (LegoPiece key in curSetMissing.keys) {
        missing[key] = (missing[key] ?? 0) + curSetMissing[key]!;
      }
    }

    return missing;
  }

  Future<String> generateBricklinkXML() async {
    String xml = "";

    xml += "<INVENTORY>\n";

    Map<LegoPiece, int> allMissing = getAllMissingPieces();

    for (LegoPiece piece in allMissing.keys) {

      String brickLinkID = await piece.getBricklinkID();
      int brickLinkColorID = await piece.getBricklinkColorID();
      int qty = allMissing[piece]!;

      xml += "  <ITEM>\n";

      xml += "    <ITEMTYPE>P</ITEMTYPE>\n";
      xml += "    <ITEMID>$brickLinkID</ITEMID>\n";
      xml += "    <COLOR>$brickLinkColorID</COLOR>\n";
      xml += "    <MINQTY>${qty}</MINQTY>\n";

      xml += "  </ITEM>\n";
    }

    xml += "</INVENTORY>";

    return xml;

  }

  bool saveProject() {
    dynamic fileData = {};
    fileData["apiKey"] = _apiAccess.getAPIKey();

    List<dynamic> sets = [];
    for (int i = 0; i < _sets.length; i++) {
      dynamic curSetData = {};
      curSetData["setID"] = _sets[i].getSetID();
      List<dynamic> piecesOwnedData = [];
      Map<LegoPiece, int> piecesOwned = _sets[i].getPiecesOwned();
      for (LegoPiece key in piecesOwned.keys) {
        dynamic curPieceData = {};
        curPieceData["partID"] = key.getPartID();
        curPieceData["colorID"] = key.getColorID();
        curPieceData["amountOwned"] = piecesOwned[key];
        piecesOwnedData.add(curPieceData);
      }

      curSetData["piecesOwned"] = piecesOwnedData;
      sets.add(curSetData);
    }

    fileData["sets"] = sets;

    try {
      fs.writeFileSync(_filePath, jsonEncode(fileData));
    } catch (e) {
      return false;
    }

    return true;
  }

  Future<bool> addNewSet(String setID) async {
    LegoSet set = new LegoSet(setID, this);
    bool loaded = await set.loadSet(_apiAccess);
    if (loaded) _sets.add(set);
    return loaded;
  }

  void removeSet(String setID) {
    for (int i = _sets.length - 1; i >= 0; i--) {
      if (_sets[i].getSetID() == setID) {
        _sets.removeAt(i);
      }
    }
  }

  RebrickableAccess getAPIAccess() {
    return _apiAccess;
  }

  LegoSet? getSetByID(String setID) {
    for (int i = 0; i < _sets.length; i++) {
      if (_sets[i].getSetID() == setID) return _sets[i];
    }
    return null;
  }

  static LegoSetProject createNewProject(String filePath, String apiKey) {
    LegoSetProject proj = new LegoSetProject(filePath);
    proj._loaded = true;
    proj._apiAccess = new RebrickableAccess(apiKey);

    return proj;
  }
}
