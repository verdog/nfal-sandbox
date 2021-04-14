import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import openfl.Assets;
import openfl.display.Sprite;
import format.SVG;

class FLVertex extends Sprite {
    public static var radius = 30;

    private static var svg:SVG = null;
    
    public var starting = false;
    private var text = null;
    public var vertexData(default, null):GraphVertex;

    public function new (vertexData:GraphVertex) {
        super();
        this.vertexData = vertexData;

		var textField = new TextField();
		
        textField.autoSize = TextFieldAutoSize.CENTER;
		textField.width = 8;
		textField.x = textField.width / 2;
		textField.y = radius + 4;
		textField.selectable = false;
		textField.mouseEnabled = false;

		textField.text = vertexData.name;
		
		addChild(textField);
    }

    public function render() {
        if (svg == null) loadSVG();

        graphics.clear();

        svg.render(graphics);

        if (vertexData.accepting == true) {
            graphics.moveTo(0, 0);
            graphics.lineStyle(3, 0x00ffff);
            graphics.drawCircle(0, 0, radius - 6);
        }

        if (vertexData.starting == true) {
            graphics.moveTo(0, 0);
            graphics.lineStyle(3, 0x00ff00);
            graphics.drawCircle(0, 0, radius - 10);
        }
    }

    private function loadSVG() {
        svg = new SVG(Assets.getText("assets/circle.svg"));
    }
}
