package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;

	import starling.core.Starling;

[SWF(width="670", height="585", frameRate="60", backgroundColor="#F4F4F4")]
	public class Startup extends Sprite
	{
		private var mStarling:Starling;
		public function Startup()
		{
			// stats class for fps
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			// create our Starling instance
			mStarling = new Starling(Main, stage);
			// set anti-aliasing (higher the better quality but slower performance)
			mStarling.antiAliasing = 4;
			
			//mStarling.showStats = true;
			// start it!
			mStarling.start();
		}
	}
}