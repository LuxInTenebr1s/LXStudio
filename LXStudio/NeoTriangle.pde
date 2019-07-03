public static class NeoTriangle extends NeoModel {
  public UI3dComponent view;
  public final static float LED_PITCH = 10 * CM;
  public final static float SIDE_LEN = 80 * CM;
  public final static int SIDE_NUM = 3;
  public final static int LEDS_PER_SIDE = int(SIDE_LEN/LED_PITCH);

  public Side[] sides;

  NeoTriangle(JSONObject config) {
    super(new Fixture(config));
    Fixture f = (Fixture)this.fixtures.get(0);
    sides = f.sides;
    //this.view = new View(f);
  }

  public static class Fixture extends NeoModel.Fixture {
    public Side[] sides;

    Fixture(JSONObject config) {
      super(config);
      sides = new Side[SIDE_NUM];
      for (int i = 0; i < SIDE_NUM; i++) {
        sides[i] = new Side(i);
      }

      for (int i = 0; i < SIDE_NUM; i++) {
        addPoints(sides[i]);
        sides[i].allPoints.add(sides[modulo(i+1, SIDE_NUM)].points[0]);
      }
    }
  }

  public static class Side extends LXModel {
    int idx;
    List<LXPoint> allPoints = new ArrayList<LXPoint>();
    Side(int idx) {
      super(new Fixture(idx));
      this.idx = idx;
      for (LXPoint p : points) {
        allPoints.add(p);
      }
    }

    public static class Fixture extends LXAbstractFixture {
      Fixture(int idx) {
        float rot = PI/3;
        LXVector pLed = new LXVector(sqrt(3)/3*SIDE_LEN, 0, 0).rotate(TWO_PI/SIDE_NUM*idx + rot);
        LXVector pitch = new LXVector(1, 0, 0).rotate(TWO_PI/SIDE_NUM*idx + 5*PI/6 + rot).mult(LED_PITCH);
        for (int i = 0; i < LEDS_PER_SIDE; i++) {
          LXPoint p = new LXPoint(pLed);
          println("point", pLed);
          addPoint(p);
          pLed.add(pitch);
        }
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
