class Config {
  private final JSONObject j; 

  Config() {
    this.j = loadJSONObject("test.json");

    JSONObject size = this.j.getJSONObject("size");
    //size(size.getInt("x"), size.getInt("y"), P3D);
  }

  JSONObject getObjects() {
    return this.j.getJSONObject("objects");
  }

  JSONObject getObject(String name) {
    return getObjects().getJSONObject(name);
  }
}


