module gvm.processor.operation.multiply;

import gvm.processor.operation.definition;

import gvm.processor.cpu;
import gvm.processor.instruction;
import gvm.memory.stack;
import gvm.util.test;
import gvm.program;

import std.algorithm;
import std.conv;

import gvm.util.algorithm;

class Multiply(T) : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	override void exec(Instruction instr)	{
		auto val1 = this.cpu.get!T(instr.val1);
		auto val2 = this.cpu.get!T(instr.val2);
		auto result = val1 * val2;
		this.cpu.write(instr.val1.val!string, result);
	}
}

@test("Multiply operation multiplies values and sets result in register")
unittest {
	import gvm.program;
	auto val1 = 5;
	auto val2 = 2;
	auto expected_result = val1 * val2;

	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	cpu.load(Program());
	cpu.write("r0", val1);
	auto instr = Instruction(OpCommand.mul_i32, Command("r0"), Command(val2.to!string));

	auto multiply = new Multiply!int(cpu);
	multiply.exec(instr);

	auto register = cpu.get("r0");
	areEqual(expected_result, register.val!int);
}
