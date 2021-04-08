class GraphVertex {
    private static var _nextId:Int = 0;

    public final id:Int;
    public var accepting(default, null):Bool;

    private var _name:String;

    public function new() {
        id = _nextId++;
        accepting = false;
        _name = "";

        trace('Created new vertex with id $id');
    }

    public function name() {
        if (_name != "") return _name else return 'q$id';
    }
}
