public static class NeoHex extends NeoModel {
  public UI3dComponent view;

  NeoHex(JSONObject config) {
    super(new Fixture(config));
    this.view = new View((Fixture)this.fixtures.get(0));
  }

  public static class Fixture extends NeoModel.Fixture {
    public final static float PIXEL_SIZE = 10*CM;
    public final static float RAY_WIDTH = 7*CM;
    public final static int SIDE_NUM = 6;
  
    private void addSide(LXTransform ctx) {
      for (int pix = 0; pix < SIDE_NUM; pix++) {
        ctx.translate(PIXEL_SIZE, 0, 0);
        addPoint(new LXPoint(ctx));
      }
    }
  
    Fixture(JSONObject config) {
      super(config);
      LXTransform ctx = getTransform();
      //addPoint(new LXPoint(ctx));
      ctx.rotateZ(PI);
      for (int i = 0; i < 3; i++) {
        ctx.push();
        ctx.rotateZ(-PI/3);
        ctx.translate(RAY_WIDTH/2, 0);
        ctx.rotateZ(PI/3);
        addSide(ctx);
        ctx.rotateZ(-2*PI/3);
        addSide(ctx);
        ctx.rotateZ(-PI/3);
        addSide(ctx);
        ctx.rotateZ(-2*PI/3);
        addSide(ctx);
        ctx.pop();
        ctx.rotateZ(-2*PI/3);
      }
    }
  }

  public class View extends UI3dComponent {
    private Fixture fixture;
    View(Fixture fixture) {
      this.fixture = fixture;
    }

    public void onDraw(UI ui, PGraphics pg) {
      //int[] colors = lx.getColors();
      for (LXPoint p : fixture.getPoints()) {
        pg.fill(#FFFFFF);
        pg.box(10);
      }
    }
  }
}
