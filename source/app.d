import derelict.sdl2.sdl;

import std.exception;
import std.string;

void main ( )
{
	// Load Derelict's SDL bindings
    DerelictSDL2.load();

    // Initialize SDL
    enum INIT_FLAGS = SDL_INIT_EVERYTHING;
    enforce(SDL_Init(INIT_FLAGS) == 0, "Couldn't initialize SDL");

    // Create our window where we render stuff
    auto window_title = toStringz("An SDL game written in D!"); // Needs to be a C string so can't be a compile time constant
    enum WINDOW_X = 100;
    enum WINDOW_Y = 100;
    enum WINDOW_WIDTH = 400;
    enum WINDOW_HEIGHT = 400;
    enum WINDOW_FLAGS = SDL_WINDOW_SHOWN;
    auto window = SDL_CreateWindow(window_title, WINDOW_X, WINDOW_Y, WINDOW_WIDTH, WINDOW_HEIGHT, WINDOW_FLAGS);
    enforce(window !is null, "Couldn't create a window");

    // Wait 5 seconds
    enum DELAY_TIME_MS = 5000;
    SDL_Delay(DELAY_TIME_MS);

    // Destroy the window
    SDL_DestroyWindow(window);
}
