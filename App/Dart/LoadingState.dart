part of DisplayState;

class LoadingState extends DisplayState {
  LoadingState(App app) : super(app) {
    _app.registerState(DisplayStateType.LOADING, this);
  }

  void renderToDiv(String divID) {
    DivElement parentDiv = document.getElementById(divID);

    parentDiv.appendHtml('''

    <h1>Loading</h1>


    ''');
  }

  void onActivate() {}

  void onDeactivate() {}
}
