var NodeCompiler;

NodeCompiler = (function(){
  var compiler, savetemp, execproc, deletetemp,
      compilecoffee, compileiced;
  compiler = {};

  temppath = function(mode) {
    return "./js/temp_code." + mode + ".tmp";
  }
  savetemp = function(code, mode) {
    save_file(temppath(mode), code);
  };
  execproc = function(code_type) {
    var args = [ npm_path + code_type, "--print", "--bare", "--compile", temppath(code_type) ]
    if (/Windows/i.test(_s(java.lang.System.getProperty("os.name")))) {
      args[0] += ".cmd"
    }
    return read_proc.apply(this, args);
  };
  deletetemp = function() {
    new java.io.File("./js/temp_code.tmp")["delete"]()
  };
  compilecoffee = function(code) {
    savetemp(code, "coffee");
    var code = execproc("coffee");
    deletetemp();
    return code;
  };
  compileiced = function(code) {
    savetemp(code, "iced");
    var code = execproc("iced");
    deletetemp();
    return code;
  };

  compiler.CompileCoffee = sync(compilecoffee);
  compiler.CompileIced = sync(compileiced);

  return compiler;
})();
