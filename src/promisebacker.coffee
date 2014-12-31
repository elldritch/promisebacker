Promise = require 'bluebird'

# Tries to detect whether the target function returns a promise or accepts callbacks, and acts accordingly.
# Detection works by intercepting passed arguments. If the last one is a function of arity at least two, we assume it's a callback.
Promiseback = (target, {scope, spread}={}) ->
  (args..., last) ->
    if (typeof last) is 'function' and last.length >= 2
      Promiseback.execute target, args, scope
        .nodeify last, spread: spread
    else
      Promiseback.execute target, (args.concat [last]), scope


# Does not detect call method, and instead assumes a promise should be returned.
Promiseback.toPromise = (target, {scope, spread}={}) ->
  (args...) ->
    Promiseback.execute target, args, scope


# Execute a function that either takes nodebacks or returns Promises, and return a Promise.
# Function target -> Promise | Function<..., Function callback<err, ...>> target, Array arguments, Object scope | undefined -> Promise result
Promiseback.execute = (target, args, scope) ->
  new Promise (resolve, reject) ->
    # Append a callback in case it takes callbacks
    returned = target.apply scope, args.concat [(err, result) -> if err then reject err else resolve result]

    # If returned has a `then` method, we assume Bluebird can resolve it.
    if (typeof returned.then) is 'function'
      resolve Promise.resolve returned

module.exports = Promiseback
