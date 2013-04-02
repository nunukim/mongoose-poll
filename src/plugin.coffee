_ = require 'lodash'
Watcher = require './watcher'

DEFAULT_OPTIONS =
  interval: 1000      # 見つからなかった時に、次にポーリング開始するまでの時間(ms)
  path: 'state'       # 状態遷移に使うパス名
  query: {}           # 検索条件(関数可)
  sort: {}            # ソート条件(mongo のsort に渡すオブジェクト)
  select: {}          # 検索時のselect
  autoIndex: yes      # init 時にインデックスをセットするか。 {state: 1, sort: 1} でセットされる。

module.exports = (schema, pluginOpts={})->
  pluginOpts = _.extend {}, DEFAULT_OPTIONS, pluginOpts

  if pluginOpts.autoIndex
    index = {}
    index[pluginOpts.path] = 1
    _.extend index, pluginOpts.sort
    schema.index index

  schema.statics.poll = (from, to, opts={}, callback)->
    if _.isFunction opts
      callback = opts
      opts = {}

    opts = _.extend {}, pluginOpts, opts

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
