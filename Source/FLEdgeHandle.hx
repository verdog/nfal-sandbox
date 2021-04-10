import openfl.display.Sprite;

class FLEdgeHandle extends Sprite {
    public var fledge(default, null):FLEdge;

    public function new(edge:FLEdge) {
        super();
        this.fledge = edge;

        graphics.beginFill(0xaaaaaa);
        graphics.drawCircle(0, 0, 6);
    }
}
