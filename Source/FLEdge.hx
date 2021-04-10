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

        if (edgeData.source.id == edgeData.sink.id) {
            handle.y = -(FLVertex.radius + 40);
        }

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

		handle.addChild(textF);
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
        
        var toHandle = if (edgeData.source.id != edgeData.sink.id) new Point(handle.x, handle.y) else new Point(); // will be filled in below

        if (edgeData.source.id != edgeData.sink.id) {
            graphics.curveTo(handle.x, handle.y, localB.x, localB.y);
        } else {
            var handleP = new Point(handle.x, handle.y);
            var subHandle = new Point(handle.x, handle.y);
            subHandle.normalize(Point.distance(localA, handleP));

            var middle = Point.interpolate(localA, handleP, .5);

            rotatePoint(subHandle, Math.PI/2);
            graphics.curveTo(subHandle.x + middle.x, subHandle.y + middle.y, handle.x, handle.y);

            rotatePoint(subHandle, Math.PI);
            graphics.curveTo(subHandle.x + middle.x, subHandle.y + middle.y, localA.x, localA.y);

            toHandle.setTo(subHandle.x + middle.x, subHandle.y + middle.y);
        }

        // calculate tip
        var arrowDir = new Point(localB.x - toHandle.x, localB.y - toHandle.y);
        arrowDir.normalize(FLVertex.radius);

        var tip = localB.clone();
        tip.offset(-arrowDir.x, -arrowDir.y);

        // draw the triangle
        // reuse arrowDir for triangle sides
        arrowDir.normalize(12);
        rotatePoint(arrowDir, 3*Math.PI/4);
        
        // graphics.drawCircle(tip.x, tip.y, 5);

        graphics.beginFill(color);
        graphics.lineStyle(1, color);

        graphics.moveTo(tip.x, tip.y);
        graphics.lineTo(tip.x + arrowDir.x, tip.y + arrowDir.y);

        rotatePoint(arrowDir, Math.PI/2);
        graphics.lineTo(tip.x + arrowDir.x, tip.y + arrowDir.y);
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
