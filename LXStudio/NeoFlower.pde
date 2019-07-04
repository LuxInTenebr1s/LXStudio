public static class NeoFlower extends NeoModel {
  public UI3dComponent view;

  NeoFlower(JSONObject config) {
    super(new Fixture(config));
    this.view = new View((Fixture)this.fixtures.get(0));
  }

  public static class Fixture extends NeoModel.Fixture {
    public final static float PIXEL_SIZE = 10*CM;
    public final static float BEAM_LENGTH = 2.5 * METER;
    public final static float INNER_SIZE = 2 * METER;
    public final static float BETA = PI/6; // random number
    public final static int PETALS = 3;

    private void addSide(LXTransform ctx) {
      for (int pix = 0; pix < BEAM_LENGTH/PIXEL_SIZE; pix++) {
        ctx.translate(PIXEL_SIZE, 0, 0);
        addPoint(new LXPoint(ctx));
      }
    }

    Fixture(JSONObject config) {
      super(config);
      LXTransform ctx = getTransform();
      addPoint(new LXPoint(ctx));
      float rot = asin((INNER_SIZE/2)/BEAM_LENGTH);
      float alpha = PI/3; // FIXME: random number, to lazy for math
      for (int i = 0; i < PETALS; i++) {
        ctx.push();
        ctx.rotateY(alpha);
        // first half
        ctx.push();
        ctx.rotateZ(-rot);
        addSide(ctx);
        ctx.rotateZ(rot);
        ctx.rotateY(-BETA);
        ctx.rotateZ(rot);
        addSide(ctx);
        ctx.pop();

        // second halft
        ctx.push();
        ctx.rotateZ(rot);
        addSide(ctx);
        ctx.rotateZ(-rot);
        ctx.rotateY(-BETA);
        ctx.rotateZ(-rot);
        addSide(ctx);
        ctx.pop();

        ctx.pop();
        ctx.rotateZ(2*PI/PETALS);
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
