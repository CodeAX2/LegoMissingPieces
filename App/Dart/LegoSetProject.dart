import 'dart:convert';

import 'LegoSet.dart';
import 'RebrickableAccess.dart';
import 'package:node_interop/fs.dart';

class LegoSetProject {
  List<LegoSet> _sets;
  String _filePath;
  bool _loaded;
  RebrickableAccess _apiAccess;

  LegoSetProject(String filePath) {
    _filePath = filePath;
    _sets = [];
    _loaded = false;
  }

  bool loadProject() {
    dynamic fileContentsJson = jsonDecode(fs.readFileSync(_filePath, "utf-8"));

    print(fileContentsJson["api-key"]);

    return true;
  }
}
