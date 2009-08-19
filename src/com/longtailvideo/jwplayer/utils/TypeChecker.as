package com.longtailvideo.jwplayer.utils {
	import flash.utils.describeType;

	public class TypeChecker {
		
		public static function getType(object:Object, property:String):String {
			return describeType(object).accessor.(@name == property).@type;
		}
		
		public static function fromString(type:String, value:String):* {
			switch(type.toLowerCase()) {
				case "uint":
					return stringToColor(value);
				case "number":
					return Number(value);
				case "Boolean":
					if (value.toLowerCase() == "true") return true;
					else if (value == "1") return true;
					else return false;
			}
			return value;
		}
		
		public static function stringToColor(value:String):uint {
			switch(value.toLowerCase()) {
				case "blue": return 0x0000FF; break;
				case "green": return 0x00FF00; break;
				case "red": return 0xFF0000; break;
				case "cyan": return 0x00FFFF; break;
				case "magenta": return 0xFF00FF; break;
				case "yellow": return 0xFFFF00; break;
				case "black": return 0x000000; break;
				case "white": return 0xFFFFFF; break;
				default:
					value = value.replace(/(#|0x)?([0-9A-F]{3,6})$/gi, "$2");
					if (value.length == 3) 
						value = value.charAt(0) + value.charAt(0) + value.charAt(1) + value.charAt(1) + value.charAt(2) + value.charAt(2);
					return uint("0x" + value);
					break;
			}
			
			return 0x000000;
		}

	}
	
}