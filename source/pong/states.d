module pong.states;

// The various states of the pong game - intro, playing, game over
enum PongStates
{
    Intro,
    Play,
    Over
}

// State interface, basically the same as the game interface with some small differences
interface State
{
    import derelict.sdl2.sdl;

    // Handle an SDL event
    void handle ( SDL_Event event );

    // Update the game state
    PongStates update ( uint ms );

    // Render the game
    void render ( SDL_Surface* dst );

    // Reset the state
    void reset ( );
}

// The intro state - render a splash screen and wait for the player to press space
class IntroState : State
{
    import derelict.sdl2.sdl;

    // The splash screen surface
    private SDL_Surface* surface;

    // Rectangle containing positional data for the splash screen
    private SDL_Rect rect;

    // Whether or not the game should start
    private bool start_game;

    // Constructor
    this ( )
    {
        import derelict.sdl2.image;

        import std.exception;
        import std.string;

        // Load the intro splash graphics
        auto img_path = toStringz("intro.bmp"); // Needs to be a C string so can't be a compile time constant
        this.surface = IMG_Load(img_path);
        enforce(this.surface !is null, "Couldn't load intro image");

        this.rect.w = 800;
        this.rect.h = 400;
    }

    // Handle an event - wait for the player to press space
    void handle ( SDL_Event event )
    {
        // Check if the player pressed space
        if ( event.type == SDL_KEYDOWN && event.key.keysym.scancode == SDL_SCANCODE_SPACE )
        {
            this.start_game = true;
        }
    }

    // Update the state - does nothing for the intro
    PongStates update ( uint ms )
    {
        return this.start_game ? PongStates.Play : PongStates.Intro;
    }

    // Render the state - draw the intro splash screen
    void render ( SDL_Surface* dst )
    {
        import std.exception;

        enforce(SDL_BlitSurface(this.surface, null, dst, &this.rect) == 0, "Couldn't draw the intro splash");
    }

    // Reset the state
    void reset ( )
    {
        this.start_game = false;
    }
}

// The game over state - display the game over screen, player can press space to reset
class OverState : State
{
    import derelict.sdl2.sdl;

    // The splash screen surfaces
    private SDL_Surface* win_surface;
    private SDL_Surface* lose_surface;

    // Rectangle containing positional data for the splash screen
    private SDL_Rect rect;

    // Whether or not the game should restart
    private bool restart_game;

    // Whether or not the player won
    bool player_won;

    // Constructor
    this ( )
    {
        import derelict.sdl2.image;

        import std.exception;
        import std.string;

        // Load the intro splash graphics
        auto win_img_path = toStringz("win.bmp"); // Needs to be a C string so can't be a compile time constant
        this.win_surface = IMG_Load(win_img_path);
        enforce(this.win_surface !is null, "Couldn't load win image");
        auto lose_img_path = toStringz("lose.bmp"); // Needs to be a C string so can't be a compile time constant
        this.lose_surface = IMG_Load(lose_img_path);
        enforce(this.lose_surface !is null, "Couldn't load lose image");

        this.rect.w = 800;
        this.rect.h = 400;
    }

    // Handle an event - wait for the player to press space
    void handle ( SDL_Event event )
    {
        // Check if the player pressed space
        if ( event.type == SDL_KEYDOWN && event.key.keysym.scancode == SDL_SCANCODE_SPACE )
        {
            this.restart_game = true;
        }
    }

    // Update the state - does nothing for the intro
    PongStates update ( uint ms )
    {
        return this.restart_game ? PongStates.Play : PongStates.Over;
    }

    // Render the state - draw the intro splash screen
    void render ( SDL_Surface* dst )
    {
        import std.exception;

        auto surface = player_won ? this.win_surface : this.lose_surface;

        enforce(SDL_BlitSurface(surface, null, dst, &this.rect) == 0, "Couldn't draw the intro splash");
    }

    // Reset the state
    void reset ( )
    {
        this.restart_game = false;
        this.player_won = false;
    }
}

// The playing state - contains the actual game logic
class PlayState : State
{
    import pong.ball;
    import pong.boundary;
    import pong.paddle;

    import derelict.sdl2.mixer;
    import derelict.sdl2.sdl;

    import std.math;

    // Helpful constants for movement angles
    // The paddles can only move up or down
    private enum MOVEMENT_UP = PI_2;
    private enum MOVEMENT_DOWN = 3 * PI_2;

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

    // The bleep sound effect
    private Mix_Chunk* bleep;

    // The ball's current angle
    private float ball_angle;

    // Has the ball collided in a recent frame?
    // This variable is used to prevent the ball from switching angles too many times
    // TODO: Come up with a better solution
    private bool ball_collided;

    // Whether or not the player won
    bool player_won;

    // Constructor
    this ( )
    {
        import std.exception;
        import std.string;

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

        // Load the bleep sound effect
        auto bleep_path = toStringz("bleep.wav"); // Needs to be a C string so can't be a compile time constant
        this.bleep = Mix_LoadWAV(bleep_path);
        enforce(this.bleep !is null, "Couldn't load bleep sound");

        // Randomize the ball's starting angle
        this.ball_angle = randomizeBallAngle();
    }

    // Destructor
    ~this ( )
    {
        // Free the bleep sound effect
        Mix_FreeChunk(this.bleep);
    }

    // Handle an SDL event
    void handle ( SDL_Event event )
    {
        // No-op for this state
    }

    // Update the game state
    PongStates update ( uint ms )
    {
        PongStates next_state = PongStates.Play;

        // Move the player paddle based on user input
        this.processInput(ms);

        // Bounce the ball
        if ( this.ball.collidesWith(this.bound_up) || this.ball.collidesWith(this.bound_down) )
        {
            this.bounceBall(true);
        }
        else if ( this.ball.collidesWith(this.bound_left) )
        {
            next_state = PongStates.Over;
        }
        else if ( this.ball.collidesWith(this.bound_right) )
        {
            next_state = PongStates.Over;
            this.player_won = true;
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

        return next_state;
    }

    // Render the game
    void render ( SDL_Surface* dst )
    {
        import std.exception;

        // Clear the surface by filling it with black pixels
        auto fill_rect = null; // If the rectangle parameter is null, the whole surface is filled
        enum CLEAR_COLOR = 0x000000;
        enforce(SDL_FillRect(dst, fill_rect, CLEAR_COLOR) == 0, "Couldn't clear the game");

        // Draw the game entities
        this.player.draw(dst);
        this.computer.draw(dst);
        this.ball.draw(dst);
    }

    // Reset the state
    void reset ( )
    {
        this.player.x = 20;
        this.player.y = 175;

        this.computer.x = 780 - this.computer.width;
        this.computer.y = 175;

        this.ball.x = 390;
        this.ball.y = 190;

        this.ball_angle = randomizeBallAngle();

        this.ball_collided = false;
        this.player_won = false;
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

        if ( !this.ball_collided )
        {
            this.ball_angle = coeff * PI - this.ball_angle;

            // Bleep!
            enum CHANNEL = -1; // -1 for first available channel
            enum LOOPS = 0; // We don't want to loop the sound
            Mix_PlayChannel(CHANNEL, this.bleep, LOOPS);
        }

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
