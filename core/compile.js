var NodeCompiler;

NodeCompiler = (function(){
  var compiler, __savetemp__, __execproc__, __deletetemp__,
      __compilecoffee__, __compileiced__;
  compiler = {};

  __temppath__ = function(mode) {
    return "./js/temp_code." + mode + ".tmp";
  }
  __savetemp__ = function(code, mode) {
    save_file(__temppath__(mode), code);
  };
  __execproc__ = function(code_type) {
    var args = [ "C:\\Users\\Nathan\\AppData\\Roaming\\npm\\" + code_type, "--print", "--bare", "--compile", __temppath__(code_type) ]
    if (/Windows/i.test(_s(java.lang.System.getProperty("os.name")))) {
      args[0] += ".cmd"
    }
    return read_proc.apply(this, args);
  };
  __deletetemp__ = function() {
    new java.io.File("./js/temp_code.tmp")["delete"]()
  };
  __compilecoffee__ = function(code) {
    __savetemp__(code, "coffee");
    var code = __execproc__("coffee");
    __deletetemp__();
    return code;
  };
  __compileiced__ = function(code) {
    __savetemp__(code, "iced");
    var code = __execproc__("iced");
    __deletetemp__();
    return code;
  };

  compiler.CompileCoffee = sync(__compilecoffee__);
  compiler.CompileIced = sync(__compileiced__);

  return compiler;
})();