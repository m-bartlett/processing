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
    for (int sa=0; sa<samplitudelesPerFrame; sa++) {
      t = map(frameCount-1 + sa*shutterAngle/samplitudelesPerFrame, 0, numFrames, 0, 1);
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
        int(result[i][0]*1.0/samplitudelesPerFrame) << 16 | 
        int(result[i][1]*1.0/samplitudelesPerFrame) << 8 | 
        int(result[i][2]*1.0/samplitudelesPerFrame);
    updatePixels();

    saveFrame("f###.gif");
    if (frameCount==numFrames)
      exit();
  }
}

//////////////////////////////////////////////////////////////////////////////

int samplitudelesPerFrame = 8;
int numFrames = 75;        
float shutterAngle = 1  ;

boolean recording = false;

void setup() {
  size(808, 700, P3D);
  smooth(8);
  result = new int[width*height][3];
  rectMode(CENTER);
  fill(32);
  noStroke();
  println(700/mn);
}

float easeSin(float q) {
  return lerp(sin(q), lerp(1, -1, ease(map(sin(q), 1, -1, 0, 1))), .25);
}

float x, y, z, tt;
int N = 18;
float offset, amplitude, dist, diam;
float spacing = 17, maxOffset = 26, maxDist = 242;
float minDiam = 4, maxDiam = 7;
float wavelength = 44;

void dots() {
  for (int i=-N; i<=N; i++) {
    for (int j=-N; j<=N; j++) {
      x = i*spacing;
      y = j*mn*spacing;
      if (j%2 != 0)
        x += .5*spacing;

      dist = max(abs(y), abs(.5*y + mn*x), abs(.5*y - mn*x));
      
      if (dist < maxDist) {

        amplitude = c01(map(dist, 0, maxDist-spacing, 1, 0));
        amplitude = 1-sq(1-amplitude);

        offset = maxOffset*easeSin(TWO_PI*t - dist/wavelength)*amplitude;

        x += offset;

        diam = lerp(minDiam, maxDiam, amplitude);

        ellipse(x, y, diam, diam);
      }
    }
  }
}

PImage f1, f2, f3;

void draw_() {
  push();
  translate(width/2, height/2);
  background(0);
  
  fill(235, 0, 0);
  push();
  translate(0, -.5);
  dots();
  pop();
  f1 = get();

  background(0);
  fill(0, 239, 0);
  push();
  scale(1.005);
  dots();
  pop();
  f2 = get();

  background(0);
  fill(0, 0, 186);
  push();
  translate(0, .5);
  scale(1.01);
  dots();
  pop();
  f3 = get();

  background(9, 8, 28);
  blend(f1, 0, 0, width, height, 0, 0, width, height, ADD);
  blend(f2, 0, 0, width, height, 0, 0, width, height, ADD);
  blend(f3, 0, 0, width, height, 0, 0, width, height, ADD);

  pop();
}