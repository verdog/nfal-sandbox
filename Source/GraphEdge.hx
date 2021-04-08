class GraphEdge {
    private static var _nextId:Int = 0;
    
    public final source:GraphVertex;
    public final sink:GraphVertex;
    public var id(default, null):Int;

    public function new(source:GraphVertex, sink:GraphVertex) {
        this.source = source;
        this.sink = sink;

        id = _nextId++;
        trace('created an edge with id $id');
    }
}