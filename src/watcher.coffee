_ = require 'lodash'

# ### Watcher(checker, interval)
#
# interval ミリ秒ごとにcheckerを実行する。
# checker のcallback(error, data)の結果によって以下の処理をする。
# - 失敗したらerror イベントを発行してinterval だけ待って再実行。
# - data がnull ならdrain イベントを発行してinterval だけ待って再実行。
# - data が非null ならdata イベントを発行してすぐに再実行。

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
    @emit 'checking'
    @checker (err, data)=>
      if err?
        @checking = no
        @emit 'error', error
      else if data?
        @emit 'found' if i is 0
        @emit 'data', data, i
        @_check(i+1)
      else
        @checking = no
        @emit 'drain', i
