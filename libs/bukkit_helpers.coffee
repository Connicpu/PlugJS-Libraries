# defineGlobal 'suitableGround'
# defineGlobal 'locationSafe'
# defineGlobal 'getItemId'
# defineGlobal 'itemStack'
# defineGlobal 'BlockInfo'
# defineGlobal 'cloneLocation'
# defineGlobal 'safeTeleport'

require 'minecraft_items.coffee'

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
  checkDirection _location, "y",  1, 10
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
  for y in [location.y..location.y+3]
    for x in [location.x-1..location.x+1]
      for z in [location.z-1..location.z+1]
        info = new BlockInfo cloneLocation location,
          x: x
          y: y
          z: z
        return false if (info.solid and not firstYSweep) or info.dangerous
        firstYSweep = false
  true
getItemId = (value) ->
  return value.id  if value instanceof org.bukkit.Material
  return new Number(value)  unless isNaN(value)
  return org.bukkit.Material[_s(value).toUpperCase()]  if enumContains(org.bukkit.Material, _s(value).toUpperCase())
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

registerEvent js, "extensions", (event) ->
  event["ent"] = org.bukkit.entity;