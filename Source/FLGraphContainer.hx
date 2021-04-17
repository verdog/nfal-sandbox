import haxe.ds.GenericStack;
import openfl.events.TextEvent;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.Assets;
import openfl.events.Event;
import format.SVG;
import openfl.display.Sprite;

using StringTools;

class FLGraphContainer extends Sprite {
    public var digraph:DiGraph; // underlying graph data
    public var edgesSprite(default, null):Sprite;
    public var verticesSprite(default, null):Sprite;
    public var input:String;

    public function new() {
        super();
        trace("Creating new FLGraph");

        edgesSprite = new Sprite();
        verticesSprite = new Sprite();

        addChild(edgesSprite);
        addChild(verticesSprite);

        digraph = new DiGraph();
    }

    public function addVertex(x:Float, y:Float) {
        var vertData = new GraphVertex();
        var vertDisplay = new FLVertex(vertData);

        digraph.addVertex(vertData);

        vertDisplay.x = x;
        vertDisplay.y = y;
        vertDisplay.render();

        verticesSprite.addChild(vertDisplay);
    }

    public function deleteVertex(vert:GraphVertex) {
        digraph.deleteVertex(vert);
    }

    public function connectVertices(a:GraphVertex, b:GraphVertex, s:String) {
        var FLa = reverseLookupVertex(a);
        var FLb = reverseLookupVertex(b);

        if (FLa == null || FLb == null) {
            trace('Couldn\'t find FL verts to connect: $FLa, $FLb');
            return;
        }
        
        var edgeData = new GraphEdge(a, b, s);
        
        digraph.addEdge(edgeData);
        
        var edgeDisplay = new FLEdge(edgeData, FLa, FLb);
        edgeDisplay.render();

        edgesSprite.addChild(edgeDisplay);

        stage.focus = edgeDisplay.textF;
    }

    public function deleteEdge(edge:GraphEdge) {
        digraph.deleteEdge(edge);
    }

    public function render() {
        var minX = 100;
        var minY = 200;
        var space = FLVertex.radius * 6;
        var placeX = minX;
        var placeY = minY;
        var row = 0;
        var columns = Std.int(Math.sqrt(digraph.numVertices() + 1) * 2);

        var trap:GraphVertex;

        // TODO: check if this is a memory leak...
        verticesSprite.removeChildren();
        edgesSprite.removeChildren();

        for (id => vert in digraph.vertices) {
            // if (vert.name == "{}") {
            //     continue;
            // }

            var vertData = vert;
            var vertDisplay = new FLVertex(vertData);

            vertDisplay.x = placeX;
            vertDisplay.y = placeY;
            vertDisplay.render();

            verticesSprite.addChild(vertDisplay);

            row++;
            placeX += space;

            if (row >= columns) {
                row = 0;
                placeX = minX;
                placeY += space;
            }

            if (vert.name == "{}") {
                trap = vert;
                vertDisplay.alpha = 0.25;
            }
        }

        var edgeCounts = new Map<String, Int>();

        for (id => edge in digraph.edges) {
            var edgeData = edge;
            // if (edge.sink.name == "{}") {
            //     continue;
            // }

            var edgeIds = [edge.source.id, edge.sink.id];
            edgeIds.sort(function(x,y) return y - x);
            var edgeString = '${edgeIds[0]}---${edgeIds[1]}';

            var FLa = reverseLookupVertex(edge.source);
            var FLb = reverseLookupVertex(edge.sink);

            if (FLa == null || FLb == null) {
                trace('Couldn\'t find FL verts to connect: $FLa, $FLb');
                return;
            }
            
            var edgeDisplay = new FLEdge(edgeData, FLa, FLb);

            if (!edgeCounts.exists(edgeString)) edgeCounts.set(edgeString, 0);

            edgeDisplay.handle.y += edgeCounts[edgeString] * -50;
            edgeDisplay.render();
            if (trap != null && edge.sink.id == trap.id) {
                edgeDisplay.alpha = 0.25;
            }
            edgeCounts[edgeString] += 1;
            edgesSprite.addChild(edgeDisplay);
        }
    }

    public function reverseLookupVertex(v:GraphVertex) {
        if (v == null) return null;
        
        for (i in 0...verticesSprite.numChildren) {
            var vert:FLVertex = cast verticesSprite.getChildAt(i);
            if (vert.vertexData.id == v.id) {
                return vert;
            }
        }

        return null;
    }

    public function reverseLookupEdge(e:GraphEdge) {
        if (e == null) return null;

        for (i in 0...edgesSprite.numChildren) {
            var edge:FLEdge = cast edgesSprite.getChildAt(i);
            if (edge.edgeData.id == e.id) {
                return edge;
            }
        }

        return null;
    }
    
    // sim stuffs
    var simStack(default, null) = new Array<FLVertex>();
    var simInputIndex = 0;

    public function simReset() {
        for (flvert in simStack) {
            flvert.highlight = 0;
        }
        for (i in 0...edgesSprite.numChildren) {
            var fledge:FLEdge = cast edgesSprite.getChildAt(i);
            fledge.highlight = 0;
        }
        simStack = new Array<FLVertex>();
        simStack.push(reverseLookupVertex(digraph.starting));
        simInputIndex = 0;

        return true;
    }

    public function simToEnd() {
        while (simStepForward() != false) {};
        trace('sim to end');

        return true;
    }

    public function simStepForward() {
        if (simInputIndex >= input.length || simInputIndex >= input.length) {
            return false;
        }

        var vert = simStack[simStack.length - 1].vertexData;
        var symbol = input.charAt(simInputIndex);

        var next = digraph.simulateStep(vert, symbol);
        var FLnext = reverseLookupVertex(next);

        if (next != null) {
            var fledge = reverseLookupEdge(digraph.getOutgoingEdges(vert, symbol)[0]);
            fledge.highlight++;

            simStack.push(FLnext);
            simInputIndex++;
            FLnext.highlight++;
        } else {
            // couldn't advance, do nothing
            return false;
        }

        trace('stepped forward on $symbol to $next');

        return true;
    }

    public function simStepBackward() {
        if (simStack.length > 1) {
            var vert = simStack.pop();
            vert.highlight--;
            simInputIndex--;

            var current = simStack[simStack.length - 1];
            var fledge = 
                reverseLookupEdge(digraph.getOutgoingEdges(current.vertexData, input.charAt(simInputIndex))[0]);
            if (fledge != null) {
                fledge.highlight--;
            }
        } else {
            return false;
        }

        trace('stepped backward');
        return true;
    }

    public function getSimString() {
        var current = simStack[simStack.length - 1];
        var currentString = input.substring(simInputIndex);
        var currentName = current.vertexData.name;
        var currentName = if (currentName.length > 10) '${currentName.substring(0, 10)}...' else currentName;

        return '[#
            ${currentName},#
            ${if (currentString.length > 0) currentString else "*"} 
        #]&${if (current.vertexData.accepting == true) "ACCEPT" else "REJECT"}'
        .replace("\n", "").replace(" ", "").replace("#", " ").replace("&", "\n")
        ;
    }
}
