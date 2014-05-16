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
		private var _hpDivisors:Array;
		private var _divisorsContainer:PixelMaskDisplayObject;
		private var _units:int;
		
		public function Bar(background:DisplayObject, border:DisplayObject)
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			_background = background;
			_border = border;
			_hpDivisors = new Array();
		}
		
		public function get units():int
		{
			return _units;
		}

		public function set units(value:int):void
		{
			_units = value;
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
			
			
			_units += value;
			
			if(_hpDivisors.length == 0) value --;
				
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
				
				_hpDivisors.push(container);
				
			}
			
			for(var j:int = 0; j < _hpDivisors.length; j ++){
				
				_hpDivisors[j].x = (j + 1) * (this.width / (_hpDivisors.length + 1));
				
			}
		}
		
		public function update(value:int):void {
			
			_mask.mask.x -= (this.width / (_hpDivisors.length + 1)) * value;
			_units -= value;
		}
		
		
		
		
	}
	
	
	
	
	
	
	
	
	
	
}