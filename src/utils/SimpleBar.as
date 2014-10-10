/**
 * Created by Pablo on 9/15/2014.
 */
package utils {

    import starling.display.Image;
    import starling.display.Sprite;
    import starling.textures.Texture;

    public class SimpleBar extends Sprite{

        private var _units:Array;
        private var _unitTexture:Texture;
        private var _gap:int;
        private var _totalUnits:int;
        private var _currentUnits:int;

        /** A simple bar **/
        public function SimpleBar(unitTexture:Texture, initialUnits:int, gap:int) {

            _units = new Array();
            _unitTexture = unitTexture;
            _gap = gap;
            _totalUnits = initialUnits;
            _currentUnits = _totalUnits;
            updateVisuals();

        }

        private function updateVisuals():void {

            var diff:int = _currentUnits - _units.length;
            var unitsLength:int = _units.length;

            if(diff > 0){

                for(var i:int = 0; i < diff; i ++){

                    var unit:Image = new Image(_unitTexture);
                    unit.x = (unitsLength + i) * (unit.width + _gap);
                    addChild(unit);
                    _units.push(unit);

                }
            }
            else {

                for (var i:int = 0; i < -diff; i++) {

                    var unit:Image = _units.pop();
                    unit.parent.removeChild(unit);

                }

            }

        }

        public function update(value:int):void {

            _currentUnits += value;

            updateVisuals();

        }

        public function setValue(value:String):void {

            switch(value) {

                case "full":

                    if(_currentUnits == _totalUnits) {
                        return;
                    }

                    _currentUnits = _totalUnits;

                    break;

                case "empty":
                    _currentUnits = 0;
                    break;
            }

            updateVisuals();

        }

        public function get totalUnits():int {
            return _totalUnits;
        }

        public function set totalUnits(value:int):void {
            _totalUnits = value;
        }

        public function get currentUnits():int {
            return _currentUnits;
        }

        public function writeTotalUnits():void {

            totalUnits = _currentUnits;
        }
    }





























}
