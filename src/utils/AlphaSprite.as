package utils
{
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.utils.Dictionary;
	
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.Color;

	public class AlphaSprite
	{
		private var _displayObjectsDic:Dictionary;
		private var _data:XML;
		private static var _instance:AlphaSprite;
		private var _sharedObject:SharedObject;
		private var _selectionQuad:Sprite;
		private var _doContainer:DisplayObjectContainer;
		private var _displayObjectsArray:Array;
		private static var THRESHOLD:int = 3;
		private var _leftLeftGuide:Quad;
		private var _rightLeftGuide:Quad;
		private var _rightRightGuide:Quad;
		private var _leftRightGuide:Quad;
		private var _thresholdCounterX:int;
		private var _snappedX:Boolean;
		
		public function AlphaSprite()
		{
			_displayObjectsDic = new Dictionary();
			_displayObjectsArray = new Array();
			_data = new XML();
			_sharedObject = SharedObject.getLocal("data");
			
		}
		
		private function recurseStage(doc:DisplayObjectContainer):void
		{
			var children:int = doc.numChildren;
			
			for(var i:int = 0; i < children; i++)
			{
				var child:* = doc.getChildAt(i);  
				
				if(child.name){
				
					child.addEventListener(TouchEvent.TOUCH, onTouch);
						
					_displayObjectsDic[child.name] = child;
					_displayObjectsArray.push(child);
					
				}
				
				if(child is DisplayObjectContainer && child.numChildren > 0){
					
					recurseStage(child);
					
				}
			}
		}
		
		
		
		
		
		
		
		private function onTouch(e:TouchEvent):void {
			
			var endedTouch:Touch = e.getTouch(DisplayObject(e.currentTarget), TouchPhase.ENDED); 
			var hoverTouch:Touch = e.getTouch(DisplayObject(e.currentTarget), TouchPhase.HOVER);
			var beganTouch:Touch = e.getTouch(DisplayObject(e.currentTarget), TouchPhase.BEGAN);
			var movedTouch:Touch = e.getTouch(DisplayObject(e.currentTarget), TouchPhase.MOVED);
		
			var displayObject:DisplayObject = DisplayObject(e.currentTarget);
			
			//highlight
			if(hoverTouch && _selectionQuad.visible == false){
				
				_selectionQuad.x = displayObject.x;
				_selectionQuad.y = displayObject.y;
				_selectionQuad = Border.createBorder(displayObject.width, displayObject.height, Color.AQUA, 1, _selectionQuad);
				_selectionQuad.visible = true;
				
			}
			else if(!hoverTouch) {
				
				_selectionQuad.visible = false;
				
			}
			
			if(movedTouch){
				
				if(_snappedX){
					_thresholdCounterX += movedTouch.getMovement(displayObject).x;
				}
				else {
					displayObject.x += movedTouch.getMovement(displayObject).x;
				}
				displayObject.y += movedTouch.getMovement(displayObject).y;
				
				var obj:Object = checkSnap(displayObject);
				if(obj) trace(obj["value"]);
			}
			
			//select
			if(beganTouch){
				
			}
			
			//save new position
			if(endedTouch) {
				
				_sharedObject.data[displayObject.name] = {"x": displayObject.x, "y": displayObject.y};
				_sharedObject.flush();
				_sharedObject.close();
				
				
				//var object:Object = _sharedObject.data[displayObject.name];
				
				
				
				
			}
			
			
			
		}
		
		private function checkSnap(selectedDO:DisplayObject):Object {
			
			var sideNames:Array = [["left", "right"], ["top", "bottom"]];
			var sDORect:Rectangle = selectedDO.getBounds(selectedDO.parent);
			var sDOSides:Array = [[sDORect.left, sDORect.right], [sDORect.top, sDORect.bottom]];
			
			for(var i:int = 0; i < _displayObjectsArray.length; i++){
				
				var dO:DisplayObject = _displayObjectsArray[i];
				
				if(dO.name == selectedDO.name)
					continue;
				
				var dORect:Rectangle = dO.getBounds(dO.parent);
				var dOSides:Array = [[dORect.left, dORect.right], [dORect.top, dORect.bottom]]
				
				for(var axisI:int = 0; axisI < sDOSides.length; axisI ++){
					
					for(var sDOSidesI:int = 0; sDOSidesI < sDOSides[axisI].length; sDOSidesI ++){
						
						for(var dOSideI:int = 0; dOSideI < dOSides[axisI].length; dOSideI ++){
								
							if(Math.abs(sDOSides[axisI][sDOSidesI] - dOSides[axisI][dOSideI]) <= THRESHOLD){
								
								return {"side": sideNames[axisI][sDOSidesI], "value": sDOSides[axisI][dOSideI]};
								
							}
						}	
					}
				}
			}	
			
			return null;
			
		}
			
		
		public function init(object:DisplayObjectContainer):void {
			
			_doContainer = object;
			
			_selectionQuad = Border.createBorder(10, 10, Color.AQUA);
			_selectionQuad.x = -99;
			_selectionQuad.y = -99;
			_doContainer.addChild(_selectionQuad);
			
			_leftLeftGuide = new Quad(1, 1, Color.AQUA);
			_leftLeftGuide.visible = false;
			_doContainer.addChild(_leftLeftGuide);
			
			_rightLeftGuide = new Quad(1, 1, Color.AQUA);
			_rightLeftGuide.visible = false;
			_doContainer.addChild(_rightLeftGuide);
			
			_rightRightGuide = new Quad(1, 1, Color.AQUA);
			_rightRightGuide.visible = false;
			_doContainer.addChild(_rightRightGuide);
			
			_leftRightGuide = new Quad(1, 1, Color.RED);
			_leftRightGuide.visible = false;
			_doContainer.addChild(_leftRightGuide);
			
			recurseStage(object);
			
			for ( var doName:String in _sharedObject.data) {
				
				for ( var property:String in _sharedObject.data[doName]) {
					
					_displayObjectsDic[doName][property] = _sharedObject.data[doName][property];
					
				}
				
				
				
				
			}
			
		}
		
		
		
		
		
		public static function getInstance():AlphaSprite {
			
			if(!_instance)
				_instance = new AlphaSprite();
			
			return _instance;
			
		}
		
	}
	
	
	
	
	
	
	
	
}