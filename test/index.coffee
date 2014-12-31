Promise = require 'bluebird'
Promise.longStackTraces()
promisebacker = require '../src/promisebacker.coffee'

expect = require 'chai'
  .expect

delay_as_callback = (f) ->
  (args..., callback) ->
    setTimeout ->
      try
        callback null, f.apply @, args
      catch err
        callback err
    , 1

delay_as_promise = (f) ->
  (args...) ->
    new Promise (resolve, reject) ->
      setTimeout ->
        try
          resolve f.apply @, args
        catch err
          reject err
      , 1

sum = (a, b) -> a + b

binary_apply = (a, b, f) -> f a, b

describe 'Promisebacker', ->
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
    tests.delayed_sum (promisebacker delay_as_callback sum), done

  it 'should wrap promises', (done) ->
    tests.delayed_sum (promisebacker delay_as_promise sum), done

  describe '.toPromise', ->
    it 'should handle functions as last arguments', (done) ->
      wrapped = promisebacker.toPromise delay_as_promise binary_apply
      wrapped 'alas ', 'poor yorick', sum
        .then (result) ->
          expect result
            .to.equal 'alas poor yorick'
          done()
        .catch done
