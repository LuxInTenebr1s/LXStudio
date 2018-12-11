public abstract static class NeoTrianglePattern extends NeoPattern {
  public NeoTrianglePattern(LX lx) {
    super(lx, "triangle");
  }

  public NeoTriangle getTriangle() {
    return (NeoTriangle)getObject("triangle");
  }
}

@LXCategory("Triangle")
public static class NeoTriangleGradient extends NeoGradientPattern {
  public NeoTriangleGradient(LX lx) {
    super(lx, "triangle");
  }
}

@LXCategory("Triangle Form")
public static class SideStripePattern extends NeoTrianglePattern {
  public final CompoundParameter pos = new CompoundParameter("Pos", 0, 1)
    .setDescription("Position");
  
  public final CompoundParameter wth = new CompoundParameter("Width", .4, 0, 1)
    .setDescription("Thickness");

  public SideStripePattern(LX lx) {
    super(lx);
    addParameter("pos", this.pos);
    addParameter("width", this.wth);
  }
  
  @Override
  public void run(double deltaMs) {
    float pos = this.pos.getValuef() * 1.5 - 0.25;
    float falloff = 100 / this.wth.getValuef();
    for (NeoTriangle.Side s : getTriangle().sides) {
      int len = s.allPoints.size();
      for (int i = 0; i < len; i++) {
        LXPoint p = s.allPoints.get(i);
        float n = float(i)/len;
        colors[p.index] = LXColor.gray(max(0, 100 - falloff*abs(n - pos)));
      }
    }
  }
}

@LXCategory("Triangle Form")
public static class AllStripePattern extends NeoTrianglePattern {
  public final CompoundParameter pos = new CompoundParameter("Pos", 0, 1)
    .setDescription("Position");
  
  public final CompoundParameter wth = new CompoundParameter("Width", .4, 0, 1)
    .setDescription("Thickness");

  public final DiscreteParameter div = new DiscreteParameter("Divide", 1, 10)
    .setDescription("Number of parts to divide");

  public AllStripePattern(LX lx) {
    super(lx);
    addParameter("pos", this.pos);
    addParameter("width", this.wth);
    addParameter("div", this.div);
  }
  
  @Override
  public void run(double deltaMs) {
    float pos = this.pos.getValuef();
    float falloff = 100 / this.wth.getValuef();
    NeoTriangle t = getTriangle();
    int numPerDiv = t.size / this.div.getValuei();
    for (int i = 0; i < t.size; i++) {
      LXPoint p = t.points[i];
      float level = abs((modulo(i + pos*numPerDiv, numPerDiv))/numPerDiv - 0.5);
      colors[p.index] = LXColor.gray(max(0, 100 - falloff*level));
    }
  }
}

