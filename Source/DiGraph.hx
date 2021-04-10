import openfl.Assets;
#if sys
import sys.io.FileOutput;
import sys.io.File;
#end

class DiGraph {
	public var vertices(default, null):Map<Int, GraphVertex>;
	public var edges(default, null):Map<Int, GraphEdge>;

    private var starting:GraphVertex;

	public function new() {
		vertices = new Map<Int, GraphVertex>();
		edges = new Map<Int, GraphEdge>();
        starting = null;
	}

	public function addVertex(node:GraphVertex = null) {
		if (node == null) {
			var node = new GraphVertex();
		}
		vertices.set(node.id, node);
	}

	public function deleteVertex(vertex:GraphVertex) {
		vertices.remove(vertex.id);
	}

	public function connectVertices(source:GraphVertex, sink:GraphVertex, symbol:String) {
		var edge = new GraphEdge(source, sink, symbol);
		edges.set(edge.id, edge);
	}

	public function deleteEdge(edge:GraphEdge) {
		edges.remove(edge.id);
	}

    public function fromText(text:String) {
        vertices.clear();
        edges.clear();

        trace("Building digraph from text:");
		#if sys
        Sys.print(text);
		#else
		trace("\n" + text);
		#end

		for (l in text.split("\n")) {
			while (l != "") {
                var colonIdx = l.indexOf(":");
				var sourceName = l.substring(0, colonIdx);

				// create source
				var existingSource = findVertexByName(sourceName);
				var source = if (existingSource != null) existingSource else new GraphVertex();
				if (existingSource == null) { source.name = sourceName; }

				// mark starting if there isn't one yet
				if (starting == null) {
					starting = source;
				}

				l = l.substring(colonIdx + 1); // move passed "X:"

				while (l != "") {
					// skip whitespace or dividers
					while (getEndIdx(l) == 0) {
						l = l.substring(getEndIdx(l) + 1);
					}

					// get symbol
					var symbol = l.charAt(0);

					// get sink
					var sinkName = l.substring(1, getEndIdx(l));
					var existingSink = findVertexByName(sinkName);
					var sink = if (existingSink != null) existingSink else new GraphVertex();
					if (existingSink == null) sink.name = sinkName;

					addVertex(source);
					addVertex(sink);
					connectVertices(source, sink, symbol);

					l = l.substring(getEndIdx(l));
				}
			}
		}
    }

	private function findVertexByName(name:String) {
		for (id => vert in vertices) {
			if (vert.name == name) {
				return vert;
			}
		}

		return null;
	}

	public function fromFile(filename:String) {
		#if sys
		var text = Assets.getText("assets/inputs/simple.txt");
        fromText(text);
		#else
		trace("DiGraph::fromFile is not supported on this platform!");
		#end
	}

	private function getEndIdx(string:String) {
		var ends = [" ", "|", "\n"];

		var minEnd = string.length;

		for (c in ends) {
			var idx = string.indexOf(c);
			if (idx == -1) idx = string.length;
			minEnd = cast Math.min(idx, minEnd);
		}

		return minEnd;
	}
}
