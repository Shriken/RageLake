import std.stdio;
import std.string;
import std.signals;
import logger;
import world : World;
import util : Cell, Point, Bounds, Color;
import deimos.ncurses.ncurses;

class Display {
    int width, height;
    Bounds viewport;

    void update(ref World world) {
        // Get the window bounds
        getmaxyx(stdscr, this.height, this.width);

        erase();

        // Draw background grid
        {
            attron(COLOR_PAIR(Color.NORMAL));
            scope (exit) attroff(COLOR_PAIR(Color.NORMAL));
            foreach (i; 0 .. width) {
                foreach (j; 0 .. height) {
                    auto p = Point(i, j);
                    if (viewport.contains(p)) {
                        drawCell(p, Cell('.'));
                    }
                }
            }
        }

        foreach (entity; world.entities) {
            if (viewport.contains(entity.position)) {
                entity.render(this);
            }
        }
        emit(this); // At this point, anything can hook in by registering for events from display

        refresh();
    }
    mixin Signal!(Display);

    void drawString(int x, int y, string str, Color color = Color.NORMAL) {
        attron(COLOR_PAIR(color));
        scope (exit) attroff(COLOR_PAIR(color));
        mvprintw(y, x, toStringz(str));
    }

    void drawCell(Point position, Cell cell) {
        // There's probably a much more efficient way to convert from a character to a c-string
        auto glyph = toStringz("" ~ cell.glyph);
        attron(COLOR_PAIR(cell.color));
        scope (exit) attroff(COLOR_PAIR(cell.color));
        mvprintw(position.y - viewport.min.y, position.x - viewport.min.x, glyph);
    }
    
    this(Bounds view) {
        this.viewport = view;

        // init ncurses
        initscr();
        start_color();
        cbreak();
        noecho();
        nonl();
        nodelay(stdscr, true);
        intrflush(stdscr, false);
        keypad(stdscr, false);

        // Get the window bounds
        getmaxyx(stdscr, this.height, this.width);
        writeln(); // Writeln to flush buffers

        init_pair(Color.NORMAL, COLOR_WHITE, COLOR_BLACK);
        init_pair(Color.HEALING, COLOR_GREEN, COLOR_BLACK);
        init_pair(Color.TAKING_DAMAGE, COLOR_WHITE, COLOR_RED);
        init_pair(Color.UNIMPORTANT, COLOR_WHITE, COLOR_BLACK);
        init_pair(Color.ENEMY, COLOR_RED, COLOR_BLACK);
        init_pair(Color.PLAYER, COLOR_GREEN, COLOR_BLACK);

        auto displayLog = new DisplayLogger();
        registerLogger(displayLog);
        this.connect(&displayLog.update); // Register display logger for updates
    }

    ~this() {
        endwin();
    }

    class DisplayLogger : Logger {
        LogLine[] lines;
        this() {
            this.minLevel = LogLevel.update;
        }

        override bool acceptsLevel(LogLevel level) {
            return level == this.minLevel;
        }

        override void log(ref LogLine line) {
            lines ~= line;
        }

        // Update the display. This will be registered to the display's event listener
        void update(Display display) {
            auto i = 0;
            foreach (line; lines) {
                display.drawString(0, i, line.msg);
                i++;
            }
            lines.clear();
        }
    }
}
