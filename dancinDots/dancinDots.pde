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

    saveFrame("f###.png");
    if (frameCount==numFrames)
      exit();
  }
}

//////////////////////////////////////////////////////////////////////////////

int samplesPerFrame = 4;
int numFrames = 160;        
float shutterAngle = .6;

boolean recording = false;

void setup() {
  size(720, 720, P3D);
  pixelDensity(recording ? 1 : 2);
  smooth(8);
  result = new int[width*height][3];
  rectMode(CENTER);
  fill(32);
  noStroke();
}

float x, y, z, tt;
int N = 8, n = 11;
float R = 18, r = 12;

float br;

void pair(float q) {
  br = map(sin(TWO_PI*q),1,-1,0,1);
  br = 1-sq(1-br);
  push();
  fill(color(250,255*br));
  rotateY(TWO_PI*q);
  translate(R, 0, 0);
  sphere(r);
  pop();
  
  br = map(-sin(TWO_PI*q),1,-1,0,1);
  br = 1-sq(1-br);
  push();
  fill(210, 100, 220,255*br);
  rotateY(TWO_PI*q);
  translate(-R, 0, 0);
  sphere(r);
  pop();
}

void draw_() {
  background(20, 30, 55); 
  push();
  translate(width/2, height/2);
  for (int a=0; a<N; a++) {
    push();
    rotate(TWO_PI*a/N);
    for (int i=0; i<n; i++) {
      push();
      scale(exp(.21*i));
      translate(0,-33,0);
      scale(.25);
      pair(t+i*1.0/n + a*1.0/N);
      pop();
    }
    pop();
  }
  pop();
}
