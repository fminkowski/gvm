module gvm.processor.operation.conditional_jump;
import gvm.processor.operation.definition;
import gvm.processor.operation.jump;

import gvm.processor.cpu;
import gvm.processor.instruction;
import gvm.memory.stack;
import gvm.util.test;
import gvm.program;

import std.algorithm;
import std.conv;

import gvm.util.algorithm;

class ConditionalJump : Operation {
	private {
		Cpu cpu;
		Jump jump;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
		this.jump = new Jump(cpu);
	}

	override void exec(Instruction instr)	{
		auto val1 = this.cpu.get("cn").val!int;
		auto should_jump = (val1 != 0);
		if (should_jump) {
			jump.exec(instr);
		}
	}
}

@test("Conditional jump operation updates instruction pointer if conditional register is set")
unittest {
	import gvm.program;
	auto func_ptr = 42;
	auto func_def = new FuncDef("function", func_ptr);

	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	cpu.load(Program());
	cpu.write("cn", 1);

	auto instr = Instruction(OpCommand.cjmp, Command(), Command());
	instr.ptr = func_def.ptr;

	auto conditional_jump = new ConditionalJump(cpu);
	conditional_jump.exec(instr);

	auto ip = cpu.read_instr_ptr;
	areEqual(func_ptr, ip);
}

@test("Conditional jump operation does not update instruction pointer if conditional register is not set")
unittest {
	import gvm.program;
	auto expected_func_ptr = 0;
	auto func_ptr = 42;
	auto func_def = new FuncDef("function", func_ptr);

	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	cpu.load(Program());
	cpu.write("cn", 0);
	
	auto instr = Instruction(OpCommand.cjmp, Command(), Command());
	instr.ptr = func_def.ptr;

	auto conditional_jump = new ConditionalJump(cpu);
	conditional_jump.exec(instr);

	auto ip = cpu.read_instr_ptr;
	areEqual(expected_func_ptr, ip);
}