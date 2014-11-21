package helpers {


import flash.utils.setTimeout;

import starling.animation.Transitions;

import starling.animation.Tween;
import starling.core.Starling;

import starling.display.Image;
import starling.display.Quad;
import starling.display.Shape;
import starling.display.Sprite;
import starling.text.TextField;
import starling.textures.RenderTexture;
import starling.utils.Color;
import starling.utils.deg2rad;

public class LoadingWheel extends Sprite {

    private static const DEGREE:Number = Math.PI / 180;
    private static const DEGREE_360:Number = Math.PI * 2;

    private var _greenGuide:Sprite;
    private var _redGuide:Sprite;
    private var _greenFill:Sprite;
    private var _redFill:Sprite;
    private var _canvasGreen:RenderTexture;
    private var _canvasRed:RenderTexture;
    private var _greenGauge:Image;
    private var _redGauge:Image;
    private var _numberTxt:TextField;
    private var _valueToGo:Number;
    private var _rawValue:int;
    private var _buffer:Number;
    private var _positiveValue:int;
    private var _negativeValue:int;
    private var _greenTween:Tween;
    private var _redTween:Tween;
    private var _previousRedRotation:Number;
    private var _previousGreenRotation:Number;
    private var _rotationIncrement:int;


    public function LoadingWheel(positiveValue:int, negativeValue:int) {

        _positiveValue = positiveValue;
        _negativeValue = negativeValue;

        _canvasGreen = new RenderTexture(200, 200, true);
        _canvasRed = new RenderTexture(200, 200, true);
        _greenGauge = new Image(_canvasGreen);
        _redGauge = new Image(_canvasRed);
        _buffer = 0;

        _greenGuide = new Sprite();
        _redGuide = new Sprite();
        _greenFill = new Sprite();
        _redFill = new Sprite();

        var greenLine:Quad = new Quad(60, 6, 0x58C23C);
        greenLine.x = 40;
        _greenFill.addChild(greenLine);
        _greenFill.x = 100;
        _greenFill.y = 100;

        var redLine:Quad = new Quad(60, 6, Color.RED);
        redLine.x = 40;
        _redFill.addChild(redLine);
        _redFill.x = 100;
        _redFill.y = 100;

        addPercentageArea();

        addChild(_redGauge);
        addChild(_greenGauge);

        pivotX = width / 2;
        pivotY = height / 2;

        //to delay the call once everything is initialized, so the frames are steady
        //remove if not needed
        setTimeout(processValue, 1000);

    }


    private function onRedUpdate():void {

        var diff:Number = Math.abs(Math.abs(_redGuide.rotation) - Math.abs(_previousRedRotation));
        var rotated:Number = 0;

        _redFill.rotation = _previousRedRotation;

        do{

            _canvasRed.draw(_redFill);
            _redFill.rotation += DEGREE * 3;

            rotated += DEGREE * 3;

        }while (rotated <= diff)



        _previousRedRotation = _redGuide.rotation;

    }

    private function onGreenUpdate():void {

        var diff:Number = Math.abs(Math.abs(_greenGuide.rotation) - Math.abs(_previousGreenRotation));
        var rotated:Number = 0;
        _greenFill.rotation = _previousGreenRotation;

        do{

            _canvasGreen.draw(_greenFill);
            _greenFill.rotation += DEGREE * _rotationIncrement;

            rotated += DEGREE * _rotationIncrement;


        }while (rotated <= diff)

        _previousGreenRotation = _greenGuide.rotation;

    }

    private function onComplete():void {

        Starling.juggler.remove(_greenTween);
        Starling.juggler.remove(_redTween);

    }

    private function processValue():void{

        _redTween = new Tween(_redGuide, 1, Transitions.EASE_IN_OUT);
        _redTween.animate("rotation", deg2rad(360));
        _redTween.onComplete = onComplete;
        _redTween.onUpdate = onRedUpdate;
        Starling.juggler.add(_redTween);

        _greenTween = new Tween(_greenGuide, 1, Transitions.EASE_IN_OUT);
        _greenTween.animate("rotation", deg2rad(_positiveValue * 360 / 100));
        _greenTween.onUpdate = onGreenUpdate;
        Starling.juggler.add(_greenTween);

        _rotationIncrement = _positiveValue > 3 ? 3 : _positiveValue;

    }

    public function reset():void {

        _buffer = 0;
        _greenGuide.rotation = 0;
        _canvasGreen.clear();
        _redGuide.rotation = 0;
        _canvasRed.clear();
        _numberTxt.text = "0";
        _rawValue = 0;
        _valueToGo = 0;

    }


    private function updateNumber():void {

        _buffer += 50 / 180;

        _numberTxt.text = String(Math.round(_buffer)) + "%";


    }

    private function addPercentageArea(){

        var numberCircle:Shape = new Shape();
        numberCircle.graphics.beginFill(0xF4F4F4);
        numberCircle.graphics.drawCircle(60, 60, 40);
        numberCircle.graphics.endFill();
        numberCircle.x = numberCircle.width / 2;
        numberCircle.y = numberCircle.height / 2;
        addChild(numberCircle);

        _numberTxt = new TextField(80, 80, "0");
        _numberTxt.text = _numberTxt.text + "%";
        _numberTxt.color = _positiveValue >= _negativeValue ? 0x58C23C : 0xEF0D2B ;
        _numberTxt.fontSize = 22;
        _numberTxt.x = 60;
        _numberTxt.y = 60;

        addChild(_numberTxt);

    }

}

}
