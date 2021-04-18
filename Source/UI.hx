import openfl.text.TextFieldAutoSize;
import format.SVG;
import openfl.events.MouseEvent;
import openfl.Assets;
import openfl.text.TextField;
import openfl.text.TextFieldType;
import openfl.display.Sprite;
import openfl.events.Event;

class UI extends Sprite {
	public var input(default, null):TextField;
    public var simStatus(default, null):TextField;
	public var resetSimButton(default, null):Sprite;
	public var leftButton(default, null):Sprite;
	public var rightButton(default, null):Sprite;
	public var fullSimButton(default, null):Sprite;
	public var toDFAButton(default, null):Sprite;
	public var resetButton(default, null):Sprite;
    private var flgraph:FLGraphContainer;

	private var uiWidth:Int = 0;
	private var uiHeight:Int = 100;

	public function new(graph, width, height) {
		super();

        flgraph = graph;

        uiWidth = width;
        uiHeight = height;

		// input
		input = new TextField();
		input.selectable = true;
		input.mouseEnabled = true;
		input.type = TextFieldType.INPUT;
		input.width = 180;
		input.height = uiHeight - (2 * uiHeight / 10);
		input.background = true;
		input.backgroundColor = 0xaaaaaa;
		input.multiline = false;
		input.x = uiHeight / 10;
		input.y = uiHeight / 10;

		addChild(input);
		addEventListener(Event.CHANGE, onChange);

        // sim status
        simStatus = new TextField();
		simStatus.selectable = false;
		simStatus.mouseEnabled = false;
		simStatus.width = 160;
		simStatus.height = uiHeight - (2 * uiHeight / 10);
		simStatus.background = true;
		simStatus.backgroundColor = 0xaaaaaa;
		simStatus.multiline = false;
		simStatus.x = uiHeight / 10 * 2 + input.width;
		simStatus.y = uiHeight / 10;

        addChild(simStatus);

		// navigation buttons
        var middle = uiWidth / 2;
        var buttonHeight = uiHeight / 2;
        var buttonBuffer = 70;
		resetSimButton = createButton(middle - buttonBuffer * 2, buttonHeight, "farrightarrow.svg", true, simResetSim);
		leftButton = createButton(middle - buttonBuffer, buttonHeight, "rightarrow.svg", true, simStepBackward);
		rightButton = createButton(middle + buttonBuffer, buttonHeight, "rightarrow.svg", false, simStepForward);
		fullSimButton = createButton(middle + buttonBuffer * 2, buttonHeight, "farrightarrow.svg", false, simFullSim);
		
        addChild(resetSimButton);
        addChild(leftButton);
        addChild(rightButton);
        addChild(fullSimButton);

        // functional buttons
        toDFAButton = createButton(uiWidth - 250, buttonHeight, "box.svg", false, toDFA, "DFA");
        resetButton = createButton(uiWidth - 100, buttonHeight, "box.svg", false, reset, "Reset");

        addChild(toDFAButton);
        addChild(resetButton);
	}

	public function render() {
		// math
		var x1 = 0;
		var y1 = stage.stageHeight - uiHeight;

		// background
		graphics.beginFill(0xbbbbbb);
		graphics.drawRect(0, 0, uiWidth, uiHeight);

		x = x1;
		y = y1;
	}

	private function onChange(event:Event) {
		trace(event);
		trace('new text is ${input.text}');
        flgraph.input = input.text;
        flgraph.simReset();
        flgraph.simToEnd();
        updateStatus();
	}

	private function createButton(x, y, svgFile, flipped, callBack, text=""):Sprite {
		var button = new Sprite();

		button.mouseChildren = false;
		button.buttonMode = true;

		button.x = x;
		button.y = y;

		if (flipped == true) {
			button.scaleX = -1;
		}

		var svg = new SVG(Assets.getText('assets/$svgFile'));
		svg.render(button.graphics);

		button.addEventListener(MouseEvent.MOUSE_UP, callBack);
		button.addEventListener(MouseEvent.MOUSE_DOWN, callBack);

        if (text != "") {
            var textChild = new TextField();
            textChild.text = text;
            textChild.width = button.width;
            textChild.selectable = false;
            textChild.autoSize = TextFieldAutoSize.CENTER;
            textChild.height = 20;
            textChild.backgroundColor = 0xffffff;
            // textChild.border = true;
            textChild.x = -button.width/2;
            textChild.y = -textChild.height/2;
            button.addChild(textChild);
        }

		return button;
	}
    
    private function simResetSim(event:MouseEvent) {
        if (event.type == MouseEvent.MOUSE_UP) {
            flgraph.simReset();
        }

        updateStatus();
        event.stopPropagation();
    }

    private function simStepForward(event:MouseEvent) {
        if (event.type == MouseEvent.MOUSE_UP) {
            flgraph.simStepForward();
        }

        updateStatus();
        event.stopPropagation();
    }

    private function simStepBackward(event:MouseEvent) {
        if (event.type == MouseEvent.MOUSE_UP) {
            flgraph.simStepBackward();
        }

        updateStatus();
        event.stopPropagation();
    }

    private function simFullSim(event:MouseEvent) {
        if (event.type == MouseEvent.MOUSE_UP) {
            flgraph.simToEnd();
        }

        updateStatus();
        event.stopPropagation();
    }

    private function toDFA(event:MouseEvent) {
        if (event.type == MouseEvent.MOUSE_UP) {
            flgraph.digraph = flgraph.digraph.toDFA(flgraph.input);
            flgraph.render();
            flgraph.simReset();
        }

        event.stopImmediatePropagation();
    }

    private function reset(event:MouseEvent) {
        if (event.type == MouseEvent.MOUSE_UP) {
            event.stopImmediatePropagation();
            var main:Main = cast parent;
            main.restart();
        }

        event.stopImmediatePropagation();
    }

    public function updateStatus() {
        simStatus.text = flgraph.getSimString();
    }
}
