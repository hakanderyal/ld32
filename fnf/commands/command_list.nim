# import csfml

# import fnf.ecs.entity
# import fnf.commands.commands, fnf.commands.command_type

# proc applyForce*(velocity: Vector2f): Command =
#   new result
#   result.action = proc (entity: Entity, deltaTime: Time) =
#     entity.accelerate(velocity)
#   result.category = CommandType.ctPlayerAircraft