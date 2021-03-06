import std.string;
import world : World;
import tile;
import display;
import action : Action;
import util;
import event : Event;
import inventory;
import equipment;
import stats;

class Entity : Updates {
    Point position;
    int stamina;
    int staminaRechargeRate = 4;
    int maxStamina = 100;
    int health = 10;
    int maxHealth = 10;
    bool alive = true;
    Stats stats;
    Action desiredAction;
    World world;
    Cell cell;
    Color normalColor = Color.NORMAL;
    Inventory inventory;
    EquipRegion[] regions;

    this() {
        this.position = Point(0, 0);
        this.cell = Cell('c');
        stamina = maxStamina;
        this.inventory = new Inventory(this);
        regions = [
            EquipRegion.HEAD,
            EquipRegion.TORSO,
            EquipRegion.LEFT_ARM,
            EquipRegion.RIGHT_ARM,
            EquipRegion.LEFT_LEG,
            EquipRegion.RIGHT_LEG
            ];
    }

    this(World world) {
        this();
        this.world = world;
    }

    this(World world, Point p) {
        this(world);
        this.position = p;
    }

    void takeHit(Entity hitter, int damage) {
        if (alive) {
            this.cell.color = Color.TAKING_DAMAGE;
            this.health -= damage;
            if (this.health <= 0) {
                this.die();
            }
        }
    }

    void die() {
        alive = false;
        normalColor = Color.UNIMPORTANT;
    }

    Action update(World world) {
        // Recharge stamina
        stamina += staminaRechargeRate;
        if (stamina > maxStamina) stamina = maxStamina;
        if (this.stamina == this.maxStamina) cell.color = normalColor;
        return new Action(this);
    }

    bool canTraverse(Tile tile) {
        return tile.isA!FloorTile;
    }

    void render(Display display) {
        if (display.viewport.contains(this.position)) {
            display.drawCell(this.position, this.cell);
        }
    }
}
