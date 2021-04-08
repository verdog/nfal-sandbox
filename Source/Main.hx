package;

import openfl.events.Event;
import openfl.display.DisplayObject;
import openfl.display.InteractiveObject;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import format.SVG;
import openfl.display.Sprite;
import openfl.Assets;
import openfl.events.MouseEvent;

enum State {
	IDLE;
	PLACEVERTONRELEASE;
	CONNECTINGVERT;
	DRAGGING;
}

class Main extends Sprite {
	static var graph:FLGraphContainer;
	static var state:State = IDLE;
	static var stateText:TextField = null;

	static var ghost:Sprite = null;

	static var sourceVert:FLVertex = null;

	static var currentlyDragging:FLVertex = null;

	private function initData() {
		trace("initializing data");
		removeChildren();
		graph = new FLGraphContainer();
		addChild(graph);
	}

	private function initState() {
		stateText = new TextField();

		stateText.mouseEnabled = false;
		stateText.selectable = false;
		stateText.width = 128;

		changeState(IDLE);
		addChild(stateText);
	}
	
	private function changeState(newState:State) {
		state = newState;
		stateText.text = '$state';
	}

	public function init() {
		initData();
		initState();
		stage.addEventListener(Event.ENTER_FRAME, onFrame);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouse);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouse);
		stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMouse);
		stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMouse);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKey);
	}
	
	public function new() {
		super();

		init();
	}

	private function onFrame(event:Event) {
		switch state {
			case PLACEVERTONRELEASE:
				if (ghost != null) {
					ghost.x = mouseX;
					ghost.y = mouseY;
				}
			case CONNECTINGVERT:
				if (ghost != null) {
					ghost.graphics.clear();
					ghost.graphics.lineStyle(3, 0xff00ff, .2);
					ghost.graphics.moveTo(0, 0);
					ghost.graphics.lineTo(ghost.mouseX, ghost.mouseY);
				}
			case DRAGGING:
				if (currentlyDragging != null) {
					currentlyDragging.x = mouseX;
					currentlyDragging.y = mouseY;

					for (i in 0...graph.edgesSprite.numChildren) {
						var edge:FLEdge = cast graph.edgesSprite.getChildAt(i);
						var edgeData = edge.edgeData;

						if (edgeData.source.id == currentlyDragging.vertexData.id
							|| edgeData.sink.id == currentlyDragging.vertexData.id) {
							edge.render();
						}
					}
				}
			default:
				// do nothing
		}
	}

	private function onMouse(event:MouseEvent):Void {
		trace(event);
		var point = new Point(event.stageX, event.stageY);
		var things = getObjectsUnderPoint(point);
		var nothing = true;

		for (thing in things) {
			var interactive = Std.downcast(thing, InteractiveObject);
			if (interactive != null) {
				if (interactive.mouseEnabled == true) {
					nothing = false;
					break;
				}
			}
		}

		trace('things: $things');
		trace('nothing: $nothing');

		switch state {
			case IDLE:
				if (event.type == MouseEvent.MOUSE_DOWN && nothing == true) {
					ghost = new Sprite();
					ghost.graphics.beginFill(0xff00ff, 0.2);
					ghost.graphics.drawCircle(0, 0, 16);
					ghost.mouseEnabled = false;
					addChild(ghost);

					changeState(PLACEVERTONRELEASE);
				} else if (event.type == MouseEvent.MOUSE_DOWN && nothing == false) {
					var vert = getThingFromThings(FLVertex, things);
					
					if (vert != null) {
						sourceVert = vert;
						ghost = new Sprite();
						ghost.graphics.beginFill(0xff00ff, 0.2);
						ghost.x = mouseX;
						ghost.y = mouseY;

						addChild(ghost);

						changeState(CONNECTINGVERT);
					}
				} else if (event.type == MouseEvent.MIDDLE_MOUSE_DOWN && nothing == false) {
					var vert = getThingFromThings(FLVertex, things);

					if (vert != null) {
						currentlyDragging = vert;
						changeState(DRAGGING);
					}
				}
			
			case PLACEVERTONRELEASE:
				if (event.type == MouseEvent.MOUSE_UP && nothing == true) {
					graph.addVertex(event.stageX, event.stageY);
				}

				removeChild(ghost);
				ghost = null;

				changeState(IDLE);

			case CONNECTINGVERT:
				if (event.type == MouseEvent.MOUSE_UP && nothing == false) {
					var vert = getThingFromThings(FLVertex, things);

					if (vert != null) {
						graph.connectVertices(sourceVert.vertexData, vert.vertexData);
					}
				}

				removeChild(ghost);
				ghost = null;

				changeState(IDLE);

			case DRAGGING:
				if (event.type == MouseEvent.MIDDLE_MOUSE_UP) {
					currentlyDragging = null;
					changeState(IDLE);
				}

			default:
				// nothing
		}
	}

	private function onKey(event:KeyboardEvent) {
		trace(event);
		// r
		if (event.charCode == 114) {
			initData();
		}
	}

	private function getThingFromThings<T:DisplayObject>(clss:Class<T>, things:Array<DisplayObject>):T {
		for (thing in things) {
			var found = Std.downcast(thing, clss);
			if (found != null) {
				return found;
			}
		}

		return null;
	}
}
