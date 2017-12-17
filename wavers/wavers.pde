// 'wavers' by dave

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
int numFrames = 320;        
float shutterAngle = .7;

boolean recording = false;

void setup() {
  size(720, 720, P3D);
  pixelDensity(recording ? 1 : 2);
  smooth(8);
  result = new int[width*height][3];
  rectMode(CENTER);
  stroke(32);
  noFill();
  strokeWeight(3);
}

float x, y, z, tt;
float x_, y_, z_;
int N = 8;
int n = 720;
float th, rot, rotMax = PI*.75, twist = PI/3; 
float briteness;
float rMin = 65, rMax = 200;

void circ(float r, float phase, boolean black) {
  strokeWeight(black ? 6 : 18);
  beginShape();
  for (int i=0; i<n; i++) {
    th = TWO_PI*i/n;
    x = r*cos(th);
    y = r*sin(th);
    
    rot = rotMax*sin(TWO_PI*t + phase - twist*y/r);
    
    briteness = c01(map(x*sin(rot), -rMax, rMax, 0, 1));
    briteness = lerp(220, 20, briteness);
    stroke(black ? briteness : 250);
    
    vertex(x*cos(rot), y, x*sin(rot));
  }
  endShape(CLOSE);
}

void circs() {
  for (int i=0; i<N; i++) {
    circ(map(i,0,N-1,rMin,rMax), -HALF_PI*i/N, true);
    push();
    translate(0, 0, -9);
    //circ(map(i,0,N-1,rMin,rMax), -HALF_PI*i/N, false);
    pop();
  }
}

void draw_() {
  background(250); 
  push();
  translate(width/2, height/2);
  circs();
  pop();
}
