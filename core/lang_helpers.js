function _s(str) {
    return "" + new String(str);
}
function arrayContains(array, element) {
    for (var i in array) {
        if (array[i] == element) {
            return true;
        }
    }
    return false;
}
function enumContains(enu, name) {
    for (var i in enu) {
        if (i == name) return true;
    }
    return false;
}
function _a(ja) {
    var newarray = [];
    if (ja instanceof java.lang.Iterable) {
        var iter = ja.iterator();
        while (iter.hasNext()) {
            newarray.push(iter.next());
        }
        return newarray;
    } else if (_a instanceof java.util.Map) {
        ja = ja.values().toArray();
    }
    
    for (var i = 0; i < ja.length; ++i) {
        newarray.push(ja[i]);
    }
    
    return newarray;
}
function stringArray(array) {
    var _new = [];
    for (var i in array) {
        _new[i] = _s(array[i]);
    }
    return _new;
}
function numArr(start, end) {
    var res = [];
    for (var i = start; i <= end; ++i) {
        res.push(i);
    }
    return res;
}
function sleep(milliseconds) {
    milliseconds = milliseconds || 0
    java.lang.Thread.sleep(milliseconds);
}
function listMembers(obj) {
    var results = [];
    for (var i in obj) {
        results.push(i);
    }
    return results;
}
function _n(num) {
    return new Number(num) + 0
}
function setTimeout(func, time) {
    sleep(time);
    func(_a(arguments).splice(2));
}
function evalInContext(code, context) {
    with (context) {
        eval(_s(code));
    }
}