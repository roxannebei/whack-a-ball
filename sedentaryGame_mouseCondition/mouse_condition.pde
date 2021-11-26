/*

The following code is for the <mouse> condition:

For the <ball>/<weighted ball> condition: see another .pde file
  
The color tracking implementation is inspired by Daniel Shiffman's Youtube video: https://www.youtube.com/watch?v=nCVZHROb_dE&t=566s

*/

import processing.sound.*;

// hammer, hit, hole, mole_0, mole_1

PImage hole, mole_0, mole_1, mole_2;
int num_of_holes = 11;
float [] hole_x = {670, 315, 1045, 670, 1209, 107, 205, 915, 670, 1127, 418};
float [] hole_y = {245, 296, 296, 444, 488, 488, 763, 589, 719, 763, 589};
//float [] hole_y = {215, 266, 266, 414, 458, 458, 733, 559, 689, 733, 559};
float [] duration_list = {200, 185, 170, 155, 140, 125, 110, 95, 80, 65, 50, 35, 20, 15};
Hole [] hole_list = new Hole[num_of_holes];
Mole [] mole_list = new Mole[num_of_holes];
int a1, a2;
int miss;
float dizz; 
float dizz_factor = 0.15;

// adjusment 
int consecutive_hit = 0;
int consecutive_miss = 0;
int level = 1;
int highest_level = 1;
// false is miss, true is hit
boolean previousPerformance;

// level
int level_notification_duration = 15;
boolean show_level_up = false;
boolean show_level_down = false;
float level_notification_counter = 0;

// text font
PFont nerko_big;
PFont nerko_small;
PFont poiret;
PFont opensans;

// sound
SoundFile levelup;
SoundFile leveldown;
SoundFile ouch;
SoundFile punch;
SoundFile laugh;
SoundFile background;



void setup() {
  size(1500, 900);
  hole = loadImage("hole.png"); //size 334*117
  mole_0 = loadImage("mole_0.png"); //size 391*294
  mole_1 = loadImage("mole_3.png");
  mole_2 = loadImage("mole_2.png");
  
  nerko_big = createFont("NerkoOne-Regular.ttf", 120);
  nerko_small = createFont("NerkoOne-Regular.ttf", 80);
  poiret = createFont("PoiretOne-Regular.ttf", 30);
  opensans = createFont("OpenSans-SemiBold.ttf", 25);
  
  levelup = new SoundFile(this, "levelup.mp3");
  leveldown = new SoundFile(this, "leveldown.mp3");
  ouch = new SoundFile(this, "ouch.mp3");
  laugh = new SoundFile(this, "laugh.mp3");
  punch = new SoundFile(this, "punch.mp3");
  background = new SoundFile(this, "background.mp3");

  for (int i = 0; i < num_of_holes; i++) {
    hole_list[i] = new Hole(hole_x[i], hole_y[i]);
    mole_list[i] = new Mole(hole_x[i]-3, hole_y[i]-78, 0, 0, duration_list[level - 1]);
  }
  while (a1==a2) {
    // so that a1 != a2
    a1=int(random(0, 11));
    a2=int(random(0, 11));
  }
  dizz = duration_list[level - 1] * dizz_factor;
  
  background.play();
  background.loop();
  background.amp(0.8);
}

void draw() {
  setGradient(0, 0, width, height/2.5, color(229, 245, 254), color(150, 210, 245));
  noStroke();
  fill(142, 196, 128);
  ellipse(750, 680, 2000, 1040);

  for (int i = 0; i < num_of_holes; i++) {
    hole_list[i].display();
  }

  mole_list[a1].appear();
  mole_list[a2].appear();
  if (mole_list[a1].reset()) {
    int a0=a2;
    while (a0==a2) {
      a0=int(random(0, 11));
    }
    a1=a0;
  }
  if (mole_list[a2].reset()) {
    int a0=a1;
    while (a0==a1) {
      a0=int(random(0, 11));
    }
    a2=a0;
  }
  
  fill(142, 196, 128);
  textFont(opensans);
  textAlign(LEFT, BOTTOM);
  text("level: " + level + "    miss: " + consecutive_miss + "    hit: " + consecutive_hit + "    best: level " + highest_level, 100, 100);


  if (!mousePressed) {
    image(loadImage("hammer.png"), mouseX-50, mouseY-50, 103, 127); //size 310*383
  } else {
    image(loadImage("hit.png"), mouseX-50, mouseY-50, 125, 103); //size 377*310
  }
  
  check_level_adjustment();
  if (show_level_up){
    level_notification_counter++;
    show_level_up();
  }
  if (show_level_down){
    level_notification_counter++;
    show_level_down();
  }
  if (level_notification_counter > level_notification_duration){
    show_level_up = false;
    show_level_down = false;
    level_notification_counter = 0;
  }
}


void check_level_adjustment(){
  // speed down for 2 consecutive miss
  if (consecutive_miss == 2){
    if (level > 1){
      level--;
      for (int i = 0; i < num_of_holes; i++) {
        mole_list[i].update_speed();
      }
      dizz = duration_list[level - 1] * dizz_factor;
      show_level_down = true;
      
      leveldown.play();
    }
    //reset
    consecutive_miss = 0;
  }
  
  // speed up for 5 consecutive hit
  if (consecutive_hit == 5){
    if (level < 14){
      level++;
      for (int i = 0; i < num_of_holes; i++) {
        mole_list[i].update_speed();
      }
      dizz = duration_list[level - 1] * dizz_factor;
      show_level_up = true;
      
      levelup.play();
    }
    //reset
    consecutive_hit = 0;
  }
  
  if (level > highest_level){
    highest_level = level;
  }
}

void show_level_up(){
  fill(255, 87, 51);
  textAlign(CENTER, CENTER);
  textFont(nerko_big);
  text("Level Up", 750, 450);
  textAlign(CENTER, TOP);
  textFont(nerko_small);
  text("Level " + level, 750, 500);
}

void show_level_down(){
  fill(30, 144, 255);
  textAlign(CENTER, CENTER);
  textFont(nerko_big);
  text("LEVEL DOWN", 750, 450);
  textAlign(CENTER, TOP);
  textFont(nerko_small);
  text("Level " + level, 750, 500);
}


class Hole {
  float x, y;

  Hole(float h_x0, float h_y0) {
    x = h_x0;
    y = h_y0;
  }

  void display() {
    image(hole, x, y, 190, 70);
  }
}

class Mole {
  float x, y, duration;
  int life;
  float init_time;
  boolean hit;

  Mole(float m_x0, float m_y0, float t, int l, float d) {
    x = m_x0;
    y = m_y0;
    life = l;
    init_time = t;
    duration = d;
    hit=false;
  }

  void display_0() {
    image(mole_0, x, y, 195.5, 147);
  }

  void display_1() {
    image(mole_1, x, y-12, 195.5, 160);
  }

  void display_2() {
    image(mole_2, x, y-27, 195.5, 200);
  }
  
  void update_speed() {
    duration = duration_list[level - 1];
  }
  
  boolean hit() {  
    if (mousePressed) {
      if (mouseX>x+50 && mouseX<x+195 && mouseY>y-30 && mouseY<y+110) {
        hit=true;
        punch.play();
        ouch.play();
        return true;
      }
    }
    return false;
  }

  boolean reset() {
    if (init_time>=duration) {
      if (miss>0) {
        
        // count miss
        if (previousPerformance == false){
          // if the previous is miss, then one more miss count
          consecutive_miss++;
        }
        else{
          // if the previous is hit, hit count is reset
          consecutive_hit = 0;
        }
        previousPerformance = false;
      }
      
      miss = 0;
      init_time=0;
      life=0;
      hit=false;
      return true;
    }
    return false;
  }
  
  void appear() {
    init_time++;

    if (init_time<duration-dizz) {
      display_0();
      if (hit()) {
        life++;
        // count hit
        if (previousPerformance == true){
          // if the previous is hit, then one more hit count
          consecutive_hit++;
        }
        else{
          // if the previous is miss, then hit count is reset
          consecutive_miss = 0;
        }
        previousPerformance = true;
        display_1();
        init_time = duration-dizz;
      }
    }
    if (init_time>=duration-dizz && init_time<duration) {
      if (life>0) {
        display_1();
      } else {
        if (miss == 1){
          laugh.play();
        }
        miss++;
        display_2();
      }
    }
  }
  
}



void setGradient(int x, int y, float w, float h, color c1, color c2) {
  //noFill();
  for (int i = y; i <= y+h; i++) {
    float inter = map(i, y, y+h, 0, 1);
    color c = lerpColor(c1, c2, inter);
    stroke(c);
    line(x, i, x+w, i);
  }
}
