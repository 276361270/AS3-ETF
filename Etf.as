package {

import flash.display.Sprite;
import flash.utils.ByteArray;

public class Etf extends Sprite {

    public function Etf() {
    }

    public static function decode(ba:ByteArray):Object {
        if (ba.readUnsignedByte() != 131) return({});

        return(decode_unit(ba));
    }

    private static function decode_unit(unit:ByteArray):Object {
        var o:Object = {};
        var a:Array = [];
        var tag:int = unit.readUnsignedByte();

        if (tag == 97) {
            o = unit.readUnsignedByte();
        } else if (tag == 98) {
            o = unit.readInt();
        } else if (tag == 100) {
            var atom_length:int = unit.readUnsignedShort();
            while (atom_length > 0) {
                a.push(String.fromCharCode(unit.readUnsignedByte()));
                atom_length--;
            }
            o = a.join("");
        } else if (tag == 107) {
            o = [];
            var array_107_length:int = unit.readShort();
            while (array_107_length > 0) {
                o.push(unit.readUnsignedByte());
                array_107_length--;
            }
        } else if (tag == 108) {
            o = [];
            var array_108_length:int = unit.readInt();
            while (array_108_length > 0) {
                o.push(decode_unit(unit));
                array_108_length--;
            }
            unit.readUnsignedByte();
        } else if (tag == 109) {
            var binary_length:int = unit.readUnsignedInt();
            o = unit.readMultiByte(binary_length, "utf-8");
        } else if (tag == 116) {
            var object_length:int = unit.readUnsignedInt();
            while (object_length > 0) {
                var key:Object = decode_unit(unit);
                var value:Object = decode_unit(unit);
                o[key] = value;
                object_length--;
            }
        }

        return(o);
    }

    public static function encode(o:Object):ByteArray {
        var ba:ByteArray = new ByteArray();
        ba.writeByte(131);
        ba.writeBytes(encode_unit(o));
        ba.position = 0;

        return(ba);
    }

    private static function encode_unit(unit:Object):ByteArray {
        var ba:ByteArray = new ByteArray();

        if (unit is int) {
            ba.writeByte(98);
            ba.writeInt(unit as int);
        } else if (unit is Array) {
            ba.writeByte(108);
            ba.writeInt(unit.length);
            for each(var array_unit:Object in unit) {
                ba.writeBytes(encode_unit(array_unit));
            }
            ba.writeByte(106);
        } else if (unit is String) {
            ba.writeByte(109);
            var tmp:ByteArray = new ByteArray();
            tmp.writeUTFBytes(unit as String);
            ba.writeUnsignedInt(tmp.length);
            ba.writeUTFBytes(unit as String);
        } else if (unit is ByteArray){
            ba.writeBytes(unit as ByteArray);
        } else if (unit is Object) {
            ba.writeByte(116);
            ba.position = 5;

            var object_length:int = 0;
            for (var key:String in unit) {
                ba.writeBytes(encode_unit(key));
                ba.writeBytes(encode_unit(unit[key]));
                object_length += 1;
            }

            ba.position = 1;
            ba.writeInt(object_length);
        }

        return(ba);
    }

    public static function string_to_atom(atom:String):ByteArray{
        var tmp:ByteArray = new ByteArray();
        tmp.writeUTFBytes(atom);

        var ba:ByteArray = new ByteArray();
        ba.writeByte(100);
        ba.writeShort(tmp.length);
        ba.writeBytes(tmp);
        return(ba);
    }
}
}
