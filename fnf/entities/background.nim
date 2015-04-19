import csfml, csfml_ext
import fnf.ecs.entity
import fnf.resources

type
  Background* = ref object of Entity
    kind*: BackgroundKind
  
  BackgroundKind* {. pure .} = enum
    Desert

proc toTextureID(backgroundKind: BackgroundKind): TextureID =
  # case backgroundKind:
  # of BackgroundKind.Desert:
  #   return TextureID.Desert
  discard

proc newBackground*(kind: BackgroundKind, textureHolder: TextureHolder): Background =
  new result
  result.kind = kind
  result.transformable = newTransformable()

  result.drawable = newSprite()
  result.texture = textureHolder.get(kind.toTextureID).texture

proc newBackground*(kind: BackgroundKind, textureHolder: TextureHolder, rectangle: IntRect): Background =
  new result
  result.kind = kind
  result.transformable = newTransformable()

  result.drawable = newSprite(textureHolder.get(kind.toTextureID).texture, rectangle)