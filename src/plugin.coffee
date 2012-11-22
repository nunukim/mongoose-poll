_ = require 'underscore'
Watcher = require './watcher'

module.exports = (schema, pluginOpts={})->
  pluginOpts = _.defaults {}, pluginOpts,
    interval: 1000      # 見つからなかった時に、次にポーリング開始するまでの時間(ms)
    path: 'state'
    query: {}
    sort: {}
    select: {}
    autoIndex: yes

  if pluginOpts.autoIndex
    index = {}
    index[pluginOpts.path] = 1
    _.extend index, pluginOpts.sort
    schema.index index

  schema.statics.poll = (from, to, opts={}, callback)->
    if _.isFunction opts
      callback = opts
      opts = {}
    opts = _.defaults {}, opts, pluginOpts


    throw new Error 'callback should be a function' unless _.isFunction callback

    query = ->
      q = _.clone opts.query?() ? opts.query
      q[opts.path] = from
      q
    update = {}
    update[opts.path] = to

    queryOptions =
      upsert: no
      new:    yes
      sort:   opts.sort
      select: opts.select
      
    checker = (cb)=>
      @findOneAndUpdate query(), update, queryOptions, cb

    watcher = new Watcher checker, opts.interval
    watcher.on 'data', (doc)-> callback.call doc, doc
    watcher.start()
    watcher
