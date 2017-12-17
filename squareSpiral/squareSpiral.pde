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
int numFrames = 280;        
float shutterAngle = .6;

boolean recording = false, 
  preview = true;

void setup() {
  size(800, 800, P3D);
  smooth(8);  
  rectMode(CENTER);
  result = new int[width*height][3];
  fill(32);
  noStroke();
  
  coords[0][0] = 0;
  coords[0][1] = 0;
  in = 1;
  
  for(int i=0; i<80; i++){
    dx = int(sin(HALF_PI*i));
    dy = int(cos(HALF_PI*i));
    l = 4*(i+1);
     
    for(int j=0; j<l; j++){
      coords[in][0] = coords[in-1][0] + dx;
      coords[in][1] = coords[in-1][1] + dy;
      in++;
    }
  }
  numPts = in;
}

float x, y, z, tt;
int N = 12;
int numPts;
int in;
float scale = 1.68, sw;
int dx, dy, l;
float[][] coords = new float[16000][2];
float phase, rotation, wavelength = 20;
float minWeight = 1.8, maxWeight = 7.8;
int zoomSpeed = 3;

void draw_() {
  rotation = HALF_PI*t;
  background(250);
  push();
  translate(width/2, height/2);
  rotate(HALF_PI);
  for(int i=0; i<numPts-8; i++){
    x = scale*coords[i][0];
    y = scale*coords[i][1];
    phase = max(abs(x*cos(rotation)+y*sin(rotation)),abs(y*cos(rotation)-x*sin(rotation)))/wavelength;
    sw = cos(TWO_PI*zoomSpeed*t - phase);
    sw = map(sw,1,-1,0,1);
    sw = lerp(minWeight,maxWeight,ease(c01(1.3*sw-0.2)));
    strokeWeight(sw);
    rect(x,y,sw,sw);
  }
  pop();
  
}