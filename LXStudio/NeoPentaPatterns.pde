public abstract static class NeoPentaPattern extends NeoPattern {
  public final NeoPenta penta;
  public NeoPentaPattern(LX lx) {
    super(lx, "penta");
    penta = (NeoPenta)getObject("penta");
  }
}

@LXCategory("NeoPenta")
public static class NeoPentaGradient extends NeoGradientPattern {
  GradientPattern gradient;
  public NeoPentaGradient(LX lx) {
    super(lx, "penta");
  }
}

@LXCategory("NeoPenta Form")
public static class NeoPentaSpiralPattern extends NeoPentaPattern {
  public enum Orientation { IN, OUT };
  public final CompoundParameter speed = new CompoundParameter("Speed", 10, 1, 100)
    .setDescription("Speed");

  public final CompoundParameter width = new CompoundParameter("Width", .4, 0, 1)
    .setDescription("Thickness");

  public final CompoundParameter offset = new CompoundParameter("Offset", 0, -1, 1)
    .setDescription("Offest");

  public final EnumParameter<Orientation> direction = new EnumParameter<Orientation>("Direction", Orientation.IN).setDescription("Direction");

  public NeoPentaSpiralPattern(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("width", this.width);
    addParameter("offset", this.offset);
    addParameter("direction", this.direction);
  }

  private final LXModulator pos = startModulator(new SawLFO(0, 1, new FunctionalParameter() {
    @Override
    public double getValue() {
      return (10000 / speed.getValue());
    }
  }));
  @Override
    public void run(double deltaMs) {
      int chordSize = penta.CHORD_LEDS_NUM;
      int starSize = chordSize * penta.CHORD_COUNT;

      for (int i = 0; i < starSize; i++) {
        int idx = i / chordSize;
        int posOffShift = (int)(this.offset.getValuef() * chordSize / 5) + chordSize;

        int pos = int(this.pos.getValuef() * chordSize) + idx * posOffShift;
        int posNext = (pos + posOffShift) % starSize;
        int posPrev = (pos > posOffShift) ? (pos - posOffShift) : (pos - posOffShift + starSize);

        int distCurrent = abs(i - pos);
        int distNext = min(abs(i - posNext), abs(abs(i - posNext) - starSize));
        int distPrev = min(abs(i - posPrev), abs(abs(i - posPrev) - starSize));

        int distMin = min(min(distCurrent, distNext), distPrev);

        LXPoint p = penta.star.chords.get(idx).points[i % chordSize];
        colors[p.index] = LXColor.gray(max(0, 100 - distMin / this.width.getValuef()));
      }
    }
}

@LXCategory("NeoPenta Form")
public static class NeoPentaSplashPattern extends NeoPentaPattern {
  public final CompoundParameter speed = new CompoundParameter("Speed", 10, 1, 100)
    .setDescription("Speed");

  public final CompoundParameter radius = new CompoundParameter("Radius", 0.8, 0, 1)
    .setDescription("Radius");

  public final CompoundParameter fade = new CompoundParameter("Fade", 0.5, 0, 1)
    .setDescription("Fade");

  public final GradientPattern gr;
  public final LXPalette pal;

  public NeoPentaSplashPattern(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("radius", this.radius);
    addParameter("fade", this.fade);
    gr = new GradientPattern(lx);
//    sw = new LXSwatch(lx);

    pal = new LXPalette(lx);
//    pal.setSwatch(sw);
  }

  public final Random rand = new Random();
  public final float max_radius = 5 * METER / TWO_PI;

  public float x_pos;
  public float y_pos;
  public float curr_radius;
  public boolean update_coord = true;

  private final LXModulator pos = startModulator(new SawLFO(0, 1, new FunctionalParameter() {
    @Override
    public double getValue() {
      return (10000 / speed.getValue());
    }
  }));
  @Override
    public void run(double deltaMs) {
      float two_rad = this.max_radius * 2;

      if (this.update_coord == true) {
        float y_range;
        this.x_pos = this.max_radius - this.rand.nextFloat() * two_rad;

        y_range = sqrt((float)(Math.pow(this.max_radius, 2) - Math.pow(this.x_pos, 2)));
        this.y_pos = y_range - this.rand.nextFloat() * 2 * y_range;

        this.update_coord = false;
        this.curr_radius = 0;
      }

      this.curr_radius += (this.speed.getValuef() * two_rad) / 100;

      for (int i = 0; i < penta.size; i++) {
        LXPoint p = penta.points[i];
        LXVector r;
        float dist;

        r = new LXVector(this.x_pos - p.x, this.y_pos - p.y, 0.0);

        if (r.mag() <= this.curr_radius) {
          colors[p.index] = LXColor.gray(max(0, 100 - (this.curr_radius - r.mag()) / this.fade.getValuef()));
        } else {
          colors[p.index] = this.pal.getColor();
//          colors[p.index] = 0xFF000000;
        }
      }

      if (this.curr_radius > (two_rad * this.radius.getValuef())) {
        this.update_coord = true;
      }
   }
}
