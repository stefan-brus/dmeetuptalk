module pong.entity;

// Common base class for game entities
abstract class Entity
{
    import derelict.sdl2.sdl;

    // SDL rectangle containing position and size data
    protected SDL_Rect rect;

    // Draw the entity onto the given SDL surface
    abstract void draw ( SDL_Surface* dst );

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
