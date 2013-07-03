registerEvent entity, 'creatureSpawn', (event) ->
  reason = _s(event.spawnReason.toString()).toTitleCase()
  legit = switch reason
    when "Natural" then yes
    when "Jockey" then yes
    when "Chunk Gen" then yes
    when "Spawner" then no
    when "Egg" then yes
    when "Spawner Egg" then no
    when "Lightning" then yes
    when "Bed" then yes
    when "Build Snowman" then yes
    when "Build Irongolem" then yes
    when "Village Defense" then yes
    when "Village Invasion" then yes
    when "Breeding" then yes
    when "Slime Split" then yes
    when "Custom" then no
    when "Default" then yes
    else no

  reasonMeta = new org.bukkit.metadata.FixedMetadataValue plugin, new java.lang.String reason
  legitMeta = new org.bukkit.metadata.FixedMetadataValue plugin, new java.lang.Boolean legit


