function read_file(file) {
    var f_in = new java.io.BufferedReader(new java.io.InputStreamReader(new java.io.FileInputStream(file), "UTF8"));
            
    var line;
    var string = "";
    while ((line = f_in.readLine()) != null) {
        string += line + '\n';
    }
    
    return string;
}
function save_file(file, data) {
    var f_out = new java.io.BufferedWriter(new java.io.OutputStreamWriter(new java.io.FileOutputStream(file), "UTF8"));
    
    f_out.append(data);
    f_out.flush();
    f_out.close();
}

JsPersistence = new (function() {
    this.objects = {};
    
    this.load = function() {
        new java.io.File('./js').mkdirs();
        var file = new java.io.File('./js/persistence.json');
        if (!file.exists()) {
            file.createNewFile();
        }
        
        try {
            var fdata = read_file(file);
            this.objects = JSON.parse(fdata);
        } catch(ex) { return false; }
        
        return true;
    }
    this.save = function() {
        new java.io.File('./js').mkdirs();
        var file = new java.io.File('./js/persistence.json');
        
        try {
            save_file(file, JSON.stringify(this.objects, null, '\t'));
        } catch(ex) { return false; }
    }
    this.get = function(key) {
        return this.objects[key];
    }
    this.put = function(key, data) {
        try {
            JSON.stringify(data);
        } catch(ex) { return false; }
        
        this.objects[key] = data;
        return true;
    }
    this.tryGet = function(key, _default) {
        if (this.objects[key]) {
            return this.objects[key];
        } else {
            return this.objects[key] = _default;
        }
    }
})();

JsPersistence.load();

function saveJs() {
    JsPersistence.save();
}