evalResultStack = registerHash "evalResultStack"

registerEvent js, "extensions", (event) ->
  event.ext.p = event.sender
  event.ext.loc = event.sender.location
  event.ext.i = event.sender.itemInHand
  event.ext.world = event.sender.world
  event.ext.pl = _a loader.server.onlinePlayers
  event.ext.en = org.bukkit.entity;
  if evalResultStack[event.sender.name]
    stack = evalResultStack[event.sender.name]
    event.ext.lr = stack[0]
    event.ext.lrs = stack

  for player in _a loader.server.offlinePlayers
    event.ext[player.name] ||= player

registerEvent js, "evalComplete", (event) ->
  stack = evalResultStack[event.sender.name] ||= []
  stack.threads ||= []

  return unless event.result?

  stack.splice 0, 0, event.result
  stack.threads.splice 0, 0, event.result if event.result instanceof java.lang.Thread

registerCommand {
    name: "stopJsThreads"
    description: "Stops all the threads you've started with js/cf"
    usage: "\xA7e/<command>"
    permission: "js.eval"
    permissionMessage: "\xA7cNo can do, boss!"
  },
  (sender, label, args) ->
    unless (stack = evalResultStack[sender.name]) and stack.threads and stack.threads.length
      sender.sendMessage "\xA7eNo threads stored"
      return

    thread.stop() for thread in stack.threads
    stack.threads = []

    sender.sendMessage "\xA7eThreads stopped"

registerEvent player, "interact", (event) ->
  
