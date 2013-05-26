class Permissions
  throw "Vault not found!" unless 'Vault'.plugin?
  vault = getPlugin "Vault"

  chatProviderService = loader.server.servicesManager.getRegistration vault.class.classLoader.loadClass "net.milkbowl.vault.chat.Chat"
  throw "Error loading vault chat provider" unless chatProviderService.provider?
  chatProvider = chatProviderService.provider

  permissionProviderService = loader.server.servicesManager.getRegistration vault.class.classLoader.loadClass "net.milkbowl.vault.permission.Permission"
  throw "Error loading vault permission provider" unless permissionProviderService.provider?
  permissionProvider = permissionProviderService.provider

  @prop 'supportsGroups', get: () -> permissionProvider.hasGroupSupport()
  @prop 'superPermsCompatible', get: () -> permissionProvider.hasSuperPermsCompat()

  @::getPlayer = (player) -> new PlayerInfo player

  class PlayerInfo
    constructor: (@player) ->
      @player = (gplr @player || Bukkit.server.getOfflinePlayer @player) unless @player instanceof org.bukkit.command.CommandSender
    getGroups: (world) ->
      if world == undefined
        permissionProvider.getPlayerGroups @player
      else
        permissionProvider.getPlayerGroups world, @player.name
    getPrimaryGroup: (world) ->
      permissionProvider.getPrimaryGroup world
    has: (permission, world) ->
      if world is undefined
        permissionProvider.has @player, permission
      else
        permissionProvider.has world, @player.name, permission
    add: (permission, world) ->
      if world is undefined
        permissionProvider.playerAdd @player, permission
      else
        permissionProvider.playerAdd world, @player.name, permission
    remove: (permission, world) ->
      if world is undefined
        permissionProvider.playerRemove @player, permission
      else
        permissionProvider.playerRemove world, @player.name, permission
    isInGroup: (group, world) ->
      if world is undefined
        permissionProvider.playerInGroup @player, group
      else
        permissionProvider.playerInGroup world, @player.name, group
    addGroup: (group, world) ->
      if world is undefined
        permissionProvider.playerAddGroup @player, group
      else
        permissionProvider.playerAddGroup world, @player.name, group
    removeGroup: (group, world) ->
      if world is undefined
        permissionProvider.playerRemoveGroup @player, group
      else
        permissionProvider.playerRemoveGroup world, @player.name, group

    getPrefix: (world) ->
      if world is undefined
        chatProvider.getPlayerPrefix @player
      else
        chatProvider.getPlayerPrefix world, @player.name
    setPrefix: (value, world) ->
      if world is undefined
        chatProvider.setPlayerPrefix @player, value
      else
        chatProvider.setPlayerPrefix world, @player.name, value

    getSuffix: (world) ->
      if world is undefined
        chatProvider.getPlayerSuffix @player
      else
        chatProvider.getPlayerSuffix world, @player.name
    setSuffix: (value, world) ->
      if world is undefined
        chatProvider.setPlayerSuffix @player, value
      else
        chatProvider.setPlayerSuffix world, @player.name, value

    class PlayerOptionInfoNoWorld
      constructor: (@pinfo, @node, @def) ->
        @player = @pinfo.player
      @prop 'boolean', get: () -> chatProvider.getPlayerInfoBoolean @player, @node, @def
      @prop 'string', get: () -> chatProvider.getPlayerInfoString @player, @node, @def
      @prop 'double', get: () -> chatProvider.getPlayerInfoDouble @player, @node, @def
      @prop 'integer', get: () -> chatProvider.getPlayerInfoInteger @player, @node, @def
    class PlayerOptionInfoWithWorld
      constructor: (@pinfo, @node, @world, @def) ->
        @player = @pinfo.player
      @prop 'boolean', get: () -> chatProvider.getPlayerInfoBoolean @world, @player.name, @node, @def
      @prop 'string', get: () -> chatProvider.getPlayerInfoString @world, @player.name, @node, @def
      @prop 'double', get: () -> chatProvider.getPlayerInfoDouble @world, @player.name, @node, @def
      @prop 'integer', get: () -> chatProvider.getPlayerInfoInteger @world, @player.name, @node, @def

    getInfo: (node, world, def) -> if world? then new PlayerOptionInfoWithWorld @, node, world, def else new PlayerOptionInfoNoWorld @, node, def

    @prop 'primaryGroup', get: () -> getPrimaryGroup null
    @prop 'groups', get: () -> getGroups null
    @prop 'prefix',
      get: () -> @getPrefix null
      set: (value) -> @setPrefix value, null
    @prop 'suffix',
      get: () -> @getSuffix null
      set: (value) -> @setSuffix value, null

