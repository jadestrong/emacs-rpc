const epc = require("elrpc");

function fib(n) {
  if (n < 2) {
    return 1;
  } else {
    return fib(n - 2) + fib(n - 1);
  }
}

epc.startServer().then((server) => {
  server.defineMethod("echo", (args) => {
    return args;
  });
  server.defineMethod("calc", (...args) => {
    const [filepath, position, prefix] = args.map(epcArgTransformer);
    // return args;
    // console.log(args);
    // const result = fib(43);
    epc.initLogger().debug('filepath: ', filepath);
    epc.initLogger().debug('position: ', JSON.stringify(position));
    epc.initLogger().debug('prefix', prefix);
    return ["alan", "john", "ada", "don"];
  });
  server.wait();
});

// function _do_wrap(...args: any[]) {

// }

function epcArgTransformer(arg) {
  if (!Array.isArray(arg) || arg.length % 2 !== 0) {
    return arg;
  }

  for (let i = 0; i < arg.length; i++) {
    if (i % 2 === 1) {
      continue;
    }
    if (!String.prototype.startsWith.call(arg[i], ':')) {
      return arg;
    }
  }
  const ret = {};
  for (let i of range(0, arg.length, 2)) {
    ret[arg[i].slice(1)] = arg[i + 1];
  }
  return ret;
}

function range(start, stop, step) {
  if (typeof stop == 'undefined') {
    // one param defined
    stop = start;
    start = 0;
  }

  if (typeof step == 'undefined') {
    step = 1;
  }

  if ((step > 0 && start >= stop) || (step < 0 && start <= stop)) {
    return [];
  }

  var result = [];
  for (var i = start; step > 0 ? i < stop : i > stop; i += step) {
    result.push(i);
  }

  return result;
}
