vows = require "vows"
assert = require "assert"
async = require 'async'
sinon = require 'sinon'
_ = require 'underscore'

m = require 'mongoose'
m.connect 'localhost/mongoose-poll-test'

plugin = require '../src/plugin'

testSchema = new m.Schema
  name:  String
  state: String
  order: Number

testSchema.plugin plugin, interval: 100, sort: {'order': 1}

TestModel = m.model 'test_model', testSchema


vows.describe('mongoose-poll').addBatch(
  'clean Model': ->
    TestModel.remove(->)
).addBatch(
  'one object':
    topic: ->
      @cb = sinon.spy()
      TestModel.create state: 'init', name: "obj1", =>
        watcher = TestModel.poll 'init', 'end', @cb
        watcher.on 'error', @callback
        watcher.on 'drain', (cnt)=>
          watcher.stop()
          @callback null, cnt
      undefined
    'found and drain': (count)->
      assert.ok @cb.calledOnce
      assert.ok @cb.withArgs(sinon.match(name: 'obj1')).calledOnce
      assert.equal count, 1
).addBatch(
  'two objects':
    topic: ->
      itr = (name, fn)->
        TestModel.create {state: 'init2', name: name}, fn
      @cb = sinon.spy()
      async.forEach ['obj2', 'obj3'], itr, =>
        watcher = TestModel.poll 'init2', 'end', @cb
        watcher.on 'error', @callback
        watcher.on 'drain', (cnt)=>
          watcher.stop()
          @callback null, cnt
        setTimeout (-> watcher.stop()), 200
      undefined

    'found and drain': (count)->
      assert.equal count, 2
      assert.ok @cb.calledTwice
      assert.ok @cb.withArgs(sinon.match(name: 'obj2')).calledOnce
      assert.ok @cb.withArgs(sinon.match(name: 'obj3')).calledOnce
).addBatch(
  'insert after watch':
    topic: ->
      @cb = sinon.spy()
      @drained = sinon.spy()
      watcher = TestModel.poll 'init3', 'end', @cb
      watcher.on 'error', @callback
      watcher.on 'drain', @drained
      watcher.on 'drain', (cnt)=> @callback() if cnt

      setTimeout (-> TestModel.create state: 'init3', name: "obj4", ->), 50
      undefined

    'found and drain': ->
      assert.ok @drained.calledTwice
      assert.ok @drained.firstCall.calledWith(0)
      assert.ok @drained.secondCall.calledWith(1)
      assert.ok @cb.withArgs(sinon.match(name: 'obj4')).calledOnce

).export(module)
