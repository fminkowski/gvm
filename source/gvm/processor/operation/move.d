module gvm.processor.operation.move;

import gvm.processor.operation.definition;

import gvm.processor.cpu;
import gvm.processor.instruction;
import gvm.memory.stack;
import gvm.util.test;
import gvm.program;

import std.algorithm;
import std.conv;

import gvm.util.algorithm;

class Move(T) : Operation {
	private {
		Cpu cpu;
		Stack!ubyte stack;
	}

	this(Cpu cpu, Stack!ubyte stack) {
		this.cpu = cpu;
		this.stack = stack;
	}

	override void exec(Instruction instr) {
		T val2 = this.cpu.get!T(instr.val2);

		if (instr.val1.is_register()) {
			this.cpu.write(instr.val1.val!string, val2);
		} else {
			auto location = instr.val1.offset;
			this.stack.write(location, val2);
		}
	}
}

@test("Move operation moves value to register")
unittest {
	import gvm.program;
	auto val1 = 3;
	auto register_name = "r1";

	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	cpu.load(Program());
	auto instr = Instruction(OpCommand.mov_i32, Command(register_name), Command(val1.to!string));

	auto move = new Move!int(cpu, stack);
	move.exec(instr);

	auto register = cpu.get(register_name);
	areEqual(val1, register.val!int);
}

@test("Move operation moves value to stack")
unittest {
	import gvm.program;
	auto val1 = 3;
	auto stack_location = "@0";

	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	cpu.load(Program());
	auto instr = Instruction(OpCommand.mov_i32, Command(stack_location), Command(val1.to!string));

	auto move = new Move!int(cpu, stack);
	move.exec(instr);

	auto stack_value = cpu.get!int(Command(stack_location));
	areEqual(val1, stack_value);
}