//float space = 172.5;

class Trigger { //platforms to jump between
  PVector pos;
  PVector dim;
  Boolean isNull;

  Trigger(float x, float y, float w, float h) {
    pos = new PVector(x, y);
    dim = new PVector(w, h);
    isNull = false;
  }

  void draw() {
    pushMatrix();
    noStroke();
    fill(#00F9FF);
    rect(pos.x, pos.y, dim.x, dim.y);
    popMatrix();
  }
}

void triggers() {//hard coded platfomrs
  //t1 = new Trigger(width/2 - 120, 695, 50, 10);
  //t2 = new Trigger(width/2 + 120, 695, 50, 10);
  //t3 = new Trigger(40, space*2.5 + 120, 10, 50);
  //t4 = new Trigger(600, space*2.5 + 120, 10, 50);
  //t5 = new Trigger(40, space*2.1, 10, 50);
  //t6 = new Trigger(600, space*2.1, 10, 50);
  //t7 = new Trigger(40, space, 10, 50);
  //t8 = new Trigger(600, space, 10, 50);
  //tNull = new Trigger(0,0,0,0);
  tNull.isNull = true;


  t[0] = t1;
  t[1] = t2;
  t[2] = t3;
  t[3] = t4;
  t[4] = t5;
  t[5] = t6;
  t[6] = t7;
  t[7] = t8;

  for (int i = 0; i < t.length; i++) {
    t[i].draw(); // draw each platform
  }
}