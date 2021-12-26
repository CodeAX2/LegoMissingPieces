part of DisplayState;

class LoadingState extends DisplayState {
  LoadingState(App app) : super(app) {
    _app.registerState(DisplayStateType.LOADING, this);
  }

  void renderToDiv(String divID) {
    DivElement parentDiv = document.getElementById(divID);
    parentDiv.children.clear();

    DivElement loadingDiv = new DivElement();
    loadingDiv.id = "ldLoadingDiv";
    parentDiv.append(loadingDiv);

    HeadingElement loadingTitle = HeadingElement.h1();
    loadingTitle.text = "Loading";
    loadingTitle.id = "ldLoadingTitle";
    loadingDiv.append(loadingTitle);
  }

  void onActivate() {}

  void onDeactivate() {}
}
