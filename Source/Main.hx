package;

import format.gfx.GfxTextFinder;
import openfl.display.FPS;
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
import openfl.geom.Point;

enum State {
	IDLE;
	PLACEVERT;
	CONNECTVERT;
	DELETEVERT;
	DRAGVERT;
	DELETEEDGE;
	DRAGEDGE;
}

class Main extends Sprite {
	static var graph:FLGraphContainer;
	static var state:State = IDLE;
	static var stateText:TextField = null;
	static var ui:UI;

	static var ghost:Sprite = null;

	static var sourceVert:FLVertex = null;

	static var currentlyDraggingVert:FLVertex = null;
	static var currentlyDraggingEdge:FLEdgeHandle = null;
	static var dragStart:Point = null;

	static var CTRL:Bool = false;

	private function restart() {
		initData();
		initState();
	}

	private function initData() {
		trace("initializing data");
		removeChildren();
		graph = new FLGraphContainer();

		graph.digraph.fromFile("inputs/simple.txt");

		graph.render();
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
		stage.addEventListener(Event.ENTER_FRAME, onFrame);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouse);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouse);
		stage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMouse);
		stage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMouse);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouse);
		stage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouse);

		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKey);

		stage.showDefaultContextMenu = false;

		restart();
		// addChild(new FPS());
	}
	
	public function new() {
		super();
		// ui = new UI();
		init();
	}

	private function onFrame(event:Event) {
		switch state {
			case PLACEVERT:
				if (ghost != null) {
					ghost.x = mouseX;
					ghost.y = mouseY;
				}
			case CONNECTVERT:
				if (ghost != null) {
					ghost.graphics.clear();
					ghost.graphics.lineStyle(3, 0xff00ff, .2);
					ghost.graphics.moveTo(0, 0);
					ghost.graphics.lineTo(ghost.mouseX, ghost.mouseY);
				}
			case DRAGVERT:
				if (currentlyDraggingVert != null) {
					currentlyDraggingVert.x = mouseX;
					currentlyDraggingVert.y = mouseY;

					for (i in 0...graph.edgesSprite.numChildren) {
						var edge:FLEdge = cast graph.edgesSprite.getChildAt(i);
						var edgeData = edge.edgeData;

						if (edgeData.source.id == currentlyDraggingVert.vertexData.id
							|| edgeData.sink.id == currentlyDraggingVert.vertexData.id) {
							edge.render();
						}
					}
				}
			case DRAGEDGE:
				if (currentlyDraggingEdge != null) {
					var mousep = new Point(mouseX, mouseY);
					var localMousep = currentlyDraggingEdge.parent.globalToLocal(mousep);
					currentlyDraggingEdge.x = localMousep.x;
					currentlyDraggingEdge.y = localMousep.y;
					currentlyDraggingEdge.fledge.render();
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
				if ((event.type == MouseEvent.MIDDLE_MOUSE_DOWN 
					|| event.type == MouseEvent.MOUSE_DOWN && CTRL == true)
						&& nothing == false) {
					var vert = getThingFromThings(FLVertex, things);

					if (vert != null) {
						changeState(DRAGVERT);
						dragStart = new Point(mouseX, mouseY);
						currentlyDraggingVert = vert;
					}

					var edgehandle = getThingFromThings(FLEdgeHandle, things);

					if (edgehandle != null) {
						changeState(DRAGEDGE);
						currentlyDraggingEdge = edgehandle;
					}
				} else if (event.type == MouseEvent.MOUSE_DOWN && nothing == true) {
					ghost = new Sprite();
					ghost.graphics.beginFill(0xff00ff, 0.2);
					ghost.graphics.drawCircle(0, 0, 16);
					ghost.mouseEnabled = false;
					addChild(ghost);

					changeState(PLACEVERT);
				} else if (event.type == MouseEvent.MOUSE_DOWN && nothing == false) {
					var vert = getThingFromThings(FLVertex, things);
					
					if (vert != null) {
						sourceVert = vert;
						ghost = new Sprite();
						ghost.graphics.beginFill(0xff00ff, 0.2);
						ghost.x = mouseX;
						ghost.y = mouseY;

						addChild(ghost);

						changeState(CONNECTVERT);
					}
				} else if (event.type == MouseEvent.RIGHT_MOUSE_DOWN && nothing == false) {
					var vert = getThingFromThings(FLVertex, things);
					if (vert != null) {
						changeState(DELETEVERT);
					}

					var edgeHandle = getThingFromThings(FLEdgeHandle, things);
					if (edgeHandle != null) {
						changeState(DELETEEDGE);
					}
				}
			case PLACEVERT:
				if (event.type == MouseEvent.MOUSE_UP && nothing == true) {
					graph.addVertex(event.stageX, event.stageY);
				}

				removeChild(ghost);
				ghost = null;

				changeState(IDLE);
			case CONNECTVERT:
				if (event.type == MouseEvent.MOUSE_UP && nothing == false) {
					var vert = getThingFromThings(FLVertex, things);

					if (vert != null) {
						graph.connectVertices(sourceVert.vertexData, vert.vertexData, "*");
					}
				}

				removeChild(ghost);
				ghost = null;

				changeState(IDLE);
			case DRAGVERT:
				if (Point.distance(dragStart, new Point(mouseX, mouseY)) < 10) {
					currentlyDraggingVert.vertexData.accepting = !currentlyDraggingVert.vertexData.accepting;
					currentlyDraggingVert.render();
				}
				currentlyDraggingVert = null;
				changeState(IDLE);
			case DELETEVERT:
				if (event.type == MouseEvent.RIGHT_MOUSE_UP && nothing == false) {
					var vert = getThingFromThings(FLVertex, things);
					if (vert != null) {
						var marked = new Array<FLEdge>();
						for (i in 0...graph.edgesSprite.numChildren) {
							var edge:FLEdge = cast graph.edgesSprite.getChildAt(i);
							var edgeData = edge.edgeData;
							var vertData = vert.vertexData;
							
							if (edgeData.source.id == vertData.id || edgeData.sink.id == vertData.id) {
								marked.push(edge);
							}
						}
						
						for (edge in marked) {
							graph.edgesSprite.removeChild(edge);
						}
						
						graph.verticesSprite.removeChild(vert);
						
						graph.deleteVertex(vert.vertexData);
					}
				}
				
				changeState(IDLE);
			case DRAGEDGE:
				currentlyDraggingEdge = null;
				changeState(IDLE);
			case DELETEEDGE:
				if (event.type == MouseEvent.RIGHT_MOUSE_UP && nothing == false) {
					var edgehandle = getThingFromThings(FLEdgeHandle, things);
					if (edgehandle != null) {
						graph.edgesSprite.removeChild(edgehandle.fledge);
					}

					graph.deleteEdge(edgehandle.fledge.edgeData);
				}

				changeState(IDLE);
			default:
				// nothing
		}
	}

	private function onKey(event:KeyboardEvent) {
		trace(event);
		// r
		if (event.type == KeyboardEvent.KEY_UP && event.charCode == 114) {
			restart();
		}
		// ctrl
		if (event.type == KeyboardEvent.KEY_DOWN && event.keyCode == 17 && event.keyLocation == 1) {
			CTRL = true;
		}
		if (event.type == KeyboardEvent.KEY_UP && event.keyCode == 17 && event.keyLocation == 1) {
			CTRL = false;
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
