cloneLocation = (location, args) ->
  loc = location.clone()
  for k,v of args
    loc[k] = v if v?
  return loc

class GroundFinder
  safeSpotCache = registerHash "safeSpotCache"
  closeCacheItem = (location, distance) ->
    for k,v of safeSpotCache
      return v if v.distance(location) < distance
    null
  closeCacheItems = (location, distance) ->
    for k,v of safeSpotCache
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
    @prop 'hashCode', get: () -> "#{@location.block.x},#{@location.block.y},#{@location.block.z}"

  GroundFinder::suitableGround = (location) ->
    distances = []

    cacheItem = closeCacheItem location, 2
    return cacheItem.safeSpot if cacheItem

    for y in [location.y - 3 .. location.y + 5]
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
      a.distance - b.distance

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
      safeSpotCache.splice safeSpotCache.indexOf(item), 1
  registerEvent block, "bbreak", (event) ->
    for item in closeCacheItems event.player.location, 10
      safeSpotCache.splice safeSpotCache.indexOf(item), 1

safeTeleport = (entity, location) ->
  checkTeleport entity
  location = GroundFinder::suitableGround location
  throw "No safe location" if not location
  entity.teleport location
