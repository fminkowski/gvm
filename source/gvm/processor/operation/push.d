module gvm.processor.operation.push;

import gvm.processor.operation.definition;

import gvm.processor.cpu;
import gvm.processor.instruction;
import gvm.memory.stack;
import gvm.util.test;
import gvm.program;

import std.algorithm;
import std.conv;

import gvm.util.algorithm;

class Push(T) : Operation {
	private {
		Cpu cpu;
		Stack!ubyte stack;
	}

	this(Cpu cpu, Stack!ubyte stack) {
		this.cpu = cpu;
		this.stack = stack;
	}

	override void exec(Instruction instr)	{
		T value = this.cpu.get!T(instr.val1);
		this.push!T(value);
	}

	void push(T)(T val)	{
		this.stack.push!T(val);
	}
}

@test("Push operation pushes value onto stack")
unittest {
	import gvm.program;
	auto val1 = 6;

	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack,);
	cpu.load(Program());
	auto instr = Instruction(OpCommand.push_i32, Command(val1.to!string), Command());

	auto push = new Push!int(cpu, stack);
	push.exec(instr);

	auto stack_value = stack.top!int;
	areEqual(val1, stack_value);
}