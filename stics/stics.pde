// stics, or “sticks”

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

void pop(){
  popStyle();
  popMatrix();
}

float c01(float g){
  return constrain(g,0,1);
}

void draw() {
  
  if(!recording){
    t = mouseX*1.0/width;
    c = mouseY*1.0/height;
    if(mousePressed)
        println(c);
    draw_();
  }
  
  else {
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
int numFrames = 240;        
float shutterAngle = .6;

boolean recording = false;

void setup() {
  size(720,720,P3D);
  noFill();
  colorMode(HSB,1);
  strokeWeight(4);
  smooth(8);
  result = new int[width*height][3];
  rectMode(CENTER);
}

float x, y, z, tt;
int N = 12;
float l = 28, sp = l*1.3;

void thing(float th){
  push();
  stroke((th/TWO_PI+t+100)%1,1,1);
  rotate(th);
  line(-l/2,0,l/2,0);
  pop();
}

float xx, yy;

void draw_() {
  background(0); 
  push();
  translate(width/2, height/2);
  xx = -200*sin(TWO_PI*t);
  yy = 200*cos(TWO_PI*t);
  for(int i=-N; i<=N; i++){
    for(int j=-N; j<=N; j++){
      x = i*sp;
      y = j*sp;
      push();
      translate(x,y);
      thing(atan2(y-yy,x-xx)+TWO_PI*t-.002*dist(x,y,0,0));
      pop();
    }
  }
  pop();
}