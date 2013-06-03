class CodeBlockAttachments
  attaching = registerHash 'code_attachments_currently'

  generateAttachment = (block, type) ->
    block = switch type
      when "cf" then CoffeeScript.compile block, bare: yes
      when "js" then block
      else throw "Unknown code type '#{type}'"
    return new org.bukkit.metadata.FixedMetadataValue plugin, block

  registerPermission "js.code.attaching", "op"

  registerCommand
    name: "blockcode",
    description: "Attaches code to a block, use {clipboard} with spout to use your clipboard",
    usage: "\xA7e/<command> <js/cf> [code...]",
    permission: "js.code.attaching",
    permissionMessage: "\xA7cLol pwned",
    aliases: [ "bc" ],
    (sender, label, args, flags) ->
      throw "Only a player can do that!" unless sender instanceof org.bukkit.entity.Player
      if args.length is 0 and attaching[sender.entityId]?
        attaching[sender.entityId] = undefined
        sender.sendMessage "\xA7cAttachment cancelled"
        return
      type = args.splice(0, 1)[0]
      message = args.join ' '
      message = message.replace /\{clipboard\}/i, sender.clipboardText

      attachment = generateAttachment message, type

      sender.sendMessage "\xA7a#{attachment.asString()}"
      sender.sendMessage "\xA76The previous code will be attached to the next block you click. Cancel with /#{label}"

      attaching[sender.entityId] = attachment

  getMetadata = (block, key, plugin) ->
    return null unless block.hasMetadata key
    keys = _a block.getMetadata key
    if plugin?
      for key in keys
        return key if key.owningPlugin is plugin
      return null
    else
      return keys[0]

  registerEvent player, 'interact', (event) ->
    return unless event.action is event.action.RIGHT_CLICK_BLOCK
    block = event.clickedBlock
    if attaching[event.player.entityId]?
      if getMetadata(block, "CodeBlockAttachment", plugin)?
        block.removeMetadata "CodeBlockAttachment", plugin
      attachment = attaching[event.player.entityId]
      block.setMetadata "CodeBlockAttachment", attachment
      event.player.sendMessage "\xA76Code attached to #{block.type} @ data=#{block.data}, x=#{block.x}, y=#{block.y}, z=#{block.z}"
      attaching[event.player.entityId] = undefined
      return

    attachment = getMetadata block, "CodeBlockAttachment", plugin
    return unless attachment?

    ext =
      p: event.player
      loc: event.player.location
      i: event.player.itemInHand
      world: event.player.world
      pl: _a Bukkit.server.onlinePlayers
      en: org.bukkit.entity

    try
      evalInContext attachment.asString(), ext
    catch error
      if typeof error is 'string'
        event.player.sendMessage "\xA7c#{error}"
      else
        log "#{error}", 'c'

