import csfml, csfml_ext, csfml_audio
import tables, hashes

type
  TextureHolder* = ref object
    map: OrderedTableRef[TextureID, ImportedTexture]

  TextureID* {. pure .} = enum 
    MainShip, AtomicPositive, AtomicNegative, AtomicPositiveFast

  ImportedTexture* = ref object
    texture*: Texture
    id*: TextureID


proc hash(x: TextureID): THash =
  result = hash($x)
  # result = !$result

proc newTextureMap*(): TextureHolder =
  var tbl = newOrderedTable[TextureID, ImportedTexture]()
  result = TextureHolder(map: tbl)

proc load*(this: var TextureHolder, id: TextureID, fileName: string): void =
  # var nTexture = newTexture(fileName)
  # if nTexture == nil:
  #   echo "error"
  var impTexture = ImportedTexture(texture: newTexture(fileName), id: id)
  this.map.add(id, impTexture)

proc get*(this: TextureHolder, id: TextureID): ImportedTexture =
  let impTexture = this.map.mget(id)
  return impTexture


type
  FontHolder* = ref object
    map: OrderedTableRef[FontID, ImportedFont]

  FontID* {. pure .} = enum 
    Main

  ImportedFont* = ref object
    font*: Font
    id*: FontID


proc hash(x: FontID): THash =
  result = hash($x)
  # result = !$result

proc newFontMap*(): FontHolder =
  var tbl = newOrderedTable[FontID, ImportedFont]()
  result = FontHolder(map: tbl)

proc load*(this: var FontHolder, id: FontID, fileName: string): void =
  # var nFont = newFont(fileName)
  # if nFont == nil:
  #   echo "error"
  var impFont = ImportedFont(font: newFont(fileName), id: id)
  this.map.add(id, impFont)

proc get*(this: FontHolder, id: FontID): ImportedFont =
  let impFont = this.map.mget(id)
  # assert impFont.Font != this.map.end()
  return impFont


type
  SoundBufferHolder* = ref object
    map: OrderedTableRef[SoundBufferID, ImportedSoundBuffer]

  SoundBufferID* {. pure .} = enum 
    Main

  ImportedSoundBuffer* = ref object
    soundBuffer*: SoundBuffer
    id*: SoundBufferID


proc hash(x: SoundBufferID): THash =
  result = hash($x)
  # result = !$result

proc newSoundBufferMap*(): SoundBufferHolder =
  var tbl = newOrderedTable[SoundBufferID, ImportedSoundBuffer]()
  result = SoundBufferHolder(map: tbl)

proc load*(this: var SoundBufferHolder, id: SoundBufferID, fileName: string): void =
  # var nSoundBuffer = newSoundBuffer(fileName)
  # if nSoundBuffer == nil:
  #   echo "error"
  var impSoundBuffer = ImportedSoundBuffer(soundBuffer: newSoundBuffer(fileName), id: id)
  this.map.add(id, impSoundBuffer)

proc get*(this: SoundBufferHolder, id: SoundBufferID): ImportedSoundBuffer =
  let impSoundBuffer = this.map.mget(id)
  # assert impSoundBuffer.SoundBuffer != this.map.end()
  return impSoundBuffer


type
  ShaderHolder* = ref object
    map: OrderedTableRef[ShaderID, ImportedShader]

  ShaderID* {. pure .} = enum 
    Main

  ImportedShader* = ref object
    shader*: Shader
    id*: ShaderID


proc hash(x: ShaderID): THash =
  result = hash($x)
  # result = !$result

proc newShaderMap*(): ShaderHolder =
  var tbl = newOrderedTable[ShaderID, ImportedShader]()
  result = ShaderHolder(map: tbl)

proc load*[T](this: var ShaderHolder, id: ShaderID, fileName: string, param: T): void =
  # var nShader = newShader(fileName)
  # if nShader == nil:
  #   echo "error"
  var impShader = ImportedShader(shader: newShader(fileName, param), id: id)
  this.map.add(id, impShader)

proc get*(this: ShaderHolder, id: ShaderID): ImportedShader =
  let impShader = this.map.mget(id)
  # assert impShader.Shader != this.map.end()
  return impShader
