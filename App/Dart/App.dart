import 'dart:html';

import 'LegoSetProject.dart';
import 'DisplayState.dart';

class App {
  LegoSetProject? _project;
  DisplayState? _currentState;
  Map<DisplayStateType, DisplayState> _allStates = new Map<DisplayStateType, DisplayState>();

  DivElement _appDiv = new DivElement();

  App() {
    _appDiv.id = "appDiv";

    document.body?.append(_appDiv);

    new LoadingState(this);
    new ProjectViewState(this);
    new AddSetState(this);
    new EditPiecesState(this);
    new AllMissingPiecesState(this);
    new OpenProjectState(this);

    window.onBeforeUnload.listen((event) {
      _project?.saveProject();
    });
  }

  void registerState(DisplayStateType type, DisplayState state) {
    _allStates[type] = state;
  }

  void setCurrentState(DisplayStateType stateType) {
    _currentState?.onDeactivate();

    _currentState = _allStates[stateType];
    _currentState!.onActivate();
    _currentState!.renderToDiv(_appDiv.id);
  }

  DisplayState? getCurrentState() {
    return _currentState;
  }

  LegoSetProject? getProject() {
    return _project;
  }

  void setProject(LegoSetProject project) {
    _project?.saveProject();
    _project = project;
  }

  DisplayState? getState(DisplayStateType stateType) {
    return _allStates[stateType];
  }
}
