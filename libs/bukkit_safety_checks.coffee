cloneLocation = (location, args) ->
  loc = location.clone()
  for k,v of args
    loc[k] = v if v?
  return loc

class GroundFinder
  safeSpotCache = registerHash "safeSpotCache"
  closeCacheItem = (location, distance) ->
    for k,v of safeSpotCache
      continue unless v?
      continue unless v.world is location.world
      return v if v.distance(location) < distance
    null
  closeCacheItems = (location, distance) ->
    for k,v of safeSpotCache
      continue unless v?
      continue unless v.world is location.world
      v if v.distance(location) < distance

  class CacheItem
    constructor: (@location, @safeSpot) ->
    distance: (loc) ->
      dists = [ 
        @safeSpot.distance loc
        @location.distance loc
      ]
      dists.sort (a, b) -> a - b
      return dists[0]
    @prop 'hashCode', get: () -> "#{@location.block.x},#{@location.block.y},#{@location.block.z},#{@location.world.name}"

  GroundFinder::suitableGround = (location) ->
    distances = []

    cacheItem = closeCacheItem location, 2
    return cacheItem.safeSpot if cacheItem

    for y in [location.y - 3 .. location.y + 2]
      for x in [location.x - 2 .. location.x + 2]
        for z in [location.z - 2 .. location.z + 2]
          loc = cloneLocation location,
            x: x
            y: y
            z: z
          if GroundFinder::locationSafe loc
            distances.push
              distance: loc.distance location
              location: loc

    return false if distances.length < 1

    distances.sort (a, b) ->
      return a.distance - b.distance

    distances[0].location.x += 0.5;
    distances[0].location.z += 0.5;

    cacheItem = new CacheItem location, distances[0].location
    safeSpotCache[cacheItem.hashCode] = cacheItem
    return distances[0].location

  GroundFinder::locationSafe = (location) ->
    location = location.clone().block.location

    for y in [location.y-1..location.y-4]
      for x in [location.x-0.5..location.x+1]
        for z in [location.z-0.5..location.z+1]
          info = new BlockInfo cloneLocation location,
            x: x
            y: y
            z: z
          return false if info.dangerous
    for y in [location.y-1..location.y+1]
      for x in [location.x-0..location.x+0]
        for z in [location.z-0..location.z+0]
          continue if y > 255
          info = new BlockInfo cloneLocation location,
            x: x
            y: y
            z: z
          return false if info.solid
    for y in [location.y-1..location.y-4]
      for x in [location.x-0..location.x+0]
        for z in [location.z-0..location.z+0]
          info = new BlockInfo cloneLocation location,
            x: x
            y: y
            z: z
          return true if info.solid
    false

  registerEvent block, "place", (event) ->
    for item in closeCacheItems event.player.location, 10
      continue unless item?
      safeSpotCache[item.hashCode] = undefined
  registerEvent block, "bbreak", (event) ->
    for item in closeCacheItems event.player.location, 10
      continue unless item?
      safeSpotCache[item.hashCode] = undefined

safeTeleport = (entity, location) ->
  checkTeleport entity
  location = GroundFinder::suitableGround location
  throw "No safe location" if not location
  entity.teleport location

#Keep pets from dying
registerEvent entity, 'damage', (event) ->
  return unless event.entity instanceof org.bukkit.entity.Tameable
  return unless event.entity.owner?
  event.cancelled = yes

#Pets aren't allowed to kill players either, though!
registerEvent entity, 'damageByEntity', (event) ->
  return unless event.entity instanceof org.bukkit.entity.Player
  return unless event.damager instanceof org.bukkit.entity.Tameable
  return unless event.damager.owner?
  event.cancelled = yes

#Block PVP unless an internal script wants to allow it
registerEvent entity, 'damageByEntity', (event) ->
  shouldHandle = ->
    entityIsPlayer = event.entity instanceof org.bukkit.entity.Player
    damagerIsPlayer = event.damager instanceof org.bukkit.entity.Player
    damagerIsProjectile = event.damager instanceof org.bukkit.entity.Projectile
    projectileOwnedByPlayer = damagerIsProjectile and event.damager.shooter instanceof org.bukkit.entity.Player
    entityIsPlayer and (damagerIsPlayer or projectileOwnedByPlayer)

  return unless shouldHandle()

  damager = event.damager.shooter ? event.damager
  projectile = if event.damager instanceof org.bukkit.entity.Projectile then event.damager else null

  pvpEvent =
    player: event.entity
    damager: damager
    projectile: projectile
    cancelled: yes

  callEvent js, 'pvp', pvpEvent

  event.cancelled = pvpEvent.cancelled

registerEvent player, 'chat', (event) ->
  msg = _s event.message
  cancel = 
    /!mine/i.test(msg) or 
    /!chop/i.test(msg) or
    /!attack/i.test(msg)

  if cancel
    event.cancelled = yes
    event.player.sendMessage "\xA7cThat command has been blocked"

fixItemMetaColors = (dataItem) ->
  if dataItem instanceof org.bukkit.entity.Player
    player = dataItem
    return fixItemMetaColors player.inventory
  else if dataItem instanceof org.bukkit.inventory.Inventory
    inventory = dataItem
    for item in _a inventory
      fixItemMetaColors item
    return
  else if dataItem instanceof org.bukkit.inventory.ItemStack
    item = dataItem
    meta = item.itemMeta

    return unless meta?

    badCharPattern = /[\u00C2\u00C3\u00C6\u0192\u2019\u201A]/g

    if meta.displayName?
      meta.displayName = _s(meta.displayName).replace badCharPattern, ''

      if meta.displayName.equals 'null'
        meta.displayName = null

    if meta.lore?
      meta.lore = for l in _a meta.lore
        _s(l).replace badCharPattern, ''

    item.itemMeta = meta
    return

registerCommand
  name: "fixitemcolors",
  description: "Fixes dem item colors that contain a \xC2",
  usage: "/<command>",
  (sender, label, args) ->
    fixItemMetaColors sender
    sender.sendMessage "Hopefully it's fixed now :)"

registerEvent player, 'join', (event) ->
  bukkit_sync ->
    fixItemMetaColors event.player

registerEvent player, 'teleport', (event) ->
  fixItemMetaColors event.player

class TpDeath
  locations: registerHash 'tpdeath_locs'
  registerEvent player, 'death', (event) ->
    
