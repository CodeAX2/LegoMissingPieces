part of DisplayState;

class AddSetState extends DisplayState {
  DivElement _divRenderingTo;
  InputElement _searchInput;
  InputElement _themeInput;
  DivElement _setOutputDiv;

  String _searchValue, _themeValue;

  bool _isActive;
  bool _scrollListenerRegistered;
  bool _atBottom;

  int _nextPage = 1;

  AddSetState(App app) : super(app) {
    _app.registerState(DisplayStateType.ADD_SET, this);
    _scrollListenerRegistered = false;
    _isActive = false;
    _atBottom = false;
  }

  void renderToDiv(String divID) {
    _divRenderingTo = document.getElementById(divID);
    _divRenderingTo.children.clear();

    if (!_scrollListenerRegistered) {
      _divRenderingTo.onScroll.listen((event) {
        _onWindowScroll(event);
      });
      _scrollListenerRegistered = true;
    }

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
    searchSubmitBtn.classes.add("subBtn");
    searchSubmitBtn.onClick.listen((event) {
      _searchValue = _searchInput.value;
      _themeValue = _themeInput.value;
      _searchSets(1);
    });
    searchBarDiv.append(searchSubmitBtn);

    _searchInput.onKeyUp.listen((event) {
      if (event.keyCode == KeyCode.ENTER) {
        searchSubmitBtn.click();
      }
    });

    _themeInput.onKeyUp.listen((event) {
      if (event.keyCode == KeyCode.ENTER) {
        searchSubmitBtn.click();
      }
    });

    _setOutputDiv = new DivElement();
    _setOutputDiv.id = "asSetOutputDiv";
    parentDiv.append(_setOutputDiv);

    ButtonElement backButton = new ButtonElement();
    backButton.id = "asBackBtn";
    backButton.onClick.listen((event) {
      _app.setCurrentState(DisplayStateType.PROJECT_VIEW);
    });

    ParagraphElement backButtonText = new ParagraphElement();
    backButtonText.append(FontAwesome.GET_ARROW_CIRCLE_LEFT());
    backButtonText.appendText("Back");
    backButton.append(backButtonText);
    parentDiv.append(backButton);
  }

  void _searchSets(int pageNum) {

    RebrickableAccess api = _app.getProject().getAPIAccess();

    api
        .get(
            "sets", "search=$_searchValue&theme_id=$_themeValue&page=$pageNum&page_size=25")
        .then((value) {
      print("Response in: " + api.getResponseTime(value).toString() + "ms");
      if (value.statusCode == 200) {
        _nextPage = pageNum + 1;
        _renderSearchedSets(jsonDecode(value.body), pageNum, 25, pageNum == 1);
      }
    });
  }

  void _renderSearchedSets(
      dynamic setsJson, int curPage, int pageSize, bool clearPreviousEntries) {
    if (clearPreviousEntries) {
      _setOutputDiv.children.clear();
      _divRenderingTo.scrollTop = 0;
    }

    int numSets = min(setsJson["count"] - (curPage - 1) * pageSize, pageSize);
    List<dynamic> sets = setsJson["results"];

    for (int i = 0; i < numSets; i++) {
      dynamic curSet = sets[i];

      String setID = curSet["set_num"];

      // Set already in project
      if (_app.getProject().getSetByID(setID) != null) continue;

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
        _app.getProject().addNewSet(setID).then((value) {
          _app.setCurrentState(DisplayStateType.PROJECT_VIEW);
          _app.getProject().saveProject();
        });
        _app.setCurrentState(DisplayStateType.LOADING);
      });
      setResultDiv.append(addSetButton);
    }
  }

  void _onWindowScroll(Event event) {
    if (!_isActive) return;
    if (_divRenderingTo.scrollTop >=
        _divRenderingTo.scrollHeight - _divRenderingTo.clientHeight - 100) {
      if (!_atBottom) {
        _searchSets(_nextPage);
      }
      _atBottom = true;
    } else {
      _atBottom = false;
    }
  }

  void onActivate() {
    _isActive = true;
  }

  void onDeactivate() {
    _isActive = false;
  }
}
