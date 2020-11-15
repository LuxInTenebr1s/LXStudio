public static class NeoPenta extends NeoModel {
  public final static float LED_PITCH = METER / 60 * 3;

  public final static int CHORD_COUNT = 5;
  public final static float CHORD_ANGLE = TWO_PI / 5.0;
  public final static float CHORD_STARTING_ANGLE = -TWO_PI / 4.0;

  public final Circle circle;
  public final Star star;

  NeoPenta(JSONObject config) {
    super(new Fixture(config));
    Fixture f = (Fixture)this.fixtures.get(0);

    circle = f.circle;
    star = f.star;

    view = new View(this);
    update();
  }

  void addDatagrams(LXDatagramOutput output) {
    circle.addDatagrams(output);
    star.addDatagrams(output);
  }

  public static class Fixture extends NeoModel.Fixture {

    public static float circleLen;

    public final Circle circle;
    public final Star star;

    Fixture(JSONObject config) {
      super(config);

      circleLen = (float)config.getDouble("circleLen") * METER;
      float radius = circleLen / TWO_PI;

      JSONObject confCircle = config.getJSONObject("circle");
      circle = new Circle(confCircle, radius);
      addPoints(circle);

      JSONObject confStar = config.getJSONObject("star");
      star = new Star(confStar, radius);
      addPoints(star);
    }
  }

  public static class View extends UI3dComponent {
    NeoPenta model;
    View(NeoPenta model) {
      this.model = model;
    }
    @Override
    protected void onDraw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
      model.circle.draw(ui, pg);

      for (Chord c : model.star.chords) {
        c.draw(ui, pg);
      }
    }
  }

  public static class Circle extends NeoModel {
    public final float radius;

    Circle(JSONObject config, float radius) {
      super(new Fixture(config, radius));

      Fixture f = (Fixture)this.fixtures.get(0);
      this.radius = radius;
    }

    void draw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
      pg.stroke(#966F33);
      pg.line(0, -radius, 0, 0, radius, 0);
      pg.line(-radius, 0, 0, radius, 0, 0);
    }

    private static class Fixture extends NeoModel.Fixture {
      Fixture(JSONObject config, float radius) {
        super(config);
        int ledCount = (int)(radius * TWO_PI / LED_PITCH);
        float ledArc = TWO_PI / ledCount;

        for (int i = 0; i < ledCount; i++) {
            float angle = CHORD_STARTING_ANGLE - (ledArc * i);

            LXPoint point = new LXPoint(cos(angle) * radius, sin(angle) * radius, 0.0);
            addPoint(point);
        }
      }
    }
  }

  public static class Star extends NeoModel {
    public final List<Chord> chords;
    public final float radius;

    Star(JSONObject config, float radius) {
      super(new Fixture(config, radius));

      Fixture f = (Fixture)this.fixtures.get(0);

      this.radius = radius;
      this.chords = Collections.unmodifiableList(f.chords);
    }

    private static class Fixture extends NeoModel.Fixture {
      public final List<Chord> chords = new ArrayList<Chord>();

      Fixture(JSONObject config, float radius) {
        super(config);

        for (int i = 0; i < CHORD_COUNT; i++) {
            Chord chord = new Chord(radius, i);
            chords.add(chord);

            addPoints(chord);
        }
      }
    }
  }

  public static class Chord extends LXModel {
    public final LXVector chordStart, chord, chordStep;
    public final int index;

    Chord(float radius, int index) {
      super(new Fixture(radius, index));

      Fixture f = (Fixture)this.fixtures.get(0);
      this.index = index;
      this.chordStart = f.chordStart;
      this.chord = f.chord;
      this.chordStep = f.chordStep;
    }

    void draw(heronarts.p3lx.ui.UI ui, PGraphics pg) {
      pg.stroke(#966F33);
      pg.line(chordStart.x + chord.x, chordStart.y + chord.y, 0.0,
              chordStart.x, chordStart.y, 0.0);
}

    private static class Fixture extends LXAbstractFixture {
      public final LXVector chordStart, chord, chordStep;

      Fixture(float radius, int index) {
        float x, x1, y, y1;
        int off = index * 2 % 5 * (-1);

        x = radius * cos(CHORD_STARTING_ANGLE - (off * CHORD_ANGLE));
        y = radius * sin(CHORD_STARTING_ANGLE - (off * CHORD_ANGLE));
        x1 = radius * cos(CHORD_STARTING_ANGLE - ((off - 2) * CHORD_ANGLE));
        y1 = radius * sin(CHORD_STARTING_ANGLE - ((off - 2) * CHORD_ANGLE));

        chordStart = new LXVector(x, y, 0.0);
        chord = new LXVector(x1, y1, 0.0).sub(chordStart);
        chordStep = chord.copy().normalize().mult(LED_PITCH);

        for (int i = 0; i < (chord.mag() / LED_PITCH); i++) {
          LXPoint p = new LXPoint(chordStart.copy().add(chordStep.copy().mult(i)));
          addPoint(p);
        }
      }
    }
  }
}



