import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.ui.MouseCursor;
import openfl.geom.Point;
import openfl.display.Sprite;

class FLLineGuide extends Sprite {
    private var vert:FLVertex;
    public var endpoint:Point = null;

    public function new(vert:FLVertex) {
        super();
        this.vert = vert;
        mouseEnabled = false;
    }

    public function render() {
        graphics.clear();
        graphics.lineStyle(1, 0xffffff);
        graphics.moveTo(0, 0);
        graphics.lineTo(endpoint.x, endpoint.y);
    }
}
