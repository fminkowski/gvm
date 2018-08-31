module gvm.processor.operation.divide;

import gvm.processor.operation.definition;

import gvm.processor.cpu;
import gvm.processor.instruction;
import gvm.memory.stack;
import gvm.util.test;
import gvm.program;

import std.algorithm;
import std.conv;

import gvm.util.algorithm;

class Divide(T) : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	override void exec(Instruction instr)	{
		auto val1 = this.cpu.get!T(instr.val1);
		auto val2 = this.cpu.get!T(instr.val2);
		auto result = val1 / val2;
		this.cpu.write(instr.val1.val!string, result);
	}
}

@test("Divide operation divides values and sets result in register")
unittest {
	import gvm.program;
	auto val1 = 5;
	auto val2 = 2;
	auto expected_result = val1 / val2;

	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	cpu.load(Program());
	cpu.write("r0", val1);
	auto instr = Instruction(OpCommand.div_f32, Command("r0"), Command(val2.to!string));

	auto divide = new Divide!float(cpu);
	divide.exec(instr);

	auto register = cpu.get("r0");
	areEqual(expected_result, register.val!int);
}
