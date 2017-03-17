module pong.pong;

import pong.game;

// Pong!
class Pong : Game
{
    import pong.states;

    import derelict.sdl2.sdl;

    // Reference to the window surface
    private SDL_Surface* window_surface;

    // The "game paused" surface
    private SDL_Surface* paused_surface;
    private SDL_Rect paused_rect;

    // Is the game paused?
    private bool paused;

    // The game states
    private State[PongStates] states;

    // The current state
    private PongStates cur_state;

    // Constructor
    this ( SDL_Surface* window_surface )
    {
        import derelict.sdl2.image;

        import std.exception;
        import std.string;

        this.window_surface = window_surface;

        // Create the game paused surface
        auto img_path = toStringz("paused.bmp"); // Needs to be a C string so can't be a compile time constant
        this.paused_surface = IMG_Load(img_path);
        enforce(this.paused_surface !is null, "Couldn't create the pause surface");
        this.paused_rect.x = 0;
        this.paused_rect.y = 0;
        this.paused_rect.w = 800;
        this.paused_rect.h = 400;

        // The paused image's background color, blue, should be considered transparent
        SDL_SetColorKey(this.paused_surface, SDL_TRUE, SDL_MapRGB(this.paused_surface.format, 0x00, 0x00, 0xFF));

        with ( PongStates )
        {
            this.states[Intro] = new IntroState();
            this.states[Play] = new PlayState();
            this.states[Over] = new OverState();

            this.cur_state = Intro;
        }
    }

    // Destructor
    ~this ( )
    {
        // Free the paused surface
        SDL_FreeSurface(this.paused_surface);
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

        if ( !this.paused ) this.states[this.cur_state].handle(event);
    }

    // Update the game state
    void update ( uint ms )
    {
        if ( this.paused ) return;

        auto next_state = this.states[this.cur_state].update(ms);

        if ( next_state != this.cur_state )
        {
            with ( PongStates ) if ( next_state == Over )
            {
                (cast(OverState)this.states[Over]).player_won = (cast(PlayState)this.states[Play]).player_won;
            }

            this.states[this.cur_state].reset();
            this.cur_state = next_state;
        }
    }

    // Render the game
    void render ( )
    {
        import std.exception;

        // Clear the surface by filling it with black pixels
        auto fill_rect = null; // If the rectangle parameter is null, the whole surface is filled
        enum CLEAR_COLOR = 0x000000;
        enforce(SDL_FillRect(this.window_surface, fill_rect, CLEAR_COLOR) == 0, "Couldn't clear the game");

        this.states[this.cur_state].render(this.window_surface);

        if ( this.paused )
            enforce(SDL_BlitSurface(this.paused_surface, null, this.window_surface, &this.paused_rect) == 0, "Couldn't blit the pause surface");
    }
}
