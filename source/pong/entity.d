module pong.entity;

// Common base class for game entities
abstract class Entity
{
    import derelict.sdl2.sdl;

    // SDL rectangle containing position and size data
    protected SDL_Rect rect;

    // Draw the entity onto the given SDL surface
    abstract void draw ( SDL_Surface* dst );

    // Override this to set the entity's movement speed
    abstract float speed ( );

    // Move the entity along the given angle (in radians) according to its speed
    void move ( uint ms, float angle )
    {
        import std.math;

        // Calculate the distance moved as a factor of the entity's speed
        auto d = cast(float)ms * this.speed();

        // Calculate the distance moved along the X and Y axes
        auto dx = d * cos(angle);
        auto dy = -d * sin(angle);

        // Update the rectangle
        this.rect.x += rndtol(dx);
        this.rect.y += rndtol(dy);
    }

    // Check if this entity collides with the given entity
    bool collidesWith ( Entity other )
    {
        // One could, in theory, use the SDL_IntersectRect function here
        // But it requires a pointer to an SDL_Rect to write the intersecting
        // rectangle data to, which is not what we want to do here
        // Hence, we check each point manually
        if ( this.x > other.x + other.width || this.x + this.width < other.x ||
             this.y > other.y + other.height || this.y + this.height < other.y )
        {
            return false;
        }
        else
        {
            return true;
        }
    }

    // Accessor properties for the rectangle's position and size data

    // The X position of the entity's top left corner
    @property int x ( ) { return this.rect.x; }
    @property int x ( int x ) { return this.rect.x = x; }

    // The Y position of the entity's top left corner
    @property int y ( ) { return this.rect.y; }
    @property int y ( int y ) { return this.rect.y = y; }

    // The entity's width
    @property int width ( ) { return this.rect.w; }
    @property int width ( int width ) { return this.rect.w = width; }

    // The entity's height
    @property int height ( ) { return this.rect.h; }
    @property int height ( int height ) { return this.rect.h = height; }
}
