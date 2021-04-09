import openfl.events.TextEvent;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.text.TextFieldAutoSize;
import openfl.display.Sprite;

class FLEdge extends Sprite {
    public static var color = 0x777777;

    private var textF:TextField;
    private var handle:FLEdgeHandle;

    public var edgeData:GraphEdge;
    public var fla(default, null):FLVertex;
    public var flb(default, null):FLVertex;

    public function new (edgeData:GraphEdge, a:FLVertex, b:FLVertex) {
        super();
        this.edgeData = edgeData;
        fla = a;
        flb = b;

        mouseEnabled = false;

        handle = new FLEdgeHandle(this);
        addChild(handle);

		textF = new TextField();
		textF.selectable = true;
        textF.mouseEnabled = true;
        textF.type = TextFieldType.INPUT;
        textF.autoSize = TextFieldAutoSize.CENTER;
        textF.width = 20;
        textF.background = true;
        textF.backgroundColor = 0xaaaaaa;
        textF.maxChars = 1;
        textF.multiline = false;
        textF.border = true;
        textF.x = textF.width / 2;
        textF.y = 16;

        addEventListener(TextEvent.TEXT_INPUT, onTextChange);

		addChild(textF);
    }

    public function render() {
        var position = Useful.lerpXY(fla.x, fla.y, flb.x, flb.y, .5);
        x = position.x;
        y = position.y;

        graphics.clear();

        var localA = globalToLocal(new Point(fla.x, fla.y));
        var localB = globalToLocal(new Point(flb.x, flb.y));

        // draw line
		graphics.lineStyle (2, color);
        graphics.moveTo(localA.x, localA.y);
		graphics.lineTo(localB.x, localB.y);

        // calculate tip
        var dirToB = localB.clone();
        dirToB.normalize(FLVertex.radius);

        var tip = localB.clone();
        tip.offset(-dirToB.x, -dirToB.y);

        // reuse dirToB
        dirToB.normalize(12);
        rotatePoint(dirToB, 3*Math.PI/4);
        
        // draw the triangle
        // graphics.drawCircle(tip.x, tip.y, 5);

        graphics.beginFill(color);
        graphics.lineStyle(1, color);

        graphics.moveTo(tip.x, tip.y);
        graphics.lineTo(tip.x + dirToB.x, tip.y + dirToB.y);

        rotatePoint(dirToB, Math.PI/2);
        graphics.lineTo(tip.x + dirToB.x, tip.y + dirToB.y);
        graphics.lineTo(tip.x, tip.y);

        // update text
        textF.text = edgeData.symbol;
    }

    private function onTextChange(event:TextEvent) {
        trace(event);
        textF.text = event.text;
        edgeData.symbol = event.text;
    }

    private function rotatePoint(point:Point, rads:Float) {
        var x2 = point.x * Math.cos(rads) - point.y * Math.sin(rads);
        var y2 = point.x * Math.sin(rads) + point.y * Math.cos(rads);
        point.setTo(x2, y2);
    }
}
