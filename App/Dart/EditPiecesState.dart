part of DisplayState;

class EditPiecesState extends DisplayState {
  LegoSet _selectedSet;
  DivElement _divRenderingTo;

  EditPiecesState(App app) : super(app) {
    _app.registerState(DisplayStateType.EDIT_PIECES, this);
  }

  void renderToDiv(String divID) {
    _divRenderingTo = document.getElementById(divID);
    _divRenderingTo.children.clear();

    DivElement piecesListHeadersDiv = new DivElement();
    piecesListHeadersDiv.id = "epPiecesListHeadersDiv";
    _divRenderingTo.append(piecesListHeadersDiv);

    HeadingElement piecesImageHeader = HeadingElement.h1();
    piecesImageHeader.text = "Piece Image";
    piecesImageHeader.id = "epPiecesImageHeader";
    piecesListHeadersDiv.append(piecesImageHeader);

    HeadingElement piecesIdHeader = HeadingElement.h1();
    piecesIdHeader.text = "Piece ID";
    piecesIdHeader.id = "epPiecesIdHeader";
    piecesListHeadersDiv.append(piecesIdHeader);

    HeadingElement piecesColorIdHeader = HeadingElement.h1();
    piecesColorIdHeader.text = "Color Name";
    piecesColorIdHeader.id = "epPiecesColorIdHeader";
    piecesListHeadersDiv.append(piecesColorIdHeader);

    HeadingElement piecesOwnedHeader = HeadingElement.h1();
    piecesOwnedHeader.text = "Number Owned";
    piecesOwnedHeader.id = "epPiecesOwnedHeader";
    piecesListHeadersDiv.append(piecesOwnedHeader);

    HeadingElement piecesSetHeader = HeadingElement.h1();
    piecesSetHeader.text = "Number In Set";
    piecesSetHeader.id = "epPiecesSetHeader";
    piecesListHeadersDiv.append(piecesSetHeader);

    DivElement piecesListDiv = new DivElement();
    piecesListDiv.id = "epPiecesListDiv";
    _divRenderingTo.append(piecesListDiv);

    List<LegoPiece> allPieces = _selectedSet.getPieces().keys.toList();

    for (LegoPiece piece in allPieces) {
      DivElement pieceListItemDiv = new DivElement();
      pieceListItemDiv.classes.add("epPieceListItemDiv");
      piecesListDiv.append(pieceListItemDiv);

      ImageElement pieceImage = new ImageElement();
      pieceImage.classes.add("epPieceImage");
      piece.getImageURL().then((value) {
        if (value == null) {
          // Use a random question mark image
          pieceImage.src =
              "https://t3.ftcdn.net/jpg/03/35/13/14/360_F_335131435_DrHIQjlOKlu3GCXtpFkIG1v0cGgM9vJC.jpg";
        } else {
          pieceImage.src = value;
        }
      });
      piece.getDescription().then((value) => pieceImage.title = value);
      pieceListItemDiv.append(pieceImage);

      HeadingElement pieceIdTitle = HeadingElement.h1();
      pieceIdTitle.classes.add("epPieceIdTitle");
      pieceIdTitle.text = piece.getPartID();
      pieceListItemDiv.append(pieceIdTitle);

      HeadingElement pieceColorIdTitle = HeadingElement.h1();
      pieceColorIdTitle.classes.add("epPieceColorIdTitle");
      pieceColorIdTitle.text = piece.getColorName().toString();
      pieceListItemDiv.append(pieceColorIdTitle);

      DivElement pieceOwnedAmountInput = new DivElement();
      pieceOwnedAmountInput.classes.add("epPieceOwnedAmountInput");
      pieceListItemDiv.append(pieceOwnedAmountInput);

      HeadingElement pieceOwnedAmountTitle = HeadingElement.h1();
      pieceOwnedAmountTitle.classes.add("epPieceOwnedAmountTitle");
      pieceOwnedAmountTitle.text =
          _selectedSet.getAmountOwned(piece).toString();

      ButtonElement pieceOwnedAmountDown = new ButtonElement();
      pieceOwnedAmountDown.classes.add("epPieceOwnedAmountDownBtn");
      pieceOwnedAmountDown.text = "-";
      pieceOwnedAmountDown.onClick.listen((event) {
        int amountOwned = max(_selectedSet.getAmountOwned(piece) - 1, 0);
        _selectedSet.setAmountOwned(piece, amountOwned);
        pieceOwnedAmountTitle.text = amountOwned.toString();
      });
      pieceOwnedAmountInput.append(pieceOwnedAmountDown);

      pieceOwnedAmountInput.append(pieceOwnedAmountTitle);

      ButtonElement pieceOwnedAmountUp = new ButtonElement();
      pieceOwnedAmountUp.classes.add("pieceOwnedAmountUpBtn");
      pieceOwnedAmountUp.text = "+";
      pieceOwnedAmountUp.onClick.listen((event) {
        int amountOwned = min(_selectedSet.getAmountOwned(piece) + 1,
            _selectedSet.getAmountInSet(piece));
        _selectedSet.setAmountOwned(piece, amountOwned);
        pieceOwnedAmountTitle.text = amountOwned.toString();
      });
      pieceOwnedAmountInput.append(pieceOwnedAmountUp);

      HeadingElement pieceSetAmountTitle = HeadingElement.h1();
      pieceSetAmountTitle.classes.add("epPieceSetAmountTitle");
      pieceSetAmountTitle.text = _selectedSet.getAmountInSet(piece).toString();
      pieceListItemDiv.append(pieceSetAmountTitle);
    }

    ButtonElement backButton = new ButtonElement();
    backButton.id = "epBackBtn";
    backButton.text = "Back";
    backButton.onClick.listen((event) {
      _app.setCurrentState(DisplayStateType.PROJECT_VIEW);
    });
    _divRenderingTo.append(backButton);
  }

  void onActivate() {}

  void onDeactivate() {
    _selectedSet.getParentProject().saveProject();
  }

  void setSelectedSet(LegoSet set) {
    _selectedSet = set;
  }
}
