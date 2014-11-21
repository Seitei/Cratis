package {

import helpers.ExtendedButton;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.Event;
import starling.utils.AssetManager;

public class UserStub extends Sprite {

    private var _names:Array;
    private var _assetManager:AssetManager;
    private static var GAP:int = 15;

    public function UserStub() {

        _names = [

            "Paul",
            "John",
            "Bruce",
            "Walter",
            "Jack",
            "Sergio",
            "Daniel",
            "Matt",
            "Kevin"

        ];

        loadGameAssets();
    }

    private function init():void {

        var background:Image = new Image(_assetManager.getTexture("stub_background"));
        addChild(background);

        var counter:int = 0;

        for each(var name:String in _names){

            var button:ExtendedButton = createButton(name);
            button.x = 20;
            button.y = 20 + counter * (button.height + GAP);
            addChild(button);

            counter ++;

        }

    }

    private function createButton(name:String):ExtendedButton {

        var button:ExtendedButton;

        var upState:Image = new Image(_assetManager.getTexture("stub_button_up"));
        upState.name = "up0000";
        var hoverState:Image = new Image(_assetManager.getTexture("stub_button_hover"));
        hoverState.name = "hover0000";
        var downState:Image = new Image(_assetManager.getTexture("stub_button_down"));
        downState.name = "down0000";

        var buttonsStates:Array = new Array();
        buttonsStates.push(upState, downState, hoverState);

        button = new ExtendedButton(buttonsStates);
        button.text = name;
        button.name = name;

        button.addEventListener("buttonTriggeredEvent", onButtonTriggered);

        return button;

    }

    private function onButtonTriggered(e:Event):void {

        dispatchEventWith("nameSelected", true, ExtendedButton(e.currentTarget).name);

    }


    private function loadGameAssets():void {

        _assetManager = new AssetManager();
        _assetManager.enqueue(["assets/stub_background.png", "assets/stub_button_up.png", "assets/stub_button_hover.png", "assets/stub_button_down.png"]);
        _assetManager.loadQueue(onProgress);

    }

    private function onProgress(ratio:Number):void {

        if(ratio == 1){

            init();

        }
    }




























}
}
