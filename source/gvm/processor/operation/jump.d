module gvm.processor.operation.jump;

import gvm.processor.operation.definition;

import gvm.processor.cpu;
import gvm.processor.instruction;
import gvm.memory.stack;
import gvm.util.test;
import gvm.program;

import std.algorithm;
import std.conv;

import gvm.util.algorithm;

class Jump : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	override void exec(Instruction instr)	{
		auto offset = instr.val1.offset;
		this.cpu.write_instr_ptr(instr.ptr + offset);
	}	
}

@test("Jump operation updates instruction pointer to new instruction")
unittest {
	import gvm.program;
	auto offset = 3;
	auto offset_str = offset.to!string;
	auto offset_cmd = "@$+" ~ offset_str;

	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	cpu.load(Program());
	auto instr = Instruction(OpCommand.jmp, Command(offset_cmd), Command());

	auto jump = new Jump(cpu);
	jump.exec(instr);

	auto ip = cpu.read_instr_ptr;
	areEqual(offset, ip);
}

@test("Jump operation updates instruction pointer to new pointer address")
unittest {
	import gvm.program;
	auto func_ptr = 42;
	auto func_def = new FuncDef("function", func_ptr);

	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	cpu.load(Program());
	auto instr = Instruction(OpCommand.jmp, Command(), Command());
	instr.ptr = func_def.ptr;

	auto jump = new Jump(cpu);
	jump.exec(instr);

	auto ip = cpu.read_instr_ptr;
	areEqual(func_ptr, ip);
}