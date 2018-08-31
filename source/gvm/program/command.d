module gvm.program.command;
import gvm.util.test;
import gvm.util.algorithm;
import gvm.processor.cpu;

import std.conv;
import std.string;
import std.algorithm;

struct Command {
	private {
		string _val;
		string _stack_addr_sym = "@";
		string _location_sym = "$";
	}

	bool is_stack_addr() {
		return _val.startsWith(_stack_addr_sym) && offset <= 0;
	}

	bool is_register() {
		return Cpu.registers.canFind(_val);
	}

	@property int offset() {
		import std.string;
		import std.array;

		if (_val.null_or_empty || _val.length == 1) {
			return 0;
		}

		auto loc = _val[1 .. $];
		if (loc.startsWith(_location_sym)) {
			auto expr = loc.split("-").map!(s => s.strip()).array;
			int offset;
			if (expr.length > 1) {
				offset = -(expr[1].to!int);
			}
			expr = loc.split("+").map!(s => s.strip()).array;
			if (expr.length > 1) {
				offset = (expr[1].to!int);
			}
			return offset;
		}
		return to!int(loc);
	}

	@property T val(T)(){
		return to!(T)(_val);
	}
}

@test("get offset returns 0 for empty value")
unittest {
	auto cmd = Command();
	auto offset = cmd.offset;
	areEqual(0, offset);
}

@test("get offset returns 0 for only current location symbol")
unittest {
	auto cmd = Command("$");
	auto offset = cmd.offset;
	areEqual(0, offset);
}

@test("get offset returns correct value for negative offset")
unittest {
	auto cmd = Command("@$-2");
	auto offset = cmd.offset;
	areEqual(-2, offset);
}

@test("get offset returns correct value for positive offset")
unittest {
	auto cmd = Command("@$+2");
	auto offset = cmd.offset;
	areEqual(2, offset);
}

@test("Check if command is a stack value")
unittest {
	auto cmd1 = Command("@0");
	isTrue(cmd1.is_stack_addr);

	auto cmd2 = Command("r0");
	isFalse(cmd2.is_stack_addr);
}

@test("Check if command is a register value")
unittest {
	auto cmd1 = Command("r0");
	isTrue(cmd1.is_register);

	auto cmd2 = Command("@0");
	isFalse(cmd2.is_register);
}
