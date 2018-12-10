public static class EmpathyTree extends NeoModel {
  public final static float R_BASE = 1.5 * METER;
  public final static float R_TOP = 0.8 * METER;
  public final static int LOOPS = 3;
  public final static int STEP = 3;
  public final static int FEET_NUM = STEP * LOOPS;
  public final static float BEAM_LENGTH = 4.2 * METER;
  public final static float LED_STRIP_LENGTH = 5 * METER / 2;
  public final static float LED_PITCH = METER / 48 * 3;
  public final static int LEDS_PER_BEAM = floor(LED_STRIP_LENGTH/LED_PITCH);


  public final List<Loop> loops;

  EmpathyTree(JSONObject config) {
    super(new Fixture(config));
    Fixture f = (Fixture)this.fixtures.get(0);
    loops = Collections.unmodifiableList(f.loops);
    view = new View(this);
    update();

    for (Loop l : loops) {
      l.printNeighbours();
    }
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
      for (int i = 0; i < 3; i++) {
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
    public final int loopIdx;
    public final List<BeamPair> pairs;
    public final List<Beam> beams = new ArrayList<Beam>();

    Loop(JSONObject config, int loopIdx) {
      super(new Fixture(config, loopIdx));

      Fixture f = (Fixture)this.fixtures.get(0);
      pairs = Collections.unmodifiableList(f.pairs);
      this.loopIdx = loopIdx;

      for (BeamPair p : pairs) {
        beams.add(p.left);
        beams.add(p.right);
      }

      for (int i = 0; i < pairs.size(); i++) {
        BeamPair p = pairs.get(i);
        BeamPair next = pairs.get(modulo(i-1, STEP));
        BeamPair prev = pairs.get(modulo(i+1, STEP));

      }
    }

    void printNeighbours() {
      println("Loop", loopIdx);
      for (BeamPair p : pairs) {
        p.printNeighbours();
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
        }

        for (int i = 0; i < STEP; i++) {
          BeamPair p = pairs.get(i);
          BeamPair next = pairs.get(modulo(i+1, STEP));
          BeamPair prev = pairs.get(modulo(i-1, STEP));
          p.left.nBase = p.right;
          p.left.nTop = next.right;
          p.right.nBase = p.left;
          p.right.nTop = prev.left;
          addPoints(p.right);
          addPoints(p.right.nTop);
        }
      }
    }
  }

  public static class BeamPair extends NeoModel {
    public final int pairIdx;
    public final Beam left, right;

    BeamPair(JSONObject config, int pairIdx) {
      super(new Fixture(config, pairIdx));
      this.pairIdx = pairIdx;
      Fixture f = (Fixture)this.fixtures.get(0);
      left = f.left;
      right = f.right;
    }

    void printNeighbours() {
      println("  BeamPair", pairIdx);
      println("    Left:");
      left.printNeighbours();
      println("    Right:");
      right.printNeighbours();
    }

    private static class Fixture extends NeoModel.Fixture {
      public final Beam left, right;

      Fixture(JSONObject config, int pairIdx) {
        super(config);
        left = new Beam(pairIdx, Beam.Orientation.LEFT);
        addPoints(left);
        right = new Beam(pairIdx, Beam.Orientation.RIGHT);
        addPoints(right);
        left.nBase = right;
        right.nBase = left;
      }
    }
  }

  public static class Beam extends LXModel {
    public final int pairIdx;
    public enum Orientation { LEFT, RIGHT };
    public final Orientation orient;

    public final LXVector pBase, pTop;
    public Beam nBase, nTop;
    public Beam nLedBase, nLedTop;

    Beam(int pairIdx, Orientation orient) {
      super(new Fixture(pairIdx, orient));
      Fixture f = (Fixture)this.fixtures.get(0);
      this.pairIdx = pairIdx;
      this.orient = orient;
      this.pBase = f.pBase;
      this.pTop = f.pTop;
    }

    void printNeighbours() {
      println("      len:", size, "base:", nBase.pairIdx, "top:", nTop.pairIdx);
    }

    void draw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
      //final static int RES = 6;
      pg.stroke(#966F33);
      pg.line(
          pBase.x, pBase.y, pBase.z,
          pTop.x, pTop.y, pTop.z
          );

      pg.text(pairIdx, pBase.x, pBase.y, pBase.z - 10 * CM);
    }

    private static class Fixture extends LXAbstractFixture {
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
        if (orient == Orientation.LEFT) {
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


