function async(fn) {
    var thread = new java.lang.Thread(new java.lang.Runnable() {
        run: function() {
            if (typeof(fn) === 'string') {
                eval(fn);
            } else {
                fn();
            }
        }
    });
    thread.start();
    return thread;
}

function asyncTask(name, func) {
    var thread;
    if (thread = persistence.get("__async__" + name)) {
        thread.stop();
    }
    thread = async(func);
    persistence.put("__async__" + name, thread);
    return thread;
}

function Runnable(func) {
    return new java.lang.Runnable {
        run: func
    }
}

default_callback = function() {};

bukkit_sync = function(fn, callback, delay, args) {
  var task;
  if (callback == null) {
    callback = default_callback;
  }
  if (delay == null) {
    delay = 1;
  }
  if (args == null) {
    args = [];
  }
  task = Runnable(function() {
    var result = fn.apply(this, args);
    return async(function() {
      return callback(result);
    });
  });
  return Bukkit.server.scheduler.scheduleSyncDelayedTask(plugin, task, delay);
};