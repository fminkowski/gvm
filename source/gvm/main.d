module gvm.gvm;
import std.stdio;
import std.file;
import std.string;
import std.array;
import std.algorithm;
import std.conv;

import gvm.cpu.processor;
import gvm.cpu.operation;
import gvm.cpu.instruction;
import gvm.memory.stack;

string[] parse_instructions(string cmds) {
	return cmds.splitter(';')
			   .map!(s => s.strip())
			   .array
			   .filter!(s => !s.startsWith("//"))
			   .array[0 .. $ - 1];
}

void run(string[] args) {
	auto file_contents = readText(args[1]);

	auto i = 0;
	FuncDef[] func_defs;

	auto instructions = file_contents
						.parse_instructions()
						.map!(delegate(string instr) {
							auto instruction = Instruction.parse(instr);
							instruction.ptr = i++;
							if (instruction.op_cmd == OpCommand.func) {
								func_defs ~= new FuncDef(instruction.val1.val!string, instruction.ptr);
							}
							return instruction;
						})
						.array;

	auto stack = new Stack!ubyte();
	auto call_stack = new Stack!FuncDef();
	auto cpu = new Cpu(stack, call_stack, func_defs);

	cpu.load(instructions);
	cpu.run();	
}