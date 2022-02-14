part of DisplayState;

class OpenProjectState extends DisplayState {
  DivElement _divRenderingTo;

  bool _active;

  String _selectedDirectory = null;

  InputElement _newProjectapiKeyInput = null;
  InputElement _newProjectNameInput = null;
  HeadingElement _projectInfoTitle = null;

  OpenProjectState(App app) : super(app) {
    _app.registerState(DisplayStateType.OPEN_PROJECT, this);
    _active = false;

    window.onMessage.listen((event) {
      if (_active && event.data["type"] == "directory-selected") {
        _selectedDirectory = event.data["data"]["directory"];
        _updateProjectInfoTitle();
      }
    });
  }

  void renderToDiv(String divID) {
    _divRenderingTo = document.getElementById(divID);
    _divRenderingTo.children.clear();

    HeadingElement openProjectTitle = HeadingElement.h1();
    openProjectTitle.id = "opOpenProjectTitle";
    openProjectTitle.text = "Open Existing Project";
    _divRenderingTo.append(openProjectTitle);

    ButtonElement openProjectButton = new ButtonElement();
    openProjectButton.id = "opOpenProjectBtn";
    openProjectButton.text = "Select Project";
    openProjectButton.classes.add("mainBtn");
    _divRenderingTo.append(openProjectButton);

    InputElement openProjectInput = new InputElement(type: "file");
    openProjectInput.id = "opOpenProjectInput";
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

    openProjectButton.onClick.listen((event) {
      openProjectInput.click();
    });

    HeadingElement createProjectTitle = HeadingElement.h1();
    createProjectTitle.id = "opCreateProjectTitle";
    createProjectTitle.text = "Create New Project";
    _divRenderingTo.append(createProjectTitle);

    HeadingElement projectInfoTitle = HeadingElement.h1();
    projectInfoTitle.id = "opProjectInfoTitle";
    projectInfoTitle.text = "Please enter your API key";
    _projectInfoTitle = projectInfoTitle;

    InputElement apiKeyInput = new InputElement(type: "text");
    apiKeyInput.id = "opApiKeyInput";
    apiKeyInput.placeholder = "Rebrickable API Key";
    apiKeyInput.onInput.listen((event) {
      _updateProjectInfoTitle();
    });
    _newProjectapiKeyInput = apiKeyInput;
    _divRenderingTo.append(apiKeyInput);

    InputElement projectNameInput = new InputElement(type: "text");
    projectNameInput.id = "opProjectNameInput";
    projectNameInput.placeholder = "New Project Name";
    projectNameInput.onInput.listen((event) {
      _updateProjectInfoTitle();
    });
    _newProjectNameInput = projectNameInput;
    _divRenderingTo.append(projectNameInput);

    ButtonElement selectDirectoryButton = new ButtonElement();
    selectDirectoryButton.id = "opSelectDirectoryBtn";
    selectDirectoryButton.text = "Select Project Location";
    selectDirectoryButton.classes.add("subBtn");
    selectDirectoryButton.onClick.listen((event) {
      dynamic messageContents = {};
      messageContents["type"] = "select-directory";
      window.postMessage(messageContents, "*");
    });
    _divRenderingTo.append(selectDirectoryButton);

    _divRenderingTo.append(projectInfoTitle);

    ButtonElement createProjectButton = new ButtonElement();
    createProjectButton.id = "opCreateProjectBtn";
    createProjectButton.text = "Create New Project";
    createProjectButton.classes.add("mainBtn");
    createProjectButton.onClick.listen((event) {
      LegoSetProject project =
          new LegoSetProject.CreateEmpty(apiKeyInput.value, _selectedDirectory, projectNameInput.value + ".json");
      project.loadProject().then((value) {
        _app.setCurrentState(DisplayStateType.PROJECT_VIEW);
      });

      _app.setProject(project);
      _app.setCurrentState(DisplayStateType.LOADING);
    });
    _divRenderingTo.append(createProjectButton);
  }

  void onActivate() {
    _active = true;
    _selectedDirectory = null;
  }

  void onDeactivate() {
    _active = false;
  }

  void _updateProjectInfoTitle() {
    String apiKey = _newProjectapiKeyInput.value;
    String currentName = _newProjectNameInput.value;
    if (apiKey == "") {
      _projectInfoTitle.text = "Please enter your API key";
    } else if (currentName == "") {
      _projectInfoTitle.text = "Please name your project";
    } else if (_selectedDirectory == null) {
      _projectInfoTitle.text = "Please select a directory";
    } else {
      _projectInfoTitle.innerHtml =
          "This will create a new project named: <i>" + currentName + "</i> in: <i>" + _selectedDirectory + "</i>";
    }
  }
}
