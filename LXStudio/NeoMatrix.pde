public static class NeoMatrix extends NeoModel {
  public UI3dComponent view;
  public final static float LED_PITCH = 6.25 * CM;
  public final static float ROW_LEN = 1000 * CM;
  public final static int ROW_NUM = 9;
  public final static float ROW_PITCH = 10 * CM;
  public final static int LEDS_PER_ROW = int(ROW_LEN/LED_PITCH);

  public Row[] rows;

  NeoMatrix(JSONObject config) {
    super(new Fixture(config));
    Fixture f = (Fixture)this.fixtures.get(0);
    rows = f.rows;
    //this.view = new View(f);
  }

  void addDatagrams(LXDatagramOutput output) {
    for (Row row : rows) {
      row.addDatagrams(output);
    }
  }

  public static class Fixture extends NeoModel.Fixture {
    public Row[] rows;

    Fixture(JSONObject config) {
      super(config);
      JSONArray confRows = config.getJSONArray("rows");

      rows = new Row[ROW_NUM];
      for (int i = 0; i < ROW_NUM; i++) {
        rows[i] = new Row(confRows.getJSONObject(i), i);
      }

      for (int i = 0; i < ROW_NUM; i++) {
        addPoints(rows[i]);
        rows[i].allPoints.add(rows[modulo(i+1, ROW_NUM)].points[0]);
      }
    }
  }

  public static class Row extends NeoModel {
    int idx;
    List<LXPoint> allPoints = new ArrayList<LXPoint>();
    Row(JSONObject config, int idx) {
      super(new Fixture(config, idx));
      this.idx = idx;
      for (LXPoint p : points) {
        allPoints.add(p);
      }
    }

    public static class Fixture extends NeoModel.Fixture {
      Fixture(JSONObject config, int idx) {
        super(config);
        float start_y = ROW_PITCH * (ROW_NUM / 2 - idx);
        LXVector pLed = new LXVector(-ROW_LEN/2, start_y, 0);
        LXVector pitch = new LXVector(1, 0, 0).mult(LED_PITCH);
        for (int i = 0; i < LEDS_PER_ROW; i++) {
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
