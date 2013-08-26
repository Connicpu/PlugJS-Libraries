class EventRegistration
  executorStatus = registerHash "custom_event_executor_status"
  executorStatus.registeredEventClasses = {}

  event_registrations = {}
  make_dummy_listener = (priority) -> new org.bukkit.event.Listener
    execute: -> return
    priority: priority
  dummy_listeners:
    

  executorStatus.executor ?= new org.bukkit.plugin.EventExecutor
    execute: (listener, event) ->
      registration = event_registrations[event.class.name]
      return unless registration?
      for handler in handlers

  class RegistrationGroup
    constructor: (@eventClass) ->
      @className = @eventClass.name
      @handlers = []
