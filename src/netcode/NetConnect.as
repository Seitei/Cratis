package netcode
{


import flash.net.GroupSpecifier;
import flash.net.NetGroup;
import flash.net.Responder;
	
	import starling.events.EventDispatcher;
	
	public class NetConnect extends starling.events.EventDispatcher
	{

		import flash.events.NetStatusEvent;
		import flash.geom.Point;
		import flash.net.NetConnection;
		import flash.net.NetStream;
		import flash.net.registerClassAlias;
		import flash.utils.Dictionary;

		
		registerClassAlias("Point", Point);
		registerClassAlias("Vector", Vector);
		registerClassAlias("Point", Point);
		registerClassAlias("Dictionary", Dictionary);
		registerClassAlias("Array", Array);
		registerClassAlias("Boolean", Boolean);
		
		private const SERVER:String = "rtmfp://p2p.rtmfp.net/"; 
		private const DEVKEY:String = "cde41fe05bb01817e82e5398-2ab5d983d09f"; 
		private const NAME:String = "Artemix";
		
		private const HOST_NAME:String = "http://localhost";
		//private const HOST_NAME:String = "http://konku.local";
		//private const HOST_NAME:String = "http://www.konkugames.com";
		
		private var _cirrusNc:NetConnection;

		private var _amfphpNc:NetConnection;
		
		private var _connected:Boolean = false;
		
	    private var _seq:int;
		
		private var _status:String;
		private var _log:String;
		
		private var _sendStream:NetStream;
		private var _receivingStream:NetStream;
		
		private var _res:Responder;
		private var _message:Object;
        private var _groupSpecifier:GroupSpecifier;
		private var _netGroup:NetGroup;

		public function NetConnect():void {

            _groupSpecifier = new GroupSpecifier("com.konkugames.battleship_group");
            _groupSpecifier.multicastEnabled = true;
            _groupSpecifier.postingEnabled = true;
            _groupSpecifier.objectReplicationEnabled = true;
            _groupSpecifier.routingEnabled = true;
            _groupSpecifier.serverChannelEnabled = true;

			_message = new Object();
			_status = "waiting";
			_cirrusNc = new NetConnection();
			_cirrusNc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_cirrusNc.connect( SERVER + DEVKEY );

		}

		private function onNetStatus(event:NetStatusEvent):void {

            _log = "NET CONNECTION  : " + event.info.code;
            trace(_log);

			switch(event.info.code) {

                case "NetConnection.Connect.Success":
					onCirrusConnect();
					break;

                case "NetGroup.Connect.Success":
					evaluateNetGroup();
                    break;

				default:
					break;
			}
			

			sendStatus(_log);
			
		}

        private function onGroupConnected(groupID:String):void {


        }

        private function onNetStatusStream(e:NetStatusEvent):void {


           trace("NET STREAM:  ", e.info.code);


        }

        private function evaluateNetGroup():void {

            trace(_netGroup.estimatedMemberCount);

        }


		private function onCirrusConnect():void {

			//connecting to amfphp

            /*_amfphpNc = new NetConnection();
			_amfphpNc.connect(HOST_NAME + "/Amfphp/");
			_res = new Responder(onResult, onFault);
			_amfphpNc.call("Rendezvous.match", _res, NAME, _cirrusNc.nearID);*/


            _netGroup = new NetGroup(_cirrusNc, _groupSpecifier.groupspecWithoutAuthorizations());
            _netGroup.addEventListener( NetStatusEvent.NET_STATUS, onNetGroupStatus );
            trace(_netGroup.estimatedMemberCount);



		}

        private function onNetGroupStatus(e:NetStatusEvent):void {

            trace("NETGROUP INFO: ", e.info.code);

            switch(e.info.code) {

                case "NetGroup.Neighbor.Connect":
                    evaluateNeighbourConnect(e);
                    break;

                case "NetGroup.Posting.Notify":
                    evaluatePostedMessage(e);

                    break;

                default:
                    break;
            }

        }

        private function evaluateNeighbourConnect(e:NetStatusEvent):void {



        }

        private function evaluatePostedMessage(e:NetStatusEvent):void {

            dispatchEventWith("notifyEvent", true, e.info.message);

        }

       	public function sendStatus(status:String):void {
			dispatchEventWith("notifyStatusEvent", true, status);
		}
		
		public function sendMessage(data:Object):void {
			
			_message = new Object();
			_message.data = data;
			_message.type = "action";
			_message.sequence = _seq ++;
			_netGroup.post(_message);

		}

        public function onResult(response:Object):void {

            //here we ask if there is another player waiting to connect to someone
            if(response == "waiting") {

                //show waiting for players screen

            }

            //if there is someone already waiting to play
            else {
                //start game
                //connectToPeer(response[1]);

            }
        }

        public function onFault(response:Object):void {
            for (var i:* in response) {
                trace(response[i]);
            }
        }
		
		
		
		
		
		
		
	}
}