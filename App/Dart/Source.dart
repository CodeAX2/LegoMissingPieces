import 'RebrickableAccess.dart';
import 'dart:html';
import 'LegoSet.dart';
import 'LegoPiece.dart';
import 'LegoSetProject.dart';

int main() {
  ButtonElement submitButton = document.getElementById("inputButton");
  submitButton.addEventListener("click", (event) {
    TextInputElement apiInput = document.getElementById("apiInput");
    //LegoSetProject project = LegoSetProject.createNewProject("TestProject.json", apiInput.value);
    //project.addNewSet("8634-1").then((value) => project.saveProject());
  });

  LegoSetProject project = new LegoSetProject("TestProject.json");
  project.loadProject().then((value) => print(project.getSets()[0].getPiecesOwned()));

  return 0;
}
