var tick = 0;
var rate = 0.1;
window.onload=function(){
  setInterval(function(){
    tick=tick + rate;
    var red = Math.sin(tick) * 127 + 128;
    var green = Math.sin(tick + 90) * 127 + 128;
    var blue = Math.sin(tick + 270) * 127 + 128;
    red=parseInt(red);
    green=parseInt(green);
    blue=parseInt(blue);
    document.body.style.backgroundColor="rgb("+red+","+green+","+blue+")";
  },50);
};
