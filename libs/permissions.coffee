permissionPlugin = getPlugin "PermissionsEx"
permissionManager = permissionPlugin.permissionManager

permUser = (player) ->
  permissionManager.getUser player || permissionManager.getUser gplr player

prefix = (newPrefix, player) ->
  user = permUser player || currEvalPlr
  user.setPrefix(newPrefix.replace(/\&(?=[0-9a-fk-o])/gi, "\xA7"), null)
  newPrefix.replace /\&(?=[0-9a-fk-o])/gi, "\xA7"

suffix = (newSuffix, player) ->
  user = permUser player || currEvalPlr
  user.setPrefix(newSuffix.replace(/\&(?=[0-9a-fk-o])/gi, "\xA7"), null)
  newSuffix.replace /\&(?=[0-9a-fk-o])/gi, "\xA7"

permOption = (option, value, player) ->
  user = permUser player || currEvalPlr
  user.setOption(option, value.replace(/\&(?=[0-9a-fk-o])/gi, "\xA7"))
  value.replace /\&(?=[0-9a-fk-o])/gi, "\xA7"

registerEvent js, "chatFormat", (event) ->
  user = permUser event.player
  event.prefix = user.prefix
  event.suffix = user.suffix
  event.chatcolor = user.getOption "chatcolor"
  event.clantag = user.getOption "clantag"
