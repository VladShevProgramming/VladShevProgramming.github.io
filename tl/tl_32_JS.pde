/* @pjs preload="load_button.png, load_button_hovered.png, play_button.png, play_button_hovered.png, tank.png, vlad_tank.png, willi_tank.png"; 
 */

ArrayList<Player> players;
ArrayList<Bullet> bullets;
ArrayList<Wall> walls;
ArrayList<Powerup> powerups;
ArrayList<Particle> particles;
int game_over_timer, powerup_timer;
Game game;

void setup() {
  size(960, 720);
  game = new Game();
}

void draw() {
  game.update();
}

void keyPressed() {
  if (game.state.equals("play")) {
    for (int i = 0; i < players.size(); i++) {
      players.get(i).keyPressed();
    }
  }
}

void keyReleased() {
  if (game.state.equals("play")) {
    for (int i = 0; i < players.size(); i++) {
      players.get(i).keyReleased();
    }
  }
}

void mouseReleased() {
  if (game.state.equals("play")) {
    for (int i = 0; i < players.size(); i++) {
      players.get(i).mouseReleased();
    }
  } else if (game.state.equals("choose_player")) {
    game.mouseReleased();
  }
}
class Bullet {
  PVector location, velocity;
  int player_of, fuse, radius, last_wall;
  boolean is_dead, fragment;
  String type;
  float rotation, rotation_increase, rotation_slow;
  
  Bullet(PVector _location, float _speed, float direction, int _player_of, boolean _fragment) {
    location = new PVector(_location.x, _location.y);
    velocity = new PVector(_speed*cos(radians(direction)), _speed*sin(radians(direction)));
    player_of = _player_of;
    radius = 10;
    fuse = 500;
    is_dead = false;
    type = "";
    last_wall = 1000;
    fragment = _fragment;
    
    if (fragment) {
      rotation = random(360);
      rotation_increase = random(1, 3);
      rotation_slow = 0.99;
    }
  }
  
  Bullet(PVector _location, float _speed, float direction, int _player_of, int _radius, boolean _fragment) {
    location = new PVector(_location.x, _location.y);
    velocity = new PVector(_speed*cos(radians(direction)), _speed*sin(radians(direction)));
    player_of = _player_of;
    radius = _radius;
    fuse = 500;
    is_dead = false;
    type = "";
    last_wall = 1000;
    fragment = _fragment;
    
    if (fragment) {
      rotation = random(360);
      rotation_increase = random(1, 3);
      rotation_slow = 0.99;
    }
  }
  
  void update() {
    location.add(velocity);
    rotation += rotation_increase;
    rotation_increase *= rotation_slow;
    
    fuse--;
    if (fuse <= -20) {
      is_dead = true;
    }
    
    checkWalls();
    display();
  }
  
  void display() {
    if (fuse >= 0) {
      fill(0);
    } else {
      fill(0, 255/-fuse);
    }
    if (fragment) {
      pushMatrix();
      translate(location.x, location.y);
      rotate(radians(rotation));
      triangle(-radius/2, -sqrt(3)*radius/6, radius/2, -sqrt(3)*radius/6, 0, sqrt(3)*radius/3);
      popMatrix();
    } else {
      ellipse(location.x, location.y, radius, radius);
    }
  }
  
  void checkWalls() {
    for (int i = 0; i < walls.size(); i++) {
      if (checkWall(walls.get(i)) && i != last_wall) {
        if (fragment) {
          is_dead = true;
          break;
        }
        last_wall = i;
        if (walls.get(i).dimesions.x == 10) {
          if (location.y < walls.get(i).location.y-walls.get(i).dimesions.y/2 || location.y > walls.get(i).location.y+walls.get(i).dimesions.y/2) {
            velocity = new PVector(velocity.x, velocity.y*-1);
          } else {
            velocity = new PVector(velocity.x*-1, velocity.y);
          }
        } else {
          if (location.x < walls.get(i).location.x-walls.get(i).dimesions.x/2 || location.x > walls.get(i).location.x+walls.get(i).dimesions.x/2) {
            velocity = new PVector(velocity.x*-1, velocity.y);
          } else {
            velocity = new PVector(velocity.x, velocity.y*-1);
          }
        }
        break;
      }
    }
  }
  
  boolean checkWall(Wall wall) {
    return circleRect(location.x, location.y, 5, wall.location.x-wall.dimesions.x/2, wall.location.y-wall.dimesions.y/2, wall.dimesions.x, wall.dimesions.y);
  }
  
  boolean circleRect(float cx, float cy, float radius, float rx, float ry, float rw, float rh) {
  
    // temporary variables to set edges for testing
    float testX = cx;
    float testY = cy;
  
    // which edge is closest?
    if (cx < rx)         testX = rx;      // test left edge
    else if (cx > rx+rw) testX = rx+rw;   // right edge
    if (cy < ry)         testY = ry;      // top edge
    else if (cy > ry+rh) testY = ry+rh;   // bottom edge
  
    // get distance from closest edges
    float distX = cx-testX;
    float distY = cy-testY;
    float distance = sqrt( (distX*distX) + (distY*distY) );
  
    // if the distance is less than the radius, collision!
    if (distance <= radius) {
      return true;
    }
    return false;
  }
}
class Button {
  PImage img, hovered_img;
  float x, y;
  boolean clicked;

  Button(float _x, float _y, String image_name) {
    x = _x;
    y = _y;
    img = loadImage(image_name);
    clicked = false;
  }
  
  Button(float _x, float _y, String image_name, String image_hovered_name) {
    x = _x;
    y = _y;
    img = loadImage(image_name);
    hovered_img = loadImage(image_hovered_name);
    clicked = false;
  }

  void display() {
    if (mouseOn() && mousePressed) {
      clicked = true;
    }
    
    if ((hovered_img != null) && mouseOn()) {
      image(hovered_img, x, y);
    } else {
      image(img, x, y);
    }
  }

  boolean mouseOn () {
    if ((mouseX > x - img.width/2) &&
        (mouseX < x + img.width/2) &&
        (mouseY > y - img.height/2) &&
        (mouseY < y + img.height/2)) {
      return true;
    } else {
      return false;
    }
  }
}
class CustomPlayer extends Player {
  String img_name;
  color low_color, high_color;
  float color_speed, color_index;
  boolean color_increasing;
  
  CustomPlayer(float x, float y, float _direction, String _controls, int _player_number, color _player_color, String _img_name, color _low_color, color _high_color, float _color_speed) {
    super(x, y, _direction, _controls, _player_number, _player_color);
    img_name = _img_name;
    init();
    low_color = _low_color;
    high_color = _high_color;
    color_speed = _color_speed;
    color_increasing = true;
    color_index = 1;
  }
  
  void init() {
    img = loadImage(img_name);
  }
  
  void display() {
    player_color = lerpColor(low_color, high_color, color_index);
    
    if (color_increasing) {
      color_index += 1/color_speed;
      if (color_index >= 1) {
        color_increasing = false;
      }
    } else {
      color_index -= 1/color_speed;
      if (color_index <= 0) {
        color_increasing = true;
      }
    }
    
    super.display();
  }
}
class DeathRay extends Bullet {
  ArrayList<PVector> vertices;
  color theColor;
  DeathRay(PVector _location, float speed, float direction, int _player_of, color _theColor) {
    super(_location, speed, direction, _player_of, false);
    theColor = _theColor;
    fuse = 100;
    vertices = new ArrayList<PVector>();
    vertices.add(new PVector(location.x, location.y));
    type = "death_ray";
    
    float left_side = 1000;
    float right_side = 0;
    float top_side = 1000;
    float bottom_side = 0;
    for (Wall wall : walls) {
      left_side = min(left_side, wall.location.x);
      right_side = max(right_side, wall.location.x);
      top_side = min(top_side, wall.location.y);
      bottom_side = max(bottom_side, wall.location.y);
    }
    
    float player_dis = 10000;
    Player target_enemy = new Player(10000, 10000, 0, null, 1000, color(0));
    for (Player player : players) {
      if (player.player_number != player_of && player_dis > dist(location.x, location.y, player.location.x, player.location.y)) {
        player_dis = dist(location.x, location.y, player.location.x, player.location.y);
        target_enemy = player;
      }
      //print(player.player_number != player_of);
    }
    //print(target_enemy.location.x);
    
    int i = 0;
    float x = velocity.x;
    float y = velocity.y;
    float n = i;
    float k = 0;
    float h = sqrt(n*x*n*x + n*y*n*y);
    float L = sqrt(h*h + n*k*n*k);
    float alpha = atan2(n*y, n*x);
    float theta = atan2(n*k, h);
    float X = L * cos(alpha+theta);
    float Y = L * sin(alpha+theta);
    while (location.x+X < right_side &&
           location.x+X > left_side &&
           location.y+Y > top_side &&
           location.y+Y < bottom_side) {
      
      player_dis = 10000;
      for (Player player : players) {
        if (player.player_number != player_of && player_dis > dist(location.x, location.y, player.location.x, player.location.y)) {
          player_dis = dist(location.x+velocity.x*i, location.y+velocity.y*i, player.location.x, player.location.y);
          target_enemy = player;
        }
      }
      
      float closest_k_value = 0;
      float closes_k_dist = 10000;
      for (float k_value = -0.01; k_value <= 0.01; k_value += 0.001) {
        x = velocity.x;
        y = velocity.y;
        n = i;
        k = n*k_value;
        h = sqrt(n*x*n*x + n*y*n*y);
        L = sqrt(h*h + n*k*n*k);
        alpha = atan2(n*y, n*x);
        theta = atan2(n*k, h);
        X = L * cos(alpha+theta);
        Y = L * sin(alpha+theta);
        
        if (closes_k_dist > dist(location.x+X, location.y+Y, target_enemy.location.x, target_enemy.location.y)) {
          closest_k_value = k_value;
          closes_k_dist = dist(location.x+X, location.y+Y, target_enemy.location.x, target_enemy.location.y);
        }
      }
      
      x = velocity.x;
      y = velocity.y;
      n = i;
      k = n*closest_k_value;
      h = sqrt(n*x*n*x + n*y*n*y);
      L = sqrt(h*h + n*k*n*k);
      alpha = atan2(n*y, n*x);
      theta = atan2(n*k, h);
      X = L * cos(alpha+theta);
      Y = L * sin(alpha+theta);
      vertices.add(new PVector(location.x+X, location.y+Y));
      i += 1;
      //velocity.rotate(atan2(vertices.get(i-1).y-vertices.get(i).y, vertices.get(i-1).x-vertices.get(i).x)+velocity.heading());
    }
    
    for (int j = vertices.size()-2; j >= 1; j--) {
      if (j % 30 != 0) {
        vertices.remove(j);
      }
    }
    vertices.remove(vertices.size()-1);
    
  }
  
  void update() {
    fuse--;
    if (fuse <= 0) {
      is_dead = true;
    }
    display();
  }
  
  void display() {
    stroke(theColor, 120);
    strokeWeight((fuse % 5) * 3);
    noFill();
    curveTightness(0);
    beginShape();
    curveVertex(vertices.get(0).x, vertices.get(0).y);
    for (PVector vertex : vertices) {
      curveVertex(vertex.x, vertex.y);
      ellipse(vertex.x, vertex.y, 10, 10);
    }
    curveVertex(vertices.get(vertices.size()-1).x, vertices.get(vertices.size()-1).y);
    endShape();
    noStroke();
  }
}
class Game {
  String state;
  Button play_button, load_button;
  boolean boolMouseReleased;

  Game() {
    players = new ArrayList<Player>();
    load_game();
    state = "menu";
    play_button = new Button(width*0.5, height*0.4, "play_button.png", "play_button_hovered.png");
    load_button = new Button(width*0.5, height*0.6, "load_button.png", "load_button_hovered.png");
    boolMouseReleased = false;
  }

  void update() {
    background(255);
    if (state.equals("menu")) {
      play_button.display();
      load_button.display();
      if (play_button.clicked) {
        play_button.clicked = false;
        
        if (players.size() == 0) {
          players.add(new Player(random(width*0.25, width*0.75), random(height*0.25, height*0.75), random(360), "1wasd", 1, color(255, 0, 0)));
          players.add(new Player(random(width*0.25, width*0.75), random(height*0.25, height*0.75), random(360), "yijkl", 2, color(0, 255, 0)));
        } else if (players.size() == 1) {
          players.add(new Player(random(width*0.25, width*0.75), random(height*0.25, height*0.75), random(360), "1wasd", 1, color(255, 0, 0)));
        }
        
        state = "play";
      } else if (load_button.clicked) {
        load_button.clicked = false;
        state = "choose_player";
      }
    } else if (state.equals("choose_player")) {
      choose_player();
    } else if (state.equals("play")) {
      update_game();
    }
  }

  void load_game() {
    rectMode(CENTER);
    imageMode(CENTER);
    textSize(20);
    noStroke();
    game_over_timer = 1000000;
    powerup_timer = 300;
    build_level();

    //players = new ArrayList<Player>();
    bullets = new ArrayList<Bullet>();
    powerups = new ArrayList<Powerup>();
    particles = new ArrayList<Particle>();
    
    for (int i = 0; i < players.size(); i++) {
      players.get(i).is_dead = false;
      players.get(i).location = new PVector(random(width*0.25, width*0.75), random(height*0.25, height*0.75));
      players.get(i).direction = random(360);
      players.get(i).powerup = "";
      players.get(i).machine_gun_counter = 0;
      players.get(i).bomb_active = false;
      players.get(i).max_bullets = 5;
      players.get(i).bullet_speed = 5;
      players.get(i).explosion_power = 0;
      players.get(i).speed = 3;
    }
    

    //for (int i = 0; i < 10; i++) {
    //  powerups.add( new Powerup(random(100, width-100), random(100, height-100), "max_bullets", "passive"));
    //}
  }

  void choose_player() {
    ArrayList<JSONObject> player_names = new ArrayList<JSONObject>();
    int counter = 1;
    while (true) {
      try {
        player_names.add(loadJSONObject(counter+".json"));
        counter++;
      } 
      catch (NullPointerException e) {
        break;
      }
    }

    for (float i = 0; i < player_names.size(); i++) {
      fill(0);
      textAlign(CENTER, CENTER);
      textSize(40);
      text(player_names.get(int(i)).getString("name"), width/2, height*0.25+height*0.5*(i/(player_names.size()-1)));
      if ((mouseX > width/2-textWidth(player_names.get(int(i)).getString("name"))/2) &&
        (mouseX < width/2+textWidth(player_names.get(int(i)).getString("name"))/2) &&
        (mouseY > height*0.25+height*0.5*(i/(player_names.size()-1)) - 20) &&
        (mouseY < height*0.25+height*0.5*(i/(player_names.size()-1)) + 20) &&
        (boolMouseReleased)) {
          players.add(new CustomPlayer(random(width*0.25, width*0.75), random(height*0.25, height*0.75), random(360), player_names.get(int(i)).getString("controls"), int(random(10, 10000)), color(player_names.get(int(i)).getInt("red"), player_names.get(int(i)).getInt("green"), player_names.get(int(i)).getInt("blue")), player_names.get(int(i)).getString("img"), color(player_names.get(int(i)).getInt("low_red"), player_names.get(int(i)).getInt("low_green"), player_names.get(int(i)).getInt("low_blue")), color(player_names.get(int(i)).getInt("high_red"), player_names.get(int(i)).getInt("high_green"), player_names.get(int(i)).getInt("high_blue")), player_names.get(int(i)).getInt("color_speed")));
          //players.get(players.size()-1).img = loadImage(player_names.get(int(i)).getString("img"));
      }
    }
    
    if (keyPressed && key == ' ') {
      state = "play";
      
      if (players.size() == 0) {
        players.add(new Player(random(width*0.25, width*0.75), random(height*0.25, height*0.75), random(360), "1wasd", 1, color(255, 0, 0)));
        players.add(new Player(random(width*0.25, width*0.75), random(height*0.25, height*0.75), random(360), "yijkl", 2, color(0, 255, 0)));
      } else if (players.size() == 1) {
        players.add(new Player(random(width*0.25, width*0.75), random(height*0.25, height*0.75), random(360), "1wasd", 1, color(255, 0, 0)));
      }
    }
    
    boolMouseReleased = false;
  }

  void update_game() {
    for (int i = 0; i < bullets.size(); i++) {
      bullets.get(i).update();
    }
    for (int i = bullets.size()-1; i >= 0; i--) {
      if (bullets.get(i).is_dead) {
        bullets.remove(i);
      }
    }

    for (int i = 0; i < walls.size(); i++) {
      walls.get(i).display();
    }

    for (int i = 0; i < powerups.size(); i++) {
      powerups.get(i).update();
    }
    for (int i = powerups.size()-1; i >= 0; i--) {
      if (powerups.get(i).is_dead) {
        powerups.remove(i);
      }
    }

    for (int i = 0; i < particles.size(); i++) {
      particles.get(i).update();
    }
    for (int i = particles.size()-1; i >= 0; i--) {
      if (particles.get(i).is_dead) {
        particles.remove(i);
      }
    }

    int dead_players = 0;
    for (int i = 0; i < players.size(); i++) {
      if (!players.get(i).is_dead) {
        players.get(i).update();
      } else {
        dead_players++;
      }
    }

    if ((dead_players >= players.size()-1) && game_over_timer == 1000000) {
      game_over_timer = 150;
      println(1);
    }

    if (powerup_timer == 0) {
      String[] powerup_types = {"death_ray", "machine_gun", "bomb", "rpg"};
      String[] powerup_types2 = {"speed", "max_bullets", "bullet_speed", "explosion_power"};
      powerups.add(new Powerup(random(width*0.1, width*0.9), random(height*0.1, height*0.9), powerup_types[int(random(powerup_types.length))], "weapon"));
      powerups.add(new Powerup(random(width*0.1, width*0.9), random(height*0.1, height*0.9), powerup_types2[int(random(powerup_types2.length))], "passive"));
      powerup_timer = 300;
    }
    powerup_timer--;

    if (game_over_timer == 0) {
      load_game();
    }
    if (game_over_timer != 1000000) {
      game_over_timer--;
    }

    fill(0);
    textAlign(RIGHT, TOP);
    text("FPS: " + round(frameRate), width, 0);
  }


  void build_level () {
    MazeMaker maze_maker = new MazeMaker();
  }
  
  void mouseReleased() {
    boolMouseReleased = true;
  }
}
class MazeMaker {
  int w = 8;
  int h = 5;
  int[][] vis;
  String[][] ver;
  String[][] hor;

  MazeMaker() {
    vis = new int[h+1][w+1];
    ver = new String[h+1][w+1];
    hor = new String[h+1][w+1];
    walls = new ArrayList<Wall>();
    
    make_maze();
    print("\n\n\n\n\n");
    for (int i = 0; i < vis.length; i++) {
      for (int j = 0; j < hor[i].length; j++) {
        print(hor[i][j]);
        if (hor[i][j].length() > 1) {
           print(hor[i][j].charAt(hor[i][j].length()-1));
        }
      }
      println();
      if (ver[i][0] != null) {
        for (int j = 0; j < ver[i].length; j++) {
          print(ver[i][j]);
          if (ver[i][j].length() > 1) {
            print(ver[i][j].charAt(ver[i][j].length()-1));
          }
        }
        println();
      }
    }
    
    float x_off = 1*width/hor[0].length;
    float y_off = 0.5*height/hor.length;
    for (int i = 0; i < hor.length; i++) {
      for (int j = 0; j < hor[i].length; j++) {
        String type = "normal";
        if (i == 0 || i == hor.length-1) {
          type = "outer";
        }
        if (hor[i][j].equals("+-")) {
          walls.add( new Wall(j*(width/hor[i].length)+x_off, i*(height/hor.length)+y_off, width/hor[i].length+10, 10, type) );
        }
      }
    }
    
    x_off = 0.5*width/hor[0].length;
    y_off = 1*height/hor.length;
    for (int i = 0; i < ver.length-1; i++) {
      for (int j = 0; j < ver[i].length; j++) {
        String type = "normal";
        if (j == 0 || j == ver[i].length-1) {
          type = "outer";
        }
        if (ver[i][j].equals("| ") || ver[i][j].equals("|")) {
          walls.add( new Wall(j*(width/ver[i].length)+x_off, i*(height/ver.length)+y_off, 10, height/ver.length+10, type) );
        }
      }
    }
    
    for (int i = 0; i < int(random(0, 15)); i++) {
      int index = int(random(walls.size()));
      if (!walls.get(index).type.equals("outer")) {
        walls.remove(index);
      }
    }
    
    //ArrayList<Wall> final_walls = new ArrayList<Wall>();
    //final_walls.add(walls.get(0));
    //for (int i = 1; i < walls.size(); i++) {
    //  if (walls.get(i-1).location.y == walls.get(i).location.y && walls.get(i-1).dimesions.x == walls.get(i).dimesions.x && dist(walls.get(i).location.x, walls.get(i).location.y, walls.get(i-1).location.x, walls.get(i-1).location.y) <= walls.get(i-1).dimesions.x/2 + walls.get(i).dimesions.x/2) {
    //    final_walls.get(final_walls.size()-1).dimesions.x = walls.get(i-1).dimesions.x + walls.get(i).dimesions.x;
    //    final_walls.get(final_walls.size()-1).location.x = walls.get(i-1).location.x + walls.get(i-1).dimesions.x/4;//(walls.get(i-1).location.x + walls.get(i).location.x)/2; //(walls.get(i-1).location.x-walls.get(i-1).dimesions.x/2 + walls.get(i).location.x+walls.get(i).dimesions.x/2)/2;
    //  } else {
    //    final_walls.add(walls.get(i));
    //  }
    //}
    //walls = final_walls;
  }
  
  void make_maze() {
    
    for (int i = 0; i < vis.length-1; i++) {
      for (int j = 0; j < vis[i].length-1; j++) {
        vis[i][j] = 0;
      }
      vis[i][vis[i].length-1] = 1;
    }
    for (int j = 0; j < vis[0].length; j++) {
      vis[vis.length-1][j] = 1;
    }
    
    for (int i = 0; i < ver.length-1; i++) {
      for (int j = 0; j < ver[i].length-1; j++) {
        ver[i][j] = "| ";
      }
      ver[i][ver[i].length-1] = "|";
    }
    
    for (int i = 0; i < hor.length; i++) {
      for (int j = 0; j < hor[i].length-1; j++) {
        hor[i][j] = "+-";
      }
      hor[i][hor[i].length-1] = "+";
    }
    
    walk(int(random(w)), int(random(h)));
  }
  
  class Int {
    int x;
    Int (int _x) {
      x = _x;
    }
    
    int get_int() {
      return x;
    }
  }
  
  void walk(int x, int y) {
    vis[y][x] = 1;
    int[][] d = {{x-1, y}, {x, y+1}, {x+1, y}, {x, y-1}};
    ArrayList<Int> d_index_1 = new ArrayList<Int>();
    d_index_1.add(new Int(0));
    d_index_1.add(new Int(1));
    d_index_1.add(new Int(2));
    d_index_1.add(new Int(3));
    
    ArrayList<Int> d_index_2 = new ArrayList<Int>();
    for (int i = 0; i < d_index_1.size(); i++) {
      int a = int(random(d_index_1.size()));
      d_index_2.add(d_index_1.get(a));
      d_index_1.remove(a);
    }
    
    
    for (Int i : d_index_2) {
      int xx = constrain(d[i.get_int()][0], 0, vis[0].length-1);
      int yy = constrain(d[i.get_int()][1], 0, vis.length-1);
      if (vis[yy][xx] == 1) {
        continue;
      }
      if (xx == x) {
        hor[max(y, yy)][x] = "+ ";
      }
      if (yy == y) {
        ver[y][max(x, xx)] = "  ";
      }
      walk(xx, yy);
    }
  }
}
class Particle {
  PVector location, velocity;
  float rotation, rotation_increase, rotation_slow, radius, fuse, max_fuse, fade_index, slowing;
  String type;
  boolean is_dead;
  color theColor;
  
  Particle(float _x, float _y, PVector _velocity, float _radius, float _rotation, float _rotation_increase, float _rotation_slow, String _type, float _fuse, color _theColor, float _fade_index, float _slowing) {
    location = new PVector(_x, _y);
    velocity = new PVector(_velocity.x, _velocity.y);
    radius = _radius;
    rotation = _rotation;
    rotation_increase = _rotation_increase;
    rotation_slow = _rotation_slow;
    type = _type;
    max_fuse = _fuse;
    fuse = _fuse;
    theColor = _theColor;
    fade_index = _fade_index;
    slowing = _slowing;
  }
  
  void update() {
    location.add(velocity);
    velocity.mult(slowing);
    rotation += rotation_increase;
    rotation_increase *= rotation_slow;
    
    if (fuse == 0) {
      is_dead = true;
    }
    fuse--;
    
    display();
  }
  
  void display() {
    float alpha = 255;
    if (fuse <= max_fuse * fade_index) {
      alpha = 255*fuse/(max_fuse*fade_index);
    }
    fill(theColor, alpha);
    if (type.equals("circle")) {
      ellipse(location.x, location.y, radius, radius);
    } else if (type.equals("rect")) {
      pushMatrix();
      translate(location.x, location.y);
      rotate(radians(rotation));
      rect(0, 0, radius, radius);
      popMatrix();
    } else if (type.equals("triangle")) {
      pushMatrix();
      translate(location.x, location.y);
      rotate(radians(rotation));
      triangle(-radius/2, -sqrt(3)*radius/6, radius/2, -sqrt(3)*radius/6, 0, sqrt(3)*radius/3);
      popMatrix();
    }
  }
}
class Player {
  PVector location;
  float direction, speed, sprite_width, sprite_height;
  String controls;
  boolean up_pressed, down_pressed, right_pressed, left_pressed, is_dead, bomb_active;
  int player_number, machine_gun_counter, max_bullets, bullet_speed, explosion_power;
  color player_color;
  String powerup;
  PImage img;
  
  Player(float x, float y, float _direction, String _controls, int _player_number, color _player_color) {
    location = new PVector(x, y);
    direction = _direction;
    speed = 3;
    controls = _controls; //qesdf
    player_number = _player_number;
    player_color = _player_color;
    powerup = "";
    
    img = loadImage("tank.png");
    sprite_width = img.width;
    sprite_height = img.height;
    
    up_pressed = false;
    down_pressed = false;
    right_pressed = false;
    left_pressed = false;
    
    is_dead = false;
    
    machine_gun_counter = 0;
    bomb_active = false;
    max_bullets = 5;
    bullet_speed = 5;
    explosion_power = 0;
  }
  
  void update() {
    move();
    checkDeath();
    checkPassive();
    display();
  }
  
  void move() {
    if (controls.equals("mouse")) {
      boolean collision = false;
      for (Wall wall : walls) {
        if (checkCollision(wall)) {
          collision = true;
        }
      }
        
      float prev_direction = direction;
      direction = degrees(atan2(mouseY-location.y, mouseX-location.x));
      while (!collision) {
        boolean new_collision = false;
        for (Wall wall : walls) {
          if (checkCollision(wall)) {
            new_collision = true;
          }
        }
        
        if (new_collision) {
          if (direction > prev_direction) {
            direction--;
          } else {
            direction++;
          }
        } else {
          break;
        }
      }
      
      if (dist(mouseX, mouseY, location.x, location.y) > 50) {
        location.x += speed * cos(radians(direction));
        location.y += speed * sin(radians(direction));
        
        if (!collision) {
          boolean new_collision = false;
          for (Wall wall : walls) {
            if (checkCollision(wall)) {
              new_collision = true;
            }
          }
          
          if (new_collision) {
            location.x -= speed * cos(radians(direction));
            location.y -= speed * sin(radians(direction));
            particles.add( new Particle(location.x - speed*cos(radians(direction))*10 + random(-10, 10), location.y - speed*sin(radians(direction))*10 + random(-10, 10), new PVector(-speed*cos(radians(direction))/3, -speed*sin(radians(direction))/3), random(10, 15), 0, 0, 0, "circle", 40, color(random(50, 70), random(150, 200)), 1, 0.99));
          }
        }
      }
        
    } else {
      boolean collision = false;
      for (Wall wall : walls) {
        if (checkCollision(wall)) {
          collision = true;
        }
      }
      
      if (up_pressed) {
        location.x += speed * cos(radians(direction));
        location.y += speed * sin(radians(direction));
        
        if (!collision) {
          boolean new_collision = false;
          for (Wall wall : walls) {
            if (checkCollision(wall)) {
              new_collision = true;
            }
          }
          
          if (new_collision) {
            location.x -= speed * cos(radians(direction));
            location.y -= speed * sin(radians(direction));
              //ellipse(location.x - speed*cos(radians(direction))*10 + random(-10, 10), location.y - speed*sin(radians(direction))*10 + random(-10, 10), radius, radius);
              particles.add( new Particle(location.x - speed*cos(radians(direction))*10 + random(-10, 10), location.y - speed*sin(radians(direction))*10 + random(-10, 10), new PVector(-speed*cos(radians(direction))/3, -speed*sin(radians(direction))/3), random(10, 15), 0, 0, 0, "circle", 40, color(random(50, 70), random(150, 200)), 1, 0.99));
          }
        }
        
      }
      if (down_pressed) {
        location.x -= speed * cos(radians(direction));
        location.y -= speed * sin(radians(direction));
        
        if (!collision) {
          boolean new_collision = false;
          for (Wall wall : walls) {
            if (checkCollision(wall)) {
              new_collision = true;
            }
          }
          
          if (new_collision) {
            location.x += speed * cos(radians(direction));
            location.y += speed * sin(radians(direction));
          }
        }
        
      }
      if (right_pressed) {
        direction += 3;
        
        if (!collision) {
          boolean new_collision = false;
          for (Wall wall : walls) {
            if (checkCollision(wall)) {
              new_collision = true;
            }
          }
          
          if (new_collision) {
            direction -= 3;
          }
        }
        
      }
      if (left_pressed) {
        direction -= 3;
        
        if (!collision) {
          boolean new_collision = false;
          for (Wall wall : walls) {
            if (checkCollision(wall)) {
              new_collision = true;
            }
          }
          
          if (new_collision) {
            direction += 3;
          }
        }
        
      }
    }
  }
  
  void shoot() {
    if (machine_gun_counter == 0 || bomb_active) {
      if (powerup.equals("")) {
        int bullets_available = max_bullets;
        for (Bullet bullet : bullets) {
          if (bullet.player_of == player_number) {
            bullets_available--;
          }
        }
        
        if (bullets_available > 0) {
          bullets.add(new Bullet(location, bullet_speed, direction, player_number, false));
        }
      } else if (powerup.equals("death_ray")) {
        bullets.add(new DeathRay(location, 1, direction, player_number, player_color));
        bullets.get(bullets.size()-1).type = "death_ray";
        //powerup = "";
      } else if (powerup.equals("machine_gun")) {
        machine_gun_counter = 150;
        powerup = "";
      } else if (powerup.equals("bomb")) {
        bullets.add(new Bullet(location, 5, direction, player_number, 15, false));
        bullets.get(bullets.size()-1).type = "bomb";
        bomb_active = true;
        powerup = "";
      } else if (powerup.equals("rpg") || powerup.equals("rpg1") || powerup.equals("rpg2")) {
        bullets.add(new RPG(location, direction, player_number));
        String[] rpg_names = {"rpg", "rpg1", "rpg2", ""};
        for (int i = 0; i < rpg_names.length; i++) {
          if (powerup.equals(rpg_names[i])) {
            powerup = rpg_names[i+1];
            break;
          }
        }
      }
    }
  }
  
  void checkDeath() {
    for (int i = bullets.size()-1; i >= 0; i--) {
      if (checkBulletCollision(bullets.get(i)) && (bullets.get(i).fuse < 490 || (bullets.get(i).type.equals("rpg") && bullets.get(i).fuse < 450)) && !bullets.get(i).type.equals("death_ray")) {
        if (bullets.get(i).type.equals("bomb")) {
          for (int j = 0; j < 360; j += int(random(2, 8))) {
            bullets.add (new Bullet(bullets.get(i).location, random(4, 6), j, player_number, 8, true));
          }
        } else if (bullets.get(i).type.equals("rpg")) {
          for (int j = 0; j < 360; j += int(random(10, 15))) {
            bullets.add (new Bullet(bullets.get(i).location, random(4, 6), j, player_number, 8, true));
          }
        }
        bullets.remove(i);
        is_dead = true;
        //game_over_timer = 150;
        if (explosion_power > 0) {
          for (int j = 0; j < pow(2, explosion_power+1); j++) {
            bullets.add (new Bullet(location, constrain(random(explosion_power*2, explosion_power*4), 0, 12), random(360), int(random(100, 10000)), 8, true));
          }
        }
        for (int j = 0; j < int(random(7, 10)); j++) {
          particles.add(new Particle(location.x, location.y, new PVector(random(-1, 1), random(-1, 1)), random(7, 12), random(360), random(1, 3), 0.99, "triangle", 150, player_color, 0.5, 0.99));
        }
        for (int j = 0; j < int(random(7, 10)); j++) {
          particles.add(new Particle(location.x, location.y, new PVector(random(-0.3, 0.3), random(-0.3, 0.3)), random(15, 20), random(360), random(1, 3), 0.99, "circle", 150, color(random(100, 150), random(100, 150)), 0.5, 0.99));
        }
      }
    }
  }
  
  void checkPassive() {
    if (machine_gun_counter > 0) {
      if (machine_gun_counter % 5 == 0) {
        bullets.add(new Bullet(location, 5, direction+random(-10, 10), player_number, 5, false));
      }
      machine_gun_counter--;
    } else if (bomb_active) {
      if ((keyPressed && key == controls.charAt(0)) || (controls.equals("mouse") && mousePressed)) {
        bomb_active = false;
        for (int i = 0; i < bullets.size(); i++) {
          if (bullets.get(i).type.equals("bomb") && bullets.get(i).player_of == player_number) {
            for (int j = 0; j < 360; j += 5) {
              bullets.add (new Bullet(bullets.get(i).location, random(4, 6), j, player_number, 8, true));
            }
            bullets.remove(i);
            break;
          }
        }
      }
    }
  }
  
  boolean checkBulletCollision(Bullet bullet) {
    PVector[] vertices = new PVector[4];
    float h = dist(0, 0, sprite_width/2, sprite_height/2);
    PVector[] vector_coords = {new PVector(sprite_width, sprite_height), new PVector(-sprite_width, sprite_height), new PVector(sprite_width, -sprite_height), new PVector(-sprite_width, -sprite_height)};
    for (int i = 0; i < 4; i++) {
      float theta = atan2(vector_coords[i].y, vector_coords[i].x);
      vertices[i] = new PVector(h*cos(theta+radians(direction))+location.x, h*sin(theta+radians(direction))+location.y);
    }
    return polyCircle(vertices, bullet.location.x, bullet.location.y, bullet.radius/2);
  }
  
  void display() {
    //fill(player_color);
    pushMatrix();
    translate(location.x, location.y);
    rotate(radians(direction));
    tint(player_color);
    image(img, 0, 0);
    popMatrix();
  }
  
  boolean checkCollision(Wall wall) {
    PVector[] vertices = new PVector[4];
    float h = dist(0, 0, sprite_width/2, sprite_height/2);
    PVector[] vector_coords = {new PVector(sprite_width, sprite_height), new PVector(-sprite_width, sprite_height), new PVector(sprite_width, -sprite_height), new PVector(-sprite_width, -sprite_height)};
    for (int i = 0; i < 4; i++) {
      float theta = atan2(vector_coords[i].y, vector_coords[i].x);
      vertices[i] = new PVector(h*cos(theta+radians(direction))+location.x, h*sin(theta+radians(direction))+location.y);
    }
    return polyRect(vertices, wall.location.x-wall.dimesions.x/2, wall.location.y-wall.dimesions.y/2, wall.dimesions.x, wall.dimesions.y);
  }
  
  boolean polyCircle(PVector[] vertices, float cx, float cy, float r) {
  
    // go through each of the vertices, plus
    // the next vertex in the list
    int next = 0;
    for (int current=0; current<vertices.length; current++) {
  
      // get next vertex in list
      // if we've hit the end, wrap around to 0
      next = current+1;
      if (next == vertices.length) next = 0;
  
      // get the PVectors at our current position
      // this makes our if statement a little cleaner
      PVector vc = vertices[current];    // c for "current"
      PVector vn = vertices[next];       // n for "next"
  
      // check for collision between the circle and
      // a line formed between the two vertices
      boolean collision = lineCircle(vc.x,vc.y, vn.x,vn.y, cx,cy,r);
      if (collision) return true;
    }
  
    // the above algorithm only checks if the circle
    // is touching the edges of the polygon – in most
    // cases this is enough, but you can un-comment the
    // following code to also test if the center of the
    // circle is inside the polygon
  
    // boolean centerInside = polygonPoint(vertices, cx,cy);
    // if (centerInside) return true;
  
    // otherwise, after all that, return false
    return false;
  }
  
  
  // LINE/CIRCLE
  boolean lineCircle(float x1, float y1, float x2, float y2, float cx, float cy, float r) {
  
    // get length of the line
    float distX = x1 - x2;
    float distY = y1 - y2;
    float len = sqrt( (distX*distX) + (distY*distY) );
  
    // get dot product of the line and circle
    float dot = ( ((cx-x1)*(x2-x1)) + ((cy-y1)*(y2-y1)) ) / pow(len,2);
  
    // find the closest point on the line
    float closestX = x1 + (dot * (x2-x1));
    float closestY = y1 + (dot * (y2-y1));
  
    // is this point actually on the line segment?
    // if so keep going, but if not, return false
    boolean onSegment = linePoint(x1,y1,x2,y2, closestX,closestY);
    if (!onSegment) return false;
  
    // optionally, draw a circle at the closest point
    // on the line
    fill(255,0,0);
    noStroke();
    //ellipse(closestX, closestY, 20, 20);
  
    // get distance to closest point
    distX = closestX - cx;
    distY = closestY - cy;
    float distance = sqrt( (distX*distX) + (distY*distY) );
  
    // is the circle on the line?
    if (distance <= r) {
      return true;
    }
    return false;
  }
  
  
  boolean polyRect(PVector[] vertices, float rx, float ry, float rw, float rh) {

    // go through each of the vertices, plus the next
    // vertex in the list
    int next = 0;
    for (int current=0; current<vertices.length; current++) {
  
      // get next vertex in list
      // if we've hit the end, wrap around to 0
      next = current+1;
      if (next == vertices.length) next = 0;
  
      // get the PVectors at our current position
      // this makes our if statement a little cleaner
      PVector vc = vertices[current];    // c for "current"
      PVector vn = vertices[next];       // n for "next"
  
      // check against all four sides of the rectangle
      boolean collision = lineRect(vc.x,vc.y,vn.x,vn.y, rx,ry,rw,rh);
      if (collision) return true;
  
      // optional: test if the rectangle is INSIDE the polygon
      // note that this iterates all sides of the polygon
      // again, so only use this if you need to
      boolean inside = polygonPoint(vertices, rx,ry);
      if (inside) return true;
    }
  
    return false;
  }
  
  boolean lineRect(float x1, float y1, float x2, float y2, float rx, float ry, float rw, float rh) {

    // check if the line has hit any of the rectangle's sides
    // uses the Line/Line function below
    boolean left =   lineLine(x1,y1,x2,y2, rx,ry,rx, ry+rh);
    boolean right =  lineLine(x1,y1,x2,y2, rx+rw,ry, rx+rw,ry+rh);
    boolean top =    lineLine(x1,y1,x2,y2, rx,ry, rx+rw,ry);
    boolean bottom = lineLine(x1,y1,x2,y2, rx,ry+rh, rx+rw,ry+rh);
  
    // if ANY of the above are true,
    // the line has hit the rectangle
    if (left || right || top || bottom) {
      return true;
    }
    return false;
  }
    
    // LINE/LINE
  boolean lineLine(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
  
    // calculate the direction of the lines
    float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
    float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  
    // if uA and uB are between 0-1, lines are colliding
    if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {
      return true;
    }
    return false;
  }
  
  
  // POLYGON/POINT
  // only needed if you're going to check if the rectangle
  // is INSIDE the polygon
  boolean polygonPoint(PVector[] vertices, float px, float py) {
    boolean collision = false;
  
    // go through each of the vertices, plus the next
    // vertex in the list
    int next = 0;
    for (int current=0; current<vertices.length; current++) {
  
      // get next vertex in list
      // if we've hit the end, wrap around to 0
      next = current+1;
      if (next == vertices.length) next = 0;
  
      // get the PVectors at our current position
      // this makes our if statement a little cleaner
      PVector vc = vertices[current];    // c for "current"
      PVector vn = vertices[next];       // n for "next"
  
      // compare position, flip 'collision' variable
      // back and forth
      if (((vc.y > py && vn.y < py) || (vc.y < py && vn.y > py)) &&
           (px < (vn.x-vc.x)*(py-vc.y) / (vn.y-vc.y)+vc.x)) {
              collision = !collision;
      }
    }
    return collision;
  }
  
  boolean linePoint(float x1, float y1, float x2, float y2, float px, float py) {

    // get distance from the point to the two ends of the line
    float d1 = dist(px,py, x1,y1);
    float d2 = dist(px,py, x2,y2);
  
    // get the length of the line
    float lineLen = dist(x1,y1, x2,y2);
  
    // since floats are so minutely accurate, add
    // a little buffer zone that will give collision
    float buffer = 0.1;    // higher # = less accurate
  
    // if the two distances are equal to the line's
    // length, the point is on the line!
    // note we use the buffer here to give a range, rather
    // than one #
    if (d1+d2 >= lineLen-buffer && d1+d2 <= lineLen+buffer) {
      return true;
    }
    return false;
  }



  
  void keyPressed() {
    if (!controls.equals("mouse")) {
      if (key == controls.charAt(1)) {
        up_pressed = true;
      }
      if (key == controls.charAt(3)) {
        down_pressed = true;
      }
      if (key == controls.charAt(2)) {
        left_pressed = true;
      }
      if (key == controls.charAt(4)) {
        right_pressed = true;
      }
    }
  }
  
  void keyReleased() {
    if (!controls.equals("mouse")) {
      if (key == controls.charAt(0) && !is_dead) {
        shoot();
      }
      if (key == controls.charAt(1)) {
        up_pressed = false;
      }
      if (key == controls.charAt(3)) {
        down_pressed = false;
      }
      if (key == controls.charAt(2)) {
        left_pressed = false;
      }
      if (key == controls.charAt(4)) {
        right_pressed = false;
      }
    }
  }
  
  void mouseReleased() {
    if (controls.equals("mouse") && !is_dead) {
      shoot();
    }
  }
}
class Powerup {
  PVector location;
  float rotation, rotation_increase, animation_timer, max_animation_timer;
  String name, type;
  boolean is_dead;
  
  Powerup(float x, float y, String _name, String _type) {
    location = new PVector(x, y);
    name = _name;
    type = _type;
    max_animation_timer = random(100, 200);
    animation_timer = 0;
    rotation = random(360);
    rotation_increase = 6;
    is_dead = false;
  }
  
  void update() {
    display();
    checkPlayer();
  }
  
  void display() {
    if (animation_timer < max_animation_timer) {
      animation_timer++;
      rotation += rotation_increase*(1-(animation_timer/max_animation_timer));
    }
    
    pushMatrix();
    translate(location.x, location.y);
    rotate(radians(rotation));
    if (type.equals("weapon")) {
      fill(150, 150);
    } else {
      fill(30, 60, 150, 150);
    }
    stroke(0, 150);
    strokeWeight(1*(animation_timer/max_animation_timer));
    rect(0, 0, 20*(animation_timer/max_animation_timer), 20*(animation_timer/max_animation_timer));
    drawSprite();
    noStroke();
    popMatrix();
  }
  
  void drawSprite() {
    fill(0, 120);
    noStroke();
    if (name.equals("bomb")) {
      ellipse(0, 0, 10*(animation_timer/max_animation_timer), 10*(animation_timer/max_animation_timer));
    } else if (name.equals("death_ray")) {
      rect(0, -6*(animation_timer/max_animation_timer), 15*(animation_timer/max_animation_timer), 4*(animation_timer/max_animation_timer), 20);
      rect(0, 0, 15*(animation_timer/max_animation_timer), 4*(animation_timer/max_animation_timer), 20);
      rect(0, 6*(animation_timer/max_animation_timer), 15*(animation_timer/max_animation_timer), 4*(animation_timer/max_animation_timer), 20);
    } else if (name.equals("machine_gun")) {
      for (int i = 0; i < 3; i++) {
      pushMatrix();
      rotate(radians(60*i));
      ellipse(6*(animation_timer/max_animation_timer), 0, 5*(animation_timer/max_animation_timer), 5*(animation_timer/max_animation_timer));
      ellipse(-6*(animation_timer/max_animation_timer), 0, 5*(animation_timer/max_animation_timer), 5*(animation_timer/max_animation_timer));
      popMatrix();
      }
    } else if (name.equals("rpg")) {
      triangle(5*(animation_timer/max_animation_timer), 3*(animation_timer/max_animation_timer), 5*(animation_timer/max_animation_timer), -3*(animation_timer/max_animation_timer), 8*(animation_timer/max_animation_timer), 0);
      triangle(5*(animation_timer/max_animation_timer), 3*(animation_timer/max_animation_timer), 5*(animation_timer/max_animation_timer), -3*(animation_timer/max_animation_timer), 2*(animation_timer/max_animation_timer), 0);
      rect(-2*(animation_timer/max_animation_timer), 0, 10*(animation_timer/max_animation_timer), 2*(animation_timer/max_animation_timer));
    }
  }
  
  void checkPlayer() {
    if (animation_timer < max_animation_timer) {
      return;
    }
    
    for (int i = 0; i < players.size(); i++) {
      if (type.equals("weapon")) {
        if (players.get(i).powerup.equals("") && dist(players.get(i).location.x, players.get(i).location.y, location.x, location.y) < 15) {
          players.get(i).powerup = name;
          is_dead = true;
          return;
        }
      } else {
        if (dist(players.get(i).location.x, players.get(i).location.y, location.x, location.y) < 15) {
          if (name.equals("speed")) {
            players.get(i).speed *= 1.2;
          } else if (name.equals("max_bullets")) {
            players.get(i).max_bullets += 2;
          } else if (name.equals("bullet_speed")) {
            players.get(i).bullet_speed += 2;
          } else if (name.equals("explosion_power")) {
            players.get(i).explosion_power++;
          }
          is_dead = true;
          return;
        }
      }
    }
  }
}
class RPG extends Bullet {
  RPG(PVector _location, float direction, int _player_of) {
    super(_location, 1, direction, _player_of, false);
    type = "rpg";
  }
  
  void update() {
    velocity.mult(1.1);
    
    PVector new_velocity = new PVector(velocity.x, velocity.y);
    float index = velocity.mag();
    new_velocity.mult(1/index);
    for (float i = 0; i < index; i++) {
      location.add(new_velocity);
      checkWalls();
      particles.add(new Particle(location.x+random(-3, 3), location.y+random(-3, 3), new PVector(random(-0.3, 0.3), random(-0.3, 0.3)), random(10, 15), 0, 0, 0, "circle", 50, color(245, 100, 5, 50), 0, 0.99));
      if (is_dead) {
        break;
      }
    }
    
    fuse--;
    if (fuse <= 0) {
      is_dead = true;
    }
    
    if (is_dead) {
     explode(); 
    }
    
    display();
    
    //for (int i = 0; i < velocity.mag()/5; i++) {
    //  particles.add(new Particle(location.x+random(-3, 3), location.y+random(-3, 3), new PVector(random(-0.3, 0.3), random(-0.3, 0.3)), random(10, 15), 0, 0, 0, "circle", 50, color(245, 100, 5, 50), 0, 0.99));
    //}
  }
  
  void checkWalls() {
    for (int i = 0; i < walls.size(); i++) {
      if (checkWall(walls.get(i))) {
        is_dead = true;
      }
    }
  }
  
  void explode() {
    for (int j = 0; j < 360; j += int(random(10, 15))) {
      bullets.add (new Bullet(location, random(4, 6), j, player_of, 8, true));
    }
  }
  
  void display() {
    //fill(245, 100, 5);
    fill(150, 150);
    pushMatrix();
    translate(location.x, location.y);
    rotate(velocity.heading());
    triangle(5, 3, 5, -3, 8, 0);
    triangle(5, 3, 5, -3, 2, 0);
    rect(-2, 0, 10, 2);
    popMatrix();
  }
}
class Wall {
  PVector location, dimesions;
  String type;
  
  Wall (float x, float y, float _width, float _height, String _type) {
    location = new PVector(x, y);
    dimesions = new PVector(_width, _height);
    type = _type;
  }
  
  void display() {
    fill(100);
    rect(location.x, location.y, dimesions.x, dimesions.y);
    //fill(255, 0, 0);
    //if (dimesions.x == 10) {
    //  ellipse(location.x, location.y-dimesions.y/2, 20, 20);
    //  ellipse(location.x, location.y+dimesions.y/2, 20, 20);
    //} else {
    //  ellipse(location.x-dimesions.x/2, location.y, 20, 20);
    //  ellipse(location.x+dimesions.x/2, location.y, 20, 20);
    //}
  }
}