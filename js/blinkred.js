// Text is blinking red and black
window.onload=function() {
  var isRed = false;
  var selectAll = document.body;
  setInterval(function() {
    if (!isRed) {
          selectAll.style.color = "red";
          isRed = true;
      } else {
        selectAll.style.color = "black";
        isRed = false;
      }
    }, 100);
}
