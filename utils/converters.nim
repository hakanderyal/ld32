import csfml, csfml_ext

proc rect*(r: FloatRect): IntRect =
  result = IntRect()
  result.left = cint(r.left)
  result.top = cint(r.top)
  result.width = cint(r.width)
  result.height = cint(r.height)

proc fRect*(vec1: Vector2f, vec2: Vector2f): FloatRect =
  result = FloatRect()
  result.left = cfloat(vec1.x)
  result.top = cfloat(vec1.y)
  result.width = cfloat(vec2.x)
  result.height = cfloat(vec2.y)

proc fRect*(x: float, y: float, width: float, height: float): FloatRect =
  result = FloatRect()
  result.top = x
  result.left = y
  result.width = width
  result.height = height

proc iRect*(vec1: Vector2f, vec2: Vector2f): IntRect =
  result = IntRect()
  result.left = cint(vec1.x)
  result.top = cint(vec1.y)
  result.width = cint(vec2.x)
  result.height = cint(vec2.y)
