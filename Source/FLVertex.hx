import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.Assets;
import openfl.display.Sprite;
import format.SVG;

class FLVertex extends Sprite {
    private static var svg:SVG = null;
    private var text = null;

    public var vertexData:GraphVertex;

    public function new (vertexData:GraphVertex) {
        super();
        this.vertexData = vertexData;

		var textField = new TextField();
		
		textField.selectable = false;
		
		textField.x = 0;
		textField.y = 0;
		textField.width = 64;
		
		textField.text = vertexData.name();
		
		addChild(textField);
    }

    public function render() {
        if (svg == null) loadSVG();
        svg.render(graphics);
    }

    private function loadSVG() {
        svg = new SVG(Assets.getText("assets/circle.svg"));
    }
}
