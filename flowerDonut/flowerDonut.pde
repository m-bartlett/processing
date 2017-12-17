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

    saveFrame("g###.gif");
    if (frameCount==numFrames)
      exit();
  }
}

//////////////////////////////////////////////////////////////////////////////

int samplesPerFrame = 4;
int numFrames = 180;        
float shutterAngle = .6;

boolean recording = false;

void setup() {
  size(720, 720, P3D);
  pixelDensity(recording ? 1 : 2);
  smooth(8);
  result = new int[width*height][3];
  noFill();
  strokeWeight(10);
  ortho();
}

void strand(float q) {
  beginShape();
  for (int i=0; i<n; i++) {
    qq = i*1.0/(n-1);
    r = lerp(r1, r2, qq);
    th = om*sin(TWO_PI*t - PI*qq + q);
    vertex(r*cos(th), r*sin(th));
  }
  endShape();
}

int n = 60;
float r1 = 75, r2 = 255, r, th, om = .4;
float qq;
float x, y, z, tt;
int N = 12;

void draw_() {
  blendMode(MULTIPLY);
  background(250); 
  push();
  translate(width/2, height/2);
  for (int i=0; i<N; i++) {
    push();
    rotate(TWO_PI*i/N);
    stroke(#FFDC00);
    strand(0);
    stroke(#39CCCC);
    strand(TWO_PI/3);
    stroke(#F012BE);
    strand(-TWO_PI/3);
    pop();
  }


  // MASKS !
  push();
  translate(0, 0, 1);
  blendMode(NORMAL);
  fill(250);
  noStroke();
  ellipse(0, 0, 2*r1+5, 2*r1+5);

  beginShape(TRIANGLE_STRIP);
  for (int i=0; i<=500; i++) {
    vertex((r2-5)*cos(TWO_PI*i/500), (r2-5)*sin(TWO_PI*i/500));
    vertex(1000*cos(TWO_PI*i/500), 1000*sin(TWO_PI*i/500));
  }
  endShape();
  pop();

  pop();
}
