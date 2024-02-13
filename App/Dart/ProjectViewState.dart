part of DisplayState;

class ProjectViewState extends DisplayState {
  LegoSet? _selectedSet;
  DivElement? _setViewDiv;
  DivElement? _deleteConfirmationDiv;
  DivElement? _divRenderingTo;

  ProjectViewState(App app) : super(app) {
    _app.registerState(DisplayStateType.PROJECT_VIEW, this);
  }

  void renderToDiv(String divID) {
    LegoSetProject? project = _app.getProject();

    _divRenderingTo = document.getElementById(divID) as DivElement?;
    _divRenderingTo?.children.clear();

    DivElement pvStateDiv = new DivElement();
    pvStateDiv.id = "pvStateDiv";
    _divRenderingTo?.append(pvStateDiv);

    DivElement menuDiv = new DivElement();
    menuDiv.id = "pvMenuDiv";
    pvStateDiv.append(menuDiv);

    ButtonElement addSetButton = new ButtonElement();
    addSetButton.text = "Add Set";
    addSetButton.id = "pvAddSetBtn";
    addSetButton.onClick.listen((event) {
      _app.setCurrentState(DisplayStateType.ADD_SET);
    });
    menuDiv.append(addSetButton);

    ButtonElement viewAllMissingButton = new ButtonElement();
    viewAllMissingButton.text = "View All Missing Pieces";
    viewAllMissingButton.id = "pvViewAllMissingBtn";
    viewAllMissingButton.onClick.listen((event) {
      _app.setCurrentState(DisplayStateType.ALL_MISSING_PIECES_VIEW);
    });
    menuDiv.append(viewAllMissingButton);

    ButtonElement changeProjectButton = new ButtonElement();
    changeProjectButton.text = "Change Project";
    changeProjectButton.id = "pvChangeProjectBtn";
    changeProjectButton.onClick.listen((event) {
      _app.setCurrentState(DisplayStateType.OPEN_PROJECT);
    });
    menuDiv.append(changeProjectButton);

    DivElement parentDiv = new DivElement();
    parentDiv.id = "pvContainerDiv";
    pvStateDiv.append(parentDiv);

    DivElement leftNavDiv = new DivElement();
    leftNavDiv.id = "pvNavDiv";
    parentDiv.append(leftNavDiv);

    if (project != null) {
      List<LegoSet> sets = project.getSets();
      for (LegoSet set in sets) {
        DivElement setDiv = new DivElement();
        setDiv.onClick.listen((event) {
          selectSet(set);
        });
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

    _setViewDiv = new DivElement();
    _setViewDiv?.id = "pvSetViewDiv";
    parentDiv.append(_setViewDiv as Node);

    if (_selectedSet != null) _renderSelectedSet();

    _deleteConfirmationDiv = new DivElement();
    _deleteConfirmationDiv?.id = "pvDeleteConfirmationDiv";

    HeadingElement deleteHeading = HeadingElement.h1();
    deleteHeading.text = "Are You Sure You Want To Proceed?";
    _deleteConfirmationDiv?.append(deleteHeading);

    ParagraphElement deleteInformation = new ParagraphElement();
    deleteInformation.text =
        "This will remove the set from the current project, and any parts you have marked as missing. Are you sure you want to proceed?";
    _deleteConfirmationDiv?.append(deleteInformation);

    ButtonElement deleteConfirmButton = new ButtonElement();
    deleteConfirmButton.id = "pvDeleteConfirmationBtn";
    deleteConfirmButton.text = "Remove Set";
    deleteConfirmButton.onClick.listen((event) {
      _deleteCurrentSet();
    });
    _deleteConfirmationDiv?.append(deleteConfirmButton);

    ButtonElement confirmationCloseButton = new ButtonElement();
    confirmationCloseButton.id = "pvConfirmationCloseBtn";
    confirmationCloseButton.append(FontAwesome.GET_TIMES());
    confirmationCloseButton.onClick.listen((event) {
      _hideDeletionConfirm();
    });
    _deleteConfirmationDiv?.append(confirmationCloseButton);

    pvStateDiv.append(_deleteConfirmationDiv as Node);
  }

  void selectSet(LegoSet set) {
    _selectedSet = set;
    _renderSelectedSet();
  }

  void _renderSelectedSet() {
    _setViewDiv?.children.clear();

    _deleteConfirmationDiv?.classes.remove("pvDeleteConfirmationAnim");

    ImageElement setImage = new ImageElement();
    setImage.src = _selectedSet?.getImageURL();
    _setViewDiv?.append(setImage);

    HeadingElement setTitle = HeadingElement.h1();
    setTitle.text = _selectedSet?.getName();
    _setViewDiv?.append(setTitle);

    ParagraphElement setInformation = new ParagraphElement();

    String setInformationText = "";
    setInformationText += "Set ID: ${_selectedSet?.getSetID()}\n";
    setInformationText += "Year: ${_selectedSet?.getYear()}\n";
    setInformationText += "Theme ID: ${_selectedSet?.getThemeID()}\n";
    setInformationText += "Number of Pieces: ${_selectedSet?.getNumPieces()}";

    setInformation.text = setInformationText;

    _setViewDiv?.append(setInformation);

    DivElement setButtonsDiv = new DivElement();
    setButtonsDiv.id = "pvSetButtonsDiv";
    _setViewDiv?.append(setButtonsDiv);

    ButtonElement editPiecesButton = new ButtonElement();
    editPiecesButton.text = "Edit Missing Pieces";
    editPiecesButton.id = "pvEditPiecesBtn";
    editPiecesButton.classes.add("mainBtn");
    editPiecesButton.onClick.listen((event) {
      EditPiecesState? newState = _app.getState(DisplayStateType.EDIT_PIECES) as EditPiecesState?;
      newState?.setSelectedSet(_selectedSet!);
      _app.setCurrentState(DisplayStateType.EDIT_PIECES);
    });

    setButtonsDiv.append(editPiecesButton);

    ButtonElement removeSetButton = new ButtonElement();
    removeSetButton.text = "Remove Set";
    removeSetButton.id = "pvRemoveSetBtn";
    removeSetButton.classes.add("mainBtn");
    removeSetButton.onClick.listen((event) {
      _showDeletionConfirm();
    });

    setButtonsDiv.append(removeSetButton);
  }

  void _showDeletionConfirm() {
    _deleteConfirmationDiv?.classes.add("pvDeleteConfirmationAnim");
    // Because CSS is dumb and limited
    _deleteConfirmationDiv?.style.top = "-" + _deleteConfirmationDiv!.offsetHeight.toString() + "px";
  }

  void _hideDeletionConfirm() {
    // Because CSS is still dumb and limited
    _deleteConfirmationDiv?.style.top = "-" + _deleteConfirmationDiv!.offsetHeight.toString() + "px";
    _deleteConfirmationDiv?.getAnimations()[0].reverse();

    _deleteConfirmationDiv
        ?.getAnimations()[0]
        .finished
        .then((value) => {_deleteConfirmationDiv?.classes.remove("pvDeleteConfirmationAnim")});
  }

  void _deleteCurrentSet() {
    _app.getProject()?.removeSet(_selectedSet!.getSetID());
    _selectedSet = null;
    renderToDiv(_divRenderingTo!.id);
  }

  void onActivate() {
    if (_selectedSet != null && _selectedSet?.getParentProject() != _app.getProject()) {
      _selectedSet = null;
    }
  }

  void onDeactivate() {}
}
