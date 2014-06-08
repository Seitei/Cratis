package utils
{
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.extensions.pixelmask.PixelMaskDisplayObject;
	import starling.utils.Color;
	
	public class Bar extends Sprite
	{
		private var _background:DisplayObject;
		private var _border:DisplayObject;
		private var _mask:PixelMaskDisplayObject;
		private var _divisors:Array;
		private var _divisorsContainer:PixelMaskDisplayObject;
		private var _units:int;
		private var _firstValue:Boolean; 
		private var _maxUnits:int;
		
		public function Bar(background:DisplayObject, border:DisplayObject)
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			_background = background;
			_border = border;
			_divisors = new Array();
		}
		
		public function get maxUnits():int
		{
			return _maxUnits;
		}

		public function set maxUnits(value:int):void
		{
			_maxUnits = value;
		}

		public function get units():int
		{
			return _units;
		}

		public function set units(value:int):void
		{
			_units = value;
			_mask.mask.x = -this.width + (this.width / (_divisors.length + 1)) * _units;
		}

		private function onAdded(e:Event):void {
			
			_mask = new PixelMaskDisplayObject();
			_mask.mask = new Quad(_background.width, _background.height);
			_mask.addChild(_background);
			addChild(_mask);
			addChild(_border);
			_divisorsContainer = new PixelMaskDisplayObject();
			_divisorsContainer.mask = _background;
			addChild(_divisorsContainer);
		}
		
		public function increaseUnits(value:int):void {
			
			if(value == 0) return;
			
			_units += value;
			_maxUnits = _units;
			
			if(!_firstValue){
				_firstValue = true;
				value --;
			}
				
			for(var i:int = 0; i < value; i ++){
				
				var container:Sprite = new Sprite();
				
				var bQuad:Quad = new Quad(1, this.height, Color.BLACK);
				bQuad.alpha = 0.2;
				container.addChild(bQuad);
				
				var wQuad:Quad = new Quad(1, this.height, Color.WHITE);
				wQuad.alpha = 0.25;
				wQuad.x = 1;
				container.addChild(wQuad);
				
				_divisorsContainer.addChild(container);
				
				_divisors.push(container);
				
			}
			
			for(var j:int = 0; j < _divisors.length; j ++){
				
				_divisors[j].x = (j + 1) * (this.width / (_divisors.length + 1));
				
			}
		}
		
		public function update(value:int):void {
			
			_mask.mask.x -= (this.width / (_divisors.length + 1)) * value;
			_units -= value;
			
		}
		
		public function setValue(value:String):void {
			
			
			switch(value) {
				
				case "full": 
					units = _maxUnits;
					break;
				
				case "empty": 
					units = 0;
					break;
			}
		}
	}
	
	
	
	
	
	
	
	
	
	
}