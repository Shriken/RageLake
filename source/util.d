import display : Display;
import world : World;

/*
 * Represents a cell in a terminal-like display.
 * Has a character
 * TODO: Add foreground and background colors
 */
struct Cell {
    char glyph;

    this(char glyph) {
        this.glyph = glyph;
    }
}

struct Point {
    int x, y;
}

struct Bounds {
    Point min, max;
    this(Point min, Point max) {
        // Correct min and max if they're not set up so that min is top left and max is bottom right
        if (min.x > max.x) {
            auto tmp = min.x;
            min.x = max.x;
            max.x = tmp;
        }
        if (min.y > max.y) {
            auto tmp = min.y;
            min.y = max.y;
            max.y = tmp;
        }
        this.min = min;
        this.max = max;
    }
    @safe bool contains(Point p) pure {
        return (min.x <= p.x && p.x <= max.x
             && min.y <= p.y && p.y <= max.y);
    }
}

unittest {
    Point p = Point(10, 10);
    
    // Check that the point lies in a bounds it definetly should
    Bounds b = Bounds(Point(0, 0), Point(20, 20));
    assert(b.contains(p));

    // Check that the right edge of a bounds that lies on a point counts as containing it
    Bounds b2 = Bounds(Point(0, 0), Point(10, 10));
    assert(b2.contains(p));

    // Check that the left edge of a bounds that lies on a point counts as containing it
    Bounds b3 = Bounds(Point(10, 10), Point(20, 20));
    assert(b3.contains(p));
    

    // Check that a weird rectangle gets corrected in the constructor so contains still works
    Bounds b4 = Bounds(Point(10, 0), Point(0, 10));
    assert(b4.contains(p));
}

struct KeyState {
    int keyCode;
    bool pressed;
}

enum EventType {
    KEY_PRESS
}
enum KeyType {
    MOVE_LEFT,
    MOVE_RIGHT,
    MOVE_UP,
    MOVE_DOWN,
    QUIT,
    NONE
}

union DataType {
    KeyType key;
}

struct Event {
    EventType type;
    DataType data;
}

interface Updates {
    void update(World world);
    void render(Display display);
}
