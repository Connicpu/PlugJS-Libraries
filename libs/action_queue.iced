class Queue
  constructor: () ->
    @queue = []
  enqueue: sync (item) ->
    @queue.push(item)
  dequeue: sync () ->
    first = @queue[0]
    @queue.splice 0, 1
    return first

Number.prop 'times', get: () -> (fn, cb = default_callback) -> 
  for i in [1..@]
    await bukkit_sync fn, defer(), 1, [ i ]
  cb()
