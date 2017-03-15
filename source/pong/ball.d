module pong.ball;

import pong.entity;

// A ball entity
class Ball : Entity
{
    import derelict.sdl2.image;
    import derelict.sdl2.sdl;

    // The sprite surface
    private SDL_Surface* surface;

    // Constructor
    this ( )
    {
        import std.exception;
        import std.string;

        this.width = 20;
        this.height = 20;

        // Load the ball sprite
        auto img_path = toStringz("ball.bmp"); // Needs to be a C string so can't be a compile time constant
        this.surface = IMG_Load(img_path);
        enforce(this.surface !is null, "Couldn't load ball sprite");

        // The sprite's background color, blue, should be considered transparent
        SDL_SetColorKey(this.surface, SDL_TRUE, SDL_MapRGB(this.surface.format, 0x00, 0x00, 0xFF));
    }

    // Destructor
    ~this ( )
    {
        SDL_FreeSurface(this.surface);
    }

    // Draw the ball
    override void draw ( SDL_Surface* dst )
    {
        import std.exception;

        enforce(SDL_BlitSurface(this.surface, null, dst, &this.rect) == 0, "Couldn't blit the ball surface");
    }
}
