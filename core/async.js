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