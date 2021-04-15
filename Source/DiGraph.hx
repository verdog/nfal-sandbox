import openfl.Assets;
#if sys
import sys.io.FileOutput;
import sys.io.File;
#end
import haxe.ds.GenericStack;

class DiGraph {
	public var vertices(default, null):Map<Int, GraphVertex>;
	public var edges(default, null):Map<Int, GraphEdge>;
	public var starting(default, set):GraphVertex;

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

		return vertices[node.id];
	}

	public function deleteVertex(vertex:GraphVertex) {
		vertices.remove(vertex.id);
	}

	public function connectVertices(source:GraphVertex, sink:GraphVertex, symbol:String) {
		// make sure the edge doesn't exist already
		for (id => edge in edges) {
			if (edge.source.id == source.id && edge.sink.id == sink.id && edge.symbol == symbol) {
				return edge;
			}
		}

		var edge = new GraphEdge(source, sink, symbol);
		edges.set(edge.id, edge);

		return edges[edge.id];
	}

	public function addEdge(edge:GraphEdge) {
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
				if (existingSource == null) {
					source.name = sourceName;
				}

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

					// is this symbol a lambda transition or an acceptance marker?
					if (symbol == "*" && getEndIdx(l) == 1) {
						// it's an accepting marker
						source.accepting = true;
					} else {
						// get sink
						var sinkName = l.substring(1, getEndIdx(l));
						var existingSink = findVertexByName(sinkName);
						var sink = if (existingSink != null) existingSink else new GraphVertex();
						if (existingSink == null)
							sink.name = sinkName;

						addVertex(source);
						addVertex(sink);
						connectVertices(source, sink, symbol);
					}

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
			if (idx == -1)
				idx = string.length;
			minEnd = cast Math.min(idx, minEnd);
		}

		return minEnd;
	}

	public function numVertices() {
		var count = 0;
		for (k in vertices.keys()) {
			count++;
		}
		return count;
	}

	public function toDFA() {
		var DFA = new DiGraph();
		var workStack = new GenericStack<GraphVertex>();
		var done = new Map<Int, GraphVertex>();
		var alpha = deduceAlphabet();
		var nodeSets = new Map<Int, Map<Int, GraphVertex>>();

		var nameFromSet = function(set:Map<Int, GraphVertex>) {
			var comma = "";
			var name = "";
			for (id => vert in set) {
				name += comma + vert.name;
				comma = ", ";
			}
			return name;
		};

		// create new start state
		var start = new GraphVertex();
		start.name = nameFromSet(lClosure(starting));
		nodeSets.set(start.id, lClosure(starting));
		DFA.addVertex(start);
		DFA.starting = start;

		// remove old trap state from current graph if its there.
		// it will mess up later calculations
		for (id => vert in vertices) {
			if (vert.name == "{}") {
				deleteVertex(vert);

				// remove any edges pointing to the old trap
				var toDelete = [];

				for (id => edge in edges) {
					if (edge.sink.id == vert.id) {
						toDelete.push(edge);
					}
				}

				for (edge in toDelete) {
					deleteEdge(edge);
				}
				break;
			}
		}

		// create trap state
		var trap = new GraphVertex();
		trap.name = "{}";
		nodeSets.set(trap.id, new Map<Int, GraphVertex>());
		DFA.addVertex(trap);
		for (c in alpha) {
			DFA.connectVertices(trap, trap, c);
		}

		// create new dfa
		workStack.add(start);

		while (!workStack.isEmpty()) {
			var workNode = workStack.pop();
			for (c in alpha) {
				// union tClosures of nodes in this node's set
				var newNodeSet = new Map<Int, GraphVertex>();
				for (id => node in nodeSets[workNode.id]) {
					for (id2 => tNode in tClosure(node, c)) {
						newNodeSet.set(id2, tNode);
					}
				}

				// find corresponding node in new graph to this set
				var newName = nameFromSet(newNodeSet);
				var newVertex = new GraphVertex(); // default to new
				newVertex.name = newName;
				for (id => set in nodeSets) {
					var setName = nameFromSet(set);
					if (newName == setName) {
						newVertex = DFA.vertices[id];
						break;
					}
				}

				nodeSets.set(newVertex.id, newNodeSet);

				// put into graph
				if (newNodeSet.keys().hasNext()) {
					DFA.addVertex(newVertex);
					DFA.connectVertices(workNode, newVertex, c);

					if (!done.exists(newVertex.id)) {
						workStack.add(newVertex);
					}
				} else {
					// to trap state
					DFA.addVertex(newVertex);
					DFA.connectVertices(workNode, trap, c);
				}
			}

			done.set(workNode.id, workNode);
		}

		// mark accepting states
		for (id => onode in vertices) {
			if (onode.accepting == true) {
				for (id2 => nnode in DFA.vertices) {
					if (nodeSets[id2].exists(id)) {
						nnode.accepting = true;
					}
				}
			}
		}

		return DFA;
	}

	public function deduceAlphabet() {
		var alpha = new Map<String, Bool>();

		for (edge in edges) {
			alpha.set(edge.symbol, true);
		}

		alpha.remove("*"); // no * in dfas

		return [for (c in alpha.keys()) c];
	}

	public function lClosure(node:GraphVertex) {
		var set = new Map<Int, GraphVertex>();
		var processed = new Map<Int, GraphVertex>();
		var stack = new GenericStack<GraphVertex>();

		stack.add(node);

		while (!stack.isEmpty()) {
			var node = stack.pop();
			set.set(node.id, node);

			for (edge in edges) {
				if (edge.source.id == node.id && edge.symbol == "*" && !processed.exists(edge.sink.id)) {
					set.set(edge.sink.id, edge.sink);
					stack.add(edge.sink);
				}
			}

			processed.set(node.id, node);
		}

		return set;
	}

	public function tClosure(node:GraphVertex, symbol:String) {
		var set = new Map<Int, GraphVertex>();

		for (id => vert in lClosure(node)) {
			for (edge in edges) {
				if (edge.source.id == vert.id && edge.symbol == symbol) {
					for (id2 => other in lClosure(edge.sink)) {
						set.set(other.id, other);
					}
				}
			}
		}

		return set;
	}

	private function set_starting(vert:GraphVertex) {
		if (this.starting != null) {
			this.starting.starting = false;
		}

		this.starting = vert;

		if (vert != null) {
			vert.starting = true;
		}

		return this.starting;
	}

	public function simulate(input:String) {
		trace('Processing "$input"');
		var node = starting;
		var broken = false;
		var to = "   ";

		while (input != "") {
			var c = input.charAt(0);
			var jumped = false;

			trace('$to [${node.name}, $input]');
			to = "|- ";

			node = simulateStep(node, c);

			if (node != null) {
				input = input.substring(1);
				jumped = true;
			} else {
				trace("node returned null, something went wrong.");
				broken = true;
				break;
			}
		}

		if (node != null) {
			trace('$to [${node.name}, $input]');
			trace('Ended on state ${node.name} which is ${if (node.accepting == true) "" else "not "}accepting');
			trace('${if (node.accepting == true) "ACCEPT" else "REJECT"}');
		} else {
			trace ('Ended in a broken state');
		}
	}

	public function simulateStep(vert:GraphVertex, symbol:String) {
		if (symbol == "*") return null;

		var outgoing = getOutgoingEdges(vert, symbol);
		if (outgoing.length == 0) {
			trace('${vert.name}: nowhere to go on symbol ${symbol}!');
			return null;
		} else if (outgoing.length > 1) {
			trace('more than one choice...');
			return null;
		} else {
			// length one
			var edge = outgoing[0];
			return edge.sink;
		}
	}

	public function getOutgoingEdges(vert:GraphVertex, symbol:String = null) {
		var edges = [];

		for (id => edge in this.edges) {
			if (symbol == null) {
				// no symbol specified
				if (edge.source.id == vert.id) {
					edges.push(edge);
				}
			} else {
				// symbol specified
				if (edge.source.id == vert.id && edge.symbol == symbol) {
					edges.push(edge);
				}
			}
		}

		return edges;
	}
}
