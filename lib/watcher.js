// Generated by CoffeeScript 1.6.2
(function() {
  var Watcher, _,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  _ = require('lodash');

  module.exports = Watcher = (function(_super) {
    __extends(Watcher, _super);

    function Watcher(checker, interval) {
      this.checker = checker;
      this.interval = interval;
      if (!_.isFunction(this.checker)) {
        throw new Error('checker should be function');
      }
      this.checking = false;
    }

    Watcher.prototype.start = function() {
      var chk,
        _this = this;

      if (this.timeoutId != null) {
        return;
      }
      chk = function() {
        return _this.check();
      };
      this.timeoutId = setInterval(chk, this.interval);
      return process.nextTick(chk);
    };

    Watcher.prototype.stop = function() {
      if (this.timeoutId) {
        clearInterval(this.timeoutId);
      }
      return this.timeoutId = void 0;
    };

    Watcher.prototype.check = function() {
      if (!this.checking) {
        return this._check(0);
      }
    };

    Watcher.prototype._check = function(i) {
      var _this = this;

      this.checking = true;
      this.emit('checking');
      return this.checker(function(err, data) {
        if (err != null) {
          _this.checking = false;
          return _this.emit('error', error);
        } else if (data != null) {
          if (i === 0) {
            _this.emit('found');
          }
          _this.emit('data', data, i);
          return _this._check(i + 1);
        } else {
          _this.checking = false;
          return _this.emit('drain', i);
        }
      });
    };

    return Watcher;

  })(require('events').EventEmitter);

}).call(this);
