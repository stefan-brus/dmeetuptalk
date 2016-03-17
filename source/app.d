import derelict.sdl2.image;
import derelict.sdl2.sdl;

import std.exception;
import std.string;

void main ( )
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
    auto hero_surface = IMG_Load(hero_img_path);
    enforce(hero_surface !is null, "Couldn't load hero sprite");

    // Create our window where we render stuff
    auto window_title = toStringz("An SDL game written in D!"); // Needs to be a C string so can't be a compile time constant
    enum WINDOW_X = 100;
    enum WINDOW_Y = 100;
    enum WINDOW_WIDTH = 400;
    enum WINDOW_HEIGHT = 400;
    enum WINDOW_FLAGS = SDL_WINDOW_SHOWN;
    auto window = SDL_CreateWindow(window_title, WINDOW_X, WINDOW_Y, WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_FLAGS);
    enforce(window !is null, "Couldn't create a window");

    // Get the window surface so we can render stuff in the window
    auto window_surface = SDL_GetWindowSurface(window);
    enforce(window_surface !is null, "Couldn't get the window surface");

    // Render our hero onto the center-ish of the window surface
    auto src_rect = null; // The source rectangle to copy from, null copies the entire surface
    auto dst_rect = new SDL_Rect(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2); // The destination rectangle contains the x and y position of the sprite, width and height can be 0 since we are copying the whole surface
    enforce(SDL_BlitSurface(hero_surface, src_rect, window_surface, dst_rect) == 0, "Couldn't draw the hero surface");
    enforce(SDL_UpdateWindowSurface(window) == 0, "Couldn't update the window surface");

    // Wait 5 seconds
    enum DELAY_TIME_MS = 5000;
    SDL_Delay(DELAY_TIME_MS);

    // Free the surfaces
    SDL_FreeSurface(window_surface);
    SDL_FreeSurface(hero_surface);

    // Destroy the window
    SDL_DestroyWindow(window);
}
