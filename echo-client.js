const elrpc = require('elrpc');

elrpc.startProcess(['node', 'echo.js']).then((client) => {
  client.callMethod('echo', '3 hello ok').then(ret => {
    console.log(ret);
  });
  client.callMethod('calc', 'a').then(ret => {
    console.log('calc', ret);
    client.stop();
  })

  console.log('2 call hello');
});

console.log('1 start');
