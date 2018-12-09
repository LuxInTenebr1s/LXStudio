public static class EmpathyTree extends NeoModel {
  public final static float R_BASE = 1.5 * METER;
  public final static float R_TOP = 0.8 * METER;
  public final static int LOOPS = 3;
  public final static int STEP = 3;
  public final static int FEET_NUM = STEP * LOOPS;

  public final List<Loop> loops;

  EmpathyTree(JSONObject config) {
    super(new Fixture(config));
    Fixture f = (Fixture)this.fixtures.get(0);
    loops = f.loops;
    view = new View(this);
    update();
  }

  void addDatagrams(LXDatagramOutput output) {
    for (Loop l : loops) {
      l.addDatagrams(output);
    }
  }

  public static class Fixture extends NeoModel.Fixture {
    // TODO: get these from config?
    public final List<Loop> loops = new ArrayList<Loop>();

    Fixture(JSONObject config) {
      super(config);

      JSONArray confLoops = config.getJSONArray("loops");
      for (int i = 0; i < LOOPS; i++) {
        Loop l = new Loop(confLoops.getJSONObject(i), i);
        loops.add(l);
        addPoints(l);
      }
    }
  }

  public static class View extends UI3dComponent {
    EmpathyTree model;
    View(EmpathyTree model) {
      this.model = model;
    }
    @Override
    protected void onDraw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
      for (Loop l : model.loops) {
        for (BeamPair p : l.pairs) {
          p.left.draw(ui, pg);
          p.right.draw(ui, pg);
        }
      }
    }
  }

  public static class Loop extends NeoModel {
    public final List<BeamPair> pairs;
    public final List<Beam> beams = new ArrayList<Beam>();

    Loop(JSONObject config, int loopIdx) {
      super(new Fixture(config, loopIdx));

      Fixture f = (Fixture)this.fixtures.get(0);
      pairs = f.pairs;

      for (BeamPair p : pairs) {
        beams.add(p.left);
        beams.add(p.right);
      }
    }

    void addDatagrams(LXDatagramOutput output) {
      for (BeamPair p : pairs) {
        p.addDatagrams(output);
      }
    }

    private static class Fixture extends NeoModel.Fixture {
      public final List<BeamPair> pairs = new ArrayList<BeamPair>();

      Fixture(JSONObject config, int loopIdx) {
        super(config);

        JSONArray confPairs = config.getJSONArray("pairs");
        for (int i = 0; i < STEP; i++) {
          BeamPair bp = new BeamPair(confPairs.getJSONObject(i), loopIdx + i*STEP);
          pairs.add(bp);
          addPoints(bp);
        }
      }
    }
  }

  public static class BeamPair extends NeoModel {
    public final Beam left, right;

    BeamPair(JSONObject config, int pairIdx) {
      super(new Fixture(config, pairIdx));
      Fixture f = (Fixture)this.fixtures.get(0);
      left = f.left;
      right = f.right;
    }

    private static class Fixture extends NeoModel.Fixture {
      public final Beam left, right;

      Fixture(JSONObject config, int pairIdx) {
        super(config);
        left = new Beam(pairIdx, Beam.Orientation.LEFT);
        addPoints(left);
        right = new Beam(pairIdx, Beam.Orientation.RIGHT);
        addPoints(right);
      }
    }
  }

  public static class Beam extends LXModel {
    public final int pairIdx;
    public enum Orientation { LEFT, RIGHT };
    public final Orientation orient;

    public final LXVector pBase, pTop;

    Beam(int pairIdx, Orientation orient) {
      super(new Fixture(pairIdx, orient));
      Fixture f = (Fixture)this.fixtures.get(0);
      this.pairIdx = pairIdx;
      this.orient = orient;
      this.pBase = f.pBase;
      this.pTop = f.pTop;
    }

    void draw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
      //final static int RES = 6;
      pg.stroke(#966F33);
      pg.line(
          pBase.x, pBase.y, pBase.z,
          pTop.x, pTop.y, pTop.z
          );
    }

    private static class Fixture extends LXAbstractFixture {
      public final static float BEAM_LENGTH = 4.2 * METER;
      public final static float LED_STRIP_LENGTH = 5 * METER / 2;
      public final static float LED_PITCH = METER / 48 * 3;

      public final LXVector pBase, pTop;

      Fixture(int idx, Orientation orient) {
        int step;
        if (orient == Orientation.RIGHT) {
          step = STEP;
        } else {
          step = -STEP;
        }

        // calculate positions of beam ends
        // "Base" end position is simple
        pBase = new LXVector(R_BASE, 0, 0).rotate(TWO_PI/FEET_NUM*idx);

        // "Top" is more complicated. First, find the position of the top point
        // projection to the base plane, with a similar method as Base, but
        // rotated.
        pTop = new LXVector(R_TOP, 0, 0).rotate(TWO_PI/FEET_NUM*(idx+step));
        // Then, calculate Z position of the top point using some trigonometry
        pTop.add(0, 0, sqrt(BEAM_LENGTH*BEAM_LENGTH - pTop.copy().sub(pBase).magSq()));

        int count = (int)(LED_STRIP_LENGTH/LED_PITCH);
        LXVector pitch = pTop.copy().sub(pBase).normalize().mult(LED_PITCH);

        LXVector pLed;
        if (orient == Orientation.RIGHT) {
          pLed = pTop.sub(pitch.copy().mult(count));
        }
        else {
          pLed = pTop;
          pitch = pitch.mult(-1);
        }
        println("Beam", idx, ": base", pBase, "top", pTop);

        for (int i = 0; i < count; i++) {
          LXPoint p = new LXPoint(pLed);
          addPoint(p);
          pLed.add(pitch);
        }
      }
    }
  }


}


