package netcode
{

	import flash.net.Responder;
	
	import starling.events.EventDispatcher;
	
	public class NetConnect extends starling.events.EventDispatcher
	{
		import flash.display.SimpleButton;
		import flash.display.Sprite;
		import flash.events.Event;
		import flash.events.EventDispatcher;
		import flash.events.NetStatusEvent;
		import flash.events.StatusEvent;
		import flash.geom.Point;
		import flash.net.GroupSpecifier;
		import flash.net.NetConnection;
		import flash.net.NetGroup;
		import flash.net.NetStream;
		import flash.net.registerClassAlias;
		import flash.utils.ByteArray;
		import flash.utils.Dictionary;
		import flash.utils.Timer;
		import flash.utils.getTimer;
		
		registerClassAlias("Point", Point);
		registerClassAlias("Vector", Vector);
		registerClassAlias("Point", Point);
		registerClassAlias("Dictionary", Dictionary);
		registerClassAlias("Array", Array);
		registerClassAlias("Boolean", Boolean);
		
		private const SERVER:String = "rtmfp://p2p.rtmfp.net/"; 
		private const DEVKEY:String = "cde41fe05bb01817e82e5398-2ab5d983d09f"; 
		private const NAME:String = "Artemix";
		
		private var _cirrusNc:NetConnection;
		private var _amfphpNc:NetConnection;
		
		private var _connected:Boolean = false;
		
		private var _user:String;
		private var _seq:int;
		
		private var _status:String;
		private var _log:String;
		
		private var _sendStream:NetStream;
		private var _receivingStream:NetStream;
		
		private var _res:Responder;
		private static var _instance:NetConnect;
		private var _receiving:Boolean;
		private var _message:Object;
			
		public function NetConnect():void {
				_message = new Object();
				_status = "waiting";
				_cirrusNc = new NetConnection(); 
				_cirrusNc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus); 
				_cirrusNc.connect( SERVER + DEVKEY );
		}
		
		public function onResult(response:Object):void {
			
			//here we ask if there is another player waiting to connect to someone
			if(response == "waiting") {
				
				//show waiting for players screen
				
			}
			
			//if there is someone already waiting to play
			else {
				//start game
				connectToPeer(response[1]);
				
			}
		}
		
		public function onFault(response:Object):void {
			for (var i:* in response) {
				trace(response[i]);
			}
		}
		
		private function onNetStatus(event:NetStatusEvent):void {
			
			switch(event.info.code) {
				case "NetConnection.Connect.Success":
					onCirrusConnect();
					break;
				case "NetStream.Play.Start":
					break;
				case "NetStream.Connect.Success":
					if(!_connected){
						_connected = true;
						onPeerConnect(event.info.stream.farID);
					}
					break;
				default:
					break;
			}
			
			_log = event.info.code; 
			trace(_log);
			sendStatus(_log);
			
		}
		
		private function onCirrusConnect():void {
			//connecting to amfphp
			_amfphpNc = new NetConnection();
			//_amfphpNc.connect("http://localhost/Amfphp/");
			_amfphpNc.connect("http://www.konkugames.com/Amfphp/");
			_res = new Responder(onResult, onFault);
			_amfphpNc.call("Rendezvous.match", _res, NAME, _cirrusNc.nearID);
			
			//defining the send stream
			_sendStream = new NetStream(_cirrusNc, NetStream.DIRECT_CONNECTIONS);	
			//_sendStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_sendStream.client = this;
			_sendStream.publish("data");
		}
		
		private function onPeerConnect(farID:String):void {
			
			//defining the receiving stream
			_receivingStream = new NetStream(_cirrusNc, farID);
			//_receivingStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_receivingStream.client = this;
			_receivingStream.play("data");
			dispatchEventWith("notifyNeighborConnectedEvent", true, "first");
			_connected = true;
		}
		
		private function connectToPeer(farID:String):void {
			
			//defining the receiving stream
			_receivingStream = new NetStream(_cirrusNc, farID);
			//_receivingStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_receivingStream.client = this;
			_receivingStream.play("data");
			dispatchEventWith("NotifyNeighborConnectedEvent", true, "second");
			_connected = true;
		}
		
		public function sendStatus(status:String):void {
			dispatchEventWith("notifyStatusEvent", true, status);
		}
		
		public function handler(message:Object):void {
			
			dispatchEventWith("notifyEvent", true, message);
			
		}
		
		public function sendMessage(data:Object):void {
			
			/*var byteArray:ByteArray;
			byteArray = new ByteArray();
			byteArray.writeObject(data);
			byteArray.position = 0;
			var object:Object = byteArray.readObject();*/ 
			
			_message = new Object();
			_message.data = data;
			_message.type = "action";
			_message.sequence = _seq++;
			_sendStream.send("handler", _message);
		}
		
		
		
		
		
		
		
		
		
		
		
	}
}