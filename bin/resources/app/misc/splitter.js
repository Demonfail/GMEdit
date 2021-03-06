(function() { // splitter
	var sp = document.getElementById("splitter-td");
	var eq = document.getElementById("tree-td") || document.getElementById("game-td");
	var gq = document.getElementById("main");
	var ls = window.localStorage;
	if (ls) eq.style.width = Math.max(0|(ls.getItem("splitter-width") || "200"), 50) + "px";
	var sp_mousemove, sp_mouseup, sp_x, sp_y;
	sp_mousemove = function(e) {
		var nx = e.pageX, dx = nx - sp_x; sp_x = nx;
		var ny = e.pageY, dy = ny - sp_y; sp_y = ny;
		var nw = parseFloat(eq.style.width) + dx * (eq.parentElement.children[0] == eq ? 1 : -1);
		if (nw < 50) nw = 50;
		eq.style.width = nw + "px";
	};
	sp_mouseup = function(e) {
		document.removeEventListener("mousemove", sp_mousemove);
		document.removeEventListener("mouseup", sp_mouseup);
		gq.classList.remove("resizing");
		if (ls) ls.setItem("splitter-width", "" + parseFloat(eq.style.width));
	};
	sp.addEventListener("mousedown", function(e) {
		sp_x = e.pageX; sp_y = e.pageY;
		document.addEventListener("mousemove", sp_mousemove);
		document.addEventListener("mouseup", sp_mouseup);
		gq.classList.add("resizing");
		e.preventDefault();
	});
})();
