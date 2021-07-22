import 'RebrickableAccess.dart';
import 'dart:html';
import 'LegoSet.dart';
import 'LegoPiece.dart';
import 'LegoSetProject.dart';

int main() {
  LegoSetProject project = new LegoSetProject("TestProject.lego");
  project.loadProject();

  ButtonElement submitButton = document.getElementById("inputButton");
  submitButton.addEventListener("click", (event) {
    TextInputElement apiInput = document.getElementById("apiInput");
    RebrickableAccess apiAccess = new RebrickableAccess(apiInput.value);

    TextInputElement searchInput = document.getElementById("searchInput");
    String search = searchInput.value;
    if (search != "") {
      LegoSet.searchSets(search, apiAccess).then((value) {
        if (value != null) {
          DivElement searchResultsElement = document.getElementById("searchResults");
          searchResultsElement.children.clear();

          int numSets = value["count"];
          dynamic results = value["results"];

          for (int i = 0; i < numSets; i++) {
            dynamic curSet = results[i];
            String curID = curSet["set_num"];
            String curImageURL = curSet["set_img_url"];

            Element setTag = Element.a();
            setTag.text = curID;
            setTag.onClick.listen((event) {
              LegoSet set = new LegoSet(curID, null);
              set.loadSet(apiAccess).then((value) {
                Map<LegoPiece, int> pieces = set.getPieces();
                for (LegoPiece key in pieces.keys) {
                  key.getImageURL().then((value) {
                    if (value != null) print(value + ":" + pieces[key].toString());
                  });
                }
              });
            });

            searchResultsElement.children.add(setTag);

            ImageElement img = new ImageElement();
            img.src = curImageURL;
            img.classes.add("setImages");

            searchResultsElement.children.add(img);
          }
        }
      });
    }
  });

  return 0;
}
