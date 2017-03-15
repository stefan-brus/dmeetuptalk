module pong.game;

// Simple game interface
interface Game
{
    import derelict.sdl2.sdl;

    // Handle an SDL event
    void handle ( SDL_Event event );

    // Update the game state
    void update ( uint ms );

    // Render the game
    void render ( );
}
