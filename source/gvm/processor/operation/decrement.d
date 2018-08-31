module gvm.processor.operation.decrement;

import gvm.processor.operation.definition;

import gvm.processor.cpu;
import gvm.processor.instruction;
import gvm.memory.stack;
import gvm.util.test;
import gvm.program;

import std.algorithm;
import std.conv;

import gvm.util.algorithm;

class Decrement(T) : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	override void exec(Instruction instr)	{
		auto val1 = this.cpu.get!T(instr.val1);
		auto result = --val1;
		this.cpu.write(instr.val1.val!string, result);
	}
}

@test("Decrement operation decreases value by 1 and sets result in register")
unittest {
	import gvm.program;
	auto val1 = 2;
	auto expected_result = val1 - 1;

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack);
	cpu.load(Program());
	cpu.write("r0", val1);
	auto instr = Instruction(OpCommand.dec_i32, Command("r0"), Command(val1.to!string));

	auto decrement = new Decrement!int(cpu);
	decrement.exec(instr);

	auto register = cpu.get("r0");
	areEqual(expected_result, register.val!int);
}
