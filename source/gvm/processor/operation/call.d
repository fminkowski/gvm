module gvm.processor.operation.call;
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

class Call : Operation {
	private {
		Cpu cpu;
		FuncDef[] func_defs;
		Jump jump;
	}

	this(Cpu cpu, FuncDef[] func_defs) {
		this.cpu = cpu;
		this.func_defs = func_defs;
		jump = new Jump(this.cpu);
	}

	override void exec(Instruction instr)	{
		auto func = this.func_defs.first!FuncDef(f => f.name == instr.val1.val!string);
		this.cpu.push_call(func, instr.ptr);

		Instruction jump_instr;
		jump_instr.ptr = func.ptr;		
		jump.exec(jump_instr);
	}	
}

@test("Call operation jumps to function definition")
unittest {
	import gvm.program;
	auto func_ptr = 42;
	auto func_name = "test_func";
	auto func_def = new FuncDef(func_name, func_ptr);

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	func_defs ~= func_def;
	auto cpu = new Cpu(stack);
	cpu.load(Program(null, func_defs));	
	auto instr = Instruction(OpCommand.call, Command(func_name), Command());
	instr.ptr = func_def.ptr;

	auto call = new Call(cpu, func_defs);
	call.exec(instr);

	auto ip = cpu.read_instr_ptr;
	areEqual(func_ptr, ip);
}