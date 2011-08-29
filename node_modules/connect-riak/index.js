/**
 * Module dependencies.
 */

var riak = require('riak-js');

/**
 * Return the `RiakStore` extending `connect`'s session Store.
 *
 * @param {object} connect
 * @return {Function}
 * @api public
 */

module.exports = function(connect) {

  /**
   * Connect's Store.
   */

  var Store = connect.session.Store;

  /**
   * Initialize RiakStore with the given `options`.
   *
   * @param {Object} options
   * @api public
   */

  function RiakStore(options) {
    options = options || {};
    Store.call(this, options);
    this.client = options.client || new riak.getClient(options);
    this.bucket = options.bucket || '_sessions';
    
    if (options.reapInterval > 0) {
      setInterval(function() {
        reapSessions(this);
      }.bind(this), options.reapInterval);
    }
    
  };

  /**
   * Reap sessions, ignoring errors
   *
   * @param {Object} this
   * @api public
   */
  function reapSessions(self) {
    
    self.client
      .add(self.bucket)
      .map(function(v) {
        
        var data = Riak.mapValuesJson(v)[0];
        
        // lame spidermonkey can't parse ISO8601 dates
        var d = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/.exec(data.cookie.expires);
        if (d) d = new Date(Date.UTC(+d[1], +d[2] - 1, +d[3], +d[4], +d[5], +d[6]));
        
        if (+d - +new Date() <= 0) {
          return [v.key];
        } else {
          return [];
        }
      })
      .reduce('Riak.filterNotFound')
      .run(function(err, expired) {
        if (!err && expired && expired.unshift) {
          expired.forEach(function(e) {
            self.client.remove(self.bucket, e);
          });
        }
      });
  };
  
  /**
   * Inherit from `Store`.
   */

  RiakStore.prototype.__proto__ = Store.prototype;

  /**
   * Attempt to fetch session by the given `sid`.
   *
   * @param {String} sid
   * @param {Function} callback
   * @api public
   */

  RiakStore.prototype.get = function(sid, callback) {
    this.client.get(this.bucket, sid, { encodeUri: true }, function(err, data, meta) {
      if (err && err.notFound) return callback();
      if (err) return callback(err);
      callback(null, data);
    });
  };

  /**
   * Commit the given `session` object associated with the given `sid`.
   *
   * @param {String} sid
   * @param {Session} session
   * @param {Function} callback
   * @api public
   */

  RiakStore.prototype.set = function(sid, session, callback) {    
    this.client.save(this.bucket, sid, session, { encodeUri: true }, callback);
  };

  /**
   * Destroy the session associated with the given `sid`.
   *
   * @param {String} sid
   * @api public
   */

  RiakStore.prototype.destroy = function(sid, callback) {
    this.client.remove(this.bucket, sid, { encodeUri: true }, callback);
  };

  /**
   * Fetch number of sessions.
   *
   * @param {Function} callback
   * @api public
   */

  RiakStore.prototype.length = function(callback) {
    this.client.count(this.bucket, callback);
  };

  return RiakStore;
};