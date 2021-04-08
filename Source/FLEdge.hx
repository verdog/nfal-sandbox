import openfl.geom.Point;
import openfl.text.TextField;
import openfl.display.Sprite;

class FLEdge extends Sprite {
    private var text = null;

    public var edgeData:GraphEdge;
    public var fla(default, null):FLVertex;
    public var flb(default, null):FLVertex;

    public function new (edgeData:GraphEdge, a:FLVertex, b:FLVertex) {
        super();
        this.edgeData = edgeData;
        fla = a;
        flb = b;

        var position = Useful.lerpXY(a.x, a.y, b.x, b.y, .5);
        x = position.x;
        y = position.y;

		var textField = new TextField();
		textField.selectable = false;
		textField.width = 64;
		textField.text = "edge";
		
		addChild(textField);
    }

    public function render() {
        var localA = globalToLocal(new Point(fla.x, fla.y));
        var localB = globalToLocal(new Point(flb.x, flb.y));

		graphics.lineStyle (2, 0x777777);
        graphics.moveTo(localA.x, localA.y);
		graphics.lineTo(localB.x, localB.y);

        var tip = Point.interpolate(localB, localA, .80);
        graphics.drawCircle(tip.x, tip.y, 3);
    }
}
