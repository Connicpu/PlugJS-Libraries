importPackage org.bukkit
require 'minecraft_items.coffee'
require 'time_helpers.coffee'

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
cloneLocation = (location, args) ->
  loc = location.clone()
  for k,v of args
    loc[k] = v if v?
  return loc
suitableGround = (_location) ->
  distances = []
  checkDirection = (location, property, direction, radius) ->
    i = location[property]

    for i in [location[property]..location[property] + radius*direction]
      loc = location.clone()
      loc[property] = i
      if locationSafe(loc)
        distances.push
          distance: location.distance(loc)
          location: loc
        break

  checkDirection _location, "x",  1,  5
  checkDirection _location, "x", -1,  5
  checkDirection _location, "y",  1, 20
  checkDirection _location, "y", -1,  5
  checkDirection _location, "z",  1,  5
  checkDirection _location, "z", -1,  5

  return false if distances.length < 1

  distances.sort (a, b) ->
    a.distance - b.distance

  distances[0].location
locationSafe = (location) ->
  location = location.clone().block.location

  firstYSweep = true
  for y in [location.y-1..location.y+1]
    for x in [location.x-0..location.x+0]
      for z in [location.z-0..location.z+0]
        info = new BlockInfo cloneLocation location,
          x: x
          y: y
          z: z
          yaw: location.yaw
          pitch: location.pitch
        return false if (info.solid and not firstYSweep) or info.dangerous
        firstYSweep = false
  true
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
BlockInfo = (block) ->
  block = block.block if block instanceof org.bukkit.Location
  @id = new Number(block.typeId)
  @data = new Number(block.data)
  @solid = block.type.solid
  @dangerous = arrayContains([8, 9, 10, 11, 30, 81], @id)
  @getBlock = ->
    block
  return
safeTeleport = (entity, location) ->
  checkTeleport entity
  location = suitableGround(location)
  throw "No safe location" if not location
  entity.teleport(location)
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

  if entity.health
    entity.health = 0
  else
    entity.remove()

  true

boolOnOff = (bool) ->
  if bool
    "\xA7aOn"
  else
    "\xA7cOff"

String::toTitleCase = () ->
  newstr = ""
  firstLetter = true
  for c in @
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

enumerate = (_enum) ->
  for k,v of _enum
    v if v instanceof _enum

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
    player if player?

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
    throw "Invalid coordinates" if not /^([\d]+),([\d]+),([\d]+)(,[a-z0-9_]+)?$/i.test arg;
    cloneLocation getloc
      x: split[0]
      y: split[1]
      z: split[2]
      world: loader.server.getWorld(split[3]) || sender.world || players[0].world

  switch arg
    when '#spawn'
      return player.world.spawnLocation
    when '#near'
      nearby = nearestEntity player, 'Player'
      throw "No other players in your world!" if not nearby?
      return nearby.location

  return parseCoords arg if isCoords arg
  return exactPlayer(arg).location if exactPlayer arg
  return getWorld arg if getWorld arg
  return gplr(arg).location if gplr arg
  throw "Target not found!"

