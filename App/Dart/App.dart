import 'LegoSetProject.dart';
import 'DisplayState.dart';

class App {
  LegoSetProject _project;
  DisplayState _currentState;
  Map<DisplayStateType, DisplayState> _allStates;

  App() {
    _allStates = new Map<DisplayStateType, DisplayState>();
  }

  void registerState(DisplayStateType type, DisplayState state) {
    _allStates[type] = state;
  }
}
