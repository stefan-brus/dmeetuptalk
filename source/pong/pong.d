module pong.pong;

import pong.game;

// Pong!
class Pong : Game
{
    import pong.ball;
    import pong.boundary;
    import pong.paddle;

    import derelict.sdl2.sdl;

    import std.math;

    // Helpful constants for movement angles
    // The paddles can only move up or down
    private enum MOVEMENT_UP = PI_2;
    private enum MOVEMENT_DOWN = 3 * PI_2;

    // Reference to the window surface
    private SDL_Surface* window_surface;

    // The player paddle
    private Paddle player;

    // The computer controlled paddle
    private Paddle computer;

    // The ball
    private Ball ball;

    // The game boundaries
    private Boundary bound_up;
    private Boundary bound_down;
    private Boundary bound_left;
    private Boundary bound_right;

    // The ball's current angle
    private float ball_angle;

    // Has the ball collided in a recent frame?
    // This variable is used to prevent the ball from switching angles too many times
    // TODO: Come up with a better solution
    private bool ball_collided;

    // Is the game paused?
    private bool paused;

    // Constructor
    this ( SDL_Surface* window_surface )
    {
        this.window_surface = window_surface;

        // Create the paddles and move them to their initial positions
        this.player = new Paddle();
        this.player.x = 20;
        this.player.y = 175;

        this.computer = new Paddle();
        this.computer.x = 780 - this.computer.width;
        this.computer.y = 175;

        // Create the ball and move it to the middle
        this.ball = new Ball();
        this.ball.x = 390;
        this.ball.y = 190;

        // Set up the game boundaries
        this.bound_up = new Boundary(0, 0, 800, 0);
        this.bound_down = new Boundary(0, 400, 800, 0);
        this.bound_left = new Boundary(0, 0, 0, 400);
        this.bound_right = new Boundary(800, 0, 0, 400);

        // Randomize the ball's starting angle
        this.ball_angle = randomizeBallAngle();
    }

    // Handle an SDL event
    void handle ( SDL_Event event )
    {
        // Here we want to check if a key was pressed (or a mouse button clicked, etc)
        // This is different from e.g. when a key is held down, which controls player movement
        if ( event.type == SDL_KEYDOWN )
        {
            switch ( event.key.keysym.scancode )
            {
                // Only the 'P' key is handled so far, which pauses the game
                case SDL_SCANCODE_P:
                    this.paused = !this.paused;
                    break;

                default:
                    break;
            }
        }
    }

    // Update the game state
    void update ( uint ms )
    {
        // Do nothing if the game is paused
        if ( this.paused ) return;

        // Move the player paddle based on user input
        this.processInput(ms);

        // Bounce the ball
        if ( this.ball.collidesWith(this.bound_up) || this.ball.collidesWith(this.bound_down) )
        {
            this.bounceBall(true);
        }
        else if ( this.ball.collidesWith(this.bound_left) || this.ball.collidesWith(this.bound_right) )
        {
            // TODO: This collision means that one paddle scored, game should be reset
            this.bounceBall(false);
        }
        else if (this.ball.collidesWith(this.player) || this.ball.collidesWith(this.computer) )
        {
            this.bounceBall(false);
        }
        else
        {
            this.ball_collided = false;
        }

        // Move the ball
        this.ball.move(ms, this.ball_angle);

        // Move the computer paddle relative to the ball's position
        // If the middle of the ball is higher up than the middle of the computer paddle,
        // The computer paddle should move to chase the ball
        auto ball_mid = this.ball.y - this.ball.height / 2;
        auto comp_mid = this.computer.y - this.computer.height / 2;

        if ( ball_mid > comp_mid && !this.computer.collidesWith(this.bound_down) )
        {
            this.computer.move(ms, MOVEMENT_DOWN);
        }
        else if ( ball_mid < comp_mid && !this.computer.collidesWith(this.bound_up) )
        {
            this.computer.move(ms, MOVEMENT_UP);
        }
    }

    // Render the game
    void render ( )
    {
        import std.exception;

        // Clear the window surface by filling it with black pixels
        auto fill_rect = null; // If the rectangle parameter is null, the whole surface is filled
        enum CLEAR_COLOR = 0x000000;
        enforce(SDL_FillRect(this.window_surface, fill_rect, CLEAR_COLOR) == 0, "Couldn't clear the window surface");

        // Draw the game entities
        this.player.draw(this.window_surface);
        this.computer.draw(this.window_surface);
        this.ball.draw(this.window_surface);
    }

    // Process non-event related user input
    private void processInput ( uint ms )
    {
        // The keyboard state tells us which keys are currently pressed
        // The argument is a pointer to an integer where the number of pressed keys should be stored
        // Since we don't care about this, we pass null here
        // The return value is an array containing the state of each key
        auto key_state = SDL_GetKeyboardState(null);

        if ( key_state[SDL_SCANCODE_W] > 0 && !this.player.collidesWith(this.bound_up) )
            this.player.move(ms, MOVEMENT_UP);
        if ( key_state[SDL_SCANCODE_S] > 0 && !this.player.collidesWith(this.bound_down) )
            this.player.move(ms, MOVEMENT_DOWN);
    }

    // Bounce the ball, unless it was already bounced recently
    private void bounceBall ( bool vertical_hit )
    {
        // If the ball hit one of the upper boundaries, the coefficient should be 2PI, otherwise PI
        auto coeff = vertical_hit ? 2 : 1;
        if ( !this.ball_collided ) this.ball_angle = coeff * PI - this.ball_angle;
        this.ball_collided = true;
    }

    // Generate a random starting angle for the ball
    static private float randomizeBallAngle ( )
    {
        import std.random;

        // For simplicity, the ball will always start firing towards the player's paddle
        // To accomplish this, we generate angle between 135 and 225 degrees (3pi/4 and 5pi/4 radians)
        return uniform(3.0 * PI_4, 5.0 * PI_4);
    }
}
