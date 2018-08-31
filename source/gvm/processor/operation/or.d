module gvm.processor.operation.or;

import gvm.processor.operation.definition;

import gvm.processor.cpu;
import gvm.processor.instruction;
import gvm.memory.stack;
import gvm.util.test;
import gvm.program;

import std.algorithm;
import std.conv;

import gvm.util.algorithm;

class Or : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	override void exec(Instruction instr)	{
		auto val1 = this.cpu.get!int(instr.val1);
		auto val2 = this.cpu.get!int(instr.val2);

		auto result = (val1 | val2);
		this.cpu.write(instr.val1.val!string, result);
	}
}

@test("Or operation does bit wise or")
unittest {
	import gvm.program;
	auto val1 = 3;
	auto val2 = 6;
	auto expected_result = 7;

	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	cpu.load(Program());
	cpu.write("r0", val1);
	auto instr = Instruction(OpCommand.gt, Command("r0"), Command(val2.to!string));

	auto or = new Or(cpu);
	or.exec(instr);

	auto register = cpu.get("r0");
	areEqual(expected_result, register.val!int);
}