permissionPlugin = getPlugin "PermissionsEx"
permissionManager = permissionPlugin.permissionManager

permUser = (player) ->
  permissionManager.getUser player || permissionManager.getUser gplr player

prefix = (newPrefix, player) ->
  user = permUser player || currEvalPlr
  user.setPrefix(newPrefix.replace(/\&(?=[0-9a-fk-o])/gi, "\xA7"), null)

registerEvent js, "chatFormat", (event) ->
  user = permUser event.player
  event.prefix = user.prefix
  event.suffix = user.suffix