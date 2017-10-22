class Node
{
    constructor(x, y, r)
    {
        this.neighbors = [];
        this.neighbors.push(this);
        this.edges = 1;
        this.player=-1;
        this.count=0;
        this.x=x;
        this.y=y;
        this.r=r;
    }
    
    addNeighbor(node)
    {
        this.neighbors.push(node);
        this.edges = this.edges+1;
    }

    contains(xCoord, yCoord)
    {
    	var dx = xCoord - this.x;
    	var dy = yCoord - this.y;
    	return (Math.sqrt(dx*dx + dy*dy) <= this.r);
    }
}

class Graph
{
    constructor()
    {
        this.nodes = [];
        this.order = 0;
        this.playerCounts = [];
        for(var i = 0; i < numPlayers; i++) {
        	this.playerCounts.push(0);
        }
    }

    addNode(node)
    {
        this.nodes.push(node);
        this.order = this.order + 1;
    }

	rmNode(node)
	{
		nodes.splice(nodes.indexOf(node),1);
		for(let newNode of node.neighbors){
		    newNode.neighbors.splice(neighbors.indexOf(node),1);
			newNode.edges -= 1;
		}
		this.order -= 1;
	}
    splode(node, player)
    {	
    	console.log(node.count + " " + node.neighbors.length + " " + node.edges)
        node.count = node.count + 1;
        if(node.player != player) {
        	if(node.player != -1) {
        		this.playerCounts[node.player]--;
        	}
        	this.playerCounts[player]++;
        	node.player = player;
        }
        var toProcess = [];
        toProcess.push(node);
        var overflow = 0;
        while(toProcess.length != 0 && overflow < 30) {
        	overflow = overflow + 1
            var current = toProcess.pop();
            console.log(toProcess.length);
            if(current.edges <= current.count) {
                current.count = current.count - current.edges;
                for (let newNode of current.neighbors) {
                    newNode.count = newNode.count + 1;
                    if(newNode.player != player) {
			        	if(newNode.player != -1) {
			        		this.playerCounts[newNode.player]--;
			        	}
			        	this.playerCounts[player]++;
			        	newNode.player = player;
			        }
                    toProcess.push(newNode);
                }
            }
        }
    }
}

class RectGraph extends Graph
{
    constructor(width, height)
    {
    	super()
        for(var i = 0; i < width; i++) {
            for(var j = 0; j < height; j++) {
                this.addNode(new Node(i*100+100, j*100+100, 30));
            }
        }

        for( i = 0; i < this.order; i++){
            var current = this.nodes[i];
            if(i >= height)
                current.addNeighbor(this.nodes[i - height]);
            if(i%height != height-1)
                current.addNeighbor(this.nodes[i + 1]);
            if(i < (width-1)*height)
                current.addNeighbor(this.nodes[i + height]);
            if(i%height != 0)
                current.addNeighbor(this.nodes[i - 1]);
        }
    }
}

class DiamondGraph extends Graph
{
    constructor(height)
    {
    	super()
        var width = height;   
		for(var i = 0; i < width; i++) {
            for(var j = 0; j < height; j++) {
                this.addNode(new Node(i*100+100, j*100+100, 30));
            }
        }

        for( i = 0; i < this.order; i++){
            var current = this.nodes[i];
            if(i >= height)
                current.addNeighbor(this.nodes[i - height]);
            if(i%height != height-1)
                current.addNeighbor(this.nodes[i + 1]);
            if(i < (width-1)*height)
                current.addNeighbor(this.nodes[i + height]);
            if(i%height != 0)
                current.addNeighbor(this.nodes[i - 1]);
        }
		//this.rmNode(this.nodes[0]);
    }
	
}
/*var testGraph = new Graph();
var node1 = new Node(200, 200, 40);
var node2 = new Node(200, 400, 40);
var node3 = new Node(400, 200, 40);
var node4 = new Node(400, 400, 40);

node1.addNeighbor(node2);
node1.addNeighbor(node3);
node1.addNeighbor(node4);

node2.addNeighbor(node1);
node2.addNeighbor(node4);
node3.addNeighbor(node1);
node3.addNeighbor(node4);

node4.addNeighbor(node1);
node4.addNeighbor(node2);
node4.addNeighbor(node3);

testGraph.addNode(node1);
testGraph.addNode(node2);
testGraph.addNode(node3);
testGraph.addNode(node4);

console.log("3")*/






var numPlayers = 2;
var testGraph = new DiamondGraph(5);
var currPlayer = 0;


function drawBox(xPos, yPos, xSize, ySize, color) {
	ctx.beginPath();
	ctx.rect(xPos, yPos, xSize, ySize);
	ctx.fillStyle = color;
	ctx.fill();
	ctx.closePath();
}

function drawDice(xPos, yPos, size, color, num) {
    drawCircle(xPos, yPos, size,color);
    ctx.fillStyle = "#ffffff";
    var dotRadius = size / 9;
    var dotPos = .2*size;
    if (num % 2 == 1)
        drawCircle(xPos, yPos, dotRadius);
    if (num >= 2) {
        drawCircle(xPos - dotPos, yPos + dotPos, dotRadius);
        drawCircle(xPos + dotPos, yPos - dotPos, dotRadius);
    }
    if (num >= 4) {
        drawCircle(xPos - dotPos, yPos - dotPos, dotRadius);
        drawCircle(xPos + dotPos, yPos + dotPos, dotRadius);
    }
    if (num >= 6) {
        drawCircle(xPos - dotPos, yPos, dotRadius);
        drawCircle(xPos + dotPos, yPos, dotRadius);
    }
    if (num >= 8) {
        drawCircle(xPos, yPos - dotPos, dotRadius);
        drawCircle(xPos, yPos + dotPos, dotRadius);
    }
}

function drawCircle(xPos, yPos, r, color) {
    ctx.beginPath();
    ctx.arc(xPos, yPos, r, 0, Math.PI*2);
    ctx.fillStyle = color;
    ctx.fill();
    ctx.closePath();
}

function drawLine(xStart, yStart, xEnd, yEnd, color) {
	ctx.beginPath();
	ctx.strokeStyle = color;
	ctx.moveTo(xStart,yStart);
	ctx.lineTo(xEnd,yEnd);
	ctx.stroke();
	ctx.closePath();
}

/*// Does nothing with color
function drawCircle(xPos, yPos, r) {
	ctx.beginPath();
	ctx.arc(xPos, yPos, r, 0, Math.PI*2);
	//ctx.fillStyle = "#0095DD";
	ctx.fill();
	ctx.closePath();
}*/


function numberToColor(num) {
	if(num == -1)
		return "#BBBBBB";
	if(num == 0)
		return "#33CCFF";
	if(num == 1)
		return "#FF33CC";
}



function drawSpaces(width, height) {
	
}



// time is a float number of milliseconds since the page was loaded (?)
function loop(time, width, height) {
	for (let node of testGraph.nodes) {
		drawDice(node.x, node.y, node.r, numberToColor(node.player), node.count);
		for (let neigh of node.neighbors) {
			drawLine(node.x, node.y, neigh.x, neigh.y, "#00FF00");
		}
	}
}

function clickHandler(evt) {
	console.log("Click!")
	var mousePos = getMousePos(canvas, evt);
	for (let node of testGraph.nodes) {
		if(node.contains(mousePos.x, mousePos.y) && (node.player == currPlayer || node.player == -1)) {
			testGraph.splode(node, currPlayer);
			currPlayer = (currPlayer + 1) % numPlayers;
		}
	}

/*	var mousePos = getMousePos(canvas, evt);
	var dicex = Math.floor((mousePos.x - originx) * n / playAreaSize);
	var dicey = Math.floor((mousePos.y - originy) * n / playAreaSize);
	if (allowMove && dicex >= 0 && dicex < n && dicey >= 0 && dicey < n) {
		var spaceIndex = dicex + dicey * n
		if (spaces[spaceIndex].whichPlayer == -1 || spaces[spaceIndex].whichPlayer == playerTurn)
			makeMove(spaceIndex, playerTurn);
	}*/
}