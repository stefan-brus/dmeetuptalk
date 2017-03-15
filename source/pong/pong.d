module pong.pong;

import pong.game;

// Pong!
class Pong : Game
{
    import pong.ball;
    import pong.paddle;

    import derelict.sdl2.sdl;

    // Reference to the window surface
    private SDL_Surface* window_surface;

    // The player paddle
    private Paddle player;

    // The computer controlled paddle
    private Paddle computer;

    // The ball
    private Ball ball;

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
    }

    // Handle an SDL event
    void handle ( SDL_Event event )
    {
        // Nothing happens yet, but stay tuned!
    }

    // Update the game state
    void update ( uint ms )
    {
        // This empty code space is for rent, 950€ Warmmiete
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
}
