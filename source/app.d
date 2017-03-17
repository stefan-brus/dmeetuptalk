module app;

import pong.game;

class SDLGame ( GameClass : Game )
{
    import derelict.sdl2.image;
    import derelict.sdl2.mixer;
    import derelict.sdl2.sdl;

    // The window
    enum WINDOW_WIDTH = 800;
    enum WINDOW_HEIGHT = 400;
    private SDL_Window* window;

    // The window surface where we draw things
    private SDL_Surface* window_surface;

    // The game
    private Game game;

    // The number of ms elapsed since the last tick
    private uint elapsed;

    // Constructor - initializes resources
    this ( )
    {
        import std.exception;
        import std.string;

        // Load Derelict's SDL bindings
        DerelictSDL2.load();

        // Load Derelict's SDL_Image bindings
        DerelictSDL2Image.load();

        // Load Derelict's SDL_Mixer bindings
        DerelictSDL2Mixer.load();

        // Initialize SDL
        enum INIT_FLAGS = SDL_INIT_EVERYTHING;
        enforce(SDL_Init(INIT_FLAGS) == 0, "Couldn't initialize SDL");

        // Initialize SDL_Mixer
        enum FREQUENCY = 22500;
        enum CHANNELS = 2;
        enum CHUNK_SIZE = 4096;
        enforce(Mix_OpenAudio(FREQUENCY, MIX_DEFAULT_FORMAT, CHANNELS, CHUNK_SIZE) == 0, "Couldn't initialize mixer");

        // Create our window where we render stuff
        auto window_title = toStringz("Pongelipong!"); // Needs to be a C string so can't be a compile time constant
        enum WINDOW_X = 100;
        enum WINDOW_Y = 100;
        enum WINDOW_FLAGS = SDL_WINDOW_SHOWN;
        this.window = SDL_CreateWindow(window_title, WINDOW_X, WINDOW_Y, WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_FLAGS);
        enforce(this.window !is null, "Couldn't create a window");

        // Get the window surface so we can render stuff in the window
        this.window_surface = SDL_GetWindowSurface(this.window);
        enforce(this.window_surface !is null, "Couldn't get the window surface");

        // Create the game class, which requires a reference to the window surface for rendering
        this.game = new GameClass(this.window_surface);
    }

    // Destructor - frees SDL resources
    ~this ( )
    {
        // Free the window surface
        SDL_FreeSurface(this.window_surface);

        // Destroy the window
        SDL_DestroyWindow(this.window);

        // Close the audio mixer
        Mix_CloseAudio();
    }

    // Run the game
    void run ( )
    {
        import std.exception;

        // Attempt to smoothen out movement, input, and framerate
        enum FPS = 75;
        enum MS_PER_FRAME = 1000 / FPS;

        // Wait for the player to quit
        bool quit;
        SDL_Event event;
        while ( !quit )
        {
            // PollEvent returns 1 while there are events in the queue, 0 if the event queue is empty
            while ( SDL_PollEvent(&event) != 0 )
            {
                if ( event.type == SDL_QUIT )
                {
                    quit = true;
                    break;
                }

                // Handle the event
                this.game.handle(event);
            }

            // Get the number of milliseconds elapsed
            auto ms_passed = SDL_GetTicks() - this.elapsed;
            this.game.update(ms_passed);

            // Render the game
            this.game.render();

            // Update the window surface with newly drawn pixels
            enforce(SDL_UpdateWindowSurface(this.window) == 0, "Couldn't update the window surface");

            // Wait a bit so the game doesn't go too fast
            if ( ms_passed < MS_PER_FRAME ) SDL_Delay(MS_PER_FRAME - ms_passed);

            this.elapsed += ms_passed;
        }
    }
}

void main ( )
{
    import pong.pong;

    auto game = new SDLGame!Pong();
    game.run();
}
