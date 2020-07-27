import de.voidplus.leapmotion.*;

LeapMotion leap_controller;
PImage img;
PGraphics g;

float[] finger_pos_x;
float[] finger_pos_y;

PShader leap;
float time;
ArrayList<PVector> fingers;
float hand_present = 0;

void setup() {
  //size(640, 360, P3D);
  fullScreen(P3D);
  noStroke();
  fill(204);
  leap = loadShader("Leap.glsl");
  time = 0.0;
  fingers = new ArrayList<PVector>();
  finger_pos_x = new float[5];
  finger_pos_y = new float[5];
  for (int i = 0; i < finger_pos_x.length; i++) {
    finger_pos_x[i] = 0.0;
    finger_pos_y[i] = 0.0;
  }
  leap_controller = new LeapMotion(this);
  img = loadImage("vangogh.jpg");
  img.resize(width, height);
 
  //Initialize previous pass
  g = createGraphics(width, height, P3D);
  g.beginDraw();
  g.background(0);
  g.endDraw();
}

void draw() { 
  noCursor();
  //Create an array list to allocate fingers positions 
  
  fingers = new ArrayList<PVector>();
  
  for (Hand hand : leap_controller.getHands ()) {
    //Checking if the right hand is present
    
    if (hand.isRight()) {
      //Use some easing on hand presence
      hand_present += 0.07;
      hand_present = min(hand_present, 1.0);
      for (Finger finger : hand.getFingers()) {

        fingers.add(finger.getStabilizedPosition());
      }
    }
  }

  //Check if all 5 fingers are present. Otherwise just add a 0 PVector
  //This is done so to not make the shader mad with the array passing
  
  while (fingers.size() < 5) {
    fingers.add(new PVector(0.0, 0.0));
  }

  for (int i = 0; i < fingers.size(); i++) {
    PVector f = fingers.get(i);
    
    //Use some easing for the finger positions
    
    finger_pos_x[i] += (f.x - finger_pos_x[i]) * 0.07; 
    finger_pos_y[i] += (f.y - finger_pos_y[i]) * 0.07;
  }

  //Pass the fingers x and y position
  
  leap.set("fingers_x", finger_pos_x);
  leap.set("fingers_y", finger_pos_y);
  
  //Pass the texture
  
  leap.set("texture", img);
  leap.set("feedback", g);
  
  //Tell the shader about the presence of the right hand
  
  leap.set("hand", hand_present);

  //Pass the other variables
  leap.set("resolution", width, height);
  leap.set("time", time);
  
  background(0);
  shader(leap);
  rect(0, 0, width, height);
  g.loadPixels();
  g.pixels = copy().pixels;
  g.updatePixels();
  g.endDraw();
  
  time += 0.1;
  
  //Ease the hand presence out;
  
  hand_present -= 0.01 ;
  hand_present = max(hand_present, 0.0);
}
