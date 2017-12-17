// swingers, by davey

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

int samplesPerFrame = 8;
int numFrames = 100;        
float shutterAngle = .5;

boolean recording = false;

void setup() {
  size(800, 720, P3D);
  strokeWeight(2);
  smooth(8);
  result = new int[width*height][3];
  rectMode(CENTER);
  fill(32);
  colorMode(HSB);
  noStroke();
}

float x, y, z, tt;
int N = 8;
float r = 36, sp = 2.55*r;;

void thing(float q) {
  stroke(#fafafa);
  noFill();
  arc(0, 0, 2*r, 2*r, 0, PI);
  push();
  fill(lerpColor(#ff847c, #8ac5a0, ease(q)));
  noStroke();
  translate(0,0,1);
  rotate(PI*q);
  ellipse(r, 0, 16, 16);
  pop();
}

void draw_() {
  background(#1a2630); 
  push();
  translate(width/2, height/2);
  for (int i=-N; i<=N; i++) {
    for (int j=-N; j<=N; j++) {
      x = i*sp;
      y = j*.5*sp;
      if(j%2 != 0)
        x += .5*sp;
      tt = map(cos(TWO_PI*t - 0.008*dist(x,y,0,0)),1,-1,0,1);
      push();
      translate(x,y);
      thing(tt);
      pop();
    }
  }
  pop();
}
