import csfml, csfml_ext

import fnf.ecs.entity

type

  SceneNode* = ref object {.inheritable.}
    children*: seq[SceneNode]
    parent*: SceneNode

    sceneObj*: Entity

  # IDrawable* = object
  #   draw*:  proc (target: RenderWindow, state: RenderStates)
  #   update*:  proc (deltaTime: Time)
  #   transform*:  proc (): Transform
  #   category*: proc (): int

## forward

proc update*(this: SceneNode, deltaTime: Time)

proc newSceneNode*(): SceneNode =
  result = SceneNode()
  result.children = @[]

proc setObj* [T](node: var SceneNode, item: T) =
  # node.sceneObj = IDrawable(
  #   draw: proc (target: RenderWindow, state: RenderStates) = item.draw(target, state),
  #   update: proc (deltaTime: Time) = item.update(deltaTime),
  #   transform: proc (): Transform = return item.transform,
  #   category: proc (): int = return item.category,
  # )
  node.sceneObj = item

proc attachChild*(this: SceneNode, child: SceneNode): void =
  child.parent = this
  this.children.add(child)

proc detachChild*(this: SceneNode, child: SceneNode): bool =
  var found = this.children.find(child)
  
  if found == -1:
    return false

  child.parent = nil
  this.children.delete(found)

  return true

proc hasDrawable*(this: SceneNode): bool =
  result = this.sceneObj != nil

proc draw*[T](this: SceneNode, target: T, states: RenderStates) =
  var varStates = states
  if this.hasDrawable:
    var varTransform = this.sceneObj.transform()
    # varStates.transform.combine varTransform
    # test varTransform
    combine(varStates.transform, varTransform)
    # varTransform.combine varStates.transform
    this.drawCurrent(target, varStates)
  this.drawChildren(target, varStates)

proc drawCurrent*[T](this: SceneNode, target: T, states: RenderStates) =
  # target.draw(this.sceneObj, states)
  this.sceneObj.draw(target, states)

proc drawChildren*[T](this: SceneNode, target: T, states: RenderStates) =
  for childNode in this.children:
    childNode.draw(target, states)

proc updateCurrent*(this: SceneNode, deltaTime: Time) =
  if this.hasDrawable:
    this.sceneObj.update deltaTime

proc updateChildren*(this: SceneNode, deltaTime: Time) =
  for childNode in this.children:
      childNode.update deltaTime

proc update*(this: SceneNode, deltaTime: Time) =
  this.updateCurrent(deltaTime)
  this.updateChildren deltaTime

proc worldTransform*(this: SceneNode): Transform =
  var transform = Identity
  var parent = this.parent

  transform = (this.sceneObj.transform()) * transform

  while parent != nil:
    if parent.hasDrawable:
      transform = (parent.sceneObj.transform()) * transform
    parent = parent.parent

  result = transform

proc worldPosition*(this: SceneNode): Vector2f =
  return this.worldTransform * vec2(0, 0)
