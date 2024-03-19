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

static final int platform_speed = 5;
static final int platform_width = 128;
static final int platform_height = 9;

class Platform {
    int x = arena_x_center;
    int y = arena_height + (2 * (arena_margin + arena_border)) - (4 * arena_margin);
}

Platform platform = new Platform();

// -------------------------------------------------------------------------------- //

static final int brick_rows = 4;
static final int brick_cols = 8;

static final int brick_margin = 4;
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

class Ball{
    int x = arena_x_center;
    int y = arena_y_center;
    int heading = 0;
}

Ball ball = new Ball();

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
}

// -------------------------------------------------------------------------------- //

void draw_ball() {
    fill(#FFFFFF);
    stroke(#FFFFFF);
    strokeWeight(1);
    ellipse(ball.x, ball.y, ball_size, ball_size);
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
}

// -------------------------------------------------------------------------------- //
