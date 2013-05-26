class Permissions
  vault = getPlugin "Vault"
  throw "Vault not found!" unless vault?

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
      if world == undefined
        permissionProvider.has @player, permission
      else
        permissionProvider.has world, @player.name, permission
    add: (permission, world) ->
      if world == undefined
        permissionProvider.playerAdd @player, permission
      else
        permissionProvider.playerAdd world, @player.name, permission
    remove: (permission, world) ->
      if world == undefined
        permissionProvider.playerRemove @player, permission
      else
        permissionProvider.playerRemove world, @player.name, permission
    isInGroup: (group, world) ->
      if world == undefined
        permissionProvider.playerInGroup @player, group
      else
        permissionProvider.playerInGroup world, @player.name, group
    addGroup: (group, world) ->
      if world == undefined
        permissionProvider.playerAddGroup @player, group
      else
        permissionProvider.playerAddGroup world, @player.name, group
    removeGroup: (group, world) ->
      if world == undefined
        permissionProvider.playerRemoveGroup @player, group
      else
        permissionProvider.playerRemoveGroup world, @player.name, group

    @prop 'primaryGroup', get: () -> getPrimaryGroup null
    @prop 'groups', get: () -> getGroups()
