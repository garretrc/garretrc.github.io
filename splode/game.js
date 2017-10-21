
var textSize = 16;
var gameTime = 0;
var animTime = -1;
var delay = 400;
var msg = ""; // debug message

var n = 6;
var playerColors = [];
var recentColors = [];
var recentMoves = []; // space index of most recent moves for each player
var spaceCounts = []; // how many spaces each player has
var spaces = [];
var splitStack = [];

var colorArr = ["#3030D0", "#D03030", "#30D030"];
var recentColorArr = ["#5050E0", "#E05050", "#50E050"];
var emptyColor = "#888888";
var diceSizeRatio = 0.9;
var originx = 0;
var originy = 0;
var playAreaSize = 100;

var allowMove = true;
var playerTurn = 0;
var winner = -1; // -1 means game still going on

function initGame(size, colors) {
	n = size;
	for (i = 0; i < n * n; i++)
		spaces.push({whichPlayer: -1, num: 0});
	for (i = 0; i < colors.length; i++) {
		playerColors.push(colorArr[colors[i]]);
		recentColors.push(recentColorArr[colors[i]]);
		recentMoves.push(-1);
		spaceCounts.push(0);
	}
}

function clickHandler(evt) {
	var mousePos = getMousePos(canvas, evt);
	var dicex = Math.floor((mousePos.x - originx) * n / playAreaSize);
	var dicey = Math.floor((mousePos.y - originy) * n / playAreaSize);
	if (allowMove && dicex >= 0 && dicex < n && dicey >= 0 && dicey < n) {
		var spaceIndex = dicex + dicey * n
		if (spaces[spaceIndex].whichPlayer == -1 || spaces[spaceIndex].whichPlayer == playerTurn)
			makeMove(spaceIndex, playerTurn);
	}
}

function makeMove(spaceIndex, whichPlayer) {
	allowMove = false;
	colorSpace(spaceIndex);
	recentMoves[playerTurn] = spaceIndex;
	increment(spaceIndex);
	if (splitStack.length == 0)
		endTurn();
	else
		animTime = gameTime + delay;
}

function endTurn() {
	if (winner == -1) {
		playerTurn = (playerTurn + 1) % playerColors.length;
		allowMove = true;
		msg = spaceCounts[0] + ", " + spaceCounts[1];
	} else {
		alert("Player " + (winner + 1) + " wins!");
	}
}

function increment(spaceIndex) {
	if (++spaces[spaceIndex].num > getNumAdj(spaceIndex))
		splitStack.push(spaceIndex);
}

function colorSpace(spaceIndex) {
	if (spaces[spaceIndex].whichPlayer != playerTurn) {
		if (spaces[spaceIndex].whichPlayer != -1)
			spaceCounts[spaces[spaceIndex].whichPlayer]--;
		spaces[spaceIndex].whichPlayer = playerTurn;
		if (++spaceCounts[playerTurn] == n * n) // win check
			winner = playerTurn;
	}
}

function split() {
	var i = splitStack.pop();
	if (i % n > 0) {
		// Transfer a dot to the left
		colorSpace(i - 1);
		increment(i - 1);
		spaces[i].num--;
	}
	if (i % n < n - 1) {
		// Transfer a dot to the right
		colorSpace(i + 1);
		increment(i + 1);
		spaces[i].num--;
	}
	if (Math.floor(i / n) > 0) {
		// Transfer a dot up
		colorSpace(i - n);
		increment(i - n);
		spaces[i].num--;
	}
	if (Math.floor(i / n) < n - 1) {
		// Transfer a dot down
		colorSpace(i + n);
		increment(i + n);
		spaces[i].num--;
	}
	
	if (splitStack.length == 0 || winner != -1)
		endTurn();
	else
		animTime = gameTime + delay;
}

function getNumAdj(spaceIndex) {
	var result = 2;
	if (spaceIndex % n > 0 && spaceIndex % n < n-1)
		result++;
	if (Math.floor(spaceIndex / n) > 0 && Math.floor(spaceIndex / n) < n-1)
		result++;
	return result;
}

// time is a float number of milliseconds since the page was loaded (?)
function loop(time, width, height) {
	ctx.font = textSize + "px Arial";
	ctx.fillStyle = (allowMove ? playerColors[playerTurn] : emptyColor);
	ctx.fillText(winner == -1 ? ("Player " + (playerTurn + 1) + "'s turn") : "Game over", 10, textSize + 10);
	
	// Debug message
	ctx.fillStyle = "#000000";
	//ctx.fillText("msg: " + msg, 10, textSize + 20);
	
	gameTime = time;
	if (animTime > 0 && time >= animTime) {
		animTime = -1;
		split();
	}
	
	drawSpaces(width, height);
}

function drawSpaces(width, height) {
	var row = 0;
	var col = 0;
	playAreaSize = Math.min(height * 0.7, width * 0.9);
	var cellSize = playAreaSize / n;
	originx = 0.5 * (width - playAreaSize + cellSize * (1 - diceSizeRatio));
	originy = 0.5 * (height - playAreaSize + cellSize * (1 - diceSizeRatio));
	var whichColor = emptyColor;
	for (i = 0; i < n * n; i++) {
		row = Math.floor(i / n);
		col = i % n;
		var p = spaces[i].whichPlayer;
		whichColor = (p == -1 ? emptyColor : (recentMoves[p] == i ? recentColors[p] : playerColors[p]));
		drawDice(originx + col * cellSize, originy + row * cellSize, cellSize * diceSizeRatio, whichColor, spaces[i].num);
	}
}

function drawDice(xPos, yPos, size, color, num) {
	drawBox(xPos, yPos, size, size, color);
	ctx.fillStyle = "#ffffff";
	var dotRadius = size / 8;
	if (num % 2 == 1)
		drawCircle(xPos + size / 2, yPos + size / 2, dotRadius);
	if (num >= 2) {
		drawCircle(xPos + 0.2 * size, yPos + 0.8 * size, dotRadius);
		drawCircle(xPos + 0.8 * size, yPos + 0.2 * size, dotRadius);
	}
	if (num >= 4) {
		drawCircle(xPos + 0.2 * size, yPos + 0.2 * size, dotRadius);
		drawCircle(xPos + 0.8 * size, yPos + 0.8 * size, dotRadius);
	}
	if (num == 6) {
		drawCircle(xPos + 0.2 * size, yPos + size / 2, dotRadius);
		drawCircle(xPos + 0.8 * size, yPos + size / 2, dotRadius);
	}
}

function drawBox(xPos, yPos, xSize, ySize, color) {
	ctx.beginPath();
	ctx.rect(xPos, yPos, xSize, ySize);
	ctx.fillStyle = color;
	ctx.fill();
	ctx.closePath();
}

// Does nothing with color
function drawCircle(xPos, yPos, r) {
	ctx.beginPath();
	ctx.arc(xPos, yPos, r, 0, Math.PI*2);
	//ctx.fillStyle = "#0095DD";
	ctx.fill();
	ctx.closePath();
}