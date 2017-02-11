/* @pjs crisp=true; 
globalKeyEvents=true; 
pauseOnBlur=true; 
preload="data/decrease_fractal_stage_button_1.png, data/decrease_fractal_stage_button_2.png, data/export_button_1.png, data/export_button_2.png, data/free_button_1.png, data/free_button_2.png, data/go_button_1.png, data/go_button_2.png, data/increase_fractal_stage_button_1.png, data/increase_fractal_stage_button_2.png, data/next_example_button_1.png, data/next_example_button_2.png, data/prev_example_button_1.png, data/prev_example_button_2.png, data/reset_button_1.png, data/reset_button_2.png, data/square_button_1.png, data/square_button_2.png, data/triangle_button_1.png, data/triangle_button_2.png, decrease_fractal_stage_button_1.png, decrease_fractal_stage_button_2.png, export_button_1.png, export_button_2.png, free_button_1.png, free_button_2.png, go_button_1.png, go_button_2.png, increase_fractal_stage_button_1.png, increase_fractal_stage_button_2.png, next_example_button_1.png, next_example_button_2.png, prev_example_button_1.png, prev_example_button_2.png, reset_button_1.png, reset_button_2.png, square_button_1.png, square_button_2.png, triangle_button_1.png, triangle_button_2.png"; 
 */

int fractal_stage, numberOfLines, example_index;
float canvas_x, canvas_y, canvas_radius, display_x, display_y, display_radius, fractal_stroke_weight, display_x_off, display_y_off;
String canvas_mode;
Fractal canvas_fractal;
Fractal[] display_fractals, examples;
Button go_button, reset_button, increase_fractal_stage_button, decrease_fractal_stage_button, square_button, triangle_button, free_button, export_button, next_example_button, prev_example_button;
Scroller fractal_stroke_weight_scroller;
PImage save_file;

void setup() {
  size(960, 720);
  rectMode(CENTER);
  imageMode(CENTER);
  textFont(createFont("Arial", 40, true));
  textAlign(CENTER, CENTER);
  fractal_stage = 0;
  example_index = 0;

  canvas_x = width*0.17;
  canvas_y = height-canvas_x;
  canvas_radius = width*0.3;
  canvas_mode = "square";
  display_x = width-height*0.43;
  display_y = height*0.43;
  display_radius = height*0.8;
  numberOfLines = 20;
  canvas_fractal = new Fractal();
  canvas_fractal.display_mode = false;
  display_fractals = new Fractal[8];
  examples = new Fractal[23];
  loadExamples();
  for (int i = 0; i < display_fractals.length; i++) {
    display_fractals[i] = new Fractal();
  }
  fractal_stroke_weight = 1;
  fractal_stroke_weight_scroller = new Scroller(width*0.3, height*0.05, 100);

  go_button = new Button(width*0.3, height*0.4, "go_button_1.png", "go_button_2.png");
  reset_button = new Button(width*0.1, height*0.4, "reset_button_1.png", "reset_button_2.png");
  export_button = new Button(width*0.185, height*0.25, "export_button_1.png", "export_button_2.png");

  square_button = new Button(width*0.05, height*0.5, "square_button_1.png", "square_button_2.png");
  triangle_button = new Button(width*0.175, height*0.5, "triangle_button_1.png", "triangle_button_2.png");
  free_button = new Button(width*0.3, height*0.5, "free_button_1.png", "free_button_2.png");

  increase_fractal_stage_button = new Button(display_x+width*0.15, display_y+display_radius/2+height*0.08, "increase_fractal_stage_button_1.png", "increase_fractal_stage_button_2.png");
  decrease_fractal_stage_button = new Button(display_x-width*0.15, display_y+display_radius/2+height*0.08, "decrease_fractal_stage_button_1.png", "decrease_fractal_stage_button_2.png");

  next_example_button = new Button(display_x-width*0.265, display_y+display_radius/2+height*0.05, "next_example_button_1.png", "next_example_button_2.png");
  prev_example_button = new Button(display_x-width*0.265, display_y+display_radius/2+height*0.11, "prev_example_button_1.png", "prev_example_button_2.png");
}

void draw() {
  //background(200, 240, 140);
  background(230);

  //canvas
  stroke(0);

  //rect(display_x, display_y, display_radius, display_radius);
  strokeWeight(fractal_stroke_weight);
  if (display_fractals[fractal_stage].points.size() > 0) {
    display_fractals[fractal_stage].display();
  }
  strokeWeight(1);
  fill(0, 1);
  stroke(0);
  rect(display_x, display_y, display_radius, display_radius);

  fill(200, 240, 140);
  rectMode(CORNERS);
  noStroke();
  rect(0, 0, width, display_y-display_radius/2);
  rect(0, display_y-display_radius/2, display_x-display_radius/2, height);
  rect(display_x-display_radius/2, display_y+display_radius/2, width, height);
  rect(display_x+display_radius/2, display_y-display_radius/2, width, display_y+display_radius/2);
  stroke(0);
  rectMode(CENTER);
  fill(230);

  drawCanvas(canvas_x, canvas_y, canvas_radius);
  updateCanvas();

  reset_button.display();
  go_button.display();
  export_button.display();

  square_button.display();
  triangle_button.display();
  free_button.display();

  increase_fractal_stage_button.display();
  decrease_fractal_stage_button.display();
  
  next_example_button.display();
  prev_example_button.display();

  fractal_stroke_weight_scroller.display();
  textSize(20);
  fill(0);
  text("Line thickness: ", width*0.1, height*0.045);

  fill(0);
  textSize(40);
  text("Stage: " + (fractal_stage + 1), display_x, display_y+display_radius/2+height*0.075);
}

void loadExamples() {
  for (int i = 0; i < examples.length; i++) {
    examples[i] = new Fractal();
  }
  
  examples[0].points.add(get_fractal_point(0, 0.5));
  examples[0].points.add(get_fractal_point(1.0/3, 0.5));
  examples[0].points.add(get_fractal_point(0.5, 0.5-sqrt(3)/6.0));
  examples[0].points.add(get_fractal_point(2.0/3, 0.5));
  examples[0].points.add(get_fractal_point(1, 0.5));
  for (int i = 0; i < 4; i++) {
    examples[0].lines.add("forward");
  }
  
  examples[1].points.add(get_fractal_point(0, 0.5));
  examples[1].points.add(get_fractal_point(0.5, 0.5));
  examples[1].points.add(get_fractal_point(0.25, 0.5-sqrt(3)/4.0));
  examples[1].points.add(get_fractal_point(0.75, 0.5-sqrt(3)/4.0));
  examples[1].points.add(get_fractal_point(0.5, 0.5));
  examples[1].points.add(get_fractal_point(1, 0.5));
  examples[1].lines.add("forward");
  examples[1].lines.add("non-recursive");
  examples[1].lines.add("forward");
  examples[1].lines.add("non-recursive");
  examples[1].lines.add("forward");
  
  examples[2].points.add(get_fractal_point(0.25, 0.5));
  examples[2].points.add(get_fractal_point(0.5, 0.25));
  examples[2].points.add(get_fractal_point(0.75, 0.5));
  examples[2].lines.add("forward");
  examples[2].lines.add("backward");
  
  examples[3].points.add(get_fractal_point(0, 0.5));
  examples[3].points.add(get_fractal_point(1.0/3, 0.5));
  examples[3].points.add(get_fractal_point(1.0/3, 0.5-1.0/3));
  examples[3].points.add(get_fractal_point(2.0/3, 0.5-1.0/3));
  examples[3].points.add(get_fractal_point(2.0/3, 0.5));
  examples[3].points.add(get_fractal_point(1.0/3, 0.5));
  examples[3].points.add(get_fractal_point(1.0/3, 0.5+1.0/3));
  examples[3].points.add(get_fractal_point(2.0/3, 0.5+1.0/3));
  examples[3].points.add(get_fractal_point(2.0/3, 0.5));
  examples[3].points.add(get_fractal_point(1, 0.5));
  examples[3].lines.add("forward");
  examples[3].lines.add("forward");
  examples[3].lines.add("forward");
  examples[3].lines.add("forward");
  examples[3].lines.add("invisible");
  examples[3].lines.add("forward");
  examples[3].lines.add("forward");
  examples[3].lines.add("forward");
  examples[3].lines.add("forward");
  
  examples[4].points.add(get_fractal_point(0, 0.5));
  examples[4].points.add(get_fractal_point(0.6, 0.3));
  examples[4].points.add(get_fractal_point(0.4, 0.3));
  examples[4].points.add(get_fractal_point(1, 0.5));
  examples[4].lines.add("forward");
  examples[4].lines.add("forward");
  examples[4].lines.add("forward");
  
  examples[5].points.add(get_fractal_point(0, 0.5));
  examples[5].points.add(get_fractal_point(0.5, 0.4));
  examples[5].points.add(get_fractal_point(0.4, 0.4+sqrt(3)*0.1));
  examples[5].points.add(get_fractal_point(0.6, 0.4+sqrt(3)*0.1));
  examples[5].points.add(get_fractal_point(0.5, 0.4));
  examples[5].points.add(get_fractal_point(1, 0.5));
  for (int i = 0; i < 5; i++) {
    examples[5].lines.add("forward");
  }
  
  examples[6].points.add(get_fractal_point(0, 0.5));
  examples[6].points.add(get_fractal_point(0.5, 0.4));
  examples[6].points.add(get_fractal_point(0.4, 0.4+sqrt(3)*0.1));
  examples[6].points.add(get_fractal_point(0.6, 0.4+sqrt(3)*0.1));
  examples[6].points.add(get_fractal_point(0.5, 0.4));
  examples[6].points.add(get_fractal_point(1, 0.5));
  for (int i = 0; i < 5; i++) {
    examples[6].lines.add("backward");
  }
  
  examples[7].points.add(get_fractal_point(0.5, 1));
  examples[7].points.add(get_fractal_point(0.5, 0.7));
  examples[7].points.add(get_fractal_point(0.55, 0.12));
  examples[7].points.add(get_fractal_point(0.5, 0.8));
  examples[7].points.add(get_fractal_point(0.35, 0.5));
  examples[7].points.add(get_fractal_point(0.5, 0.86));
  examples[7].points.add(get_fractal_point(0.65, 0.45));
  examples[7].points.add(get_fractal_point(0.5, 0));
  examples[7].lines.add("non-recursive");
  examples[7].lines.add("forward");
  examples[7].lines.add("invisible");
  examples[7].lines.add("forward");
  examples[7].lines.add("invisible");
  examples[7].lines.add("forward");
  examples[7].lines.add("invisible");
  
  examples[8].points.add(get_fractal_point(0, 0.5));
  examples[8].points.add(get_fractal_point(0.43, 0.37));
  examples[8].points.add(get_fractal_point(0.5, 0.75));
  examples[8].points.add(get_fractal_point(0.57, 0.37));
  examples[8].points.add(get_fractal_point(1, 0.5));
  for (int i = 0; i < 4; i++) {
    examples[8].lines.add("forward");
  }
  
  examples[9].points.add(get_fractal_point(0.25, 1));
  examples[9].points.add(get_fractal_point(0.27, 0.7));
  examples[9].points.add(get_fractal_point(0.48, 0.6));
  examples[9].points.add(get_fractal_point(0.52, 0.7));
  examples[9].points.add(get_fractal_point(0.8, 0.8));
  examples[9].points.add(get_fractal_point(0.75, 1));
  examples[9].lines.add("non-recursive");
  examples[9].lines.add("forward");
  examples[9].lines.add("non-recursive");
  examples[9].lines.add("forward");
  examples[9].lines.add("non-recursive");
  
  examples[10].points.add(get_fractal_point(0, 0.5));
  examples[10].points.add(get_fractal_point(0.6, 0.6));
  examples[10].points.add(get_fractal_point(0.5, 0.6-sqrt(3)*0.1));
  examples[10].points.add(get_fractal_point(0.7, 0.6-sqrt(3)*0.1));
  examples[10].points.add(get_fractal_point(0.6, 0.6));
  examples[10].points.add(get_fractal_point(1, 0.5));
  for (int i = 0; i < 5; i++) {
    examples[10].lines.add("forward");
  }
  
  examples[11].points.add(get_fractal_point(0, 0.5));
  examples[11].points.add(get_fractal_point(0.35, 0.5));
  examples[11].points.add(get_fractal_point(0.36, 0.37));
  examples[11].points.add(get_fractal_point(0.3, 0.4));
  examples[11].points.add(get_fractal_point(0.4, 0.2));
  examples[11].points.add(get_fractal_point(0.5, 0.4));
  examples[11].points.add(get_fractal_point(0.44, 0.36));
  examples[11].points.add(get_fractal_point(0.45, 0.5));
  examples[11].points.add(get_fractal_point(0.47, 0.75));
  examples[11].points.add(get_fractal_point(0.33, 0.77));
  examples[11].points.add(get_fractal_point(0.35, 0.5));
  examples[11].points.add(get_fractal_point(0.45, 0.5));
  examples[11].points.add(get_fractal_point(1, 0.5));
  examples[11].lines.add("forward");
  examples[11].lines.add("non-recursive");
  examples[11].lines.add("non-recursive");
  examples[11].lines.add("non-recursive");
  examples[11].lines.add("non-recursive");
  examples[11].lines.add("non-recursive");
  examples[11].lines.add("non-recursive");
  examples[11].lines.add("non-recursive");
  examples[11].lines.add("non-recursive");
  examples[11].lines.add("non-recursive");
  examples[11].lines.add("invisible");
  examples[11].lines.add("forward");
  
  examples[12].points.add(get_fractal_point(0.2, 0.5));
  examples[12].points.add(get_fractal_point(1.0/3, 0.25));
  examples[12].points.add(get_fractal_point(2.0/3, 0.25));
  examples[12].points.add(get_fractal_point(0.8, 0.45));
  examples[12].points.add(get_fractal_point(2.0/3, 0.25));
  for (int i = 0; i < 3; i++) {
    examples[12].lines.add("forward");
  }
  examples[12].lines.add("invisible");
  
  examples[13].points.add(get_fractal_point(0.15, 0.5));
  examples[13].points.add(get_fractal_point(0.5, 0.5));
  examples[13].points.add(get_fractal_point(0.85, 0.5));
  examples[13].points.add(get_fractal_point(1.0/3, 0.2));
  examples[13].points.add(get_fractal_point(2.0/3, 0.2));
  examples[13].lines.add("forward");
  examples[13].lines.add("forward");
  examples[13].lines.add("invisible");
  examples[13].lines.add("forward");
  
  examples[14].points.add(get_fractal_point(0.1, 0.6));
  examples[14].points.add(get_fractal_point(0.25, 0.75));
  examples[14].points.add(get_fractal_point(0.25, 0.45));
  examples[14].points.add(get_fractal_point(0.55, 0.45));
  examples[14].points.add(get_fractal_point(0.55, 0.75));
  examples[14].points.add(get_fractal_point(0.25, 0.6));
  examples[14].points.add(get_fractal_point(0.55, 0.6));
  examples[14].points.add(get_fractal_point(0.7, 0.6));
  examples[14].lines.add("invisible");
  examples[14].lines.add("forward");
  examples[14].lines.add("forward");
  examples[14].lines.add("forward");
  examples[14].lines.add("invisible");
  examples[14].lines.add("forward");
  examples[14].lines.add("invisible");
  
  examples[15].points.add(get_fractal_point(0, 0.5));
  examples[15].points.add(get_fractal_point(0.25, 0.85));
  examples[15].points.add(get_fractal_point(0.25, 0.35));
  examples[15].points.add(get_fractal_point(0.28, 0.32));
  examples[15].points.add(get_fractal_point(0.72, 0.32));
  examples[15].points.add(get_fractal_point(0.75, 0.35));
  examples[15].points.add(get_fractal_point(0.75, 0.85));
  examples[15].points.add(get_fractal_point(0.27, 0.5));
  examples[15].points.add(get_fractal_point(0.73, 0.5));
  examples[15].points.add(get_fractal_point(1, 0.5));
  examples[15].lines.add("invisible");
  examples[15].lines.add("forward");
  examples[15].lines.add("invisible");
  examples[15].lines.add("forward");
  examples[15].lines.add("invisible");
  examples[15].lines.add("forward");
  examples[15].lines.add("invisible");
  examples[15].lines.add("forward");
  examples[15].lines.add("invisible");
  
  examples[16].points.add(get_fractal_point(0, 0.5));
  examples[16].points.add(get_fractal_point(0.5, 0.5));
  examples[16].points.add(get_fractal_point(1, 0.5));
  examples[16].points.add(get_fractal_point(0.25, 0.75));
  examples[16].points.add(get_fractal_point(0.25, 0.25));
  examples[16].points.add(get_fractal_point(0.75, 0.75));
  examples[16].points.add(get_fractal_point(0.75, 0.25));
  examples[16].points.add(get_fractal_point(1, 0.5));
  examples[16].lines.add("forward");
  examples[16].lines.add("forward");
  examples[16].lines.add("invisible");
  examples[16].lines.add("forward");
  examples[16].lines.add("invisible");
  examples[16].lines.add("forward");
  examples[16].lines.add("invisible");
  
  examples[17].points.add(get_fractal_point(0.15, 0.3));
  examples[17].points.add(get_fractal_point(0.85, 0.3));
  examples[17].points.add(get_fractal_point(0.5, 0.6));
  examples[17].points.add(get_fractal_point(0.15, 0.3));
  examples[17].points.add(get_fractal_point(0.85, 0.3));
  examples[17].lines.add("invisible");
  examples[17].lines.add("forward");
  examples[17].lines.add("forward");
  examples[17].lines.add("invisible");
  
  examples[18].points.add(get_fractal_point(0, 0.6));
  examples[18].points.add(get_fractal_point(0.5-(0.0625*sqrt(10-2*sqrt(5))), 0.6));
  examples[18].points.add(get_fractal_point(0.5, 0.6-(0.125*(sqrt(5)+1)) ));
  examples[18].points.add(get_fractal_point(0.5+(0.0625*sqrt(10-2*sqrt(5))), 0.6));
  examples[18].points.add(get_fractal_point(0.5-(0.0625*sqrt(10+2*sqrt(5))), 0.6-(0.125*(sqrt(5)+1))+(0.125*(sqrt(5)-1)) ));
  examples[18].points.add(get_fractal_point(0.5+(0.0625*sqrt(10+2*sqrt(5))), 0.6-(0.125*(sqrt(5)+1))+(0.125*(sqrt(5)-1)) ));
  examples[18].points.add(get_fractal_point(0.5-(0.0625*sqrt(10-2*sqrt(5))), 0.6));
  examples[18].points.add(get_fractal_point(1, 0.6));
  examples[18].lines.add("invisible");
  examples[18].lines.add("forward");
  examples[18].lines.add("forward");
  examples[18].lines.add("forward");
  examples[18].lines.add("forward");
  examples[18].lines.add("forward");
  examples[18].lines.add("invisible");
  
  examples[19].points.add(get_fractal_point(0.2, 0.65));
  examples[19].points.add(get_fractal_point(0.2, 0.35));
  examples[19].points.add(get_fractal_point(0.5, 0.35));
  examples[19].points.add(get_fractal_point(0.5, 0.65));
  examples[19].points.add(get_fractal_point(0.8, 0.65));
  examples[19].points.add(get_fractal_point(0.8, 0.35));
  for (int i = 0; i < 5; i++) {
    examples[19].lines.add("forward");
  }
  
  examples[20].points.add(get_fractal_point(0.2, 0.1));
  examples[20].points.add(get_fractal_point(0.5-0.08*sqrt(10+2*sqrt(5)), 0.16+0.2*(sqrt(5)-1)));
  examples[20].points.add(get_fractal_point(0.5, 0.2));
  examples[20].points.add(get_fractal_point(0.5+0.08*sqrt(10+2*sqrt(5)), 0.16+0.2*(sqrt(5)-1)));
  examples[20].points.add(get_fractal_point(0.5+0.08*sqrt(10-2*sqrt(5)), 0.16+0.2*(sqrt(5)+1)));
  examples[20].points.add(get_fractal_point(0.5-0.08*sqrt(10-2*sqrt(5)), 0.16+0.2*(sqrt(5)+1)));
  examples[20].points.add(get_fractal_point(0.5-0.08*sqrt(10+2*sqrt(5)), 0.16+0.2*(sqrt(5)-1)));
  examples[20].points.add(get_fractal_point(0.5, 0.35));
  examples[20].points.add(get_fractal_point(0.4, 0.7));
  examples[20].points.add(get_fractal_point(0.85, 0.93));
  examples[20].points.add(get_fractal_point(1, 1));
  examples[20].points.add(get_fractal_point(0, 1));
  examples[20].points.add(get_fractal_point(0.5, 1));
  
  examples[20].lines.add("invisible");
  for (int i = 0; i < 5; i++) {
    examples[20].lines.add("forward");
  }
  examples[20].lines.add("invisible");
  examples[20].lines.add("forward");
  for (int i = 0; i < 4; i++) {
    examples[20].lines.add("invisible");
  }
  
  examples[21].points.add(get_fractal_point(0.2, 0.3));
  examples[21].points.add(get_fractal_point(0.2, 0.5));
  examples[21].points.add(get_fractal_point(0.4, 0.3));
  examples[21].points.add(get_fractal_point(0.6, 0.5));
  examples[21].points.add(get_fractal_point(0.8, 0.3));
  examples[21].points.add(get_fractal_point(0.4, 0.3));
  examples[21].points.add(get_fractal_point(0.6, 0.1));
  examples[21].points.add(get_fractal_point(0.4, 0.7));
  examples[21].points.add(get_fractal_point(0.6, 0.5));
  examples[21].points.add(get_fractal_point(0.8, 0.5));
  examples[21].lines.add("invisible");
  examples[21].lines.add("forward");
  examples[21].lines.add("forward");
  examples[21].lines.add("forward");
  examples[21].lines.add("invisible");
  examples[21].lines.add("forward");
  examples[21].lines.add("invisible");
  examples[21].lines.add("forward");
  examples[21].lines.add("invisible");
  
  examples[22].points.add(get_fractal_point(0.2, 0.9));
  examples[22].points.add(get_fractal_point(0.35, 0.7));
  examples[22].points.add(get_fractal_point(0.5, 0.5));
  examples[22].points.add(get_fractal_point(0.2, 0.7));
  examples[22].points.add(get_fractal_point(0.35, 0.5));
  examples[22].points.add(get_fractal_point(0.5, 0.3));
  examples[22].points.add(get_fractal_point(0.5, 0.9));
  examples[22].points.add(get_fractal_point(0.65, 0.7));
  examples[22].points.add(get_fractal_point(0.5, 0.7));
  examples[22].points.add(get_fractal_point(0.65, 0.5));
  examples[22].points.add(get_fractal_point(0.5, 0.5));
  examples[22].lines.add("forward");
  examples[22].lines.add("invisible");
  examples[22].lines.add("invisible");
  examples[22].lines.add("forward");
  examples[22].lines.add("forward");
  examples[22].lines.add("invisible");
  examples[22].lines.add("invisible");
  examples[22].lines.add("invisible");
  examples[22].lines.add("forward");
  examples[22].lines.add("invisible");
}

PVector get_fractal_point(float x, float y) {
  float canvas_s_radius = canvas_radius*0.9;
  return new PVector(canvas_x+canvas_s_radius*(x-0.5), canvas_y+canvas_s_radius*(y-0.5));
}

void drawCanvas(float x, float y, float radius) {
  fill(230);
  rect(x, y, radius, radius);

  stroke(180);
  if (canvas_mode.equals("square")) {
    for (float i = x-radius/2+radius/numberOfLines; i <= x+radius/2-radius/numberOfLines; i += radius/numberOfLines) {
      line(i, y-radius/2+1, i, y+radius/2-1);
    }
    for (float i = y-radius/2+radius/numberOfLines; i <= y+radius/2-radius/numberOfLines+1; i += radius/numberOfLines) {
      line(x-radius/2+1, i, x+radius/2-1, i);
    }
  } else if (canvas_mode.equals("triangle")) {
    ArrayList<PVector> point_coords = get_triangular_matrix();
    for (PVector point_coord : point_coords) {
      for (PVector point_coord_2 : point_coords) {
        if (dist(point_coord.x, point_coord.y, point_coord_2.x, point_coord_2.y) <= 20) {
          line(point_coord.x, point_coord.y, point_coord_2.x, point_coord_2.y);
        }
      }
    }
  }
  stroke(0);
  canvas_fractal.display();
}

void updateCanvas() {
  float mouse_round = canvas_radius/numberOfLines;
  if ((mouseX > canvas_x - canvas_radius/2) &&
    (mouseX < canvas_x + canvas_radius/2) &&
    (mouseY > canvas_y - canvas_radius/2) &&
    (mouseY < canvas_y + canvas_radius/2)) {
    fill(0);
    if (canvas_mode.equals("square")) {
      ellipse(round(mouseX/mouse_round)*mouse_round+4, round(mouseY/mouse_round)*mouse_round-4, 5, 5);
    } else if (canvas_mode.equals("triangle")) {
      ArrayList<PVector> point_coords = get_triangular_matrix();
      PVector closest_point = new PVector(0, 0);
      for (PVector point_coord : point_coords) {
        if (dist(point_coord.x, point_coord.y, mouseX, mouseY) < dist(closest_point.x, closest_point.y, mouseX, mouseY)) {
          closest_point = point_coord;
        }
      }
      ellipse(closest_point.x, closest_point.y, 5, 5);
    } else if (canvas_mode.equals("free")) {
      ellipse(mouseX, mouseY, 5, 5);
    }
  }
}

void mouseClicked() {
  if ((mouseX > canvas_x - canvas_radius/2) &&
    (mouseX < canvas_x + canvas_radius/2) &&
    (mouseY > canvas_y - canvas_radius/2) &&
    (mouseY < canvas_y + canvas_radius/2)) {
    if (mouseButton == LEFT) {
      float mouse_round = canvas_radius/numberOfLines;

      if (canvas_mode.equals("square")) {
        canvas_fractal.add_point(round(mouseX/mouse_round)*mouse_round+4, round(mouseY/mouse_round)*mouse_round-4);
      } else if (canvas_mode.equals("triangle")) {
        ArrayList<PVector> point_coords = get_triangular_matrix();
        PVector closest_point = new PVector(0, 0);
        for (PVector point_coord : point_coords) {
          if (dist(point_coord.x, point_coord.y, mouseX, mouseY) < dist(closest_point.x, closest_point.y, mouseX, mouseY)) {
            closest_point = point_coord;
          }
        }
        canvas_fractal.add_point(closest_point.x, closest_point.y);
      } else if (canvas_mode.equals("free")) {
        canvas_fractal.add_point(mouseX, mouseY);
      }

      if (canvas_fractal.points.size() > 1) {
        canvas_fractal.add_line(canvas_fractal.points.size()-2, "forward");
      }
    } else if (mouseButton == RIGHT) {
      for (int i = 0; i < canvas_fractal.points.size()-1; i++) {
        float dist_between_pixels = dist(canvas_fractal.points.get(i).x, canvas_fractal.points.get(i).y, canvas_fractal.points.get(i+1).x, canvas_fractal.points.get(i+1).y) + 5;
        float dist_between_mouse = dist(canvas_fractal.points.get(i).x, canvas_fractal.points.get(i).y, mouseX, mouseY) + dist(canvas_fractal.points.get(i+1).x, canvas_fractal.points.get(i+1).y, mouseX, mouseY);
        if (dist_between_pixels > dist_between_mouse) {
          String[] line_types = {"forward", "backward", "non-recursive", "invisible"};
          for (int j = 0; j < line_types.length-1; j++) {
            if (canvas_fractal.lines.get(i).equals(line_types[j])) {
              canvas_fractal.lines.set(i, line_types[j+1]);
              return;
            }
          }
          canvas_fractal.lines.set(i, "forward");
        }
      }
    }
  }

  if (go_button.clicked) {
    go_button.clicked = false;
    //display_fractals = new Fractal[5];
    for (int i = 0; i < display_fractals.length; i++) {
      display_fractals[i] = new Fractal();
    }
    for (int i = 0; i < canvas_fractal.points.size(); i++) {
      float point_x = map(canvas_fractal.points.get(i).x, canvas_x-canvas_radius/2, canvas_x+canvas_radius/2, display_x-display_radius/2, display_x+display_radius/2);
      float point_y = map(canvas_fractal.points.get(i).y, canvas_y-canvas_radius/2, canvas_y+canvas_radius/2, display_y-display_radius/2, display_y+display_radius/2);
      display_fractals[0].add_point(point_x, point_y);
    }
    for (int i = 0; i < canvas_fractal.lines.size(); i++) {
      display_fractals[0].add_line(i, canvas_fractal.lines.get(i));
    }
    for (int i = 1; i < display_fractals.length; i++) {
      display_fractals[i] = display_fractals[i-1].next_gen(i);
    }
    fractal_stage = 0;
  }

  if (reset_button.clicked) {
    reset_button.clicked = false;
    for (int i = 0; i < display_fractals.length; i++) {
      display_fractals[i] = new Fractal();
    }
    canvas_fractal = new Fractal();
    canvas_fractal.display_mode = false;
    fractal_stage = 0;
  }

  if (export_button.clicked) {
    export_button.clicked = false;
    PImage img = createImage(int(display_radius)-1, int(display_radius)-1, RGB);
    img.loadPixels();
    loadPixels();

    for (int i = 0; i < img.width; i++) {
      for (int j = 0; j < img.height; j++) {
        img.pixels[j*img.width+i] = pixels[(j+int(display_y-display_radius/2)+1)*width+(i+int(display_x-display_radius/2)+1)];
      }
    }

    img.updatePixels();
    save_file = img.get();
    selectInput("Select a file to process:", "selectImgFile");
    //img.save("img.png");
  }

  if (square_button.clicked) {
    square_button.clicked = false;
    if (!canvas_mode.equals("square")) {
      canvas_mode = "square";
      square_button.swap_imgs();
      triangle_button.reset_imgs();
      free_button.reset_imgs();
    }
  }

  if (triangle_button.clicked) {
    triangle_button.clicked = false;
    if (!canvas_mode.equals("triangle")) {
      canvas_mode = "triangle";
      triangle_button.swap_imgs();
      square_button.reset_imgs();
      free_button.reset_imgs();
    }
  }

  if (free_button.clicked) {
    free_button.clicked = false;
    if (!canvas_mode.equals("free")) {
      canvas_mode = "free";
      free_button.swap_imgs();
      triangle_button.reset_imgs();
      square_button.reset_imgs();
    }
  }

  if (increase_fractal_stage_button.clicked) {
    increase_fractal_stage_button.clicked = false;
    fractal_stage = constrain(fractal_stage+1, 0, display_fractals.length-1);
  } else if (decrease_fractal_stage_button.clicked) {
    decrease_fractal_stage_button.clicked = false;
    fractal_stage = constrain(fractal_stage-1, 0, display_fractals.length-1);
  }
  
  if (next_example_button.clicked) {
    next_example_button.clicked = false;
    example_index++;
    if (example_index >= examples.length) {
      example_index = 0;
    }
    canvas_fractal = new Fractal();
    for (int i = 0; i < examples[example_index].points.size(); i++) {
      canvas_fractal.points.add(examples[example_index].points.get(i));
    }
    for (int i = 0; i < examples[example_index].lines.size(); i++) {
      canvas_fractal.lines.add(examples[example_index].lines.get(i));
    }
    canvas_fractal.display_mode = false;
  } else if (prev_example_button.clicked) {
    prev_example_button.clicked = false;
    example_index--;
    if (example_index <= 0) {
      example_index = examples.length-1;
    }
    canvas_fractal = new Fractal();
    for (int i = 0; i < examples[example_index].points.size(); i++) {
      canvas_fractal.points.add(examples[example_index].points.get(i));
    }
    for (int i = 0; i < examples[example_index].lines.size(); i++) {
      canvas_fractal.lines.add(examples[example_index].lines.get(i));
    }
    canvas_fractal.display_mode = false;
  }
}

void mouseDragged() {
  fractal_stroke_weight_scroller.mouseDragged();
  fractal_stroke_weight = 10*((fractal_stroke_weight_scroller.position+fractal_stroke_weight_scroller.len/2)/fractal_stroke_weight_scroller.len);

  if (mouseX > display_x-display_radius/2 &&
    mouseX < display_x+display_radius/2 &&
    mouseY > display_y-display_radius/2 &&
    mouseY < display_y+display_radius/2) {
    display_x_off += mouseX-pmouseX;
    display_y_off += mouseY-pmouseY;
    for (int i = 0; i < display_fractals.length; i++) {
      display_fractals[i].x_off = display_x_off;
      display_fractals[i].y_off = display_y_off;
    }
  }
}

ArrayList<PVector> get_triangular_matrix() {
  ArrayList<PVector> point_coords = new ArrayList<PVector>();
  float row_offset = 0;
  for (float j = canvas_y-canvas_radius/2-canvas_radius/numberOfLines; j <= canvas_y+canvas_radius/2; j += (sqrt(3)*canvas_radius)/(numberOfLines*2)) { //(sqrt(3)*radius)/(numberOfLines*2)
    for (float i = canvas_x-canvas_radius/2-canvas_radius/numberOfLines; i <= canvas_x+canvas_radius/2; i += canvas_radius/numberOfLines) {
      if ((i+row_offset > canvas_x-canvas_radius/2) && (i+row_offset < canvas_x+canvas_radius/2-1) && (j > canvas_y-canvas_radius/2) && (j < canvas_y+canvas_radius/2)) {
        point_coords.add(new PVector(i+row_offset, j));
      }
    }
    if (row_offset == 0) {
      row_offset = canvas_radius/(numberOfLines*2);
    } else {
      row_offset = 0;
    }
  }
  return point_coords;
}

void selectImgFile(File selection) {
  if (selection != null) {
    save_file.save(selection.getAbsolutePath()+".jpg");
  }
}
class Button {
  //variables
  PImage img, hovered_img;
  float x, y;
  boolean clicked, swapped;

  //constructors
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
    swapped = false;
  }

  //behaviours
  //display the button
  void display() {
    if (mouseOn() && mousePressed) {
      clicked = true;
    }
    
    //change colour if the mouse is hovering
    if ((hovered_img != null) && mouseOn()) {
      image(hovered_img, x, y);
    } else {
      image(img, x, y);
    }
  }

  //check if the mouse is over the button
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
  
  void swap_imgs() {
    if (hovered_img != null) {
      PImage temp_img = img.get();
      img = hovered_img.get();
      hovered_img = temp_img.get();
      swapped = !swapped;
    }
  }
  
  void reset_imgs() {
    if (hovered_img != null) {
      if (swapped) {
        swap_imgs();
      }
    }
  }
}
class Fractal {
  ArrayList<PVector> points = new ArrayList<PVector>();
  ArrayList<String> lines = new ArrayList<String>();
  float rotation, arrow_offset, x_off, y_off;
  boolean display_mode;
  
  Fractal() {
    rotation = 0;
    arrow_offset = 30;
    display_mode = true;
    x_off = 0;
    y_off = 0;
  }
  
  void add_point(float x, float y) {
    points.add(new PVector(x, y));
  }
  
  void add_line(int i, String type) {
    if (i > lines.size()-1) {
      lines.add(type);
    } else {
      lines.set(i, type);
    }
  }
  
  //void set_line(int index, String type) {
  //  lines.set(index, type);
  //}
  
  void rotate_fractal(float _rotation) {
    rotation += _rotation;
  }
  
  void display() {
    if (points.size() > 0) {
      pushMatrix();
      translate(points.get(0).x, points.get(0).y);
      rotate(radians(rotation));
      for (int i = 0; i < points.size(); i++) {
        fill(0);
        if (!display_mode) {
          ellipse(points.get(i).x-points.get(0).x+x_off, points.get(i).y-points.get(0).y+y_off, 5, 5);
        }
        if (i > 0) {
          if (display_mode) {
            stroke(0);
          } else {
            String[] line_types = {"forward", "backward", "non-recursive", "invisible"};
            color[] line_colors = {color(0, 255, 0), color(0, 0, 255), color(255, 0, 0), color(180)};
            stroke(255, 0, 255);
            for (int j = 0; j < line_types.length; j++) {
              //println(points.size(), lines.size());
              if (lines.get(i-1).equals(line_types[j])) {
                stroke(line_colors[j]);
              }
            }
          }
          if (!display_mode || !lines.get(i-1).equals("invisible")) {
            line(points.get(i).x-points.get(0).x+x_off, points.get(i).y-points.get(0).y+y_off, points.get(i-1).x-points.get(0).x+x_off, points.get(i-1).y-points.get(0).y+y_off);
          }
          noStroke();
        }
      }
      if (!display_mode && points.size() > 1) {
        fill(0, 120);
        rotate(atan2(points.get(points.size()-1).y - points.get(0).y, points.get(points.size()-1).x - points.get(0).x));
        //rect((points.get(points.size()-1).x-points.get(0).x)/2, arrow_offset, (points.get(points.size()-1).x-points.get(0).x), 10);
        rect(dist(points.get(points.size()-1).x+x_off, points.get(points.size()-1).y+y_off, points.get(0).x+x_off, points.get(0).y+y_off)/2, arrow_offset, dist(points.get(points.size()-1).x+x_off, points.get(points.size()-1).y+y_off, points.get(0).x+x_off, points.get(0).y+y_off), 10);
        triangle(dist(points.get(points.size()-1).x+x_off, points.get(points.size()-1).y+y_off, points.get(0).x+x_off, points.get(0).y+y_off) + 10, arrow_offset, dist(points.get(points.size()-1).x+x_off, points.get(points.size()-1).y+y_off, points.get(0).x+x_off, points.get(0).y+y_off), arrow_offset+10, dist(points.get(points.size()-1).x+x_off, points.get(points.size()-1).y+y_off, points.get(0).x+x_off, points.get(0).y+y_off), arrow_offset-10);
      }
      popMatrix();
    }
  }
  
  Fractal next_gen(int iteration) {
    Fractal new_fractal = new Fractal();
    
    for (int i = 0; i < points.size(); i++) {
      new_fractal.add_point(points.get(i).x, points.get(i).y);
      if (i < points.size()-1) {
        if ((lines.get(i).equals("forward") || lines.get(i).equals("backward"))) {
          new_fractal.lines.add(display_fractals[0].lines.get(0));
        } else {
          new_fractal.lines.add(lines.get(i));
        }
      }
      
      if (i < points.size()-1 && (lines.get(i).equals("forward") || lines.get(i).equals("backward"))) {
        float ax, ay, bx, by;
        if (lines.get(i).equals("forward")) {
          ax = points.get(0).x;
          ay = points.get(0).y;
          bx = points.get(points.size()-1).x;
          by = points.get(points.size()-1).y;
        } else {
          ax = points.get(points.size()-1).x;
          ay = points.get(points.size()-1).y;
          bx = points.get(0).x;
          by = points.get(0).y;
        }
        float Ax = points.get(i).x;
        float Ay = points.get(i).y;
        float Bx = points.get(i+1).x;
        float By = points.get(i+1).y;
        
        //float ab = sqrt(pow(bx - ax, 2) + pow(by - ay, 2));
        //float AB = sqrt(pow(Bx - Ax, 2) + pow(By - Ay, 2));
        float ab = dist(ax, ay, bx, by);
        float AB = dist(Ax, Ay, Bx, By);
        
        float scale_factor = AB/ab;
        
        float Dx=(Bx - Ax);
        float Dy=(By - Ay);
        float dx=(bx - ax);
        float dy=(by - ay);
        
        float cos_phi = (Dx*dx + Dy*dy) / (AB*ab);
        float sin_phi = (dx * Dy - dy * Dx)/(AB*ab);
        
        if (lines.get(i).equals("forward")) {
          for (int j = 1; j < display_fractals[0].points.size()-1; j++) {
            float offset_x = display_fractals[0].points.get(j).x - ax;
            float offset_y = display_fractals[0].points.get(j).y - ay;
            float scaled_x = offset_x * scale_factor;
            float scaled_y = offset_y * scale_factor;
            float new_x = scaled_x * cos_phi - scaled_y * sin_phi + Ax;
            float new_y = scaled_x * sin_phi + scaled_y * cos_phi + Ay;
            //println(new_x + " " + new_y);
            //println(scaled_y * cos_phi);
            
            new_fractal.add_point(new_x, new_y);
            new_fractal.lines.add(display_fractals[0].lines.get(j));
            
          }
        } else {
          for (int j = display_fractals[0].points.size()-2; j >= 0; j--) {
            float offset_x = display_fractals[0].points.get(j).x - ax;
            float offset_y = display_fractals[0].points.get(j).y - ay;
            float scaled_x = offset_x * scale_factor;
            float scaled_y = offset_y * scale_factor;
            float new_x = scaled_x * cos_phi - scaled_y * sin_phi + Ax;
            float new_y = scaled_x * sin_phi + scaled_y * cos_phi + Ay;
            //println(new_x + " " + new_y);
            //println(scaled_y * cos_phi);
            
            new_fractal.add_point(new_x, new_y);
            new_fractal.lines.add(display_fractals[0].lines.get(j));
            
          }
        }
        if (points.size() - 1 != lines.size()) {
          println("points: " + points.size() + " lines: " + lines.size());
          exit();
        }
      }
    }
    
    return new_fractal;
  }
}
class Scroller {
  float x, y, len, position, radius;

  Scroller (float _x, float _y, float _len) {
    x = _x;
    y = _y;
    len = _len;
    radius = 5;
  }

  void display() {
    strokeWeight(1);
    stroke(0);
    line(x-len/2, y, x+len/2, y);
    fill(100);
    ellipse(x+position, y, radius*2, radius*2);
  }

  void mouseDragged() {
    if (mouseX < x+position+radius*2 &&
      mouseX > x+position-radius*2 &&
      mouseY < y+radius*2 &&
      mouseY > y-radius*2) {
        position = constrain(mouseX-x, -len/2, len/2);
    }
  }
}