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
  func = args.splice args.length - 1, 1
  Bukkit.server.scheduler.scheduleSyncDelayedTask plugin, Runnable () -> func.apply @, args