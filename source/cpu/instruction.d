module cpu.instruction;

import cpu.processor;
import cpu.operation;

import std.array;
import std.algorithm;
import std.conv;

struct Instruction {
	OpCommand op_cmd;
	Command val1;
	Command val2;
	int ptr;

	static Instruction parse(string instr) {
		auto instructions = instr.split(" ");
		auto cmd = instructions[0];

		Command value1, value2;
		if (instructions.length > 1) {
			value1 = Command(instructions[1]);
		}
		if (instructions.length > 2) {
			value2 = Command(instructions[2]);
		}
		return Instruction(to!OpCommand(cmd), value1, value2);
	}
}