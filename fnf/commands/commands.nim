import csfml

import fnf.scene_graph
import fnf.commands.command_type
import fnf.ecs.entity

import queues

type

  Command* = ref object
    action*: proc (node: Entity, deltaTime: Time)
    category*: CommandType

proc onCommand* (this: SceneNode, command: Command, deltaTime: Time) =
  # echo this.sceneObj.category()
  # echo command.category
  # echo (ord(command.category) and this.sceneObj.category())
  if (this.sceneObj.category() and ord(command.category)) != 0:
    command.action(this.sceneObj, deltaTime) 

  for childNode in this.children:
    childNode.onCommand command, deltaTime

type
  CommandQueue* = ref object
    queue: Queue[Command]

proc newCommandQueue*(): CommandQueue =
  new result
  result.queue = initQueue[Command]()

proc push*(this: CommandQueue, command: Command) =
  this.queue.add(command)

proc pop*(this: CommandQueue): Command =
  return this.queue.dequeue

proc isNotEmpty*(this: CommandQueue): bool =
  return this.queue.len != 0