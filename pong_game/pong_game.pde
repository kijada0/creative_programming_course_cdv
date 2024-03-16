
import processing.core.PFont;

// -------------------------------------------------------------------------------- //

int arena_margin = 16;
int bottom_bar_height = 60;

int arean_width = 800 - (2*arena_margin);
int arean_height = 600 - (2*arena_margin) - bottom_bar_height;
int vertical_arena_center = (arean_height/2) + arena_margin;

int border_width = 8;
int hit_line_width = 8;

int scores_size = 32;
int scores_distance_form_center = 40;
String font_path = "KodeMono.ttf";

int button_width = 100;
int button_height = 50;

// -------------------------------------------------------------------------------- //

int start_button_state = 0;
int reset_button_state = 0;

int game_state = 0;

// -------------------------------------------------------------------------------- //

int ball_speed = 5;
int ball_size = 20;

class Ball{
    int x = 0;
    int y = 0;
    int heading = 0;
}

Ball ball = new Ball();

// -------------------------------------------------------------------------------- //

int player_speed = 5;
int player_width = 8;
int player_height = 100;
int player_margin = 20;
int deviation_factor = 10; // Deviation of the reflection angle depending on the position of the ball on the paddle

class Player{
    int scores = 0;
    int vertical_posision = 0;
    int horizontal_posision = arena_margin + player_margin + (2 * border_width);

    char up_button = 'w';
    char down_button = 's';
}

Player player_A = new Player();
Player player_B = new Player();

// -------------------------------------------------------------------------------- //

void setup(){
    size(800, 600);
    frameRate(30);

    // Chane default values for player B
    player_B.horizontal_posision = width - (arena_margin + player_margin + (2 * border_width));
    player_B.up_button = 'o';
    player_B.down_button = 'l';
}

void draw(){
    draw_board();
    update_game_state();

    draw_pleyer(player_A, 1);
    draw_pleyer(player_B, 2);


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

        player_A.vertical_posision = 0;
        player_B.vertical_posision = 0;
        
        ball.x = 0;
        ball.y = 0;
    }
}


// -------------------------------------------------------------------------------- //

void draw_pleyer(Player player, int player_number){
    // Player paddle
    stroke(#FFFFFF);
    strokeWeight(player_width);
    strokeCap(SQUARE);
    line(player.horizontal_posision, vertical_arena_center + player.vertical_posision - (player_height/2), player.horizontal_posision, vertical_arena_center + player.vertical_posision + (player_height/2));

    // Player movement
    if(keyPressed){
        if(key == player.up_button){
            player.vertical_posision -= player_speed;
        }
        if(key == player.down_button){
            player.vertical_posision += player_speed;
        }
    }

    // Player limits
    if(vertical_arena_center + player.vertical_posision - (player_height/2) < arena_margin + border_width){
        player.vertical_posision = (arena_margin + border_width) - vertical_arena_center + (player_height/2);
    }
    if(vertical_arena_center + player.vertical_posision + (player_height/2) > arean_height + arena_margin - border_width){
        player.vertical_posision = (arean_height + arena_margin - border_width) - vertical_arena_center - (player_height/2);
    }

}

// -------------------------------------------------------------------------------- //
