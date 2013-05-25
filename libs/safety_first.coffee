class safety_first
  joinLogs = registerHash "joinLogs"

  registerEvent player, "join", (event) ->
    joinLogs[event.player.entityId] = TimeSpan::now

  registerEvent entity, "damage", (event) ->
    return unless joinLogs[event.entity.entityId] > 10.seconds.ago
    event.cancelled = true

  registerEvent block, "burn", (event) ->
    event.cancelled = true

  registerEvent block, "spread", (event) ->
    return unless event.source.type == Material.FIRE
    event.cancelled = true

class MagicalFires
  MagicalFires::magicalFire = createItemMeta 1, (meta) ->
    meta.displayName = "\xA76\xA7oMagical Fire"
    meta.lore = [ "\xA77Watch the magics happen when you place it on wood :3" ]

  nextToMagicalFire = (block) ->
    return true if cloneLocation(block.location, x: block.location.x + 1).block.hasMetadata "magicalFire"
    return true if cloneLocation(block.location, x: block.location.x - 1).block.hasMetadata "magicalFire"

    return true if cloneLocation(block.location, y: block.location.y + 1).block.hasMetadata "magicalFire"
    return true if cloneLocation(block.location, y: block.location.y - 1).block.hasMetadata "magicalFire"

    return true if cloneLocation(block.location, z: block.location.z + 1).block.hasMetadata "magicalFire"
    return true if cloneLocation(block.location, z: block.location.z - 1).block.hasMetadata "magicalFire"

    false

  registerEvent block, "burn", (event) ->
    return unless nextToMagicalFire event.block
    fw.mk event.block.location, [fw.randcolor(2)], 0

  registerEvent block, "place", (event) ->
    return unless MagicalFires::magicalFire.equals event.itemInHand.itemMeta
    event.blockPlaced.setMetadata "magicalFire", new org.bukkit.metadata.FixedMetadataValue plugin, "magicalFire"