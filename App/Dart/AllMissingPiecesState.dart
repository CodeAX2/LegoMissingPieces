part of DisplayState;

class AllMissingPiecesState extends DisplayState {
  DivElement? _divRenderingTo;

  AllMissingPiecesState(App app) : super(app) {
    _app.registerState(DisplayStateType.ALL_MISSING_PIECES_VIEW, this);
  }

  void renderToDiv(String divID) {
    _divRenderingTo = document.getElementById(divID) as DivElement?;
    _divRenderingTo?.children.clear();

    Map<LegoPiece, int>? allMissingPieces = _app.getProject()?.getAllMissingPieces();

    DivElement piecesListHeadersDiv = new DivElement();
    piecesListHeadersDiv.id = "ampPiecesListHeadersDiv";
    _divRenderingTo?.append(piecesListHeadersDiv);

    HeadingElement piecesImageHeader = HeadingElement.h1();
    piecesImageHeader.text = "Piece Image";
    piecesImageHeader.id = "ampPiecesImageHeader";
    piecesListHeadersDiv.append(piecesImageHeader);

    HeadingElement piecesIdHeader = HeadingElement.h1();
    piecesIdHeader.text = "Piece ID";
    piecesIdHeader.id = "ampPiecesIdHeader";
    piecesListHeadersDiv.append(piecesIdHeader);

    HeadingElement piecesColorIdHeader = HeadingElement.h1();
    piecesColorIdHeader.text = "Color Name";
    piecesColorIdHeader.id = "ampPiecesColorIdHeader";
    piecesListHeadersDiv.append(piecesColorIdHeader);

    HeadingElement piecesSetHeader = HeadingElement.h1();
    piecesSetHeader.text = "Number Missing";
    piecesSetHeader.id = "ampPiecesAmountHeader";
    piecesListHeadersDiv.append(piecesSetHeader);

    DivElement piecesListDiv = new DivElement();
    piecesListDiv.id = "ampPiecesListDiv";
    _divRenderingTo?.append(piecesListDiv);

    if (allMissingPieces != null) {
      for (LegoPiece piece in allMissingPieces.keys) {
        if (allMissingPieces[piece] == 0) continue;

        DivElement pieceListItemDiv = new DivElement();
        pieceListItemDiv.classes.add("ampPieceListItemDiv");
        piecesListDiv.append(pieceListItemDiv);

        ImageElement pieceImage = new ImageElement();
        pieceImage.classes.add("ampPieceImage");
        piece.getImageURL().then((value) {
          if (value == "") {
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
        pieceIdTitle.classes.add("ampPieceIdTitle");
        pieceIdTitle.text = piece.getPartID();
        pieceListItemDiv.append(pieceIdTitle);

        HeadingElement pieceColorIdTitle = HeadingElement.h1();
        pieceColorIdTitle.classes.add("ampPieceColorIdTitle");
        pieceColorIdTitle.text = piece.getColorName().toString();
        pieceListItemDiv.append(pieceColorIdTitle);

        HeadingElement pieceAmountTitle = HeadingElement.h1();
        pieceAmountTitle.classes.add("ampPieceAmountTitle");
        pieceAmountTitle.text = allMissingPieces[piece].toString();
        pieceListItemDiv.append(pieceAmountTitle);
      }
    }

    ButtonElement backButton = new ButtonElement();
    backButton.id = "ampBackBtn";
    backButton.onClick.listen((event) {
      _app.setCurrentState(DisplayStateType.PROJECT_VIEW);
    });
    ParagraphElement backButtonText = new ParagraphElement();
    backButtonText.append(FontAwesome.GET_ARROW_CIRCLE_LEFT());
    backButtonText.appendText("Back");
    backButton.append(backButtonText);
    _divRenderingTo?.append(backButton);

    ButtonElement bricklinkXMLButton = new ButtonElement();
    bricklinkXMLButton.id = "ampBricklinkXMLBtn";
    bricklinkXMLButton.onClick.listen((event) {
      _app.getProject()?.generateBricklinkXML().then((value) {
        // Copy text to clipboard
        TextAreaElement textarea = new TextAreaElement();
        document.body?.append(textarea);
        textarea.style.border = '0';
        textarea.style.margin = '0';
        textarea.style.padding = '0';
        textarea.style.opacity = '0';
        textarea.style.position = 'absolute';
        textarea.readOnly = true;
        textarea.value = value;
        textarea.select();
        document.execCommand('copy');
        textarea.remove();
      });
    });
    ParagraphElement bricklinkXMLButtonText = new ParagraphElement();
    bricklinkXMLButtonText.appendText("Copy Bricklink XML");
    bricklinkXMLButton.append(bricklinkXMLButtonText);
    _divRenderingTo?.append(bricklinkXMLButton);
  }

  void onActivate() {}

  void onDeactivate() {}
}
