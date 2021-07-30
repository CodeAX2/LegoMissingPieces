part of DisplayState;

class ProjectViewState extends DisplayState {
  ProjectViewState(App app) : super(app) {
    _app.registerState(DisplayStateType.PROJECT_VIEW, this);
  }

  void renderToDiv(String divID) {
    LegoSetProject project = _app.getProject();
    DivElement parentDiv = document.getElementById(divID);
    parentDiv.children.clear();

    DivElement leftNavDiv = new DivElement();
    leftNavDiv.id = "pvNavDiv";
    parentDiv.append(leftNavDiv);

    List<LegoSet> sets = project.getSets();
    for (LegoSet set in sets) {

      DivElement setDiv = new DivElement();
      setDiv.classes.add("pvNavSetDiv");
      leftNavDiv.children.add(setDiv);

      ImageElement setImg = new ImageElement(src: set.getImageURL());
      setImg.classes.add("pvNavSetImg");
      setDiv.append(setImg);

      HeadingElement setTitle = HeadingElement.h1();
      setTitle.text = set.getName();
      setTitle.classes.add("pvNavSetTitle");
      setDiv.append(setTitle);

      HeadingElement setID = HeadingElement.h2();
      setID.text = set.getSetID();
      setID.classes.add("pvNavSetSubtitle");
      setDiv.append(setID);

      HeadingElement setYear = HeadingElement.h2();
      setYear.text = set.getYear().toString();
      setYear.classes.add("pvNavSetSubtitle");
      setDiv.append(setYear);

    }
  }

  void onActivate() {}

  void onDeactivate() {}
}
