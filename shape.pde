
void floatShape(float rotoMIDI, float r, float x, float y) {
  PVector shapeLoc = new PVector(r, rotoMIDI);
  shapeLoc.x = x;
  shapeLoc.y = y;
  float sVertx = 150 + (sin(rotoMIDI * .0004)*20);
  float sVerti = 90 + (cos(rotoMIDI * .00045)*10);
  float sVerty = 125 + (sin(rotoMIDI * .0005)*20);
  pg.pushMatrix();
  pg.translate(shapeLoc.x, shapeLoc.y);
  pg.rotate(shapeLoc.x*.01);
  pg.fill(objClr);
  pg.noStroke();
  pg.beginShape();
  pg.vertex(-sVertx, 0);
  pg.vertex(-sVerti, -sVerti);
  pg.vertex(0, -sVerty);
  pg.vertex(sVerti, -sVerti);
  pg.vertex(sVertx, 0);
  pg.vertex(sVerti, sVerti);
  pg.vertex(0, sVerty);
  pg.vertex(-sVerti, sVerti);
  pg.endShape(CLOSE);
  pg.fill(bkg);
  pg.rectMode(CENTER);
  for(int i = 0; i < 20; i++){
    pg.rect(sin(i)*150,cos(i)*130,sin(rotoMIDI*.0001)*300,cos(rotoMIDI*.001)*20);
    pg.rect(sin(rotoMIDI*.0001 * i)*10 + (tan(i)*10),cos(rotoMIDI*.0008 * i)*10 * (noise(i)*5),noise(i+1)*20,noise(i*3)*30);
  }
  pg.rect(0,0,20,20);
 
  pg.popMatrix();

  //pg.ellipse(r, height/2, 500 + (cos(shapeLoc.x)*50), 200 + (sin(shapeLoc.x)*25));
  //pg.fill(bkg);
  //pg.ellipse(r, height/2, 150 + (sin(shapeLoc.x)*50), 150+ (cos(shapeLoc.x)*25));
}
