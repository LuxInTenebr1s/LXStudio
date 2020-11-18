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
