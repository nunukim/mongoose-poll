_ = require 'underscore'

# 一定時間ごとにクエリを実行し、成功したらdata を、失敗したらerror イベントを発行する。
# 成功した場合、時間を待たずにもう一度実行する。

module.exports = class Watcher extends require('events').EventEmitter
  constructor: (@checker, @interval)->
    throw new Error 'checker should be function' unless _.isFunction @checker
    @checking = no

  start: ->
    return if @timeoutId?
    chk = => @check()
    @timeoutId = setInterval(chk, @interval)
    process.nextTick chk

  stop: ->
    clearInterval(@timeoutId) if @timeoutId
    @timeoutId = undefined

  check: ->
    @_check(0) unless @checking

  _check: (i)->
    @checking = yes
    @checker (err, data)=>
      if err?
        @checking = no
        @emit 'error', error
      else if data?
        @emit 'data', data, i
        @_check(i+1)
      else
        @checking = no
        @emit 'drain', i
