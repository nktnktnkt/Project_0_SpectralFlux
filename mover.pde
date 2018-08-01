class Mover {
  PVector location;
  PVector regen;
  PVector velocity;
  PVector acceleration;
  float mass;
  color clr, refclr;
  float alpha;
  float distance; 
  float time = 0;
  float lifeSpan = 0;
  float clrHue, clrBr;
  float pitch;
  float[] sDist = new float[26];

  Mover(float m, float x, float y, float r, float g, float b, float a, float p) {
    mass = m;
    alpha = a;
    location = new PVector(x, y);
    regen = new PVector(x, 0);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    refclr = color(r-alpha, g-alpha, b+alpha);
    pitch = p;
  }

  // Newton’s second law.
  void applyForce(PVector force) {
    //[full] Receive a force, divide by mass, and add to acceleration.
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
    //[end]
  }

  boolean isInside(Liquid l) {
    if (location.x>l.x && location.x<l.x+l.w && location.y>l.y && location.y<l.y+l.h) {
      return true;
    } else {
      return false;
    }
  }

  void drag(Liquid l) {
    float speed = velocity.mag();
    float dragMagnitude = l.c * speed * speed;

    PVector drag = velocity.copy();
    drag.mult(-1);
    drag.normalize();
    drag.mult(dragMagnitude);
    applyForce(drag);
  }

  void life() {
    time = time + 1;
    if (time > lifeSpan) {
      time = 0;
      velocity.mult(0);
      location.mult(0);
      location.add(regen.x, random(height));
    }
  }

  void collision(float d) {
    color c2;
    distance = abs(velocity.mag());
    color c = pg.get(int(location.x +(mass*.5)), int(location.y + (mass*.5)));
    if (d > 0) {
      c2 = pg.get(int(location.x + (mass*.5)), int(location.y + mass + 1));
    } else {
      c2 = pg.get(int(location.x + (mass*.5)), int(location.y - mass - 1));
    }
    float valueBr = brightness(c);
    float valueBr2 = brightness(c2);

    if (valueBr != bkg) {
      PVector direction = velocity.copy();
      if (c == objClr) {
        direction.mult(-2);
      } else {
        direction.x = direction.x + random(-2, 2);

        //direction.y = direction.y + random(-1, 1);
        //if (distance < 7) {
        //  alpha = alpha*distance;
        //}
        direction.mult(-d*.15);
      }
      if (valueBr2 != bkg) {
        direction.add(0, -(velocity.y*.8) - (random(.1, 1)*d));
        location.add(direction);
      } else {
        location.add(direction);
      }
    }
  }

  void update() {
    velocity.add(acceleration);
    velocity.limit(300);
    location.add(velocity);
    acceleration.mult(0);
  }

  void display() {
    clr = color(red(refclr)-100+alpha, green(refclr)-100+alpha, blue(refclr)-100+alpha);
    clrHue = hue(clr);
    clrBr = brightness(clr);
    if (location.x + mass < width && location.x > 0 && location.y + mass < height && location.y > 0) {
      for (int i = int(location.x); i < int(location.x + mass); i++) {
        for (int f = int(location.y); f < int(location.y + mass); f++) {
          int loc = i + f * width;
          if (loc < width * height - 1 && loc >= 0) {
            pg.pixels[loc] = clr;
          }
        }
      }
    }
  }

  void speakerPanning() {
    for (int i = 0; i < speakersPos.length; i++) {
      sDist[i] = abs(location.dist(speakersPos[i]));
      if (sDist[i] < range) {
        speakerVal[i] = map(sDist[i], 0., range, 0, .9);
      } else {
        speakerVal[i] = 0;
      }
    }
  }

  void checkEdges() {

    //bottom and top edge behavior
    if (location.y - mass > height) {
      velocity.y *= -1;
      location.y = height - (location.y - height);
      
    } else if (location.y + mass < 0) {
      location.x = location.x + (width*1.5);
      location.y = abs(location.y);
      velocity.y *= -1;
    }

    //left & right edge behavior 
    if (location.x + mass > width) {
      location.x = 0;
      
    } else if (location.x - mass < 0) {
      location.x = width - mass;
    }
  }
}
