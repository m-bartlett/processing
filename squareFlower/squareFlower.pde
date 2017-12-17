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

int samplesPerFrame = 8;
int numFrames = 860;        
float shutterAngle = .6;

boolean recording = false;

void setup() {
  size(720,720,P3D);
  pixelDensity(recording ? 1 : 2);
  smooth(8);
  result = new int[width*height][3];
  rectMode(CENTER);
  fill(32);
  noStroke();
}

float x, y, z, tt;
int N = 14;
float l, maxL = 340;
float easing;

float easeSin(float g){
  return lerp(-.5,.5,ease(map(sin(g),-1,1,0,1),easing));
}

void draw_() {
  background(250); 
  push();
  translate(width/2, height/2);
  for(int i=0; i<N; i++){
    easing = lerp(12,2,sqrt(i/float(N)));
    l = map(i,0,N,maxL,0);
    fill(i%2 == 0 ? 32 : 250);
    push();
    rotate(QUARTER_PI + QUARTER_PI*easeSin(TWO_PI*(i+1)*t));
    rect(0,0,l,l);
    pop();
  }
  pop();
}