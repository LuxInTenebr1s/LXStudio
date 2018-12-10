public abstract class EmpathyTreePattern extends LXModelPattern<Model> {
  public EmpathyTreePattern(LX lx) {
    super(lx);
  }

  public EmpathyTree getTree() {
    return (EmpathyTree)(model.objects.get("tree"));
  }

  public List<EmpathyTree.Loop> getLoops() {
    return getTree().loops;
  }
}

@LXCategory("Form")
public class LoopIteratorPattern extends EmpathyTreePattern {
  public final CompoundParameter pos = new CompoundParameter("Pos", 0, 0, 1)
    .setDescription("Position of the center of the plane");

  public final CompoundParameter wth = new CompoundParameter("Width", .4, 0, 1)
    .setDescription("Thickness");
 
  private final int steps = EmpathyTree.LEDS_PER_BEAM;
  public LoopIteratorPattern(LX lx) {
    super(lx);
    addParameter("pos", this.pos);
    addParameter("width", this.wth);
  }

  public float prevPos;
  public boolean direction = false;
  @Override
  public void run(double deltaMs) {
    float pos = this.pos.getValuef();
    float falloff = 100 / (this.wth.getValuef() * (1 + abs(pos - prevPos)));
    if (direction && prevPos < pos) {
      direction = false;
    }
    if (!direction && prevPos > pos) {
      direction = true;
    }
    prevPos = pos;
    
    pos = 1.5*pos-0.25;
    for (EmpathyTree.Loop l : getLoops()) {
      for (EmpathyTree.BeamPair bp : l.pairs) {
        EmpathyTree.Beam bOn, bOff;
        if (direction) {
            bOn = bp.left;
            bOff = bp.right;
          } else {
            bOn = bp.right;
            bOff = bp.left;
          }

        for (int i = 0; i < bOn.size; i++) {
          LXPoint p = bOn.points[i];
          float n = p.zn;
          colors[p.index] = LXColor.gray(max(0, 100 - falloff*abs(n - pos)));
        }

        for (int i = 0; i < bOff.size; i++) {
          colors[bOff.points[i].index] = 0xFF000000;
        }
      }
    }
  }
}

@LXCategory("Form")
public class SpiralPattern extends EmpathyTreePattern {
  public final CompoundParameter speed = new CompoundParameter("Speed", 10, 1, 100)
    .setDescription("Speed");

  public final CompoundParameter wth = new CompoundParameter("Width", .4, 0, 1)
    .setDescription("Thickness");

  public final CompoundParameter offset = new CompoundParameter("Offset", 0, -1, 1)
    .setDescription("Offset");

  public final EnumParameter<EmpathyTree.Beam.Orientation> direction = 
    new EnumParameter<EmpathyTree.Beam.Orientation>("Direction", EmpathyTree.Beam.Orientation.LEFT)
    .setDescription("Direction");

  private final int steps = EmpathyTree.LEDS_PER_BEAM;
  public SpiralPattern(LX lx) {
    super(lx);
    addParameter("speed", this.speed);
    addParameter("width", this.wth);
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
      float pos = this.pos.getValuef();
      float offset = this.offset.getValuef();
      float falloff = 100 / this.wth.getValuef();

      for (EmpathyTree.Loop l : getLoops()) {
        for (EmpathyTree.BeamPair bp : l.pairs) {
          EmpathyTree.Beam bOn, bOff;
          switch (this.direction.getEnum()) {
            case LEFT:
              bOn = bp.left;
              bOff = bp.right;
              break;
            default:
              bOn = bp.right;
              bOff = bp.left;
              break;
          }

          float posOff = modulo(2*pos + (EmpathyTree.FEET_NUM-bp.pairIdx)*offset, 2.0f)-0.5;
          for (int i = 0; i < bOn.size; i++) {
            LXPoint p = bOn.points[i];
            float n = p.zn;
            colors[p.index] = LXColor.gray(max(0, 100 - falloff*abs(n - posOff)));
          }

          for (int i = 0; i < bOff.size; i++) {
            colors[bOff.points[i].index] = 0xFF000000;
          }
        }
      }
    }
}
