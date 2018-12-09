public class UISimulation extends UI3dComponent {
  
  UISimulation() {
    for (NeoModel obj : model.objects.values()) {
      if (obj.view != null) {
        addChild(obj.view);
      }
    }
  }
}
