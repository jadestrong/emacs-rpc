const elrpc = require('elrpc');

const FILE_ACTION_DICT = new WeakMap();

class LspBridge {
  constructor() {
    this.status = 'not_started';
    this.start();

    this.event_queue = [];
  }

  async start() {
    try {
      const server = await elrpc.startServer();
      this.server = server;
      this.status = 'started';

      this.registerMethods();
    } catch(e) {
      console.log(e);
      this.statsu = 'exception';
    }
  }

  registerMethods() {
    ['change_file'].forEach(name => {
      this.server.defineMethod(`_${name}`, (filepath, ...rest) => {
        this.open_file_success = true;

        if (!FILE_ACTION_DICT.has(filepath)) {
          this.open_file_success = this._open_file();
        }
        if (this.open_file_success) {
          const action = FILE_ACTION_DICT.get(filepath);
          action.call(name, ...args);
        }
      });

      this.server.defineMethod(name, (...args) => {
        this.event_queue.push({
          name: 'action_func',
          content: [`_${name}`, ] // 将 s-exp args 转换成的格式
        });
      });
    });
  }
}

export default LspBridge;
