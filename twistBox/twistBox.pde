int[][] result;
float t, c;

float ease(float p) {
  return 3*p*p - 2*p*p*p;
}

float ease(float p, float g) {
  if (p < 0.5) 
    return 0.5 * pow(2*p, g);
  else
    return 1 - 0.5 * pow(2*(1 - p), g);
}

float mn = .5*sqrt(3), ia = atan(sqrt(.5));

void push() {
  pushMatrix();
  pushStyle();
}

void pop() {
  popStyle();
  popMatrix();
}

float c01(float g) {
  return constrain(g, 0, 1);
}

void draw() {

  if (!recording) {
    t = mouseX*1.0/width;
    c = mouseY*1.0/height;
    if (mousePressed)
      println(c);
    draw_();
  } else {
    for (int i=0; i<width*height; i++)
      for (int a=0; a<3; a++)
        result[i][a] = 0;

    c = 0;
    for (int sa=0; sa<samplesPerFrame; sa++) {
      t = map(frameCount-1 + sa*shutterAngle/samplesPerFrame, 0, numFrames, 0, 1);
      draw_();
      loadPixels();
      for (int i=0; i<pixels.length; i++) {
        result[i][0] += pixels[i] >> 16 & 0xff;
        result[i][1] += pixels[i] >> 8 & 0xff;
        result[i][2] += pixels[i] & 0xff;
      }
    }

    loadPixels();
    for (int i=0; i<pixels.length; i++)
      pixels[i] = 0xff << 24 | 
        int(result[i][0]*1.0/samplesPerFrame) << 16 | 
        int(result[i][1]*1.0/samplesPerFrame) << 8 | 
        int(result[i][2]*1.0/samplesPerFrame);
    updatePixels();

    saveFrame("f###.gif");
    if (frameCount==numFrames)
      exit();
  }
}

//////////////////////////////////////////////////////////////////////////////

int samplesPerFrame = 4;
int numFrames = 400;        
float shutterAngle = .6;

boolean recording = false;

void setup() {
  size(750, 750, P3D);
  smooth(8);  
  rectMode(CENTER);
  pixelDensity(recording ? 1 : 2);
  result = new int[width*height][3];
  noFill();
  stroke(255);
  strokeWeight(2.5);
  ortho();
}

int N = 240;  // number of vertices in each line
float l = 280;  // box side length

float twistAmount, maxTwist = 7;

float x, y;
float qq, th, twist;
float depth;
float x_, y_;


void twistLine(float q) {
  beginShape();
  for (int i=0; i<=N; i++) {
    qq = i*1.0/N;
    x = lerp(-l/2, l/2, qq);
    y = lerp(-l/2, l/2, qq);

    twist = map(cos(TWO_PI*qq), 1, -1, 0, 1);
    twist = maxTwist*q*lerp(twist, 1-sqrt(1-twist), .75);  // this makes it look a bit nicer

    x_ = x*cos(twist) + y*sin(twist);  // rotating around z-axis
    y_ = y*cos(twist) - x*sin(twist);  // by angle "twist"

    depth = c01(map(modelZ(x_, y_, 0), -l*.9, l*.9, 0, 1.6));  // front/back limits ±l*.9 i found by trial and error
    
    stroke(lerp(40,255,depth));  // darker at the back!
    vertex(x_, y_);
  }
  endShape();
}

void twistX(float q){
  twistLine(q);
  push();
  rotate(HALF_PI);
  twistLine(q);
  pop();
}

void boxx(float q) {
  for (int i=0; i<4; i++) {
    push();
    rotateY(HALF_PI*i);
    translate(0, 0, l/2);
    twistX(q);
    pop();
  }

  for (int i=0; i<2; i++) {
    push();
    rotateX(HALF_PI+PI*i);
    translate(0, 0, l/2);
    twistX(q);
    pop();
    
  }
}

void draw_() {
  background(0);
  push();
  translate(width/2, height/2);
  rotateX(-ia);  // "isometric angle"
  rotateY(PI/3 - PI*t);

  twistAmount = ease(map(cos(TWO_PI*t), 1, -1, 0, 1), 3);

  boxx(twistAmount);
  pop();
}