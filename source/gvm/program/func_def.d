module gvm.program.func_def;
import std.conv;

class FuncDef {
	string name;
	int ptr;

	this(string name, int ptr) {
		this.name = name;
		this.ptr = ptr;
	}

	override string toString() {
		return "FuncDef("~this.name~", "~this.ptr.to!string~")";
	}
}
