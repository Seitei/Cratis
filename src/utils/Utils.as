package utils
{
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
	}
}