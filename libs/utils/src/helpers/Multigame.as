package helpers

{

    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.events.Event;
    import flash.events.ProgressEvent;
import flash.net.NetGroup;
import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;
import flash.utils.Dictionary;

public class Multigame
    {

        private static var _onComplete:Function;
        private static var _games:Dictionary = new Dictionary();

        public static function loadGame(swf:String, onComplete:Function, matchData:Object):void {

            var urlRequest:URLRequest = new URLRequest(swf);
            var loaderContext:LoaderContext = new LoaderContext();
            loaderContext.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
            var gameLoader:Loader = new Loader();
            gameLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
            gameLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);
            _onComplete = onComplete;
            gameLoader.load(urlRequest, loaderContext);

            _games[gameLoader.contentLoaderInfo] = matchData;

        }

        private static function onCompleteHandler(e:Event):void {

            var loaderInfo:LoaderInfo = e.target as LoaderInfo;

            var gameClass:Class = loaderInfo.applicationDomain.getDefinition("game.Game") as Class;
            var assetsClass:Class = loaderInfo.applicationDomain.getDefinition("game.Assets") as Class;

            var classInfo:Object = {assets: assetsClass, gameClass:gameClass};

            _onComplete(classInfo, _games[e.currentTarget]);

        }

        private static function onProgressHandler(mProgress:ProgressEvent):void {

           // trace(mProgress.bytesLoaded, mProgress.bytesTotal);

        }
    }



















}