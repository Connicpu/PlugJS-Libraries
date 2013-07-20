motds = JsPersistence.tryGet "motdList", []

registerEvent server, 'ping', (event) ->
  event.motd = "\xA72CMCS - Hooray, we're back!"
