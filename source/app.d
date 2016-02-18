import derelict.sdl2.image;
import derelict.sdl2.sdl;

import std.exception;
import std.string;

class SDLGame
{
    // The window
    enum WINDOW_WIDTH = 400;
    enum WINDOW_HEIGHT = 400;
    private SDL_Window* window;

    // The window surface where we draw things
    private SDL_Surface* window_surface;

    // The surface containing our hero sprite
    private SDL_Surface* hero_surface;

    // Constructor - initializes resources
    this ( )
    {
        // Load Derelict's SDL bindings
        DerelictSDL2.load();

        // Load Derelict's SDL_Image bindings
        DerelictSDL2Image.load();

        // Initialize SDL
        enum INIT_FLAGS = SDL_INIT_EVERYTHING;
        enforce(SDL_Init(INIT_FLAGS) == 0, "Couldn't initialize SDL");

        // Load our hero image
        auto hero_img_path = toStringz("hero.jpg"); // Needs to be a C string so can't be a compile time constant
        this.hero_surface = IMG_Load(hero_img_path);
        enforce(this.hero_surface !is null, "Couldn't load hero sprite");

        // Create our window where we render stuff
        auto window_title = toStringz("An SDL game written in D!"); // Needs to be a C string so can't be a compile time constant
        enum WINDOW_X = 100;
        enum WINDOW_Y = 100;
        enum WINDOW_FLAGS = SDL_WINDOW_SHOWN;
        this.window = SDL_CreateWindow(window_title, WINDOW_X, WINDOW_Y, WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_FLAGS);
        enforce(this.window !is null, "Couldn't create a window");

        // Get the window surface so we can render stuff in the window
        this.window_surface = SDL_GetWindowSurface(this.window);
        enforce(this.window_surface !is null, "Couldn't get the window surface");
    }

    // Destructor - frees SDL resources
    ~this ( )
    {
        // Free the surfaces
        SDL_FreeSurface(this.window_surface);
        SDL_FreeSurface(this.hero_surface);

        // Destroy the window
        SDL_DestroyWindow(this.window);
    }

    // Run the game
    void run ( )
    {
        // Render our hero onto the center-ish of the window surface
        auto src_rect = null; // The source rectangle to copy from, null copies the entire surface
        auto dst_rect = new SDL_Rect(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2); // The destination rectangle contains the x and y position of the sprite, width and height can be 0 since we are copying the whole surface
        enforce(SDL_BlitSurface(this.hero_surface, src_rect, this.window_surface, dst_rect) == 0, "Couldn't draw the hero surface");
        enforce(SDL_UpdateWindowSurface(this.window) == 0, "Couldn't update the window surface");

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
            }
        }
    }
}

void main ( )
{
    auto game = new SDLGame();
    game.run();
}
