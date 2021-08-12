library DisplayState;

import 'dart:convert';

import 'App.dart';
import 'dart:html';
import 'LegoSetProject.dart';
import 'LegoSet.dart';
import 'RebrickableAccess.dart';

part 'LoadingState.dart';
part 'ProjectViewState.dart';
part 'AddSetState.dart';

enum DisplayStateType { LOADING, PROJECT_VIEW, ADD_SET, EDIT_PIECES, ALL_MISSING_PIECES_VIEW }

abstract class DisplayState {
  App _app;

  App getApp() {
    return _app;
  }

  DisplayState(App app) {
    _app = app;
  }

  void renderToDiv(String divID);
  void onActivate();
  void onDeactivate();
}
