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
int numFrames = 130;        
float shutterAngle = .75;

boolean recording = false;

void setup() {
  size(820, 720, P3D);
  pixelDensity(recording ? 1 : 2);
  smooth(8);
  result = new int[width*height][3];
  rectMode(CENTER);
  stroke(250);
  fill(10);
  strokeWeight(4);
}

float x, y, z, tt;
int N = 36;
float th = TWO_PI/N;

float R = 230, r = 80;

void wedge(float th1, float th2) {
  beginShape(QUADS);
  for (int i=0; i<4; i++) {
    vertex(R + r*cos(th1 - HALF_PI + HALF_PI*i), r*sin(th1 - HALF_PI + HALF_PI*i), 0);
    vertex(R + r*cos(th1 + HALF_PI*i), r*sin(th1 + HALF_PI*i), 0);
    vertex((R + r*cos(th2 + HALF_PI*i))*cos(th), r*sin(th2 + HALF_PI*i), (R + r*cos(th2 + HALF_PI*i))*sin(th));
    vertex((R + r*cos(th2-HALF_PI + HALF_PI*i))*cos(th), r*sin(th2-HALF_PI + HALF_PI*i), (R + r*cos(th2-HALF_PI + HALF_PI*i))*sin(th));
  }
  endShape();
}


float ro, ro_;

void draw_() {
  background(10); 
  push();
  translate(width/2, height*.4);
  rotateX(-.95);
  for (int i=0; i<N; i++) {
    ro = TWO_PI*(i+6*t)/N;
    ro_ = TWO_PI*(i-1+6*t)/N;
    push();
    rotateY(ro);
    wedge(ro/2 + HALF_PI*t, ro_/2 + HALF_PI*t);
    pop();
  }
  pop();
}
