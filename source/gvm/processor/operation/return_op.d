module gvm.processor.operation.return_op;

import gvm.processor.operation.definition;
import gvm.processor.operation.jump;
import gvm.processor.operation.pop;

import gvm.processor.cpu;
import gvm.processor.instruction;
import gvm.memory.stack;
import gvm.util.test;
import gvm.program;

import std.algorithm;
import std.conv;

import gvm.util.algorithm;


class Return : Operation {
	private {
		Cpu cpu;
		Stack!ubyte stack;
		Jump jump;
		Pop!ubyte pop;
	}

	this(Cpu cpu, Stack!ubyte stack) {
		this.cpu = cpu;
		this.stack = stack;
		jump = new Jump(this.cpu);
		pop = new Pop!ubyte(this.cpu, stack);
	}

	override void exec(Instruction instr)	{
		auto ret_addr = this.stack.top!int;
		this.cpu.pop_call();
		this.cpu.write_instr_ptr(ret_addr);
	}	
}

@test("Return operation writes instruction pointer to return location")
unittest {
	import gvm.program;
	auto expected_return_addr = 42;
	auto func_def = new FuncDef("test_func", 0);

	auto stack = new Stack!ubyte();
	stack.push(expected_return_addr);

	FuncDef[] func_defs;
	func_defs ~= func_def;
	auto cpu = new Cpu(stack);
	cpu.load(Program(null, func_defs));
	cpu.push_call(func_def, expected_return_addr);
	auto instr = Instruction(OpCommand.call, Command(), Command());

	auto ret = new Return(cpu, stack);
	ret.exec(instr);

	auto ip = cpu.read_instr_ptr;
	areEqual(expected_return_addr, ip);
}
