public abstract static class NeoFlowerPattern extends NeoPattern {
  public final NeoFlower flower;
  public NeoFlowerPattern(LX lx) {
    super(lx, "flower");
    flower = (NeoFlower)getObject("flower");
  }
}

@LXCategory("NewFlower")
public static class NeoFlowerGradient extends NeoGradientPattern {
  GradientPattern gradient;
  public NeoFlowerGradient(LX lx) {
    super(lx, "flower");
  }
}

@LXCategory("NeoFlower Form")
public static class NeoFlowerTestPattern extends NeoFlowerPattern {
  public enum Mode {
    Flower,
    Petal
  };
  public final EnumParameter<Mode> mode = new EnumParameter<Mode>("Mode", Mode.Flower);
  public final DiscreteParameter petalIdx = new DiscreteParameter("Petal", (int)flower.petalNum);
  public final BooleanParameter up = new BooleanParameter("Up", true);
  public final BooleanParameter down = new BooleanParameter("Down", true);

  public NeoFlowerTestPattern(LX lx) {
    super(lx);
    addParameter("mode", this.mode);
    addParameter("petal", this.petalIdx);
    addParameter("up", this.up);
    addParameter("down", this.down);
  }

  public void run(double deltaMs) {
    Mode mode = this.mode.getEnum();
    int petalIdx = this.petalIdx.getValuei();
    final int clOn = 0xFFFFFFFF;
    final int clOff = 0x00000000;

    int c = clOff;
    for (NeoFlower.Petal p : flower.petals) {
      if (mode == Mode.Petal) {
        c = (p.petalIdx == petalIdx) ? clOn : clOff;
      }
      else if (mode == Mode.Flower) {
        c = clOn;
      }
      for (int i = 0; i < p.up.size; i++) {
        colors[p.up.points[i].index] = this.up.isOn() ? c : clOff;
        colors[p.down.points[i].index] = this.down.isOn() ? c : clOff;
      }
    }
  }
}

@LXCategory("NeoFlower Form")
public static class FlowerWave extends NeoFlowerPattern {
  public enum Mode {
    TwoFromOne,
    Circle,
    TwoWave
  };
  public final EnumParameter<Mode> mode = new EnumParameter<Mode>("Mode", Mode.TwoWave)
    .setDescription("Mode in which loops work");

  public final CompoundParameter pos = new CompoundParameter("Pos", 0, 0, 1)
    .setDescription("Position of the center of the plane");

  public final CompoundParameter width = new CompoundParameter("Width", .4, 0, 1)
    .setDescription("Thicness");

  public final CompoundParameter offset = new CompoundParameter("Offset", .3, 0, 1)
    .setDescription("Waves offset");

  public FlowerWave(LX lx) {
    super(lx);
    addParameter("pos", this.pos);
    addParameter("width", this.width);
    addParameter("mode", this.mode);
    addParameter("offset", this.offset);
  }

  @Override
  public void run(double deltaMs) {
    float pos = this.pos.getValuef();
    float width = this.width.getValuef();
    float offset = this.offset.getValuef();
    Mode mode = this.mode.getEnum();

    for (NeoFlower.Petal p : flower.petals) {
      pos = (pos + offset) % 1;
      if (mode == Mode.Circle) {
        LXPoint point;
        for (int i = 0; i < (p.up.size + p.down.size); i++) {
          if (i >= p.up.size)
            point = p.down.points[p.size - i - 1];
          else
            point = p.up.points[i];

          float distNorm = abs((float)i/p.size - pos); distNorm = min(distNorm, 1 - distNorm);
          colors[point.index] = LXColor.gray(max(0, 100*(1 - (distNorm*distNorm)/(width/10))));
        }
        continue;
      }

      for (int i = 0; i < p.up.size; i++) {
        LXPoint point = p.up.points[i];
        float distNorm = abs((float)i/p.up.size - pos); distNorm = min(distNorm, 1 - distNorm);
        colors[point.index] = LXColor.gray(max(0, 100*(1-(distNorm*distNorm)/(width/10))));
      }
      if (mode == Mode.TwoWave) {
        for (int i = 0; i < p.down.size; i++) {
          LXPoint point = p.down.points[i];
          float distNorm = abs((float)i/p.down.size - pos); distNorm = min(distNorm, 1 - distNorm);
          colors[point.index] = LXColor.gray(max(0, 100*(1-(distNorm*distNorm)/(width/10))));
        }
      }
      else {
        for (int i = 0; i < p.down.size; i++) {
          LXPoint point = p.down.points[i];
          float distNorm = abs((float)(p.up.size - i - 1)/p.up.size - pos);
          colors[point.index] = LXColor.gray(max(0, 100*(1-(distNorm*distNorm)/(width/10))));
        }
      }
    }
  }
}
