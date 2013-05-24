class Queue
  constructor: () ->
    @queue = []
  enqueue: sync (item) ->
    @queue.push(item)
  dequeue: sync () ->
    first = @queue[0]
    @queue.splice 0, 1
    return first