loadClass = (classPath) ->
  classInfo = plugin.class.classLoader.loadClass classPath
  class BukkitClass
    constructor: () ->
      constructors = classInfo.constructors
      throw "No known constructors" if constructors.length == 0
      
String.prop 'plugin', get: () -> getPlugin @

cls =
  toString: () ->
    output = ""
    output += " \n" for i in [1..100]
    output

class EventHandler
  class EventRegistration
    constructor: (@handler, @name, @cancellationToken) ->
    unregister: -> unregisterEvent @handler, @name, @cancellationToken

  constructor: () -> 
    @registeredHandlers = []
    @onRegister()

  register: (handler, name, event) ->
    self = @
    cancellationToken = registerEvent handler, name, -> event.apply(self, arguments)
    registration = new EventRegistration handler, name, cancellationToken
    @registeredHandlers.push registration

  onRegister: ->

  finalize: -> registration.unregister() for registration in @registeredHandlers
