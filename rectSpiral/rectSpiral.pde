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
  if (recording) {
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
  } else if (preview) {
    c = mouseY*1.0/height;
    if (mousePressed)
      println(c);
    t = (millis()/(20.0*numFrames))%1;
    draw_();
  } else {
    t = mouseX*1.0/width;
    c = mouseY*1.0/height;
    if (mousePressed)
      println(c);
    draw_();
  }
}

//////////////////////////////////////////////////////////////////////////////

int samplesPerFrame = 4;
int numFrames = 120;        
float shutterAngle = .6;

boolean recording = false, 
  preview = true;

void setup() {
  size(750, 750, P3D);
  smooth(8);  
  rectMode(CENTER);
  pixelDensity(recording ? 1 : 2);
  result = new int[width*height][3];
  fill(32);
  noStroke();
  blendMode(MULTIPLY);
}

float x, y, z, tt;
int N = 28;
float l = 450;
float W = l/(2*N), w, h = l/8;
color[] colours = {#1FEBFF, #F012DE, #FFEC20};

void rects(float q){
  push();
  scale(1, .9);
  for (int i=-N; i<=N; i++) {
    for (int j=-4; j<=4; j++) {
      x = map(i, -N, N, -l/2, l/2);
      y = map(j, -4, 4, -l/2, l/2);
      w = map(cos(TWO_PI*q + atan2(x,y) - 0.02*dist(x,y,0,0)),1,-1,W*.25,W*1.75);
      if ((i+j)%2 != 0)
        rect(x, y, w, h);
    }
  }
  pop();
}

void draw_() {
  background(250);
  push();
  translate(width/2, height/2);
  for(int i=0; i<3; i++){
    push();
    translate(-1+i,0);
    fill(colours[i]);
    rects(t+.05*i);
    pop();
  }
  pop();
}