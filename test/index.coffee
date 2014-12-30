Promise = require 'bluebird'
promisebacker = require '../src/promisebacker.coffee'

expect = require 'chai'
  .expect

delay_callback = (f) ->
  (args..., callback) ->
    setTimeout ->
      try
        callback null, f.apply @, args
      catch err
        callback err
    , 1

delay_promise = (f) ->
  (args...) ->
    new Promise (resolve, reject) ->
      setTimeout ->
        try
          resolve f.apply @, args
        catch err
          reject err
      , 1

sum = (a, b) -> a + b

describe 'Promisebacker', ->
  nodebacks =
    delayed_sum: delay_callback sum

  promisers =
    delayed_sum: delay_promise sum

  tests =
    delayed_sum: (wrapped, done) ->
      wrapped 'alas ', 'poor yorick'
        .then (promised) ->
          wrapped 'alas ', 'poor yorick', (err, called) ->
            expect called
              .to.equal 'alas poor yorick'
            expect promised
              .to.equal 'alas poor yorick'
            expect err
              .to.not.be.ok
            expect called
              .to.equal promised
            done()
        .catch done

  it 'should wrap nodebacks', (done) ->
    tests.delayed_sum (promisebacker nodebacks.delayed_sum), done

  it 'should wrap promises', (done) ->
    tests.delayed_sum (promisebacker promisers.delayed_sum), done
