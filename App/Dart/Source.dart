import 'LegoSetProject.dart';
import 'App.dart';
import 'DisplayState.dart';

int main() {
  App app = new App();
  app.setCurrentState(DisplayStateType.OPEN_PROJECT);

  //LegoSetProject project = new LegoSetProject("TestProject.json");
  //project.loadProject().then((value) {
  //  app.setCurrentState(DisplayStateType.PROJECT_VIEW);
  //});

  //app.setProject(project);

  return 0;
}
