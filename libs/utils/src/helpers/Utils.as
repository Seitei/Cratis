package helpers
{
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.core.Starling;
	import starling.display.DisplayObject;

	public class Utils
	{
		
		//debugging purposes
		public static function showMap(map:Array):void {
			
			var output:String = "";
			
			for( var i:int = 0; i < map.length; i ++){
				for( var j:int = 0; j < map.length; j ++){
					output += map[j][i] + " ";	
				}
				output += "\n";
			}
			
			trace(output);
		}
		
		public static function fadeTo(dO:DisplayObject, transitionTime:Number, transitionType:String, fade:Number = 0):void {
			
			var tween:Tween = new Tween(dO, transitionTime, transitionType);
			tween.animate("alpha", fade);
			Starling.juggler.add(tween);
			
			if(fade == 0){
				tween.onComplete = onCompleteFadeTransition;
				tween.onCompleteArgs = [dO];
			}
			
		}

        public static function moveTo(dO:DisplayObject, xCoord:int, yCoord:int, transitionTime:Number, transitionType:String):void {

            var tween:Tween = new Tween(dO, transitionTime, transitionType);
            tween.moveTo(xCoord, yCoord);
            Starling.juggler.add(tween);

        }
		
		private static function onCompleteFadeTransition(dO:DisplayObject):void {
			
			dO.parent.removeChild(dO, true);
			
		}
		
	}























}