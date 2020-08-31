public abstract static class NeoMatrixPattern extends NeoPattern {
  public NeoMatrixPattern(LX lx) {
    super(lx, "matrix");
  }

  public NeoMatrix getMatrix() {
    return (NeoMatrix)getObject("matrix");
  }
}

@LXCategory("Matrix")
public static class NeoMatrixGradient extends NeoGradientPattern {
  public NeoMatrixGradient(LX lx) {
    super(lx, "matrix");
  }
}

/*
@LXCategory("Matrix")
public static class NeoMatrixImage extends NeoMatrixPattern {
  public final StringParameter filename = new StringParameter("Filename", "");
    .setDescription("Filename");

  public final CompoundParameter posX = new CompoundParameter("PosX", 0, 1)
    .setDescription("PosX");

  public final CompoundParameter posY = new CompoundParameter("PosY", 0, 1)
    .setDescription("PosY);

  public final CompoundParameter scaleX = new CompoundParameter("ScaleX", 0, 1)
    .setDescription("ScaleX);
  
  public final CompoundParameter scaleX = new CompoundParameter("ScaleY", 0, 1)
    .setDescription("ScaleY);

  PImage img;

  public NeoMatrixImage(LX lx) {
    super(lx);
    addParameter("filename", this.filename);
    addParameter("posX", this.posX);
    addParameter("posY", this.posY);
    addParameter("scaleX", this.scaleX);
    addParameter("scaleY", this.scaleY);
  }

  @Override
  public void run(double deltaMs) {
  }
}
*/

@LXCategory("Matrix Form")
public static class RowStripePattern extends NeoMatrixPattern {
  public final CompoundParameter pos = new CompoundParameter("Pos", 0, 1)
    .setDescription("Position");
  
  public final CompoundParameter wth = new CompoundParameter("Width", .4, 0, 1)
    .setDescription("Thickness");

  public final CompoundParameter offset = new CompoundParameter("Offset", 0, -1, 1)
    .setDescription("Offset");
  
  public final CompoundParameter offset2 = new CompoundParameter("Offset2", 0, -1, 1)
    .setDescription("Offset2");

  public final DiscreteParameter div = new DiscreteParameter("Divide", 1, 10)
    .setDescription("Number of parts to divide");

  private final int rows = NeoMatrix.ROW_NUM;
  private final int cols = NeoMatrix.LEDS_PER_ROW;
  public RowStripePattern(LX lx) {
    super(lx);
    addParameter("pos", this.pos);
    addParameter("width", this.wth);
    addParameter("offset", this.offset);
    addParameter("offset2", this.offset2);
    addParameter("div", this.div);
  }
  
  @Override
  public void run(double deltaMs) {
    float pos = this.pos.getValuef();
    float falloff = 100 / this.wth.getValuef();
    int numPerDiv = cols / this.div.getValuei();
    float offset = numPerDiv * this.offset.getValuef();
    int offset2 = int(rows * this.offset2.getValuef());
    for (int row_num = 0; row_num < rows; row_num++) {
      NeoMatrix.Row row = getMatrix().rows[row_num];
      int len = row.allPoints.size();
      for (int i = 0; i < len; i++) {
        LXPoint p = row.allPoints.get(i);
        float level = abs((modulo(i + (wrap(row_num + offset2, rows) * offset) + pos*numPerDiv, numPerDiv))/numPerDiv - 0.5);
        colors[p.index] = LXColor.gray(max(0, 100 - falloff*level));
      }
    }
  }
}

/*
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
*/
