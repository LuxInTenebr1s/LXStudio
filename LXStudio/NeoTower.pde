public static class NeoTower extends NeoModel {
  public final static float R_BASE = 1.5 * METER;
  public final static float R_TOP = 1.5 * METER;
  public final static int LOOPS = 2;
  public final static int STEP = 2;
  public final static int FEET_NUM = STEP * LOOPS;
  public final static float BEAM_LENGTH = 4.2 * METER;
  public final static float LED_STRIP_LENGTH = 5 * METER / 2;
  public final static float LED_PITCH = METER / 48 * 3;
  public final static int LEDS_PER_BEAM = floor(LED_STRIP_LENGTH/LED_PITCH);


  public final List<Loop> loops;
  public final List<BeamPair> pairs;

  NeoTower(JSONObject config) {
    super(new Fixture(config));
    Fixture f = (Fixture)this.fixtures.get(0);
    loops = Collections.unmodifiableList(f.loops);
    view = new View(this);
    update();

    List<BeamPair> pairs_ = new ArrayList<BeamPair>(Collections.nCopies(FEET_NUM, (BeamPair)null));
    for (Loop l : loops) {
      for (BeamPair p : l.pairs) {
        pairs_.set(p.pairIdx, p);
      }
    }
    pairs = Collections.unmodifiableList(pairs_);

    LXVector ref = new LXVector(1, 0, 0);
    for (BeamPair p : pairs) {
      BeamPair nextPair = pairs.get(modulo(p.pairIdx+LOOPS+1, FEET_NUM));
      p.left.nTop = p.right;
      p.right.nTop = p.left;
      p.left.nBase = nextPair.right;
      nextPair.right.nBase = p.left;
      for (int i = 0; i < 2*STEP; i++) {
        BeamPair other = pairs.get(modulo(p.pairIdx + LOOPS + 1 + i, FEET_NUM));
        println("beam", p.left.pairIdx, p.left.orient, "intersects", other.right.pairIdx, other.right.orient);
        p.left.intersect.add(other.right);
        other.right.intersect.add(p.left);
      }
    }
      // find which other.lefts intersect our p.right
    for (BeamPair p : pairs) {
      Beam b = p.right;
      int ledIdx = 0;
      int ledIdxPrev = 0;
      int otherIdx = 1;
      Beam other = b.intersect.get(otherIdx);
      for (ledIdx = 0; ledIdx < min(b.points.length, other.points.length); ledIdx++) {
        if (otherIdx >= b.intersect.size()) {
          break;
        }
        other = b.intersect.get(otherIdx);
        float bAngle = theta(b.points[ledIdx]);
        float otherAngle = theta(other.points[other.points.length - ledIdx -1]);
        //println("pair", p.pairIdx, "bAngle", bAngle, "other", other.pairIdx, "otherAngle", otherAngle);
        if (otherAngle <= bAngle) {
          Segment s = new Segment();
          s.beam = other;
          s.ledFirst = ledIdxPrev;
          s.ledLast = ledIdx;
          b.addSegment(ledIdx, other);
          ledIdxPrev = ledIdx;
          otherIdx++;
        }
      }
      /*
      other = b.intersect.get(otherIdx-1);
      b.addSegment(ledIdx, other);
      other.addSegment(ledIdx, b);
      */

    }
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
      for (int i = 0; i < LOOPS; i++) {
        Loop l = new Loop(confLoops.getJSONObject(i), i);
        loops.add(l);
        addPoints(l);
      }
    }
  }

  public static class View extends UI3dComponent {
    NeoTower model;
    View(NeoTower model) {
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
      println("new Loop", loopIdx);

      Fixture f = (Fixture)this.fixtures.get(0);
      pairs = f.pairs;
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
          BeamPair bp = new BeamPair(confPairs.getJSONObject(i), modulo(loopIdx + i*STEP, FEET_NUM));
          pairs.add(bp);
          addPoints(bp);
        }
      }
    }
  }

  public static class BeamPair extends NeoModel {
    public final int pairIdx;
    public final Beam left, right;

    BeamPair(JSONObject config, int pairIdx) {
      super(new Fixture(config, pairIdx));
      println("new BeamPair", pairIdx);
      this.pairIdx = pairIdx;
      Fixture f = (Fixture)this.fixtures.get(0);
      left = f.left;
      right = f.right;
    }

    void printNeighbours() {
      println("  BeamPair", pairIdx);
      left.printNeighbours();
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
      }
    }
  }

  public static class Beam extends LXModel {
    public final int pairIdx;
    public enum Orientation { LEFT, RIGHT };
    public final Orientation orient;

    public final LXVector pBase, pTop;
    public Beam nBase, nTop;
    public List<Beam> intersect = new ArrayList<Beam>();
    public List<Segment> segments = new ArrayList<Segment>();

    Beam(int pairIdx, Orientation orient) {
      super(new Fixture(pairIdx, orient));
      println("new Beam", pairIdx, orient);
      Fixture f = (Fixture)this.fixtures.get(0);
      this.pairIdx = pairIdx;
      this.orient = orient;
      this.pBase = f.pBase;
      this.pTop = f.pTop;
    }

    void printNeighbours() {
      println("      Beam", pairIdx, orient, ": base", pBase, "top", pTop);
      println("      len:", size, "nBase:", nBase.pairIdx, nBase.orient, "nTop:", nTop.pairIdx, nTop.orient);
      println("      Segments:");
      for (Segment s : segments) {
        println("        led ", s.ledFirst, ":", s.beam.pairIdx, s.beam.orient);
      }
    }

    Segment addSegment(int led, Beam beam) {
      Segment s = new Segment();
      s.ledFirst = led;
      s.beam = beam;
      segments.add(s);
      println("        beam", pairIdx, orient, "segment", led, beam.pairIdx, beam.orient);
      return s;
    }

    void draw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
      //final static int RES = 6;
      pg.stroke(#966F33);
      pg.line(
          pBase.x, pBase.y, pBase.z,
          pTop.x, pTop.y, pTop.z
          );

      if (orient == Orientation.RIGHT) {
        pg.text(pairIdx, pBase.x, pBase.y, pBase.z - 10 * CM);
      }
    }

    private static class Fixture extends LXAbstractFixture {
      public final LXVector pBase, pTop;

      Fixture(int idx, Orientation orient) {
        int step;
        int shift;
        if (orient == Orientation.LEFT) {
          step = STEP;
          shift = STEP;
        } else {
          step = -STEP;
          shift = 0;
        }

        // calculate positions of beam ends
        // "Base" end position is simple
        pBase = new LXVector(R_BASE, 0, 0).rotate(TWO_PI/FEET_NUM*(idx+shift));

        // "Top" is more complicated. First, find the position of the top point
        // projection to the base plane, with a similar method as Base, but
        // rotated.
        pTop = new LXVector(R_TOP, 0, 0).rotate(TWO_PI/FEET_NUM*(idx+shift+step));
        // Then, calculate Z position of the top point using some trigonometry
        pTop.add(0, 0, sqrt(BEAM_LENGTH*BEAM_LENGTH - pTop.copy().sub(pBase).magSq()));

        int count = (int)(LED_STRIP_LENGTH/LED_PITCH);
        LXVector pitch = pTop.copy().sub(pBase).normalize().mult(LED_PITCH);

        LXVector pLed;
        if (orient == Orientation.LEFT) {
          pLed = pTop.copy().sub(pitch.copy().mult(count));
        }
        else {
          pLed = pTop.copy().sub(pitch);
          pitch = pitch.mult(-1);
        }

        for (int i = 0; i < count; i++) {
          LXPoint p = new LXPoint(pLed);
          addPoint(p);
          pLed.add(pitch);
        }
      }
    }
  }

  public static class Segment {
    int ledFirst, ledLast;
    Beam beam;
  }

}


