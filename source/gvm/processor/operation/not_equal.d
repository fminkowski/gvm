module gvm.processor.operation.not_equal;

import gvm.processor.operation.definition;

import gvm.processor.cpu;
import gvm.processor.instruction;
import gvm.memory.stack;
import gvm.util.test;
import gvm.program;

import std.algorithm;
import std.conv;

import gvm.util.algorithm;

class NotEqual : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	override void exec(Instruction instr)	{
		auto val1 = this.cpu.get!int(instr.val1);
		auto val2 = this.cpu.get!int(instr.val2);
		auto result = (val1 != val2) ? 1 : 0;
		this.cpu.write(instr.val1.val!string, result);
	}
}

@test("NotEqual operation checks if values are not equal and sets it in register")
unittest {
	import gvm.program;
	auto val1 = 3;
	auto val2 = 2;
	auto expected_result = 1;

	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	cpu.load(Program());
	cpu.write("r0", val1);
	auto instr = Instruction(OpCommand.neq, Command("r0"), Command(val2.to!string));

	auto not_equal = new NotEqual(cpu);
	not_equal.exec(instr);

	auto register = cpu.get("r0");
	areEqual(expected_result, register.val!int);
}