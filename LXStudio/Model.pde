import java.util.List;
import java.util.HashMap;
import java.util.Collections;

public static class Model extends LXModel {
  public final HashMap<String, NeoModel> objects;
  public final List<LXPoint> displayPoints;

  public Model(Config config) {
    super(new Fixture(config));

    Fixture f = (Fixture) this.fixtures.get(0);
    this.objects = f.objects;

    List<LXPoint> displayPoints = new ArrayList<LXPoint>();
    for (NeoModel obj : this.objects.values()) {
      for (LXPoint p : obj.getPoints()) {
        displayPoints.add(p);
      }
    }
    
    this.displayPoints = Collections.unmodifiableList(displayPoints);

    println("Leds: " + this.displayPoints.size());
  }

  public void buildOutput(LX lx) {
    try {
      LXDatagramOutput output = new LXDatagramOutput(lx);
      for (NeoModel obj : this.objects.values()) {
        obj.addDatagrams(output);
      }
      lx.engine.addOutput(output);
    }
    catch (Exception x) {
      throw new RuntimeException(x);
    }
  }

  public static class Fixture extends LXAbstractFixture {
    private final HashMap<String, NeoModel> objects = new HashMap<String, NeoModel>();

    private static final HashMap<String, Class<?>> modelClasses = createModelClassesMap();
    private static HashMap<String, Class<?>> createModelClassesMap() {
      HashMap<String, Class<?>> map = new HashMap<String, Class<?>>();
      map.put("NeoHex", NeoHex.class);
      return map;
    }

    private final void addObject(String name, NeoModel obj) {
      addPoints(obj);
      this.objects.put(name, obj);
    }
    
    Fixture(Config config) {
      addObject("hex", new NeoHex(config.getObject("hex")));
      /*
      JSONObject objs = config.getObjects();
      for (String name : (String[])objs.keys().toArray(new String[objs.size()])) {
        JSONObject conf = config.getObject(name);
        String className = conf.getString("class");
        println("Adding object " + name + " of class " + className);
        Class<?> cls = modelClasses.get(className);
          //Class.forName("LXStudio." + className);
        println(cls);
        NeoModel obj = cls.getConstructor(JSONObject.class).newInstance(new Object[] { conf });
        addPoints(obj);
        this.objects.put(name, obj);
      }
      */
    }
  }
}

public static class NeoModel extends LXModel {
  public JSONObject config;
  public UI3dComponent view;

  public NeoModel(LXFixture fixture) {
    super(fixture);
    Fixture f = (Fixture) this.fixtures.get(0);
    this.config = f.config;
  }

  public void addDatagrams(LXDatagramOutput output) {
    String address = this.config.getString("artnetAddress");
    int universe = this.config.getInt("artnetUniverse");
    println("ArtNet datagram to " + address + ", universe", universe);
    ArtNetDatagram datagram = new ArtNetDatagram(this, this.config.getInt("artnetUniverse", 0));
    //datagram.setAddress(this.config.getString("artnetAddress"));
    //output.addDatagram(datagram);
  }

  public static class Fixture extends LXAbstractFixture {
    public JSONObject config;
    public LXVector origin;
    public LXVector rotation;

    Fixture(JSONObject config) {
      this.config = config;
      this.origin = new LXVector(
          this.config.getFloat("x", 0),
          this.config.getFloat("y", 0),
          this.config.getFloat("z", 0));
      this.rotation = new LXVector(
          this.config.getFloat("rotx", 0),
          this.config.getFloat("roty", 0),
          this.config.getFloat("rotz", 0));
    }

    LXTransform getTransform() {
      LXTransform xfrm = new LXTransform();
      xfrm.translate(origin.x, origin.y, origin.z);
      xfrm.push();
      xfrm.rotateX(rotation.x);
      xfrm.rotateY(rotation.y);
      xfrm.rotateZ(rotation.z);
      return xfrm;
    }
  }
}
