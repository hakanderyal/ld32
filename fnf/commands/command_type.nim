type
  CommandType* = enum
    ctNone = 0,
    ctScene = 1 shl 0,
    ctPlayerAircraft = 1 shl 1
    ctAlliedAircraft = 1 shl 2
    ctEnemyAircraft = 1 shl 3
    ctPowerCircle = 1 shl 4
    ctAtomic = 1 shl 5