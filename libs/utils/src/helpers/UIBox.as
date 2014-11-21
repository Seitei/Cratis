package helpers
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import starling.display.DisplayObject;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.utils.Color;
	
	public class UIBox extends Sprite
	{
		private var _highlightBox:Sprite;
		private var _selectionBox:Sprite;
		private var _anchorsArray:Array;
		static private var anchorSize:int = 6;
		private var _topLeftAnchor:Quad;
		private var _topMidAnchor:Quad;
		private var _topRightAnchor:Quad;
		private var _midLeftAnchor:Quad;
		private var _midRightAnchor:Quad;
		private var _botLeftAnchor:Quad;
		private var _botMidAnchor:Quad;
		private var _botRightAnchor:Quad;
		private var _rotationAnchor:Quad;
		private var _selectedDo:DisplayObject;
		private var _type:String = "beta";
		private var _needsUpdate:Boolean = true;
		
		public function UIBox(displayObject:DisplayObject)
		{
			
			//alpha UI is different from normal (beta) UI's;
			if(displayObject.name.indexOf("_alpha") != -1)
				_type = "alpha";	
				
			_highlightBox = new Sprite();
			_selectionBox = new Sprite();
			_selectedDo = displayObject;
			
			addChild(_highlightBox);
			addChild(_selectionBox);
			
			_highlightBox.visible = false;
			_selectionBox.visible = false;
			
		}
		
		public function get selectedDo():DisplayObject
		{
			return _selectedDo;
		}

		public function updateUI():void {
			
			var sDORect:Rectangle = _selectedDo.getBounds(stage);
			
			Border.createBorder(sDORect.width, sDORect.height, _type == "alpha" ? Color.RED : Color.AQUA, 1, _highlightBox);
			Border.createBorder(sDORect.width, sDORect.height, _type == "alpha" ? Color.RED : Color.AQUA, 1, _selectionBox);
			
			this.x = sDORect.left;//_selectedDo.localToGlobal(new Point()).x;
			this.y = sDORect.top;//_selectedDo.localToGlobal(new Point()).y;
			
			createAnchors();
			
			_needsUpdate = false;
		}
		
		public function highlight(value:Boolean):void {
			
			if(value && _needsUpdate)
				updateUI();
			
			_highlightBox.visible = value;
			
			if(!value)
				_needsUpdate = true;
			
		}
		
		
		public function select(value:Boolean):void {
			
			_selectionBox.visible = value;
			
		}
		
		private function createAnchors():void {
			
			_anchorsArray = new Array();
			_selectionBox.removeChildren(0, -1, true);
			
			var color:uint = _type == "alpha" ? Color.RED : Color.AQUA;
			
			_anchorsArray[1] = _topLeftAnchor = new Quad(anchorSize, anchorSize,color); 
			_anchorsArray[2] = _topMidAnchor = new Quad(anchorSize, anchorSize, color); 
			_anchorsArray[3] = _topRightAnchor = new Quad(anchorSize, anchorSize, color);
			_anchorsArray[4] = _midLeftAnchor = new Quad(anchorSize, anchorSize, color); 
			_anchorsArray[6] = _midRightAnchor = new Quad(anchorSize, anchorSize, color);
			_anchorsArray[7] = _botLeftAnchor = new Quad(anchorSize, anchorSize, color); 
			_anchorsArray[8] = _botMidAnchor = new Quad(anchorSize, anchorSize, color);  
			_anchorsArray[9] = _botRightAnchor = new Quad(anchorSize, anchorSize, color);
			_rotationAnchor = new Quad(6, 6, color);
			
			var xCounter:Number = 0;
			var yCounter:Number = 0;
			
			for(var i:int = 1; i <= 9; i++){
			
				if(i != 5){
				
					_anchorsArray[i].pivotX = _anchorsArray[i].width / 2;
					_anchorsArray[i].pivotY = _anchorsArray[i].height / 2;
					_anchorsArray[i].x = xCounter * _selectedDo.width; 
					_anchorsArray[i].y = yCounter * _selectedDo.height;
					
					_selectionBox.addChild(_anchorsArray[i]);
					
				}
			
				xCounter += 0.5;
				
				if(i % 3 == 0){
					xCounter = 0;
					yCounter += 0.5;
				}
			}
			
			_rotationAnchor.pivotX = _rotationAnchor.width / 2;
			_rotationAnchor.pivotY = _rotationAnchor.height / 2;
			
			_rotationAnchor.x = _topMidAnchor.x;
			_rotationAnchor.y = _topMidAnchor.y - 15;
			
			_selectionBox.addChild(_rotationAnchor);
			
			/*_topLeftAnchor.addEventListener(TouchEvent.TOUCH, diagonalResize);
			_topMidAnchor.addEventListener(TouchEvent.TOUCH, verticalResize);
			_topRightAnchor.addEventListener(TouchEvent.TOUCH, diagonalResize);
			_midLeftAnchor.addEventListener(TouchEvent.TOUCH, horizontalResize);
			_midRightAnchor.addEventListener(TouchEvent.TOUCH, horizontalResize);
			_botLeftAnchor.addEventListener(TouchEvent.TOUCH, diagonalResize);
			_botMidAnchor.addEventListener(TouchEvent.TOUCH, verticalResize);
			_botRightAnchor.addEventListener(TouchEvent.TOUCH, diagonalResize);
			
			_rotationAnchor.addEventListener(TouchEvent.TOUCH, rotate);
			
			//we need to recalculate the pivot since we are altering the image.
			this.pivotX = this.width / 2;
			this.pivotY = this.height / 2;*/
			
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}