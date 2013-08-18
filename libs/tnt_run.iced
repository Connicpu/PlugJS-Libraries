class TNTRun
  destruction_queue = registerHash "destruction_queue"

  class BlockDestructionHandler
    constructor: (@block) ->
      return if destruction_queue[@hashCode]?
      destruction_queue[@hashCode] = @

      await bukkit_sync defer(), null, 1.second.of.ticks

      @block.type = Material.AIR      

    @prop 'hashCode',
      get: -> "#{@block.world.name},#{@block.x},#{@block.y},#{@block.z}"

  registerEvent player, 'move', (event) ->
    block = event.player.location.block
    block = block.getRelative org.bukkit.block.BlockFace.DOWN
    return unless block.type is Material.SAND or block.type is Material.GRAVEL
