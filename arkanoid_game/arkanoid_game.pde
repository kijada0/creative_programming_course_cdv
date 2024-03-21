import processing.core.PFont;

// -------------------------------------------------------------------------------- //

static int widows_width = 800;
static int windows_height = 600;

static final int arena_margin = 10;
static final int arena_border = 4;
static final int bottom_bar_height = 60;

static final int arena_width = widows_width - (2 * (arena_margin + arena_border));
static final int arena_height = windows_height - (2 * (arena_margin + arena_border)) - bottom_bar_height;

static final int arena_x_center = (widows_width / 2);
static final int arena_y_center = ((windows_height - bottom_bar_height) / 2);
static final int bottom_bar_y_center = windows_height - (bottom_bar_height / 2) - arena_border;

static final int font_size = 32;
static final String font_path = "KodeMono.ttf";

static final int text_box_width = 200;
static final int button_width = 100;
static final int button_height = 50;
static final int text_box_stroke = 4;
static final int bottom_bar_top_y = bottom_bar_y_center - button_height / 2;

// -------------------------------------------------------------------------------- //

static final int platform_speed = 10;
static final int platform_width = 128;
static final int platform_height = 9;

static final int max_left_platform_x = arena_margin + arena_border + (platform_width / 2);
static final int max_right_platform_x = arena_width + (arena_margin + arena_border) - (platform_width / 2);

static final char platform_left_key = 'a';
static final char platform_right_key = 'd';

class Platform {
    int x = arena_x_center;
    int y = arena_height + (2 * (arena_margin + arena_border)) - (4 * arena_margin);
}

Platform platform = new Platform();

// -------------------------------------------------------------------------------- //

static final int brick_rows = 5;
static final int brick_cols = 9;

static final int brick_margin = 0;
static final int brick_width = (arena_width - (brick_margin * (brick_cols - 1)) - (2 * arena_border) - (arena_margin / 2)) / brick_cols;
static final int brick_height = 32;

static final int brick_stroke = 2;
static final int brick_font_size = 20;

class Brick {
    int remaining_hits = 1;
    int x1, y1, x2, y2;
}

Brick[] bricks = new Brick[(brick_rows * brick_cols)];

// -------------------------------------------------------------------------------- //

int ball_speed = 5;
int ball_size = 20;

int deviation_factor = 15;
int move_away_distance = 2;

class Ball{
    float x = arena_x_center;
    float y = arena_y_center;
    float heading = 90;
    int diameter = ball_size/2;
}

Ball ball = new Ball();

int last_bounce_element_id = 0;

// -------------------------------------------------------------------------------- //

int start_button_state = 0;
int reset_button_state = 0;
int game_state = 0;

int remaining_lives = 3;
int score = 0;

// -------------------------------------------------------------------------------- //

void setup(){
    size(800, 600);
    frameRate(30);
    widows_width = width;
    windows_height = height;

    generate_bricks();
}

void draw(){
    background(#000000);
    draw_grid();
    draw_board();
    draw_bricks();
    draw_platform();
    draw_ball();

    // fill(#FFFFFF);
    // textSize(20);
    // textAlign(CENTER, CENTER);
    // text(last_bounce_element_id, arena_x_center, arena_y_center);

    check_state();
}

// -------------------------------------------------------------------------------- //

void generate_bricks() {
    System.out.printf("Generating bricks... \n");
    int index = 0;
    int wall_width = brick_cols * (brick_width + brick_margin) - brick_margin;
    int wall_height = brick_rows * (brick_height + brick_margin) - brick_margin;
    int wall_x_start = arena_x_center - (wall_width / 2);
    int wall_y_start = arena_margin + arena_border + arena_margin;

    for(int i = 0; i < bricks.length; i++){
        bricks[i] = null;
    }

    for (int i = 0; i < brick_rows; i++) {
        for (int j = 0; j < brick_cols; j++) {
            bricks[index] = new Brick();

            bricks[index].remaining_hits += brick_rows - i - 1;
            bricks[index].x1 = wall_x_start + (j * (brick_width + brick_margin));
            bricks[index].y1 = wall_y_start + (i * (brick_height + brick_margin));
            bricks[index].x2 = bricks[index].x1 + brick_width;
            bricks[index].y2 = bricks[index].y1 + brick_height;

            index++;
        }
    }
}

// -------------------------------------------------------------------------------- //

void draw_grid() {
    int x_lines = 2 * 8;
    int y_lines = 2 * 6;

    // Vertical lines
    for (int i = 0; i < x_lines; i++) {
        int x = i * (width / x_lines);
        stroke(#FFFFFF, 25);
        line(x, 0, x, height);
    }

    // Horizontal lines
    for (int i = 0; i < y_lines; i++) {
        int y = i * (height / y_lines);
        stroke(#FFFFFF, 25);
        line(0, y, width, y);
    }
}

// -------------------------------------------------------------------------------- //

void draw_board() {
    draw_arena();
    draw_bottom_bar();
}

void draw_arena() {
    // Arena frame
    fill(#000000);
    stroke(#FFFFFF);
    strokeWeight(arena_border);
    rect(arena_margin, arena_margin, arena_width + (2 * arena_border), arena_height + (2 * arena_border));
}

void draw_bottom_bar(){
    // Font setup
    PFont font;
    font = createFont(font_path, font_size);
    String text;

    // Lives
    text = "Lives: " + remaining_lives;
    draw_rectange_with_text(text, font, arena_margin, bottom_bar_top_y, text_box_width, button_height);

    // Score
    text = String.format("Score: %2d", score);
    draw_rectange_with_text(text, font, width - (arena_margin + text_box_width), bottom_bar_top_y, text_box_width, button_height);

    // Buttons
    start_button_state = draw_button("START", font, arena_x_center - button_width - arena_margin, bottom_bar_top_y, button_width, button_height);
    reset_button_state = draw_button("RESET", font, arena_x_center + arena_margin, bottom_bar_top_y, button_width, button_height);
}

void draw_rectange_with_text(String text, PFont font, int x, int y, int w, int h){
    // Rectangle
    fill(#000000);
    stroke(#FFFFFF);
    strokeWeight(text_box_stroke);
    rect(x, y, w, h);

    // Text
    fill(#FFFFFF);
    textAlign(CENTER, CENTER);
    textFont(font, 24);
    text(text, x + (w/2), y + (h/2));
}

int draw_button(String text, PFont font, int x, int y, int w, int h){
    // Rectangle
    fill(#000000);
    stroke(#FFFFFF);
    strokeWeight(text_box_stroke);
    rect(x, y, w, h);

    // Text
    fill(#FFFFFF);
    textAlign(CENTER, CENTER);
    textFont(font, 24);
    text(text, x + (w/2), y + (h/2));

    // Check if mouse is over the button 
    if(check_if_mouse_is_over_button(x, y, w, h) == 1){
        fill(#FFFFFF, 100);
        rect(x, y, w, h);
        return 1;
    }

    return 0;
}

int check_if_mouse_is_over_button(int x, int y, int w, int h){
    if(mouseX > x && mouseX < x + w && mouseY > y && mouseY < y + h){
        if(mousePressed){
            return 1;
        }
    }

    return 0;
}


// -------------------------------------------------------------------------------- //

void draw_bricks() {
    int index = 0;
    int alive_bricks = 0;
    for (int i = 0; i < brick_rows; i++) {
        for (int j = 0; j < brick_cols; j++) {
            if(bricks == null || bricks[index] == null) {
                System.out.printf("[ERROR] bricks[%d] is null \n", index);
                continue;
            }

            if (bricks[index].remaining_hits > 0) {
                fill(#000000);
                stroke(#FFFFFF);
                strokeWeight(brick_stroke);
                rect(bricks[index].x1, bricks[index].y1, brick_width, brick_height);

                fill(#FFFFFF);
                textSize(brick_font_size);
                textAlign(CENTER, CENTER);
                text(bricks[index].remaining_hits, (bricks[index].x1 + bricks[index].x2) / 2, (bricks[index].y1 + bricks[index].y2) / 2);

                alive_bricks++;
            }
            index++;
        }
    }

    if (alive_bricks == 0) {
        game_state = 2;
    }
}

// -------------------------------------------------------------------------------- //

void draw_platform() {
    fill(#FFFFFF);
    stroke(#FFFFFF);
    strokeWeight(1);
    rect(platform.x - (platform_width / 2), platform.y, platform_width, platform_height);

    if (keyPressed) {
        if (key == platform_left_key) {
            platform.x -= platform_speed;
        }
        if (key == platform_right_key) {
            platform.x += platform_speed;
        }
    }

    if (platform.x < max_left_platform_x) {
        platform.x = max_left_platform_x;
    }

    if (platform.x > max_right_platform_x) {
        platform.x = max_right_platform_x;
    }
}

// -------------------------------------------------------------------------------- //

void draw_ball() {
    fill(#FFFFFF);
    stroke(#FFFFFF);
    strokeWeight(1);
    ellipse((int)ball.x, (int)ball.y, ball_size, ball_size);

    if (game_state == 1) {
        ball.x += ball_speed * cos(radians(ball.heading));
        ball.y += ball_speed * sin(radians(ball.heading));
    }

    handle_ball_collision_with_arena();
    handle_ball_collision_with_platform();
    handle_ball_collision_with_bricks();

    // show_ball_heading();
}

void handle_ball_collision_with_arena() {
    // left wall
    if (ball.x < arena_margin + arena_border && last_bounce_element_id != 10) {
        ball.x = arena_margin + arena_border + move_away_distance;
        ball.heading = 180 - ball.heading;
        last_bounce_element_id = 10;
    }

    // right wall
    if (ball.x > widows_width - (arena_margin + arena_border) && last_bounce_element_id != 11) {
        ball.x = widows_width - (arena_margin + arena_border) - move_away_distance;
        ball.heading = 180 - ball.heading;
        last_bounce_element_id = 11;
    }

    // top wall
    if (ball.y < arena_margin + arena_border && last_bounce_element_id != 12) {
        ball.y = arena_margin + arena_border + move_away_distance;
        ball.heading = 360 - ball.heading;
        last_bounce_element_id = 12;
    }
    
    // bottom wall
    if (ball.y > (arena_height + arena_margin + arena_border) && last_bounce_element_id != 13) {
        ball.y = arena_height - (ball_size / 2) - (platform_height / 2) - move_away_distance;
        ball.heading = 360 - ball.heading;
        remaining_lives--;

        if (remaining_lives == 0) {
            game_state = 3;
        }
        last_bounce_element_id = 13;
    }
}

void handle_ball_collision_with_platform() {
    if(last_bounce_element_id == 20){
        return;
    }

    float distance_from_center = ball.x - platform.x;
    float reflection_angle = calculate_ball_reflection_angle(distance_from_center);

    float platform_left_corner = platform.x - (platform_width / 2);
    float platform_right_corner = platform.x + (platform_width / 2);

    float distance_between_platform_and_ball = abs(ball.y - platform.y) - (platform_height / 2) - (ball_size / 2);

    if(ball.x > platform_left_corner && ball.x < platform_right_corner){
        if(distance_between_platform_and_ball <= 1){
            ball.heading = reflection_angle;
            last_bounce_element_id = 20;

            // move away from the platform
            if(ball.y > platform.y){
                ball.y = platform.y - (platform_height / 2) - (ball_size / 2) - (move_away_distance);
            }
        }
    }
    
    fix_ball_heading();
}

float calculate_ball_reflection_angle(float distance_from_center){
    float deviation_angle = (float)(distance_from_center / (float)(platform_width /2)) * (float)deviation_factor;

    float reflection_angle = 180 + ball.heading;
    reflection_angle += deviation_angle;

    if(reflection_angle < 0){
        reflection_angle = 360.0 + reflection_angle;
    }
    if(reflection_angle > 360){
        reflection_angle = reflection_angle - 360.0;
    }

    // // draw reflection line
    // stroke(#00FF00);
    // strokeWeight(2);
    // line(ball.x, ball.y, ball.x + (100 * cos(radians(reflection_angle))), ball.y + (100 * sin(radians(reflection_angle))));

    // // draw deviation line
    // stroke(#0000FF);
    // strokeWeight(2);
    // line(ball.x, ball.y, ball.x + (100 * cos(radians(ball.heading - deviation_angle))), ball.y + (100 * sin(radians(ball.heading  - deviation_angle))));

    // // display deviation angle
    // fill(#FFFFFF);
    // textSize(20);
    // textAlign(CENTER, CENTER);
    // text(String.format("%2.0f %2.0f %2.0f %2.0f", ball.heading, reflection_angle, deviation_angle, distance_from_center), ball.x, ball.y + 50);

    return reflection_angle;
}

void handle_ball_collision_with_bricks() {
    int index = 0;
    for (int i = 0; i < brick_rows; i++) {
        for (int j = 0; j < brick_cols; j++) {
            if (bricks[index].remaining_hits > 0 && last_bounce_element_id != 100 + index) {
                // Adjust the brick's boundaries to account for the ball's diameter
                float adjusted_x1 = bricks[index].x1 - ball.diameter / 2;
                float adjusted_y1 = bricks[index].y1 - ball.diameter / 2;
                float adjusted_x2 = bricks[index].x2 + ball.diameter / 2;
                float adjusted_y2 = bricks[index].y2 + ball.diameter / 2;

                if (ball.x > adjusted_x1 && ball.x < adjusted_x2 && ball.y > adjusted_y1 && ball.y < adjusted_y2) {
                    bricks[index].remaining_hits--;
                    score++;

                    // Determine which edge the ball hit
                    float left_diff = abs(ball.x - adjusted_x1);
                    float right_diff = abs(ball.x - adjusted_x2);
                    float top_diff = abs(ball.y - adjusted_y1);
                    float bottom_diff = abs(ball.y - adjusted_y2);

                    // Bounce off the closest edge
                    if (left_diff < right_diff && left_diff < top_diff && left_diff < bottom_diff) {
                        ball.heading = 180 - ball.heading; // Left edge
                    } else if (right_diff < top_diff && right_diff < bottom_diff) {
                        ball.heading = 180 - ball.heading; // Right edge
                    } else if (top_diff < bottom_diff) {
                        ball.heading = 360 - ball.heading; // Top edge
                    } else {
                        ball.heading = 360 - ball.heading; // Bottom edge
                    }

                    last_bounce_element_id = 100 + index;
                }
            }
            index++;
        }
    }
}

void fix_ball_heading(){
    if(ball.heading < 0){
        ball.heading = 360 + ball.heading;
    }
    if(ball.heading > 360){
        ball.heading = ball.heading - 360;
    }

    int save_anglemargin = 15;

    if(ball.heading > 360 - save_anglemargin && ball.heading < 0 + save_anglemargin){
        System.out.printf("Fixing ball heading: %f \n", ball.heading);
        if(ball.heading > 90 - save_anglemargin && ball.heading < 90){
            ball.heading = 90 - save_anglemargin;
        }
        else{
            ball.heading = 90 + save_anglemargin;
        }
    }

    if(ball.heading > 180 - save_anglemargin && ball.heading < 180 + save_anglemargin){
        System.out.printf("Fixing ball heading: %f \n", ball.heading);
        if(ball.heading > 270 - save_anglemargin && ball.heading < 270){
            ball.heading = 270 - save_anglemargin;
        }
        else{
            ball.heading = 270 + save_anglemargin;
        }
    }
}

void show_ball_heading(){
    int line_length = 100;
    stroke(#FF0000);
    strokeWeight(2);
    line(ball.x, ball.y, ball.x + (line_length * cos(radians(ball.heading))), ball.y + (line_length * sin(radians(ball.heading))));
}


// -------------------------------------------------------------------------------- //

void check_state() {
    if (game_state == 2) {
        fill(#FFFFFF);
        textSize(40);
        textAlign(CENTER, CENTER);
        text("You win!", arena_x_center, arena_y_center);
    }

    if (game_state == 3) {
        fill(#FFFFFF);
        textSize(40);
        textAlign(CENTER, CENTER);
        text("Game over!", arena_x_center, arena_y_center);
    }


    if (start_button_state == 1) {
        game_state = 1;
    }

    if (reset_button_state == 1) {
        game_state = 0;
        remaining_lives = 3;
        score = 0;
        ball.x = arena_x_center;
        ball.y = arena_y_center;
        ball.heading = 90;
        platform.x = arena_x_center;
        last_bounce_element_id = 0;
        generate_bricks();
    }
}

// -------------------------------------------------------------------------------- //
