class Queue
  constructor: () ->
    @queue = []
  enqueue: sync (item) ->
    @queue.push(item)
  dequeue: sync () ->
    first = @queue[0]
    @queue.splice 0, 1
    return first

bukkit_async = () ->
  args = _a(arguments)
  func = args.splice(args.length - 1, 1)[0]
  Bukkit.server.scheduler.scheduleSyncDelayedTask(plugin, (Runnable () -> func.apply @, args), 1)

delayed_do = (times, func) ->
  for i in [1..times]
    await bukkit_async i, defer index
    func index
Number.prop 'times', get: () -> (fn) -> delayed_do(@, fn)
