class GraphVertex {
    private static var _nextId:Int = 0;

    public final id:Int;
    public var accepting(default, null):Bool;
    public var name(get, default):String;

    public function new() {
        id = _nextId++;
        accepting = false;
        name = "";

        trace('Created new vertex with id $id');
    }

    private function get_name() {
        if (name != "") return name else return 'q$id';
    }
}
