import haxe.ui.macros.ComponentMacros;
import haxe.ui.Toolkit;
import haxe.ui.components.Button;
import haxe.ui.containers.VBox;
import haxe.ui.core.Screen;

class UI {
    public function new() {
        Toolkit.init();
        var main = ComponentMacros.buildComponent("Assets/ui.xml");
        Screen.instance.addComponent(main);
    }
}
