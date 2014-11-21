package helpers
{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class Hexagon extends Sprite
	{
		
		public function Hexagon(radius:int, border:Number = 2, color:uint = 0x000000){
			
			//TODO
			radius = 10;
			
			var topRight:Quad = new Quad(radius, border, color);
			topRight.rotation = -120 * Math.PI / 180;
			addChild(topRight);
			
			var top:Quad = new Quad((radius - topRight.width) * 2, border, color);
			top.x = -top.width - topRight.width;
			top.y = -topRight.height;
			addChild(top);
			
			var bot:Quad = new Quad((radius - topRight.width) * 2, border, color);
			bot.x = -bot.width - topRight.width;
			bot.y = topRight.height;
			addChild(bot);
			
			var topLeft:Quad = new Quad(radius, border, color);
			topLeft.rotation = -60 * Math.PI / 180;
			topLeft.x = -topLeft.width * 2 - top.width;
			addChild(topLeft);
			
			var botLeft:Quad = new Quad(radius, border, color);
			botLeft.rotation = -120 * Math.PI / 180;
			botLeft.x = -botLeft.width - top.width;
			botLeft.y = bot.y;
			addChild(botLeft);
			
			var botRight:Quad = new Quad(radius, border, color);
			botRight.rotation = -60 * Math.PI / 180;
			botRight.x = -botRight.width;
			botRight.y = bot.y;
			addChild(botRight);
			
			
			/*var flashSprite:flash.display.Sprite = drawPolygon(6, radius);
			
			var bitmapData:BitmapData = new BitmapData(radius * 2 - 4, radius * 2, true, 0x000000);
			bitmapData.draw(flashSprite);
			
			
			var image:Image = new Image(Texture.fromBitmapData(bitmapData));
			addChild(image);*/
			
			
		}
		
		private function drawPolygon(sides:Number, radius:Number):flash.display.Sprite {
			
			
			var sprite:flash.display.Sprite;
			sprite = new flash.display.Sprite();
			var angle:Number = 360/sides;
			var current_side:Number = 0;
			sprite.graphics.lineStyle(1);
			
			while (current_side <= sides) {
				
				var a:Number = angle * current_side / 180 * Math.PI;
				var x:Number = radius * Math.sin(a);
				var y:Number = radius * Math.cos(a);
				
				if (!current_side) {
					// if this is the first side, we need to move out to the correct point
					sprite.graphics.moveTo(x + radius - 2, y + radius);
				} else {
					// if we are already started, go ahead and draw from point to point.
					sprite.graphics.lineTo(x + radius - 2, y + radius);
				}
				
				current_side ++;
			}
			
			return sprite;
			
			
		}
		
		
		
	}
	
	
	
	
	
	
	
	
}