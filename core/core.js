Object.prototype.toString = function(){try{return JSON.stringify(this, ' ', '\t').replace(/\t/g, "  ");}catch(e){return "[object Object]"}}
Array.prototype.toString = function(){try{return JSON.stringify(this, ' ', '\t').replace(/\t/g, "  ");}catch(e){return "[object Array]"}}

function combineArgs(label, args) {
    return "/" + label + " " + args.join(" ");
}
function getWorld(world) {
    if (typeof(world) != 'string') return world;
    return loader.server.getWorld(_s(world).replace(/^[+]/i, ''));
}
function getloc(loc) {
    return new org.bukkit.Location(getWorld(loc.world),loc.x,loc.y,loc.z);
}
function __gplr__(pn,src) {
    pn = new java.lang.String(pn);
    var matches = null;
    for (var i = 0; i < src.length; ++i) {
        var rn = src[i].getName();
        var dn = org.bukkit.ChatColor.stripColor(src[i].displayName);
        if (pn.equalsIgnoreCase(rn) || pn.equalsIgnoreCase(dn)) {
            return src[i];
        }
        if ((rn.toLowerCase().startsWith(pn.toLowerCase()) || dn.toLowerCase().startsWith(pn.toLowerCase())) && matches == null) matches = src[i];
    }
    return matches;
}
function gplr(pn) {
    if (typeof(pn) != 'string') return pn;
    var aop = org.bukkit.Bukkit.getOnlinePlayers();
    return __gplr__(pn,aop);
}
function getEntity(entity) {
    if (typeof(entity) === 'function') {
        return entity;
    } else if (entity instanceof org.bukkit.entity.Entity) {
        return entity["class"];
    } else {
        return org.bukkit.entity[entity];
    }
}
function spawnEntity(type, loc) {
    loc = getloc(loc);
    return loc.world.spawnEntity(loc, getEntity(type));
}
function spawn(type, loc) {
    loc = getloc(loc);
    return loc.world.spawn(loc, getEntity(type));
}
function getPlugin(name) {
    if (typeof(name) !== 'string') {
        name = "PlugJS";
    }
    return loader.server.pluginManager.getPlugin(name);
}
function read_proc() {
    var pb = new java.lang.ProcessBuilder["(java.lang.String[])"](_a(arguments));
    pb.redirectErrorStream(true);
    var proc = pb.start();
    var out = proc.inputStream;
    var reader = new java.io.BufferedReader(new java.io.InputStreamReader(out));
    var output = "";
    var line;
    while ((line = reader.readLine()) != null) {
        output += line + "\n";
    }
    return output;
}
function registerEvent(handler, eventname, callback) {
    callback.cancelToken = new java.lang.Object();
    if (handler[eventname]) {
        handler[eventname].callbacks.splice(0, 0, callback);
    } else {
        handler[eventname] = function(event) {
            var callbacks = handler[eventname].callbacks;
            for (var i = 0; i < callbacks.length; ++i) {
                try {
                    callbacks[i](event);
                    if (event.cancelled) return;
                } catch (ex) {
                    log(ex)
                }
            }
        };
        handler[eventname].callbacks = [];
        handler[eventname].callbacks.push(callback);
    }
    return callback.cancelToken;
}
function unregisterEvent(handler, eventname, cancelToken) {
    list = handler[eventname].callbacks;
    for (var i = 0; i < list.length; ++i) {
        if (list[i].cancelToken == cancelToken) {
            list.splice(i, 1);
            return true;
        }
    }
    return false;
}
function registerPermission(permission, perm_default, parents) {
    if (loader.server.pluginManager.getPermission(permission)) {
        loader.server.pluginManager.removePermission(loader.server.pluginManager.getPermission(permission));
    }
    
    var perm_default = org.bukkit.permissions.PermissionDefault[perm_default.toUpperCase()]
    var permission = new org.bukkit.permissions.Permission(permission, perm_default);

    if (parents) {
        for (var i in parents) {
            permission.addParent(parents[i].permission, parents[i].value);
        }
    }
    
    loader.server.pluginManager.addPermission(permission);
    return permission;
}
function registerHash(name) {
    var specName = "__hash__" + name;
    if (persistence.containsKey(specName)) {
        return persistence.get(specName);
    }
    
    var hash = {};
    persistence.put(specName, hash);
    return hash;
}
function registerCommand(data, func) {
    var commandExecClass = plugin["class"].classLoader.loadClass("net.connorcpu.plugjs.JsCommandExecutor");
    var newCommand = function() {
        var commandClass = plugin["class"].classLoader.loadClass("net.connorcpu.plugjs.JsCommand");
        var commandEx = (function(__func__) {
            var state = { func: __func__, permTest: function(p){return true;} };
            var object = {
                execute: function(sender, label, args) {
                    if (!this.getState().permTest(sender)) {
                        return true;
                    }
                    try {
                        label = _s(label);
                        args = stringArray(_a(args));
                        var flags = [];
                        if (data.flags) {
                            for (var i in args) {
                                if (/^\-([a-z]+)/i.test(args[i])) {
                                    for (var k = 1; k < args[i].length; ++k) {
                                        flags.push(args[i][k]);
                                    }
                                    args.splice(i--, 1);
                                }
                            }
                        }
                        var result = this.getState().func(sender, label, args, flags);
                        if (result == false) {
                            sender.sendMessage(data.usage.replace(/\<command\>/g, _s(label)));
                        };
                        return true;
                    } catch(ex) {
                        if (typeof(ex) == 'string') {
                            sender.sendMessage("\xA7c" + ex);
                        } else {
                            sender.sendMessage("\xA7cAn error occured executing your command");
                            log(ex, 'c');
                        }
                        return true;
                    }
                },
                getState: function() { return state; }
            };
            return loader.Interface(object, commandClass);
        })(func);
        
        data.description = data.description || "";
        data.usage = data.usage || "";
        data.aliases = data.aliases || [];
        
        var cmd = plugin.createCommand(data.name, data.description, data.usage, data.aliases, commandEx);
        
        if (data.permission) {
            cmd.permission = data.permission;
            if (data.permissionMessage) {
                cmd.executor.state.permTest = function(p) {
                    if (cmd.testPermissionSilent(p)) {
                        return true;
                    } else {
                        p.sendMessage(data.permissionMessage);
                        return false;
                    }
                }
            } else {
                cmd.executor.state.permTest = function(p) {
                    return cmd.testPermission(p);
                }
            }
        }
        
        return cmd;
    }
    
    var command;
    if ((command = loader.server.commandMap.getCommand(data.name)) && command["class"].equals(commandExecClass)) {
        log("Unregistering old command '" + data.name + "'", 'e', 'verbose');
        var list = _a(loader.server.commandMap.commands);
        for (var i = 0; i < list.length; ++i) {
            if (_s(list[i].name) == data.name) {
                loader.server.commandMap.commands.remove(list[i]);
            }
        }
    }
    log ("Registering new command '" + data.name + "'", 'e', 'verbose');
    loader.server.commandMap.register("js", newCommand());
}
function unregisterCommand(name) {
    var list = _a(loader.server.commandMap.commands);
    for (var i = 0; i < list.length; ++i) {
        if (_s(list[i].name) == name) {
            loader.server.commandMap.commands.remove(list[i]);
        }
    }
}
function createHexString(arr) {
    var result = "";
    for (i in arr) {
        var str = arr[i].toString(16);
        str = str.length == 0 ? "00" :
              str.length == 1 ? "0" + str : 
              str.length == 2 ? str :
              str.substring(str.length-2, str.length);
        result += str;
    }
    return result;
}
function md5(input) {
    var md = java.security.MessageDigest.getInstance("MD5");
    var bytes = new java.lang.String(input).bytes;
    md.update(bytes, 0, bytes.length);
    bytes = _a(md.digest());
    return createHexString(bytes);
}
function defineGlobal(name) {
    plugin.js.eval("var " + name + ";");
}
function evalScript(javascript) {
    try {
        plugin.js.eval(javascript);
    } catch (exception) {
        var ex = exception;
        if (ex.rhinoException) {
            ex = ex.rhinoException;
            while (ex && ex.unwrap) {
                ex = ex.unwrap().cause;
            }
            ex = (ex || {message: "Unknown error"}).message;
        }

        log(ex);
        if (/syntax error/i.test(ex)) {
            throw "\n" + javascript;
        } else {
            throw exception;
        }
    }
}
function loadCoffee(file) {
    var coffee = read_file(file);
    var coffeeMd5 = md5(coffee);
    var fileName = _s(new java.io.File(file).name);
    var cachePath = "./plugins/PlugJS/coffee_cache/" + fileName.replace(/\.coffee$/, ".coffee.js");
    new java.io.File("./plugins/PlugJS/coffee_cache/").mkdirs();

    if (new java.io.File(cachePath).exists()) {
        var jsCache = read_file(cachePath);
        if (jsCache.indexOf("/*" + coffeeMd5 + "*/") == 0) {
            evalScript(jsCache);
            return;
        }
    }

    var timer = new Stopwatch();
    log("Compiling coffeescript " + fileName, 'b', 'verbose');
    var javascript;
    try {
        javascript = read_proc(npm_path + "coffee", "--bare", "--print", "--compile", file);
    } catch (ex) {
        try {
            javascript = read_proc(npm_path + "coffee.cmd", "--bare", "--print", "--compile", file);
        } catch (ex) {
            log("Couldn't find node.js coffeescript compiler, falling back to in-proccess", '7')
            javascript = CoffeeScript.compile(coffee, {bare: true});
        }
    }
    timer.stop();

    save_file(cachePath, "/*" + coffeeMd5 + "*/\n/* Compiled in " + timer.seconds + " seconds */\n" + javascript);
    evalScript(javascript);
}
function loadIcedCoffee(file) {
    var iced_coffee = read_file(file);
    var iced_coffeeMd5 = md5(iced_coffee);
    var fileName = _s(new java.io.File(file).name);
    var cachePath = "./plugins/PlugJS/coffee_cache/" + fileName.replace(/\.iced$/, ".iced.js");
    new java.io.File("./plugins/PlugJS/coffee_cache/").mkdirs();

    if (new java.io.File(cachePath).exists()) {
        var jsCache = read_file(cachePath);
        if (jsCache.indexOf("/*" + iced_coffeeMd5 + "*/") == 0) {
            evalScript(jsCache);
            return;
        }
    }

    var timer = new Stopwatch();
    log("Compiling iced coffee " + fileName, 'b', 'verbose');
    var javascript;
    try {
        javascript = read_proc(npm_path + "iced", "--bare", "--print", "--compile", file);
    } catch (ex) {
        try {
            javascript = read_proc(npm_path + "iced.cmd", "--bare", "--print", "--compile", file);
        } catch (ex) {
            throw "Could not compile iced coffee (ensure you have node.js and IcedCoffeeScript installed)"
        }
    }
    timer.stop();

    save_file(cachePath, "/*" + iced_coffeeMd5 + "*/\n/* Compiled in " + timer.seconds + " seconds */\n" + javascript);

    evalScript(javascript);
}
function require(lib) {
    var loaded = true;
    try {
        if (/\.iced$/i.test(lib)) {
            log("Loading " + lib, '2', 'verbose');
            loadIcedCoffee("./plugins/PlugJS/libs/" + lib);
        } else if (/\.coffee$/i.test(lib)) {
            log("Loading " + lib, '2', 'verbose');
            loadCoffee("./plugins/PlugJS/libs/" + lib);
        } else if (/\.js$/i.test(lib)) {
            log("Loading " + lib, '2', 'verbose');
            load("./plugins/PlugJS/libs/" + lib);
        } else {
            file = "./plugins/PlugJS/libs/" + lib + ".iced";
            if (new java.io.File(file).exists()) {
                log("Loading " + lib + ".iced", '2', 'verbose');
                loadIcedCoffee(file);
                return;
            }
            file = "./plugins/PlugJS/libs/" + lib + ".coffee";
            if (new java.io.File(file).exists()) {
                log("Loading " + lib + ".coffee", '2', 'verbose');
                loadCoffee(file);
                return;
            }
            file = "./plugins/PlugJS/libs/" + lib + ".js";
            if (new java.io.File(file).exists()) {
                log("Loading " + lib + ".js", '2', 'verbose');
                load(file);
                return;
            }
            loaded = false;
        }
        if (!loaded) {
            throw "Couldn't find library '" + lib + "'"
        }
    } catch (ex) {
        if (ex.rhinoException) {
            ex = ex.rhinoException;
            while (ex && ex.unwrap) {
                ex = ex.unwrap().cause;
            }
            ex = (ex || {message: "Unknown error"}).message;
        }
        loader.server.broadcast("\xA7cError loading " + lib + ", " + ex, "bukkit.broadcast.admin");
    }
}
function callEvent(handler, event, data) {
    if (handler[event]) {
        handler[event](data);
    }
}
function cmdEval(message, sender, type) {
    currEvalPlr = sender
    try {
        var event = {
            sender: sender,
            type: type,
            ext: { }
        }
        callEvent(js, "extensions", event);
        var result;
        with (event.ext) {
            result = eval(message);
        }
        callEvent(js, "evalComplete", { 
            sender: sender,
            result: result 
        });
        if (result === undefined) {
            result = "undefined";
        } else if (result === null) {
            result = "null";
        }
        sender.sendMessage("\xA7a=> " + result);
    } catch(ex) {
        sender.sendMessage("\xA7c" + ex);
    }
}
var currEvalPlr;
var evalEchoPlrs = JsPersistence.tryGet("evalEchoPlrs", []);
function toggleCfEcho() {
    var i = evalEchoPlrs.indexOf(_s(currEvalPlr.name));
    if (i != -1) {
        evalEchoPlrs.splice(i, 1);
    } else {
        evalEchoPlrs.push(_s(currEvalPlr.name));
    }
    JsPersistence.save()
}

var plugin = getPlugin();

registerCommand({
    name: "js",
    description: "Executes javascript in the server",
    usage: "\xA7cUsage: /<command> [javascript code]",
    permission: registerPermission("js.eval", "op"),
    permissionMessage: "\xA7cFak u gooby",
    aliases: [ "javascript" ]
}, function(sender, label, args) {
    var message = args.join(" ");
    
    if (message.length < 1) {
        return false;
    }

    message = message.replace(/\{clipboard\}/i, sender.clipboardText);

    sender.sendMessage("\xA77>> " + message);
    
    cmdEval(message, sender, "js");
});

registerCommand({
    name: "cf",
    description: "Executes coffeescript in the server",
    usage: "\xA7cUsage: /<command> [coffeescript code]",
    permission: "js.eval",
    permissionMessage: "\xA7cFak u gooby",
    aliases: [ "coffee", "coffeescript" ]
}, function(sender, label, args) {
    var message = args.join(" ");

    if (message.length < 1) {
        return false;
    }
    message = message.replace(/\{clipboard\}/i, sender.clipboardText);
    
    sender.sendMessage("\xA77>> " + message);

    async(function() {
        var coffee;
        try {
            coffee = NodeCompiler.CompileCoffee(message);
            if (/^\.\/js\/temp_code\.coffee\.tmp\:([\d]+)/i.test(coffee)) {
                throw coffee;
            }
        } catch (ex) {
            bukkit_sync(function(){ sender.sendMessage("\xA7cCompilation error: " + ex); });
            return;
        }

        bukkit_sync(function() {
            if (evalEchoPlrs.indexOf(_s(sender.name)) != -1) {
                sender.sendMessage("\xA78>> " + coffee);
            }

            cmdEval(coffee, sender, "cf");
        })
    });
});

registerCommand({
    name: "icf",
    description: "Executes coffeescript in the server",
    usage: "\xA7cUsage: /<command> [coffeescript code]",
    permission: "js.eval",
    permissionMessage: "\xA7cFak u gooby",
    aliases: [ "icedcoffee", "icedcoffeescript" ]
}, function(sender, label, args) {
    var message = args.join(" ");

    if (message.length < 1) {
        return false;
    }
    message = message.replace(/\{clipboard\}/i, sender.clipboardText);
    
    sender.sendMessage("\xA77>> " + message);

    async(function() {
        var coffee;
        try {
            coffee = NodeCompiler.CompileIced(message);
            if (/^\.\/js\/temp_code\.iced\.tmp\:([\d]+)/i.test(coffee)) {
                throw coffee;
            }
        } catch (ex) {
            bukkit_sync(function(){ sender.sendMessage("\xA7cCompilation error: " + ex); });
            return;
        }
        bukkit_sync(function() {
            if (evalEchoPlrs.indexOf(_s(sender.name)) != -1) {
                sender.sendMessage("\xA78>> " + coffee);
            }

            cmdEval(coffee, sender, "icf");
        })
    });
});

registerEvent(player, "command", function(event) {
    JsPersistence.save();
});

registerEvent(server, "pluginDisable", function(event) {
    JsPersistence.save();
});