class PrivateWarps
  warps = JsPersistence.tryGet "privateWarps", {}
  class Warp
    constructor: (@owner, location) ->
      @owner = _s @owner.name unless typeof(@owner) is 'string'
      @world = _s location.world.name
      @x = location.x
      @y = location.y
      @z = location.z
      @yaw = location.yaw

    teleport: (player) ->
      world = Bukkit.server.getWorld @world
      location = cloneLocation world.spawnLocation, x: @x, y: @y, z: @z, yaw: @yaw
      player.teleport location

  registerCommand
    name: "pwarp",
    description: "makes a private warp lel",
    usage: "/<command> [warp name]",
    permission: registerPermission("js.privatewarps", "op"),
    permissionMessage: "lel",
    (sender, label, args) ->
      warpname = args.join(' ').toLowerCase()
      throw "Warp not found" unless warps[sender.name.toLowerCase()] and warps[sender.name.toLowerCase()][warpname]?
      warp = warps[sender.name.toLowerCase()][warpname]
      Warp::teleport.apply warp, [ sender ]
      sender.sendMessage "\xA7eTeleported!"

  registerCommand
    name: "psetwarp",
    description: "makes a private warp lel",
    usage: "/<command> [warp name]",
    permission: registerPermission("js.privatewarps", "op"),
    permissionMessage: "lel",
    (sender, label, args) ->
      warpname = args.join(' ').toLowerCase()
      warps[sender.name.toLowerCase()] = {} unless warps[sender.name.toLowerCase()]?
      warp = new Warp sender, sender.location
      warps[sender.name.toLowerCase()][warpname] = warp
      sender.sendMessage "\xA7eWarp '#{warpname}' created!"

  registerCommand
    name: "pdelwarp",
    description: "makes a private warp lel",
    usage: "/<command> [warp name]",
    permission: registerPermission("js.privatewarps", "op"),
    permissionMessage: "lel",
    (sender, label, args) ->
      warpname = args.join(' ').toLowerCase()
      throw "Warp not found" unless warps[sender.name.toLowerCase()] and warps[sender.name.toLowerCase()][warpname]?
      warps[sender.name.toLowerCase()][warpname] = undefined
      sender.sendMessage "\xA7eWarp '#{warpname}' deleted!"
