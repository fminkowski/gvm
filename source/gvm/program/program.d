module gvm.program.program;

import gvm.cpu.instruction;
import gvm.program.func_def;
import gvm.cpu.operation;

import std.file;
import std.algorithm;
import std.conv;
import std.stdio;
import std.string;
import std.array;
import std.algorithm;
import std.conv;

Program parse_file(string file_name) {
	auto i = 0;
	FuncDef[] func_defs;
	auto file_contents = readText(file_name);
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
	return Program(instructions, func_defs);
}

string[] parse_instructions(string cmds) {
	return cmds.splitter(';')
			   .map!(s => s.strip())
			   .array
			   .filter!(s => !s.startsWith("//"))
			   .array[0 .. $ - 1];
}

struct Program {
	Instruction[] instructions;
	FuncDef[] func_defs;
}
