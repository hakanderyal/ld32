type
  Pair* [A, B]= tuple[first: A, second: B]

proc minmax* [A, B](item1: A, item2: B): Pair[A, B] =
  # if cast[ptr](item1) < cast[ptr](item2):
  #   result = (item1, item2)
  # else:
  #   result = (item2, item1)
  if item1.id < item2.id:
    result = (item1, item2)
  else:
    result = (item2, item1)
