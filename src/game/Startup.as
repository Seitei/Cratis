package game
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import game.Main;
	
	import starling.core.Starling;
	[SWF(width="700", height="600", frameRate="60", backgroundColor="#1d1d1d")]
	public class Startup extends Sprite
	{
		public var gameClass:Class = Main;
		private var mStarling:Starling;
		
		public function Startup()
		{
			if(stage) {
				addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);	
			}
		}
		
		private function onAddedToStage(evt:Event):void {
			// stats class for fps
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			// create our Starling instance
			mStarling = new Starling(gameClass, stage);
			// set anti-aliasing (higher the better quality but slower performance)
			mStarling.antiAliasing = 4;
			
			//mStarling.showStats = true;
			// start it!
			mStarling.start();
		}
	}
}