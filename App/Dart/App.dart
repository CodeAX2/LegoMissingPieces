import 'dart:html';

import 'LegoSetProject.dart';
import 'DisplayState.dart';

class App {
  LegoSetProject _project;
  DisplayState _currentState;
  Map<DisplayStateType, DisplayState> _allStates;

  DivElement _appDiv;

  App() {
    _allStates = new Map<DisplayStateType, DisplayState>();

    _appDiv = new DivElement();
    _appDiv.id = "appDiv";

    document.body.append(_appDiv);

    new LoadingState(this);
    new ProjectViewState(this);
  }

  void registerState(DisplayStateType type, DisplayState state) {
    _allStates[type] = state;
  }

  void setCurrentState(DisplayStateType stateType) {
    if (_currentState != null) _currentState.onDeactivate();

    _currentState = _allStates[stateType];
    _currentState.onActivate();
    _currentState.renderToDiv(_appDiv.id);
  }

  DisplayState getCurrentState() {
    return _currentState;
  }

  LegoSetProject getProject() {
    return _project;
  }

  void setProject(LegoSetProject project) {
    _project = project;
  }
}
