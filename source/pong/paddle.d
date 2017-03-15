module pong.paddle;

import pong.entity;

// A paddle entity
class Paddle : Entity
{
    import derelict.sdl2.sdl;

    // Constructor
    this ( )
    {
        this.width = 10;
        this.height = 50;
    }

    // Draw the paddle
    override void draw ( SDL_Surface* dst )
    {
        import std.exception;

        enum PADDLE_COLOR = 0xFFFFFF; // white
        enforce(SDL_FillRect(dst, &this.rect, PADDLE_COLOR) == 0, "Couldn't draw a paddle");
    }
}
