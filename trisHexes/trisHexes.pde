// animation by dave aka bees & bombs

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
int numFrames = 220;        
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

float cs(float q){
  return lerp(-1,1,ease(map(cos(q),-1,1,0,1),5));
}

float x, y, z, tt;
int N = 6;
float sp = 80;

void draw_() {
  background(10); 
  push();
  translate(width/2, height/2);
  rotate(HALF_PI);
  for (int a=-1; a<2; a++) {
    for (int i=-N; i<=N; i++) {
      for (int j=-N; j<=N; j++) {
        x = i*sp;
        y = (j+a*2/3.0)*mn*sp;
        if (j%2 != 0)
          x += .5*sp;
        tt = (t + 100 - 0.001*dist(x, y, 0, 0));
        push();
        translate(x, y);
        rotate(TWO_PI*-a/3 + HALF_PI);
        fill(lerpColor(#00c5e9,#e8509f,map(cs(TWO_PI*tt),-1,1,0,1)));
        ellipse(0,13*cs(TWO_PI*tt),42,5);
        pop();
      }
    }
  }
  pop();
}
