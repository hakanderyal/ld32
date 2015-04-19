import csfml
import tables, hashes

type
  States {.pure.}= enum
    None, Title, Menu, Game, Loading, Pause

  StackAction {.pure.} = enum
    Push, Pop, Clear

  PendingChange = object
    action: StackAction
    stateId: States

type
  State = ref object
    id: States

proc newState*(id: States): State =
  new result
  result.id = id

proc handleEvent*(this: State, event: Event): bool =
  discard

type
  StateStack = ref object
    stack: seq[State]
    pendingList: seq[PendingChange]

proc applyPendingChanges*(this: StateStack)

proc newStateStack*(): StateStack =
  new result
  result.stack = @[]

proc createState*(this: StateStack, stateId: States): State =
  return newState(stateId)

proc update*(this: StateStack, dt: Time) =
  discard

proc draw*(this: StateStack) =
  discard

proc handleEvent*(this: StateStack, event: Event) =
  for state in this.stack:
    if not state.handleEvent(event):
      break

  this.applyPendingChanges()

proc pushState*(this: StateStack, stateId: States) =
  discard

proc popState*(this: StateStack) =
  discard

proc clearStates*(this: StateStack) =
  discard

proc isEmpty*(this: StateStack): bool =
  discard

proc applyPendingChanges*(this: StateStack) =
  for change in this.pendingList:
    case change.action:
    of StackAction.Push:
      this.stack.add(this.createState(change.stateId))
    of StackAction.Pop:
      discard this.stack.pop()
    of StackAction.Clear:
      this.stack = @[]

  this.pendingList = @[]

