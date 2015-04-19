import csfml

type
  GameContext* = ref object
    viewBounds*: FloatRect

var contextObj*: GameContext