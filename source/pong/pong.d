module pong.pong;

import pong.game;

// Pong!
class Pong : Game
{
    import pong.states;

    import derelict.sdl2.sdl;

    // Reference to the window surface
    private SDL_Surface* window_surface;

    // Is the game paused?
    private bool paused;

    // The game states
    private State[PongStates] states;

    // The current state
    private PongStates cur_state;

    // Constructor
    this ( SDL_Surface* window_surface )
    {
        this.window_surface = window_surface;

        with ( PongStates )
        {
            this.states[Intro] = new IntroState();
            this.states[Play] = new PlayState();
            this.states[Over] = new OverState();

            this.cur_state = Intro;
        }
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
        this.states[this.cur_state].render(this.window_surface);
    }
}
