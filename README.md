# Promisebacker
Wraps an asynchronous function that either takes a callback or returns a promise, and allows it to do both.

**Note:** Promisebacker is still under development and not yet ready for production systems. Releases are stable but the API is subject to rapidly change.

## Installation
`npm install promisebacker`

## Example
```js
var Promise = require('promise') // Any Promises/A+ compliant library will do.
  , promisebacker = require('promisebacker');

var takes_callback = function(arg1, arg2, callback) {
  // Does something...
  var error = false;

  // Asynchronously invokes callback.
  setTimeout(function() {
    if (error){
      return callback('uh oh!');
    }
    callback(null, 'hello world!');
  }, 3000);
};

var returns_promise = function(arg1, arg2) {
  // Does something...
  var error = false;

  // Returns promise that resolves asynchronously.
  return new Promise(function(resolve, reject) {
    setTimeout(function() {
      if (error) {
        return reject('uh oh!');
      }
      resolve('hello world!');
    }, 3000);
  });
};

var wrapped_callback = promisebacker(takes_callback);

// Now we can pretend this returns a promise...
wrapped_callback('alas', 'poor yorick')
  .then(function(result) {
    // result == 'hello world!'
  });

// ...or we can continue using it as a callback!
wrapped_callback('alas', 'poor yorick', function(err, result) {
  // err == null
  // result == 'hello world!'
});

// And we can do the same for functions that return promises.
var wrapped_promise = promisebacker(returns_promise);

wrapped_promise('alas', 'poor yorick')
  .then(function(result) {
    // result == 'hello world!'
  });

wrapped_promise('alas', 'poor yorick', function(err, result) {
  // err == null
  // result == 'hello world!'
});

```

## Usage Notes
`Promisebacker(Function target)` assumes that you're trying to use a callback if the last argument passed is a `Function` of arity at least 2. If you want to force it to return promises, use `Promisebacker.toPromise` instead.

## API Reference
We define a function to take a _node-style callback_ (a _nodeback_) if it accepts a `Function` of arity at least 2 as its last argument and invokes that function whenever it finishes running. When invoking its callback, it must pass an error value as its first argument which must be truthy if and only if an error has occurred.

##### `Promisebacker(Function target [, Object options])` -> `Function`
Wraps `target` such that it can either take a callback or return a promise.
* `target` must either return a promise or take nodebacks.
* `options` is an optional object with options.

If `target` takes nodebacks and calls its callback with multiple success values, the fulfillment value will be an array of them.

See the `bluebird` documentation for [promisification](https://github.com/petkaantonov/bluebird/blob/master/API.md#promisification) for details.

###### Option: `Object scope` (default: N/A)
If you pass a `scope`, then `target` will have its `this` bound to `scope` (i.e. as if it were being called as `scope.target`).

###### Option: `Boolean spread` (default: `false` if nodeback is of arity at most 2, `true` otherwise)
Some nodebacks expect more than 1 success value but there is no mapping for this in the promise world. If `spread` is specified, the nodeback is called with multiple values when the promise fulfillment value is an array:

```js
var example = Promisebacker(Promise.resolve);
example([1, 2, 3], function(err, result) {
  // err == null
  // result == [1, 2, 3]
});

var another = Promisebacker(Promise.resolve, {spread: true});
another([1, 2, 3], function(err, a, b, c) {
  // err == null
  // a == 1, b == 2, c == 3
});
```

##### `Promisebacker.toPromise(Function target [, Object options])` -> `Function`
Same as above, but will always return a `Promise` even if the last argument is a `Function` of arity at least 2.

<!--
##### `Promisebacker.all(Object target [, Object options])` -> `Object`
Wraps all methods of `target` by going through the object's properties and creating an async equivalent of each function on the object and its prototype chain. The promisified method name will be the original method name suffixed with "Async".

See the `bluebird` documentation for [promisifyAll](https://github.com/petkaantonov/bluebird/blob/master/API.md#promisepromisifyallobject-target--object-options---object) for details.

###### Option: `String suffix`
Define a custom suffix for wrapped methods.

###### Option: `Function<String name, Function func, Object target> filter -> Boolean`
Define a custom filter to select which methods to wrap:

```js
Promise.promisifyAll(..., {
  filter: function(name, func, target) {
    // name = the property name to be promisified without suffix
    // func = the function
    // target = the target object where the promisified func will be put with name + suffix
    // return boolean
  }
});
```

###### Option: `promisifier`
Define a custom promisifier, so you could promisifyAll e.g. the chrome APIs used in Chrome extensions. See the `bluebird` documentation for [promisifyAll](https://github.com/petkaantonov/bluebird/blob/master/API.md#promisepromisifyallobject-target--object-options---object) for details.
-->
