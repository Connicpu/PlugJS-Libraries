var Stopwatch = (function() {
  (function() {
    function _Class() {}
    return _Class;
  })();
  function Stopwatch() {
    this.start = Date.now();
  }
  Stopwatch.prototype.stop = function() {
    return this.end = Date.now();
  };
  Stopwatch.prop('miliseconds', {
    get: function() {
      return this.end - this.start;
    }
  });
  Stopwatch.prop('seconds', {
    get: function() {
      return this.miliseconds / 1000;
    }
  });
  Stopwatch.prop('minutes', {
    get: function() {
      return this.seconds / 60;
    }
  });
  Stopwatch.prop('hours', {
    get: function() {
      return this.minutes / 60;
    }
  });
  Stopwatch.prop('days', {
    get: function() {
      return this.hours / 24;
    }
  });
  return Stopwatch;
})();
