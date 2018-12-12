/** 
 * By using LX Studio, you agree to the terms of the LX Studio Software
 * License and Distribution Agreement, available at: http://lx.studio/license
 *
 * Please note that the LX license is not open-source. The license
 * allows for free, non-commercial use.
 *
 * HERON ARTS MAKES NO WARRANTY, EXPRESS, IMPLIED, STATUTORY, OR
 * OTHERWISE, AND SPECIFICALLY DISCLAIMS ANY WARRANTY OF
 * MERCHANTABILITY, NON-INFRINGEMENT, OR FITNESS FOR A PARTICULAR
 * PURPOSE, WITH RESPECT TO THE SOFTWARE.
 */

// ---------------------------------------------------------------------------
//
// Welcome to LX Studio! Getting started is easy...
// 
// (1) Quickly scan this file
// (2) Look at "Model" to define your model
// (3) Move on to "Patterns" to write your animations
// 
// ---------------------------------------------------------------------------

Config config;
Model model;

void setup() {
  size(1200, 960, P3D);
  
  config = new Config();
  model = new Model(config);

  boolean headless = false;
  if (args != null && args.length > 0) {
    if (args[0].equals("headless")) {
      headless = true;
    }
  }

  if (headless) {
    println("Starting headless engine");
    heronarts.lx.LX lx = new LX(model);
    model.buildOutput(lx);
    if (args.length > 1) {
      lx.openProject(new File(args[1]));
    }
    lx.engine.start();
  }
  else {
    println("Starting LXStudio with UI");
    heronarts.lx.studio.LXStudio lx;
    lx = new heronarts.lx.studio.LXStudio(this, model, MULTITHREADED);
    lx.ui.setResizable(RESIZABLE);
  }
}

void initialize(final heronarts.lx.studio.LXStudio lx, heronarts.lx.studio.LXStudio.UI ui) {
  // Add custom components or output drivers here
  try {
    model.buildOutput(lx);
  } catch (Exception x) {
    x.printStackTrace();
  }
}

void onUIReady(heronarts.lx.studio.LXStudio lx, heronarts.lx.studio.LXStudio.UI ui) {
  ui.preview.pointCloud.setModel(new LXModel(model.displayPoints));
  ui.preview.addComponent(new UISimulation());
  ui.preview.perspective.setValue(30);
}

void draw() {
  // All is handled by LX Studio
}

// Configuration flags
final static boolean MULTITHREADED = true;
final static boolean RESIZABLE = true;

// Helpful global constants
final static float INCHES = 1;
final static float IN = INCHES;
final static float FEET = 12 * INCHES;
final static float FT = FEET;
final static float CM = IN / 2.54;
final static float MM = CM * .1;
final static float M = CM * 100;
final static float METER = M;

final static float PI = 3.1415926;
final static float TWO_PI = PI * 2;
final static LXVector X_AXIS = new LXVector(1, 0, 0);

static int modulo(int x, int mod) {
  if (x < 0) {
    x = mod + x;
  }
  return x % mod;
}

static float modulo(float x, float mod) {
  while (x < 0) {
    x += mod;
  }
  while (x > mod) {
    x -= mod;
  }
  return x;
}

// check on which side of a line through [a, b] the point x is situated
//private float pointRel(LXPoint x, LXVector a, LXVector b) {
//}

static float theta(LXPoint p) {
  return LXVector.angleBetween(X_AXIS, new LXVector(p.x, p.y, 0));
}
