module behaviors.randomwalkbehavior;

import std.math;
import std.random;

import behavior;
import enemy;
import action;


class RandomWalkBehavior : Behavior {
    
    this(Enemy ent) {
        super(ent);
    }

    override Action getNextAction(World world) {
        float dx = world.player.position.x - entity.position.x;
        float dy = world.player.position.y - entity.position.y;
        float len = sqrt(dx * dx + dy * dy);
        // normalize
        dx = round(cast(float) dx / len);
        dy = round(cast(float) dy / len);

        if (len > 10) {
            import behaviors.movetowardsplayer;
            entity.behavior = new MoveTowardsPlayerBehavior(entity);
        }
        auto act = new MovementAction(entity, uniform(-1, 2), uniform(-1, 2));
        act.staminaRequired *= 5;
        return act;
    }
}
