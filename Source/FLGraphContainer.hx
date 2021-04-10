import openfl.Assets;
import format.SVG;
import openfl.display.Sprite;

class FLGraphContainer extends Sprite {
    public var digraph:DiGraph; // underlying graph data
    public var edgesSprite(default, null):Sprite;
    public var verticesSprite(default, null):Sprite;

    function new() {
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
    }

    public function deleteEdge(edge:GraphEdge) {
        digraph.deleteEdge(edge);
    }

    public function render() {
        var minX = 200;
        var minY = 200;
        var space = FLVertex.radius * 4;
        var placeX = minX;
        var placeY = minY;
        var row = 0;
        var columns = Std.int(Math.sqrt(digraph.numVertices() + 1) * 2);

        // TODO: check if this is a memory leak...
        verticesSprite.removeChildren();
        edgesSprite.removeChildren();

        for (id => vert in digraph.vertices) {
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
        }

        for (id => edge in digraph.edges) {
            var edgeData = edge;
            var FLa = reverseLookupVertex(edge.source);
            var FLb = reverseLookupVertex(edge.sink);

            if (FLa == null || FLb == null) {
                trace('Couldn\'t find FL verts to connect: $FLa, $FLb');
                return;
            }
            
            var edgeDisplay = new FLEdge(edgeData, FLa, FLb);
            edgeDisplay.render();

            edgesSprite.addChild(edgeDisplay);
        }
    }

    public function reverseLookupVertex(v:GraphVertex) {
        for (i in 0...verticesSprite.numChildren) {
            var vert:FLVertex = cast verticesSprite.getChildAt(i);
            if (vert.vertexData.id == v.id) {
                return vert;
            }
        }

        return null;
    }

    public function reveseLookupEdge(e:GraphEdge) {
        for (i in 0...edgesSprite.numChildren) {
            var edge:FLEdge = cast edgesSprite.getChildAt(i);
            if (edge.edgeData.id == e.id) {
                return edge;
            }
        }

        return null;
    }
}
