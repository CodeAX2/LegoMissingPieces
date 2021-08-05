part of DisplayState;

class ProjectViewState extends DisplayState {
  LegoSet _selectedSet;
  DivElement _setViewDiv;
  DivElement _deleteConfirmationDiv;

  ProjectViewState(App app) : super(app) {
    _app.registerState(DisplayStateType.PROJECT_VIEW, this);
  }

  void renderToDiv(String divID) {
    LegoSetProject project = _app.getProject();

    DivElement divRenderingTo = document.getElementById(divID);
    divRenderingTo.children.clear();

    DivElement parentDiv = new DivElement();
    parentDiv.id = "pvContainerDiv";
    divRenderingTo.append(parentDiv);

    DivElement leftNavDiv = new DivElement();
    leftNavDiv.id = "pvNavDiv";
    parentDiv.append(leftNavDiv);

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

    _setViewDiv = new DivElement();
    _setViewDiv.id = "pvSetViewDiv";
    parentDiv.append(_setViewDiv);

    if (_selectedSet != null) _renderSelectedSet();

    _deleteConfirmationDiv = new DivElement();
    _deleteConfirmationDiv.id = "pvDeleteConfirmationDiv";
  }

  void selectSet(LegoSet set) {
    _selectedSet = set;
    _renderSelectedSet();
  }

  void _renderSelectedSet() {
    _setViewDiv.children.clear();

    ImageElement setImage = new ImageElement();
    setImage.src = _selectedSet.getImageURL();
    _setViewDiv.append(setImage);

    HeadingElement setTitle = HeadingElement.h1();
    setTitle.text = _selectedSet.getName();
    _setViewDiv.append(setTitle);

    ParagraphElement setInformation = new ParagraphElement();

    String setInformationText = "";
    setInformationText += "Set ID: ${_selectedSet.getSetID()}\n";
    setInformationText += "Year: ${_selectedSet.getYear()}\n";
    setInformationText += "Theme ID: ${_selectedSet.getThemeID()}\n";
    setInformationText += "Number of Pieces: ${_selectedSet.getNumPieces()}";

    setInformation.text = setInformationText;

    _setViewDiv.append(setInformation);

    ButtonElement editPiecesButton = new ButtonElement();
    editPiecesButton.text = "Edit Missing Pieces";
    editPiecesButton.id = "pvEditPiecesBtn";
    editPiecesButton.onClick.listen((event) {});

    _setViewDiv.append(editPiecesButton);

    ButtonElement removeSetButton = new ButtonElement();
    removeSetButton.text = "Remove Set";
    removeSetButton.id = "pvRemoveSetBtn";
    removeSetButton.onClick.listen((event) {
      _showDeletionConfirm();
    });

    _setViewDiv.append(removeSetButton);

    _deleteConfirmationDiv.classes.removeWhere((element) => element == "pvDeleteConfirmationAnim");
    _setViewDiv.append(_deleteConfirmationDiv);
  }

  void _showDeletionConfirm() {
    _deleteConfirmationDiv.classes.add("pvDeleteConfirmationAnim");
  }

  void onActivate() {}

  void onDeactivate() {}
}
