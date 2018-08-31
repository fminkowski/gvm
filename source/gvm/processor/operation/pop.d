module gvm.processor.operation.pop;

import gvm.processor.operation.definition;

import gvm.processor.cpu;
import gvm.processor.instruction;
import gvm.memory.stack;
import gvm.util.test;
import gvm.program;

import std.algorithm;
import std.conv;

import gvm.util.algorithm;

class Pop(T) : Operation {
	private {
		Cpu cpu;
		Stack!ubyte stack;
	}

	this(Cpu cpu, Stack!ubyte stack) {
		this.cpu = cpu;
		this.stack = stack;
	}

	override void exec(Instruction instr) {
		auto val = this.stack.pop!T();
		this.cpu.write!T("pp", val);
	}
}

@test("Pop operation pops value from stack")
unittest {
	import gvm.program;
	auto val1 = 6;
	auto val2 = 7;

	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	cpu.load(Program());
	stack.push!int(val1);
	stack.push!int(val2);
	auto instr = Instruction(OpCommand.pop_i32, Command(val1.to!string), Command());

	auto stack_value = stack.top!int;
	areEqual(val2, stack_value);

	auto pop = new Pop!int(cpu, stack);
	pop.exec(instr);

	stack_value = stack.top!int;
	areEqual(val1, stack_value);
}