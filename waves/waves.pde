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
int numFrames = 200;        
float shutterAngle = .5;

boolean recording = false;

void setup() {
  size(800, 720, P3D);
  pixelDensity(recording ? 1 : 2);
  smooth(8);
  result = new int[width*height][3];
  rectMode(CENTER);
  strokeWeight(3.4);
  fill(#111111);
}

float x, y, z, tt;
int N = 360;
float th, qq;
float h = 12, H = 24;
int nw = 10;
float d = 28;
int nd = 16;

void wave(int q) {
  stroke(cs[(q+100)%3]);
  
  beginShape();
  for (int i=0; i<N; i++) {
    qq = i/float(N-1);
    th = TWO_PI*qq*nw + TWO_PI*t;
    x = lerp(-width*.7, width*.7, qq);
    y = -H + h*sin(th) + h*.05*sin(3*th);
    vertex(x, y);
  }
  for (int i=0; i<N; i++) {
    qq = 1-i/float(N-1);
    th = TWO_PI*qq*nw + TWO_PI*t;
    x = lerp(-width*.7, width*.7, qq);
    y = H + h*sin(th) + h*.05*sin(3*th);
    vertex(x, y);
  }
  endShape();
  
  stroke(cs[(q+101)%3]);
  for (int i=0; i<nd; i++) {
    th = TWO_PI*i*1.5/nd + QUARTER_PI*q;
    push();
    translate(map(i, 0, nd-1, -width*.7, width*.7), (H+h+d/2 + 16)*sin(TWO_PI*t + th), 5*cos(TWO_PI*t + th));
    ellipse(0, 0, d, d);
    pop();
  }
}

color[] cs = { #FFFFFF, #F012BE, #01FF70 };

void draw_() {
  background(#111111); 
  push();
  translate(width/2, height/2);
  rotate(-TWO_PI/12);
  for (int i=-4; i<5; i++) {
    push();
    translate(0, 5.2*i*H);
    wave(i);
    pop();
  }
  pop();
}
