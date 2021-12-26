part of DisplayState;

class OpenProjectState extends DisplayState {
  DivElement _divRenderingTo;

  OpenProjectState(App app) : super(app) {
    _app.registerState(DisplayStateType.OPEN_PROJECT, this);
  }

  void renderToDiv(String divID) {
    _divRenderingTo = document.getElementById(divID);
    _divRenderingTo.children.clear();

    HeadingElement openProjectTitle = HeadingElement.h1();
    openProjectTitle.id = "opOpenProjectTitle";
    openProjectTitle.text = "Open Existing Project";
    _divRenderingTo.append(openProjectTitle);

    InputElement openProjectInput = new InputElement(type: "file");
    openProjectInput.id = "opOpenProjectInput";
    openProjectInput.text = "Select Project";
    openProjectInput.accept = ".json";
    openProjectInput.onChange.listen((event) {
      List<dynamic> args = new List.empty(growable: true);
      args.add(openProjectInput.files[0]);
      String filePath = context.callMethod("getFilePath", args);

      LegoSetProject project = new LegoSetProject(filePath);
      project.loadProject().then((value) {
        _app.setCurrentState(DisplayStateType.PROJECT_VIEW);
      });

      _app.setProject(project);
      _app.setCurrentState(DisplayStateType.LOADING);
    });
    _divRenderingTo.append(openProjectInput);

    HeadingElement createProjectTitle = HeadingElement.h1();
    createProjectTitle.id = "opCreateProjectTitle";
    createProjectTitle.text = "Create New Project";
    _divRenderingTo.append(createProjectTitle);

    InputElement apiKeyInput = new InputElement(type: "text");
    apiKeyInput.id = "opApiKeyInput";
    apiKeyInput.placeholder = "Rebrickable API Key";
    _divRenderingTo.append(apiKeyInput);

    InputElement projectNameInput = new InputElement(type: "text");
    projectNameInput.id = "opProjectNameInput";
    projectNameInput.placeholder = "New Project Name";
    _divRenderingTo.append(projectNameInput);

    InputElement projectDirectoryInput = new InputElement(type: "file");
    projectDirectoryInput.id = "opProjectDirectoryInput";
    projectDirectoryInput.text = "Select Project Directory";
    projectDirectoryInput.directory = true;
    _divRenderingTo.append(projectDirectoryInput);

    ButtonElement createProjectButton = new ButtonElement();
    createProjectButton.id = "opCreateProjectBtn";
    createProjectButton.text = "Create New Project";
    createProjectButton.onClick.listen((event) {
      List<dynamic> args = new List.empty(growable: true);
      args.add(projectDirectoryInput.files[0]);
      String projectDir = path.dirname(context.callMethod("getFilePath", args));

      LegoSetProject project = new LegoSetProject.CreateEmpty(
          apiKeyInput.value, projectDir, projectNameInput.value + ".json");
      project.loadProject().then((value) {
        _app.setCurrentState(DisplayStateType.PROJECT_VIEW);
      });

      _app.setProject(project);
      _app.setCurrentState(DisplayStateType.LOADING);
    });
    _divRenderingTo.append(createProjectButton);
  }

  void onActivate() {}

  void onDeactivate() {}
}
