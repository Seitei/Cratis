/**
 * Created by Pablo on 11/5/2014.
 */
package entities {
import flash.net.NetGroup;

public interface iGame {

    function addPlayer(value:Player):Boolean;
    function get gameID():String;
    function get matchID():int;

}
}
