part of DisplayState;

class AddSetState extends DisplayState {
  DivElement _divRenderingTo;
  InputElement _searchInput;
  InputElement _themeInput;
  DivElement _setOutputDiv;

  AddSetState(App app) : super(app) {
    _app.registerState(DisplayStateType.ADD_SET, this);
  }

  void renderToDiv(String divID) {
    _divRenderingTo = document.getElementById(divID);
    _divRenderingTo.children.clear();

    DivElement parentDiv = new DivElement();
    parentDiv.id = "asContainerDiv";
    _divRenderingTo.append(parentDiv);

    DivElement searchBarDiv = new DivElement();
    searchBarDiv.id = "asSearchBarDiv";
    parentDiv.append(searchBarDiv);

    _searchInput = new InputElement();
    _searchInput.id = "asSearchInput";
    _searchInput.placeholder = "Search";
    searchBarDiv.append(_searchInput);

    _themeInput = new InputElement();
    _themeInput.id = "asThemeInput";
    _themeInput.placeholder = "Theme ID";
    searchBarDiv.append(_themeInput);

    ButtonElement searchSubmitBtn = new ButtonElement();
    searchSubmitBtn.text = "Go";
    searchSubmitBtn.id = "asSearchSubmitBtn";
    searchSubmitBtn.onClick.listen((event) {
      _searchSets();
    });
    searchBarDiv.append(searchSubmitBtn);

    _setOutputDiv = new DivElement();
    _setOutputDiv.id = "asSetOutputDiv";
    parentDiv.append(_setOutputDiv);
  }

  void _searchSets() {
    String search = _searchInput.value;
    String theme = _themeInput.value;

    RebrickableAccess api = _app.getProject().getAPIAccess();

    api.get("sets", "search=$search&theme_id=$theme&page=1&page_size=25").then((value) {
      print("Response in: " + api.getResponseTime(value).toString() + "ms");
      if (value.statusCode == 200) _renderSearchedSets(jsonDecode(value.body));
    });
  }

  void _renderSearchedSets(dynamic setsJson) {
    _setOutputDiv.children.clear();

    int numSets = setsJson["count"];
    List<dynamic> sets = setsJson["results"];

    for (int i = 0; i < numSets; i++) {
      dynamic curSet = sets[i];

      String setID = curSet["set_num"];
      String setName = curSet["name"];
      String imageURL = curSet["set_img_url"];

      DivElement setResultDiv = new DivElement();
      setResultDiv.classes.add("asSetResultDiv");
      _setOutputDiv.append(setResultDiv);

      ImageElement setImage = new ImageElement(src: imageURL);
      setResultDiv.append(setImage);

      HeadingElement setTitle = HeadingElement.h1();
      setTitle.text = setName;
      setResultDiv.append(setTitle);

      ButtonElement addSetButton = new ButtonElement();
      addSetButton.text = "Add Set";
      addSetButton.onClick.listen((event) {
        _app.getProject().addNewSet(setID).then((value) => _app.setCurrentState(DisplayStateType.PROJECT_VIEW));
        _app.setCurrentState(DisplayStateType.LOADING);
      });
      setResultDiv.append(addSetButton);
    }
  }

  void onActivate() {}

  void onDeactivate() {}
}
