class DiGraph {
	public var vertices(default, null):Map<Int, GraphVertex>;
	public var edges(default, null):Map<Int, GraphEdge>;

    private var starting:GraphVertex;

	public function new() {
		vertices = new Map<Int, GraphVertex>();
		edges = new Map<Int, GraphEdge>();
        starting = null;
	}

	public function addVertex() {
		var node = new GraphVertex();
		vertices.set(node.id, node);
	}

	public function connectVertices(source:GraphVertex, sink:GraphVertex) {
		var edge = new GraphEdge(source, sink);
		edges.set(edge.id, edge);
	}

    public function fromText(text:String) {
        vertices.clear();
        edges.clear();

        trace("Building digraph from text:");
        // Sys.print(text);

		// for (l in text.split("\n")) {
		// 	while (l != "") {
        //         var colonIdx = l.indexOf(":");
		// 		var source = l.substring(0, colonIdx);

		// 		// if (starting == null) {
		// 		// 	starting = source;
		// 		// }

		// 		l = l.substr(colonIdx + 1); // move passed "X:"

		// 		while (l != "") {
		// 			// skip whitespace or dividers
		// 			while (l.charAt(0) == " " || l.charAt(0) == "|") {
		// 				l = l.substr(1);
		// 			}

		// 			// transition vs *
		// 			if (l.length >= 2 && l.charAt(1) != " " && l.charAt(1) != "|") {
		// 				// transition
		// 				var w = l.charAt(0);
		// 				var sink = l.charAt(1);

		// 				connect(source, sink, w);

		// 				l = l.substr(2);
		// 			} else if (l.charAt(0) == "*") {
		// 				if (!nodes.exists(source)) {
		// 					nodes.set(source, new Node(source));
		// 				}
		// 				setAccepting(source, true);
		// 				l = l.substr(1);
		// 			}
		// 		}
		// 	}
		// }
    }

	public function fromFile(filename:String) {
		// var text = File.getContent(filename);
        // fromText(text);
	}
}
