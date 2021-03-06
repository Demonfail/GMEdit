package gml;
using tools.NativeString;

/**
 * ...
 * @author YellowAfterlife
 */
class GmlFuncDoc {
	
	/** "func(" */
	public var pre:String;
	
	/** "): doc" */
	public var post:String;
	
	/** array of argument names */
	public var args:Array<String>;
	
	/** whether to show "..." in the end of argument list */
	public var rest:Bool;
	
	/** Whether this is an incomplete/accumulating doc */
	public var acc:Bool = false;
	
	public function new(pre:String, post:String, args:Array<String>, rest:Bool) {
		this.pre = pre;
		this.post = post;
		this.args = args;
		this.rest = rest;
	}
	
	public function getAcText() {
		return pre + "(" + args.join(", ") + ")";
	}
	
	public static function parse(s:String, ?out:GmlFuncDoc) {
		var p0 = s.indexOf("(");
		var p1 = s.indexOf(")", p0);
		var pre:String, post:String, args:Array<String>, rest:Bool;
		if (p0 >= 0 && p1 >= 0) {
			var sw = s.substring(p0 + 1, p1).trimBoth();
			pre = s.substring(0, p0 + 1);
			post = s.substring(p1);
			if (sw != "") {
				args = sw.splitReg(js.Syntax.code("/,\\s*/g"));
			} else args = [];
			rest = sw.indexOf("...") >= 0;
		} else {
			pre = s;
			post = "";
			args = [];
			rest = false;
		}
		if (out != null) {
			out.pre = pre;
			out.post = post;
			out.args = args;
			out.rest = rest;
			return out;
		} else return new GmlFuncDoc(pre, post, args, rest);
	}
}
