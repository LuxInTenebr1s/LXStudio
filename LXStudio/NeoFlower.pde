public static class NeoFlower extends NeoModel {
  public final static float R_BASE = 0 * METER;
  public final static float LED_PITCH = METER / 48 * 3;

  public static float petalNum, petalSideLen, petalBendAngle, budSideLen, budOpeningAngle;

  public final List<Petal> petals;

  NeoFlower(JSONObject config) {
    super(new Fixture(config));
    Fixture f = (Fixture)this.fixtures.get(0);
    petals = Collections.unmodifiableList(f.petals);
    view = new View(this);
    update();
  }

  public static class Fixture extends NeoModel.Fixture {
    public final List<Petal> petals = new ArrayList<Petal>();

    Fixture(JSONObject config) {
      super(config);

      petalNum        = config.getInt("petalNum");
      petalSideLen    = (float)config.getDouble("petalSideLen")    * METER;
      petalBendAngle  = (float)config.getDouble("petalBendAngle")  * (TWO_PI / 360.0);
      budSideLen      = (float)config.getDouble("budSideLen")      * METER;
      budOpeningAngle = (float)config.getDouble("budOpeningAngle") * (TWO_PI / 360.0);

      JSONArray confPetals = config.getJSONArray("petals");
      for (int i = 0; i < petalNum; i++) {
        Petal p = new Petal(confPetals.getJSONObject(i), i);
        petals.add(p);
        addPoints(p);
      }
    }
  }

  public static class View extends UI3dComponent {
    NeoFlower model;
    View(NeoFlower model) {
      this.model = model;
    }
    @Override
    protected void onDraw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
      for (Petal p : model.petals) {
        p.up.draw(ui, pg);
        p.down.draw(ui, pg);
      }
    }
  }

  public static class Petal extends NeoModel {
    public final int petalIdx;
    public final PetalSide down, up;

    Petal(JSONObject config, int petalIdx) {
      super(new Fixture(config, petalIdx));
      this.petalIdx = petalIdx;

      Fixture f = (Fixture)this.fixtures.get(0);
      up = f.up;
      down = f.down;
    }

    private static class Fixture extends NeoModel.Fixture {
      public final PetalSide down, up;

      Fixture(JSONObject config, int petalIdx) {
        super(config);
        up = new PetalSide(petalIdx, PetalSide.Orientation.UP);
        addPoints(up);
        down = new PetalSide(petalIdx, PetalSide.Orientation.DOWN);
        addPoints(down);
      }
    }
  }

  public static class PetalSide extends LXModel {
    public final int petalIdx;
    public enum Orientation { UP, DOWN };
    public final Orientation orient;

    public final LXVector pBase, pBend, pTop;

    PetalSide(int petalIdx, Orientation orient) {
      super(new Fixture(petalIdx, orient));
      Fixture f = (Fixture)this.fixtures.get(0);

      this.petalIdx = petalIdx;
      this.orient = orient;

      this.pBase = f.pBase;
      this.pBend = f.pBend;
      this.pTop = f.pTop;
    }

    void draw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
      pg.stroke(#966F33);
      pg.line(pBase.x, pBase.y, pBase.z,
              pBend.x, pBend.y, pBend.z);

      pg.line(pBend.x, pBend.y, pBend.z,
              pTop.x,  pTop.y,  pTop.z);
    }

    private static class Fixture extends LXAbstractFixture {
      public final LXVector pBase, pBend, pTop;

      Fixture(int idx, Orientation orient) {
        float petalArc = TWO_PI / petalNum;

        float shift;
        if (orient == Orientation.UP)
          shift = 0;
        else
          shift = petalArc;

        // Length of normal vector from Z-axe to flower bending line; derived from equation system analytically.
        float bendNormalLen = budSideLen/sqrt(1.0/(tan(budOpeningAngle)*tan(budOpeningAngle)) + 1.0/(cos(petalArc/2)*cos(petalArc/2)));
        // Bud triangle median length
        float budMedianLen = bendNormalLen/sin(budOpeningAngle);
        // Bud height vector length
        float budHeightLen = cos(budOpeningAngle)*budMedianLen;
        // Bud side proection vector length on XY-plane
        float budProecLen = bendNormalLen/cos(petalArc/2.0);

        LXVector bendLine = new LXVector(bendNormalLen, 0, 0).rotate(petalArc/2).sub(budProecLen, 0, 0).rotate(petalArc*idx);
        float petalMedianLen = sqrt(petalSideLen*petalSideLen - bendLine.magSq());

        // All the petals have common 'base' point
        pBase = new LXVector(0, 0, R_BASE);

        // Calculate 'bend' position which is intersection point between bud side and petal side
        pBend = new LXVector(0, 0, R_BASE).add(budProecLen, 0, budHeightLen).rotate(petalArc*idx + shift);

        // Rotate petal around bend line to get desired bend angle
        pTop = new LXVector(petalMedianLen, 0, R_BASE).rotate(petalBendAngle, 0, 1, 0).add(bendNormalLen, 0, budHeightLen);
        // Rotate petal arount Z-axe
        pTop.rotate(petalArc*(idx+0.5));

        int count;
        LXVector pLed, pitch;

        count = (int)((budSideLen) / LED_PITCH);
        pitch = pBend.copy().sub(pBase).normalize().mult(LED_PITCH);
        pLed = pBase.copy();
        // Add some orientation bias so diodes don't overlap
        pLed.add(pBend.copy().set(pBend.x, pBend.y, 0).rotate(TWO_PI/4).normalize().mult(0.5*CM).mult(orient == Orientation.UP ? 1 : -1));
        while (count-- > 0) {
          LXPoint p = new LXPoint(pLed);
          addPoint(p);
          pLed.add(pitch);
        }

        count = (int)((petalSideLen + (budSideLen % LED_PITCH)) / LED_PITCH);
        pitch = pTop.copy().sub(pBend).normalize().mult(LED_PITCH);
        pLed = pBend.copy().add(pitch.copy().normalize().mult(budSideLen % LED_PITCH));
        // Add some orientation bias so diodes don't overlap
        pLed.add(pitch.copy().normalize().mult(0.5*CM));
        while (count-- > 0) {
          LXPoint p = new LXPoint(pLed);
          addPoint(p);
          pLed.add(pitch);
        }
      }
    }
  }

  public static class Segment {
    int led;
    PetalSide side;
    Segment(int led, PetalSide side) {
        this.led = led;
        this.side = side;
    }
  }
}
