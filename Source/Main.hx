package;

import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import format.SVG;
import openfl.display.Sprite;
import openfl.Assets;
import openfl.events.MouseEvent;

class Main extends Sprite {
	static var graph:FLGraphContainer;

	private function initData() {
		trace("initializing data");
		removeChildren();
		graph = new FLGraphContainer();
		addChild(graph);
	}

	public function init() {
		initData();
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKey);
	}
	
	public function new() {
		super();

		init();
	}

	private function onMouseDown(event:MouseEvent):Void {
		trace(event);
	}

	private function onMouseUp(event:MouseEvent):Void {
		trace(event);
		graph.addVertex(event.stageX, event.stageY);
	}

	private function onKey(event:KeyboardEvent) {
		trace(event);
		// r
		if (event.charCode == 114) {
			initData();
		}
	}
}
