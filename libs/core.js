Object.prototype.toString = function(){try{return JSON.stringify(this, ' ', '\t').replace(/\t/g, "  ");}catch(e){return "[object Object]"}}
Array.prototype.toString = function(){try{return JSON.stringify(this, ' ', '\t').replace(/\t/g, "  ");}catch(e){return "[object Array]"}}


function combineArgs(label, args) {
    return "/" + label + " " + args.join(" ");
}
function getWorld(world) {
    if (typeof(world) != 'string') return world;
    return loader.server.getWorld(world);
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
function spawnEntity(type, loc) {
    loc = getloc(loc);
    return loc.world.spawnEntity(loc, org.bukkit.entity.EntityType[type]);
}
function spawn(type, loc) {
    loc = getloc(loc);
    return loc.world.spawn(loc, org.bukkit.entity[type]);
}
function getPlugin(name) {
    if (typeof(name) !== 'string') {
        name = "PlugJS";
    }
    return loader.server.pluginManager.getPlugin(name);
}
function registerEvent(handler, eventname, callback) {
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
    if (persistence.containsKey("__hash__" + name)) {
        return persistence.get("__hash__" + name);
    }
    
    var hash = new java.util.HashMap();
    persistence.put("__hash__" + name, hash);
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
        command.executor.state.func = func;
    } else {
        loader.server.commandMap.register("js:", newCommand());
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
function loadCoffee(file) {
    var coffee = read_file(file);
    var coffeeMd5 = md5(coffee);
    var fileName = _s(new java.io.File(file).name);
    var cachePath = "./plugins/PlugJS/coffee_cache/" + fileName.replace(/\.coffee$/, ".js");
    new java.io.File("./plugins/PlugJS/coffee_cache/").mkdirs();

    if (new java.io.File(cachePath).exists()) {
        var jsCache = read_file(cachePath);
        if (jsCache.indexOf("/*" + coffeeMd5 + "*/") == 0) {
            plugin.js.eval(jsCache);
            return;
        }
    }

    log("Compiling " + fileName, 'a');

    var javascript = CoffeeScript.compile(coffee, {bare: true});
    save_file(cachePath, "/*" + coffeeMd5 + "*/\n" + javascript);
    plugin.js.eval(javascript);
}
function require(lib) {
    if (/\.coffee$/i.test(lib)) {
        loadCoffee("./plugins/PlugJS/libs/" + lib);
    } else {
        load("./plugins/PlugJS/libs/" + lib);
    }
}
function callEvent(handler, event, data) {
    if (handler[event]) {
        handler[event](data);
    }
}
function cmdEval(message, sender, type) {
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
        callEvent(js, "evalComplete", result);
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
    var i = evalEchoPlrs.indexOf(currEvalPlr);
    if (i != -1) {
        evalEchoPlrs.splice(i, 1);
    } else {
        evalEchoPlrs.push(currEvalPlr);
    }
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
    sender.sendMessage("\xA77>> " + message);
    
    cmdEval(message, sender, args.join(" "));
});

registerCommand({
    name: "cf",
    description: "Executes coffeescript in the server",
    usage: "\xA7cUsage: /<command> [coffeescript code]",
    permission: registerPermission("js.eval", "op"),
    permissionMessage: "\xA7cFak u gooby",
    aliases: [ "coffee", "coffeescript" ]
}, function(sender, label, args) {
    currEvalPlr = sender
    var message = args.join(" ");

    if (message.length < 1) {
        return false;
    }
    sender.sendMessage("\xA77>> " + message);

    var coffee;
    try {
        coffee = CoffeeScript.compile(message, {bare: true});
    } catch (ex) {
        sender.sendMessage("\xA7cError compiling coffee: " + ex);
        return;
    }

    if (evalEchoPlrs.indexOf(sender) != -1) {
        sender.sendMessage("\xA78>> " + coffee);
    }
    cmdEval(coffee, sender, args.join(" "));
});

registerEvent(player, "command", function(event) {
    if (/^\/reloadjs\b/i.test(_s(event.message))) {
        JsPersistence.save();
    }
});

registerEvent(server, "pluginDisable", function(event) {
    if (event.plugin.name == plugin.name) {
        JsPersistence.save();
    }
});