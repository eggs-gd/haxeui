package haxe.ui.toolkit.style;

import flash.Lib;

class StyleParser {
	public static function fromString(styleString:String):Styles {
		if (styleString == null || styleString.length == 0) {
			return new Styles();
		}
		
		var styles = new Styles();

		var n1:Int = -1;
		var n2:Int = styleString.indexOf("{", 0);
		while (n2 > -1) {
			var n3:Int = styleString.indexOf("}", n2);
			
			var styleName:String = StringTools.trim(styleString.substr(n1 + 1, n2 - n1 - 1));
			var styleData:String = styleString.substr(n2 + 1, n3 - n2 - 1);
			var style:Dynamic = { };
			var props:Array<String> = styleData.split(";");
			for (prop in props) {
				prop = StringTools.trim(prop);
				if (prop != null && prop.length > 0) {
					var temp:Array<String> = prop.split(":");
					var propName = StringTools.trim(temp[0]);
					var propValue = StringTools.trim(temp[1]);
					if (temp.length == 3) {
						propValue += ":" + StringTools.trim(temp[2]);
					}
					
					if (propName == "width" && propValue.indexOf("%") != -1) { // special case for width
						propName = "percentWidth";
						propValue = propValue.substr(0, propValue.length - 1);
					}
					if (propName == "height" && propValue.indexOf("%") != -1) { // special case for height
						propName = "percentHeight";
						propValue = propValue.substr(0, propValue.length - 1);
					}
					
					if (propValue.indexOf(",") != -1 || !StringTools.startsWith(propValue, "#") && Std.string(Std.parseFloat(propValue)) == Std.string(Math.NaN)) { // TODO: must be a bad way of doing this
						if (propValue == "true" || propValue == "false") {
							Reflect.setField(style, propName, propValue == "true");
						} else {
							Reflect.setField(style, propName, propValue);
						}
					} else {
						if (StringTools.startsWith(propValue, "#")) { // lazyness
							propValue = "0x" + propValue.substr(1, propValue.length - 1);
						}
						if (StringTools.startsWith(propValue, "0x")) {
							Reflect.setField(style, propName, Std.parseInt(propValue));
						} else {
							Reflect.setField(style, propName, Std.parseFloat(propValue));
						}
					}
				}
			}
			
			if (Reflect.fields(style).length > 0) {
				if (styleName.indexOf(",") == -1) {
					styles.addStyle(styleName, style);
				} else {
					var arr:Array<String> = styleName.split(",");
					for (s in arr) {
						s = StringTools.trim(s);
						styles.addStyle(s, style);
					}
				}
			}
			
			n1 = n3;
			n2 = styleString.indexOf("{", n1);
		}
		
		return styles;
	}
}