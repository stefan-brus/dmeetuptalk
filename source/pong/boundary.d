module pong.boundary;

import pong.entity;

// The game boundary is an invisible entity
class Boundary : Entity
{
    import derelict.sdl2.sdl;

    // Constructor
    this ( int x, int y, int width, int height )
    {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
    }

    // A boundary is invisible, so draw does nothing
    override void draw ( SDL_Surface* dst )
    {

    }

    // A boundary is stationary, so its speed is 0
    override float speed ( )
    {
        return 0.0;
    }
}
