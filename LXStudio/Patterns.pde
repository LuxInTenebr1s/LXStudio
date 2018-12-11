// In this file you can define your own custom patterns

// Here is a fairly basic example pattern that renders a plane that can be moved
// across one of the axes.
@LXCategory("Form")
public static class PlanePattern extends LXPattern {
  
  public enum Axis {
    X, Y, Z
  };
  
  public final EnumParameter<Axis> axis =
    new EnumParameter<Axis>("Axis", Axis.X)
    .setDescription("Which axis the plane is drawn across");
  
  public final CompoundParameter pos = new CompoundParameter("Pos", 0, 1)
    .setDescription("Position of the center of the plane");
  
  public final CompoundParameter wth = new CompoundParameter("Width", .4, 0, 1)
    .setDescription("Thickness of the plane");
  
  public PlanePattern(LX lx) {
    super(lx);
    addParameter("axis", this.axis);
    addParameter("pos", this.pos);
    addParameter("width", this.wth);
  }
  
  public void run(double deltaMs) {
    float pos = this.pos.getValuef();
    float falloff = 100 / this.wth.getValuef();
    float n = 0;
    for (LXPoint p : model.points) {
      switch (this.axis.getEnum()) {
      case X: n = p.xn; break;
      case Y: n = p.yn; break;
      case Z: n = p.zn; break;
      }
      colors[p.index] = LXColor.gray(max(0, 100 - falloff*abs(n - pos))); 
    }
  }
}

public abstract class NeoPattern extends LXModelPattern<Model> {
  NeoModel obj;
  public NeoPattern(LX lx, String name) {
    super(lx);
    obj = getObject(name);
  }

  public NeoModel getObject(String name) {
    return (NeoModel)(model.objects.get(name));
  }
}


@LXCategory(LXCategory.COLOR)
public class NeoGradientPattern extends NeoPattern {

  public final CompoundParameter gradient = (CompoundParameter)
    new CompoundParameter("Gradient", 0, -360, 360)
    .setDescription("Amount of total color gradient")
    .setPolarity(LXParameter.Polarity.BIPOLAR);

  public final CompoundParameter spreadX = (CompoundParameter)
    new CompoundParameter("XSprd", 0, -1, 1)
    .setDescription("Sets the amount of hue spread on the X axis")
    .setPolarity(LXParameter.Polarity.BIPOLAR);

  public final CompoundParameter spreadY = (CompoundParameter)
    new CompoundParameter("YSprd", 0, -1, 1)
    .setDescription("Sets the amount of hue spread on the Y axis")
    .setPolarity(LXParameter.Polarity.BIPOLAR);

  public final CompoundParameter spreadZ = (CompoundParameter)
    new CompoundParameter("ZSprd", 0, -1, 1)
    .setDescription("Sets the amount of hue spread on the Z axis")
    .setPolarity(LXParameter.Polarity.BIPOLAR);

  public final CompoundParameter offsetX = (CompoundParameter)
    new CompoundParameter("XOffs", 0, -1, 1)
    .setDescription("Sets the offset of the hue spread point on the X axis")
    .setPolarity(LXParameter.Polarity.BIPOLAR);

  public final CompoundParameter offsetY = (CompoundParameter)
    new CompoundParameter("YOffs", 0, -1, 1)
    .setDescription("Sets the offset of the hue spread point on the Y axis")
    .setPolarity(LXParameter.Polarity.BIPOLAR);

  public final CompoundParameter offsetZ = (CompoundParameter)
    new CompoundParameter("ZOffs", 0, -1, 1)
    .setDescription("Sets the offset of the hue spread point on the Z axis")
    .setPolarity(LXParameter.Polarity.BIPOLAR);

  public final CompoundParameter spreadR = (CompoundParameter)
    new CompoundParameter("RSprd", 0, -1, 1)
    .setDescription("Sets the amount of hue spread in the radius from center")
    .setPolarity(LXParameter.Polarity.BIPOLAR);

  public final BooleanParameter mirror =
    new BooleanParameter("Mirror", true)
    .setDescription("If engaged, the hue spread is mirrored from center");

  public NeoGradientPattern(LX lx, String name) {
    super(lx, name);
    addParameter("gradient", this.gradient);
    addParameter("spreadX", this.spreadX);
    addParameter("spreadY", this.spreadY);
    addParameter("spreadZ", this.spreadZ);
    addParameter("spreadR", this.spreadR);
    addParameter("offsetX", this.offsetX);
    addParameter("offsetY", this.offsetY);
    addParameter("offsetZ", this.offsetZ);
    addParameter("mirror", this.mirror);
  }

  @Override
  public void run(double deltaMs) {
    float paletteHue = palette.getHuef();
    float paletteSaturation = palette.getSaturationf();
    float gradient = this.gradient.getValuef();
    float spreadX = this.spreadX.getValuef();
    float spreadY = this.spreadY.getValuef();
    float spreadZ = this.spreadZ.getValuef();
    float spreadR = this.spreadR.getValuef();
    float offsetX = this.offsetX.getValuef();
    float offsetY = this.offsetY.getValuef();
    float offsetZ = this.offsetZ.getValuef();
    float rRangeInv = (obj.rRange == 0) ? 1 : (1 / obj.rRange);
    boolean mirror = this.mirror.isOn();

    for (LXPoint p : obj.points) {
      float dx = p.xn - .5f - .5f * offsetX;
      float dy = p.yn - .5f - .5f * offsetY;
      float  dz = p.zn - .5f - .5f * offsetZ;
      float dr = (p.r - obj.rMin) * rRangeInv;
      if (mirror) {
        dx = Math.abs(dx);
        dy = Math.abs(dy);
        dz = Math.abs(dz);
      }
      float hue =
        paletteHue +
        gradient * (
          spreadX * dx +
          spreadY * dy +
          spreadZ * dz +
          spreadR * dr
        );

      colors[p.index] = LXColor.hsb(360. + hue, paletteSaturation, 100);
    }
  }
}
