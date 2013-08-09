importPackage org.bukkit
require 'classload_helpers'
require 'permissions'
require 'minecraft_items'
require 'time_helpers'
require 'bukkit_safety_checks'
try require 'action_queue'
require 'player_input'
require 'clans'

registerEvent entity, 'damageByEntity', (event) ->
  return unless event.entity instanceof org.bukkit.entity.Player and event.damager instanceof org.bukkit.entity.Player
  event.cancelled = yes

class AfkTime
  times = registerHash 'afk_times'
  for: (player) ->
    time = (TimeSpan::now - times[player.entityId]).milliseconds
    "#{time.to_minutes} and #{(time.to_seconds.value % 60).seconds}"
  onPlayerEvent: (event) ->
    times[event.player.entityId] = TimeSpan::now

  registerEvent player, 'move', AfkTime::onPlayerEvent
  registerEvent player, 'chat', AfkTime::onPlayerEvent
  registerEvent player, 'command', AfkTime::onPlayerEvent

doOnTicks = (ticks, fn) ->
  class TickEvent
    constructor: (fn) ->
      @cb = registerEvent spout, 'tick', fn
    done: -> unregisterEvent spout, 'tick', @cb

  tickMod = 0
  new TickEvent ->
    return if ++tickMod % ticks
    fn()

gplra = (playername) ->
  playername = new java.lang.String playername
  matches = for player in _s Bukkit.server.onlinePlayers
    name = player.name
    disp = ChatColor.stripColor player.displayName
    if playername.startsWith(name) or playername.startsWith(disp) then player else continue
  matches

incrementBlockId = (block) ->
  id = block.typeId
  unless Material.getMaterial(++id)?
    id = 1
  try
    block.typeId = id
checkTeleport = (player) ->
  if player instanceof org.bukkit.entity.Player
    event =
      cancelled: false
      player: player
      cancelMessage: "Teleport Cancelled"
    callEvent js, "teleport", event
    throw event.cancelMessage if event.cancelled
exactPlayer = (name) ->
  return name if name instanceof org.bukkit.entity.Player
  Bukkit.server.getPlayerExact name.replace /^@/, ''

getItemId = (value) ->
  return value.id if value instanceof org.bukkit.Material
  return new Number(value) unless isNaN value
  envalue = enumFind org.bukkit.Material, value
  return envalue.id if envalue
  for item in minecraft_item_regexes
    return item[1] if item[0].test(value)
  return -1
itemStack = (id, amount, data, meta) ->
  id = getItemId(id)
  item = new org.bukkit.inventory.ItemStack(id)
  item.amount = amount  if amount
  item.durability = data  if data
  item.itemMeta = meta  if meta
  return item
class BlockInfo
  dangerousItems = [8, 9, 10, 11, 30, 81]
  constructor: (block) ->
    block = block.block if block instanceof org.bukkit.Location
    @id = new Number(block.typeId)
    @data = new Number(block.data)
    @solid = block.type.solid
    @dangerous = arrayContains dangerousItems, @id
    @getBlock = () -> block
nearestEntity = (searchEntity, type) ->
  searchL = if searchEntity instanceof org.bukkit.Location
    searchEntity
  else searchEntity.location
  target = null

  entities = _a searchEntity.world.entities

  entities.splice(entities.indexOf(searchEntity), 1)

  if type
    type = org.bukkit.entity[type] if typeof(type) == 'string'
    _entities = entities
    entities = []
    for entity in _entities
      entities.push(entity) if entity instanceof type

  for entity in entities
    targetL = target.location if target
    entityL = entity.location

    target = entity if not target or entityL.distance(searchL) < targetL.distance(searchL)

  return target

kill = (entity) ->
  entity = gplr entity if typeof entity == 'string'

  if entity.health?
    entity.health = 0
  else
    entity.remove()

  true
heal = (entity) ->
  entity = gplr entity if typeof entity == 'string'
  return unless entity instanceof org.bukkit.entity.LivingEntity
  entity.health = entity.maxHealth

boolOnOff = (bool) ->
  if bool
    "\xA7aOn"
  else
    "\xA7cOff"

String::toTitleCase = () ->
  newstr = ""
  firstLetter = true
  for c in _s @
    if /[ _\n]/.test c
      newstr += ' '
      firstLetter = true
      continue

    if firstLetter
      newstr += c.toUpperCase()
      firstLetter = false
    else
      newstr += c.toLowerCase()

  newstr

String.prop 'titleCase', get: () -> @toTitleCase()

class ReplaceArgs
  constructor: (@args) ->
    @args = _a @args
    @match = @args[0]
    @groups = @args.splice 1, @args.length - 3
    @offset = @args[1]
    @input = @args[2]

String::toSentenceCase = () ->
  str = _s @
  str = str.replace /([^a-z]+)?(.*?)(x[d3p]|\:[lspvd]|\.|\;|$)/ig, () ->
    args = new ReplaceArgs arguments
    return "#{args.groups[0] ? ''}#{args.groups[1].substr(0, 1).toUpperCase()}#{args.groups[1].substr(1).toLowerCase()}#{args.groups[2] ? ''}"
  str = str.replace /\bi\b/ig, 'I'
  str

enumerate = (_enum) ->
  enums = []
  for k,v of _enum
    enums.push v if v instanceof _enum
  enums

enumFind = (_enum, value) ->
  value = _s(value).toUpperCase().replace /[_]/i, ''
  for k,v of _enum
    name = _s k
    name = name.toUpperCase().replace /[_]/i, ''
    if name == value
      return v
  undefined

class ItemColor
  dyes = ["black", "red", "green", "brown", "blue", "purple", "cyan", "lightgray", "gray", "pink", "lime", "yellow", "lightblue", "magenta", "orange", "white"]
  chat = ["black", "blue", "green", "cyan", "red", "magenta", "orange", "lightgray", "gray", "purple", "lime", "lightblue", "brown", "pink", "yellow", "white"]

  constructor: (@value, mode) ->
    switch _s(mode).toTitleCase()
      when "Wool"
        @value = ItemColor.fromWoolName @value
      when "Ink Sack"
        @value = ItemColor.fromDyeName @value
      else
        if isNaN @value
          throw "Unknown data value"

  woolName: () ->
    dyes[15 - @value]
  dyeName: () ->
    dyes[@value]
  chatColor: (mode) ->
    switch _s(mode).toTitleCase()
      when "Ink Sack"
        chat.indexOf(@dyeName()).toString 16
      else
        chat.indexOf(@woolName()).toString 16

  @fromDyeName: (color) ->
    index = dyes.indexOf color
    if index == -1
      throw "Unknown color" if isNaN color
      index = color

    return index
  @fromWoolName: (color) ->
    return 15 - @fromDyeName color

  ItemColor::dyeValue = (color) ->
    return new ItemColor(color, Material.INK_SACK).value
  ItemColor::woolValue = (color) ->
    return new ItemColor(color, Material.WOOL).value

selectPlayers = (args, context) ->
  plrs = [];
  for p in args
    switch p
      when '*'
        return _a Bukkit.server.onlinePlayers
      when '#near'
        throw "Requires player context" if not context instanceof org.bukkit.Player
        plrs = for p in Bukkit.server.onlinePlayers
          p if p.location.distance(context.location) < 32
        return plrs
      when '#world'
        throw "Requires player context" if not context instanceof org.bukkit.Player
        plrs = for p in Bukkit.server.onlinePlayers
          p if p.world == context.world
        return plrs
      
    player = gplr p
    plrs.push player if player?
  plrs

selectTarget = (arg, player) ->
  isCoords = (arg) ->
    split = arg.split(',')
    return false unless split.length == 3 or split.length == 4
    for k in [0..2]
      return false if isNaN split[k]
    return true unless split[3] and not loader.server.getWorld(split[3])
    return false
  parseCoords = (arg) ->
    split = arg.split(',')
    throw "Invalid coordinates" if not /^((\-)?[\d]+),((\-)?[\d]+),((\-)?[\d]+)(,[a-z0-9_]+)?$/i.test arg;
    cloneLocation getloc
      x: split[0]
      y: split[1]
      z: split[2]
      world: loader.server.getWorld(split[3]) || player.world || players[0].world

  switch arg
    when '#spawn'
      return player.world.spawnLocation
    when '#near'
      nearby = nearestEntity player, 'Player'
      throw "No other players in your world!" if not nearby?
      return nearby.location

  return parseCoords arg if isCoords arg
  return exactPlayer(arg).location if exactPlayer arg
  return getWorld(arg).spawnLocation if getWorld arg
  return gplr(arg).location if gplr arg
  throw "Target not found!"

heightAboveGround = (entity) ->
  loc = entity.location
  while loc.y > 0
    --loc.y
    for x in [loc.x - 0.5 .. loc.x + 0.5]
      for z in [loc.z - 0.5 .. loc.z + 0.5]
        info = new BlockInfo cloneLocation loc,
          x: x
          z: z
        return entity.location.y - loc.y if info.solid

  entity.location.y
makeBlockHandler = (block, func) ->
  registerEvent player, 'interact', (event) ->
    return unless event.action == event.action.RIGHT_CLICK_BLOCK
    return unless event.clickedBlock.equals block
    func event

createItemMeta = (baseType, func) ->
  stack = itemStack(baseType, 1)
  meta = stack.itemMeta
  func(meta)
  meta

require 'entity_markers'
require 'spout_helpers' if getPlugin "Spout"

class AutoSave
  save_rate = 5.minutes.of.ticks
  tick_pos = registerHash("auto_save_pos")
  tick_pos.pos ?= 1

  registerEvent spout, 'tick', ->
    return unless (tick_pos.pos++ % save_rate) is 0
    tick_pos.pos -= save_rate
    Bukkit.server.broadcastMessage "\xA77\xA7oSaving the map..."

    for world in _a Bukkit.server.worlds
      world.save()

    Bukkit.server.broadcastMessage "\xA77\xA7oSave complete"
