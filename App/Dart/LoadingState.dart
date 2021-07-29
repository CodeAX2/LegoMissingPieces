part of DisplayState;

class LoadingState extends DisplayState {
  LoadingState(App app) : super(app) {
    _app.registerState(DisplayStateType.LOADING, this);
  }

  void renderToDiv(String divID) {}

  void onActivate() {}

  void onDeactivate() {}
}
