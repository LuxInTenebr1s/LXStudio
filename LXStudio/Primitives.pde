/*
public static class Strand extends LXAbstractFixture {
  public final static float PIXEL_SIZE = 10*CM;
  public final LXTransform transform;
  public final int num;
  public final double step;

  public Strand(LXTransform transform, int num, float step) {
    this.transform = transform;
    this.num = num;
    this.step = step;
    transform.push();
    for (int i = 0; i < num; i++) {
        transform.translate(step, 0.0, 0.0);
        addPoint(new LXPoint(transform));
    }
  }

  public void draw(UI ui, PGraphics pg) {
    pg.beginShape();
    pg.rotateZ(atan2(direction.y, direction.x));
    for (LXPoint p : getPoints()) {
      pg.box(PIXEL_SIZE);
      pg.translate(direction.x, direction.y, direction.z);
    }
    pg.endShape();
  }
}
*/
