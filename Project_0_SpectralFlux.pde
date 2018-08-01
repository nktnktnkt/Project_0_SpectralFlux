import themidibus.*;

import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;

import spout.*;

import netP5.*;
import oscP5.*;

OscP5 oscP5;
OscP5 portEuler;
OscP5 portRotary;

NetAddress audioPC;

MidiBus myBus;

Spout spout;

PostFX fx;
PostFX fx2;

Liquid liquid;
Liquid liquid2;

Mover[] mover = new Mover[80000];
int pColor = 1;
int rate = 0;
float divider;
PVector gravity = new PVector(0, 0);
float ctlX, ctlY, ctlZ, pctlX, pctlY, pctlZ;
PVector controller = new PVector(0, 0);
PVector pcontroller = new PVector(0, 0);
PGraphics pg;
PGraphics cg;
int bkg = 98;
int objClr = 0;
int index = 0;
PVector[] speakersPos = new PVector[26];
float range;
float[] speakerVal = new float[26];
PVector irSensor;
int rotoMIDI;

void setup() {
  size(4096, 768, P2D);
  //size(5120, 800, P2D);
  noSmooth();
  //fullScreen(1); 

  //initialize particles
  for (int i = 0; i < mover.length; i++) {
    if (i < mover.length*.25) {
      pColor = 1;
    }
    if (i > mover.length*.25) {
      pColor = 2;
    }
    if (i > mover.length*.50) {
      pColor = 3;
    }
    if (i > mover.length*.75) {
      pColor = 4;
    }
    switch(pColor) {
    case 1:
      float cVal = random(100, 255);
      //mover[i] = new Mover(abs(random(0, 2))+1, random(width*.25), random(height), cVal, cVal - 150, cVal - 20, random(55));
      mover[i] = new Mover(random(-1, 1)*sq(random(-1, 2))+2, random(width*.25), random(height), cVal - 150, cVal, cVal + 20, random(55), 77.781746);
      break;
    case 2:
      mover[i] = new Mover(random(-1, 1)*sq(random(-1, 2))+2, random(width*.25, width*.5), random(height), 200, random(200, 255), random(100, 155), random(55), 87.30706);
      break;
    case 3:
      cVal = random(200, 255);
      mover[i] = new Mover(random(-1, 1)*sq(random(-1, 2))+2, random(width*.5, width*.75), random(height), cVal, cVal - random(200), 75, random(0), 116.540939);
      break;
    case 4:
      cVal = random(100, 150);
      mover[i] = new Mover(random(-1, 1)*sq(random(-1, 2))+2, random(width*.75, width), random(height), 50, random(150, 200), cVal, random(155), 220);
      break;
    }
  }

  //initialize drag
  liquid = new Liquid(0, 0, width, height, 0.006);
  liquid2 = new Liquid(0, 0, width, height, 0.005);

  //initialize OSC 
  oscP5 = new OscP5(this, 12000);
  portEuler = new OscP5(this, 7600);
  portRotary = new OscP5(this, 9999);
  audioPC = new NetAddress("192.168.1.9", 5555);

  //initialize Spout
  spout = new Spout(this);
  spout.createSender("sender");

  //initialize postFX filters
  fx = new PostFX(this);
  fx2 = new PostFX(this);

  //innitialize graphics buffers
  pg = createGraphics(width, height);
  cg = createGraphics(width, height, P2D);
  pg.beginDraw();
  pg.background(bkg);
  pg.endDraw();
  cg.beginDraw();
  cg.background(bkg);
  cg.endDraw();
  background(bkg);

  //innitialize speaker positions
  speakersPosition();
  range = width/13;
}

void draw() {

  irSensor = new PVector(rate, height/2);
  rate = rate + 1;
  if (rate > width) {
    rate = 0;
  }

  //set regeneration
  for (int i = 0; i < 2; i++) {
    mover[int(random(mover.length))].life();
  }

  thread("vectorMath"); 
  //println(frameRate);
  //println(ctlX,ctlY,ctlZ);
  pg.beginDraw();
  pg.background(bkg);
  //pg.image(atr,0,0);
  if (irSensor.y < -100) {
    irSensor.x = irSensor.x - (width/2);
  }
  
  //floating shape controls
  floatShape(rotoMIDI, rate, irSensor.x, irSensor.y);
  floatShape(rotoMIDI, rate, irSensor.x - width, irSensor.y);
  floatShape(rotoMIDI, rate, irSensor.x + width, irSensor.y);
  pg.endDraw();
  
  //update visuals
  pg.loadPixels();
  for (int i = 0; i < mover.length; i++) {
    mover[i].display();
  }
  pg.updatePixels();
  tint(255, 100);
  //image(pg, 0, 0);
  //tint(255,255);
  //blendMode(BLEND);
  
  //postFX filters
  fx.render(pg)
    .denoise(20)
    .rgbSplit(5)
    .blur(2, .8)
    .bloom(.1, 20, 80)
    .bloom(.1, 50, 20)
    .invert()
    .bloom(.18, 2, 80)
    .saturationVibrance(0, 1)
    .brightnessContrast(0, 2)
    .compose(cg);
  blendMode(SUBTRACT);

  image(cg, 0, 0);
  fx2.render()
    .sobel()
    //.blur(2,.4)
    .compose();
  blendMode(EXCLUSION);
  tint(255, 200, 255);
  image(cg, 0, 0);
  blendMode(DIFFERENCE);
  thread("oscSend");
  
  speakersPosition();
  //drawSpeakers();
  spout.sendTexture();
}

void drawSpeakers() {
  for (int i = 0; i < speakersPos.length; i++) {
    rectMode(CENTER);
    fill(255);
    rect(speakersPos[i].x, speakersPos[i].y, 50, 50);
  }
}

//math for particle system and interactons
void vectorMath() {
  for (int i = 0; i < mover.length; i++) {
    float m = mover[i].mass;
    float c = 0.001;
    PVector friction = mover[i].velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(c);

    //if ((ctlX != pctlX) || (ctlY != pctlY) || (ctlZ != pctlZ)) {
    pcontroller.mult(0);
    controller.mult(0);
    pcontroller.add(pctlX, pctlY);
    controller.add(ctlX, ctlY);
    pcontroller.add(pmouseX, pmouseY);
    controller.add(mouseX, mouseY);
    PVector controlDir = PVector.sub(controller, pcontroller);
    float controlVel = controlDir.mag()* random(.1, .8) * (mover[i].mass*.5);
    controlDir = controlDir.normalize();
    controlDir = controlDir.mult(controlVel);
    controlDir = controlDir.limit(100);
    PVector dir = PVector.sub(controller, mover[i].location);
    //float dist = dir.mag()/(controlVel/4);
    float dist = dir.mag()*.03*mover[i].mass;
    //if(controlDir.mag() > 5.0){  
    PVector wind = new PVector(controlDir.x/dist, controlDir.y/dist);  
    mover[i].applyForce(wind);
    //}

    if (i % mover.length*.25 > mover.length*.125) {
      mover[i].drag(liquid);
    } else {
      mover[i].drag(liquid2);
    }

    mover[i].applyForce(friction);
    mover[i].alpha = constrain(sq(mover[i].velocity.mag())*.25, 0, 150);
    mover[i].alpha = map(mover[i].alpha, 0, 150, 70, 20);
    divider = noise(mover[i].location.x * .01 + (rate*.015))*(height*.5) + (height*.3333);

    if (mover[i].location.y > divider) {
      mover[i].collision(-1);
      gravity.mult(0);
      gravity.add(0, -.0025*sq(m));
      //gravity = new PVector(0, -dist(mover[i].location.x,mover[i].location.y, mover[i].location.x, divider)*.0005*sq(m));
    } else {
      mover[i].collision(1);
      gravity.mult(0);
      gravity.add(0, .0025*sq(m));
      //gravity = new PVector(0, dist(mover[i].location.x,mover[i].location.y, mover[i].location.x, divider)*.0005*sq(m));
    }

    mover[i].applyForce(gravity);

    mover[i].update();
    mover[i].checkEdges();
  }
  pctlX = ctlX;
  pctlY = ctlY;
  pctlZ = ctlZ;
}

void oscSend() {
  if (millis() % 5 == 0) {
    index = 0;
    for (int i = 0; i < 800; i++) {
      int r = i*100;
      mover[i].speakerPanning();
      float freq = sq((abs(mover[r].velocity.x) - mover[r].velocity.y)*2) + mover[r].pitch;
      float mag = constrain(mover[r].clrBr *.0025 + (mover[i].mass*.1), 0., .9);
      index = i;

      OscMessage part = new OscMessage("part"); 
      part.add(freq); 
      //part.add(mover[i].clrHue); 
      part.add(mag); 
      part.add(index); 
      part.add(mover[i].location.x); 
      part.add(mover[i].location.y);
      //part.add(mover[i].mass);
      oscP5.send(part, audioPC);
      OscMessage panning = new OscMessage("panning");
      //panning.add(speakersOutput);
      panning.add(speakerVal);  
      oscP5.send(panning, audioPC);
    }
  }
}
