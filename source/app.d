import std.stdio;
import std.file;
import std.string;
import std.array;
import std.algorithm;
import std.conv;

import cpu.processor;
import cpu.operation;
import cpu.instruction;
import memory.stack;

string[] parse_instructions(string cmds) {
	return cmds.splitter(';')
			   .map!(s => s.strip())
			   .filter!(s => !s.startsWith("//"))
			   .array[0 .. $ - 1];
}
 
void main(string[] args) {
	if (args.length < 2) {
		throw new Exception("File not specified.");
	}
	
	auto file_contents = readText(args[1]);

	auto instructions = file_contents
						.parse_instructions()
						.map!(c => Instruction.parse(c))
						.array;

	auto stack = new Stack();
	auto cpu = new Cpu(stack);

	cpu.load(instructions);
	cpu.run();
	
	writeln(cpu.get("r0").val!float);
	writeln(cpu.get("r3").val!int);
}