window.onload = function() {
	var size = 1.0
	var up = true;

	setInterval(function() {
		document.body.style.fontSize = size + "em";
		if (up)
			size += 1;
		else
			size -= 1;
		if (size == 10)
			up = false;
		if (size == 0)
			up = true;
    }, 100);
}
