
import processing.core.PFont;

// -------------------------------------------------------------------------------- //

static final int arena_margin = 16;
static final int bottom_bar_height = 60;

static final int arean_width = 800 - (2*arena_margin);
static final int arean_height = 600 - (2*arena_margin) - bottom_bar_height;
static final int vertical_arena_center = (arean_height/2) + arena_margin;
static final int horizontal_arean_center = (arean_width/2) + arena_margin;

static final int border_width = 8;
static final int hit_line_width = 8;

static final int scores_size = 32;
static final int scores_distance_form_center = 40;
String font_path = "KodeMono.ttf";

static final int button_width = 100;
static final int button_height = 50;

// -------------------------------------------------------------------------------- //

int start_button_state = 0;
int reset_button_state = 0;

int game_state = 0;

int top_border_reflection_lock = 0;
int bottom_border_reflection_lock = 0;
int player_reflection_lock = 0;

// -------------------------------------------------------------------------------- //

int ball_speed = 5;
int ball_size = 20;

class Ball{
    int x = horizontal_arean_center;
    int y = vertical_arena_center;
    int heading = 0;
}

Ball ball = new Ball();

// -------------------------------------------------------------------------------- //

int player_speed = 5;
int player_width = 8;
int player_height = 100;
int player_margin = 20;
int deviation_factor = 30; // Deviation of the reflection angle depending on the position of the ball on the paddle

class Player{
    int id = 0;
    int scores = 0;
    int y = 0;
    int x = arena_margin + player_margin + (2 * border_width);

    char up_button = 'w';
    char down_button = 's';
}

Player player_A = new Player();
Player player_B = new Player();

// -------------------------------------------------------------------------------- //

void setup(){
    size(800, 600);
    frameRate(60);

    // Chane default values for player B\
    player_B.id = 1;
    player_B.x = width - (arena_margin + player_margin + (2 * border_width));
    player_B.up_button = 'o';
    player_B.down_button = 'l';
}

void draw(){
    draw_board();
    update_game_state();

    draw_pleyer(player_A);
    draw_pleyer(player_B);

    draw_ball();
}

// -------------------------------------------------------------------------------- //

void draw_board(){
    background(#000000);
    draw_aren();
    draw_bottom_bar();

}

void draw_aren(){
    // Arena border
    fill(#000000);
    stroke(#FFFFFF);
    strokeWeight(border_width);
    rect(arena_margin, arena_margin, arean_width, arean_height);

    // Right hit line
    stroke(#FF0000);
    strokeWeight(hit_line_width);
    strokeCap(SQUARE);
    line(arena_margin + (border_width/2) + (hit_line_width/2), arena_margin + (border_width/2), arena_margin + (border_width/2) + (hit_line_width/2), arean_height + arena_margin - (border_width/2));

    // Left hit line
    stroke(#FF0000);
    strokeWeight(hit_line_width);
    strokeCap(SQUARE);
    line(arena_margin + arean_width - (border_width/2) - (hit_line_width/2), arena_margin + (border_width/2), arena_margin + arean_width - (border_width/2) - (hit_line_width/2), arean_height + arena_margin - (border_width/2));

    // Middle line
    stroke(#FFFFFF, 100);
    strokeWeight(hit_line_width);
    strokeCap(SQUARE);
    line(arena_margin + (arean_width/2), arena_margin + (border_width/2), arena_margin + (arean_width/2), arean_height + arena_margin - (border_width/2));
}

void draw_bottom_bar(){
    // Font setup
    PFont font;
    font = createFont(font_path, scores_size);

    // Points player A
    fill(#FFFFFF);
    textAlign(CENTER, CENTER);
    textFont(font, scores_size);
    text(player_A.scores, arena_margin + (arean_width/2) - scores_distance_form_center, arean_height + arena_margin + (bottom_bar_height/2));

    // Points player B
    fill(#FFFFFF);
    textAlign(CENTER, CENTER);
    textFont(font, scores_size);
    text(player_B.scores, arena_margin + (arean_width/2) + scores_distance_form_center, arean_height + arena_margin + (bottom_bar_height/2));

    // Buttons
    start_button_state = draw_button("START", font, arena_margin , arean_height + (2 * arena_margin), button_width, button_height);
    reset_button_state = draw_button("RESET", font, width - arena_margin - button_width, arean_height + (2 * arena_margin), button_width, button_height);
}

int draw_button(String text, PFont font, int x, int y, int w, int h){
    // Rectangle
    fill(#000000);
    stroke(#FFFFFF);
    strokeWeight(4);
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

void update_game_state(){
    if(start_button_state == 1){
        game_state = 1;
    }

    if(reset_button_state == 1){
        game_state = 0;

        player_A.scores = 0;
        player_B.scores = 0;

        player_A.y = 0;
        player_B.y = 0;
        
        ball.x = horizontal_arean_center;
        ball.y = vertical_arena_center;
        ball.heading = 0;
    }
}

// -------------------------------------------------------------------------------- //

void draw_pleyer(Player player){
    int player_x1 = player.x;
    int player_x2 = player.x;
    int player_y1 = vertical_arena_center + player.y - (player_height/2);
    int player_y2 = vertical_arena_center + player.y + (player_height/2);

    // Player paddle
    stroke(#FFFFFF);
    strokeWeight(player_width);
    strokeCap(SQUARE);
    line(player_x1, player_y1, player_x2, player_y2);

    // Player movement
    if(keyPressed){
        if(key == player.up_button){
            player.y -= player_speed;
        }
        if(key == player.down_button){
            player.y += player_speed;
        }
    }

    // Player limits
    if(vertical_arena_center + player.y - (player_height/2) < arena_margin + border_width){
        player.y = (arena_margin + border_width) - vertical_arena_center + (player_height/2);
    }
    if(vertical_arena_center + player.y + (player_height/2) > arean_height + arena_margin - border_width){
        player.y = (arean_height + arena_margin - border_width) - vertical_arena_center - (player_height/2);
    }

    if(game_state == 1){
        check_if_ball_hit_player(player, player_x1, player_y1, player_x2, player_y2);
    }
}

void check_if_ball_hit_player(Player player ,int x1, int y1, int x2, int y2){
    int x_distance = ball.x - player.x - ((player_width/2) + (ball_size/2));
    if(player.id == 1){
        x_distance = player.x - ball.x - ((player_width/2) + (ball_size/2));
    }

    int y_distance = ball.y - (vertical_arena_center + player.y);

    // fill(#FFFFFF);
    // textAlign(CENTER, CENTER);
    // text(x_distance, 12*arena_margin + (player.id * 100), 4*arena_margin);
    // text(y_distance, 12*arena_margin + (player.id * 100), 8*arena_margin);

    int reflection_angle = calculate_ball_reflection_angle(y_distance);
    // show_reflection_angle(reflection_angle);

    if(ball.y >= y1 && ball.y <= y2){
        if(x_distance < 0 && x_distance > -1*(ball_size/2)){
            if(player_reflection_lock == 0){
                ball.heading = reflection_angle;
                player_reflection_lock = 1;
                top_border_reflection_lock = 0;
                bottom_border_reflection_lock = 0;
            }
        }
    }

    int distance_from_area_center = abs(ball.x - horizontal_arean_center);
    if(distance_from_area_center < 100){
        player_reflection_lock = 0;
    }

    fix_ball_heading();
}



int calculate_ball_reflection_angle(int distance_from_center){
    float deviation_angle = (float)(distance_from_center / (float)(player_height/2)) * (float)deviation_factor;

    int reflection_angle = 180 - ball.heading; 
    if(reflection_angle < 0){
        reflection_angle = 360 + reflection_angle;
    }
    if(reflection_angle > 360){
        reflection_angle = reflection_angle - 360;
    }

    reflection_angle -= deviation_angle;
    return reflection_angle;
}

void show_reflection_angle(int reflection_angle){
    int line_length = 100;
    int reflection_x = horizontal_arean_center + (int)(line_length * cos(radians(reflection_angle)));
    int reflection_y = vertical_arena_center + (int)(line_length * sin(radians(reflection_angle)));

    stroke(#0000FF);
    strokeWeight(4);
    strokeCap(SQUARE);
    line(horizontal_arean_center, vertical_arena_center, reflection_x, reflection_y);
}

void fix_ball_heading(){
    if(ball.heading < 0){
        ball.heading = 360 + ball.heading;
    }
    if(ball.heading > 360){
        ball.heading = ball.heading - 360;
    }

    int save_anglemargin = 15;

    if(ball.heading > 90 - save_anglemargin && ball.heading < 90 + save_anglemargin){
        if(ball.heading > 90 - save_anglemargin && ball.heading < 90){
            ball.heading = 90 - save_anglemargin;
        }
        else{
            ball.heading = 90 + save_anglemargin;
        }
    }

    if(ball.heading > 270 - save_anglemargin && ball.heading < 270 + save_anglemargin){
        if(ball.heading > 270 - save_anglemargin && ball.heading < 270){
            ball.heading = 270 - save_anglemargin;
        }
        else{
            ball.heading = 270 + save_anglemargin;
        }
    }
}



// -------------------------------------------------------------------------------- //

void draw_ball(){
    fill(#FFFFFF);
    noStroke();
    ellipse(ball.x, ball.y, ball_size, ball_size);

    // draw_ball_heading();

    if(game_state == 1){
        ball.x += (int)(ball_speed * (float)cos(radians(ball.heading)));
        ball.y += (int)(ball_speed * (float)sin(radians(ball.heading)));
    }

    check_if_ball_hit_border();
}


void draw_ball_heading(){
    int line_length = 100;
    int end_x = horizontal_arean_center + (int)(line_length * cos(radians(ball.heading)));
    int end_y = vertical_arena_center + (int)(line_length * sin(radians(ball.heading)));

    stroke(#FF0000);
    strokeWeight(4);
    strokeCap(SQUARE);
    line(horizontal_arean_center, vertical_arena_center, end_x, end_y);

    fill(#FFFFFF);
    textAlign(CENTER, CENTER);
    text(ball.heading, 4*arena_margin, 4*arena_margin);
}

void check_if_ball_hit_border(){
    int hit_back_border = 0;

    // top border
    if(ball.y <= arena_margin + border_width + (ball_size/2)){
        if(top_border_reflection_lock == 0){
            ball.heading = 360 - ball.heading;
        }
        top_border_reflection_lock = 1;
    }
    else{
        top_border_reflection_lock = 0;
    }

    // bottom border
    if(ball.y >= arean_height + arena_margin - border_width - (ball_size/2)){
        if(bottom_border_reflection_lock == 0){
            ball.heading = 360 - ball.heading;
        }
        bottom_border_reflection_lock = 1;
    }
    else{
        bottom_border_reflection_lock = 0;
    }

    // left border
    if(ball.x < arena_margin + border_width){
        player_B.scores += 1;
        ball.heading = 0;
        hit_back_border = 1;
    }

    // right border
    if(ball.x > arean_width + arena_margin - border_width){
        player_A.scores += 1;
        ball.heading = 180;
        hit_back_border = 1;
    }

    if(hit_back_border == 1){
        delay(1000);
        ball.x = horizontal_arean_center;
        ball.y = vertical_arena_center;
        game_state = 0;
    }
}

// -------------------------------------------------------------------------------- //
