module cpu.operation;

import cpu.processor;
import cpu.instruction;

import memory.stack;

import std.algorithm;
import std.conv;

enum OpCommand {
	none,
	mov_i32,
	mov_f32,
	add_i32,
	add_f32,
	inc_i32,
	sub_i32,
	sub_f32,
	dec_i32,
	mul_i32,
	mul_f32,
	div_f32,
	push_i32,
	push_f32,
	pop_i32,
	pop_f32
}

struct Command {
	private {
		string _val;
	}

	bool is_stack_addr() {
		return _val.startsWith("$");
	}

	bool is_register() {
		return Cpu.registers.canFind(_val);
	}

	int get_stack_location() {
		return to!int(_val[1 .. $]);
	}

	@property T val(T)(){
		return to!(T)(_val);
	}
}

interface Operation {
	void exec(Instruction instr);
}

class Add(T) : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	void exec(Instruction instr)	{
		auto val1 = this.cpu.get!T(instr.val1);
		auto val2 = this.cpu.get!T(instr.val2);
		auto result = val1 + val2;
		this.cpu.write(instr.val1.val!string, result);
	}
}

class Increment(T) : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	void exec(Instruction instr)	{
		auto val1 = this.cpu.get!T(instr.val1);
		auto result = ++val1;
		this.cpu.write(instr.val1.val!string, result);
	}
}

class Decrement(T) : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	void exec(Instruction instr)	{
		auto val1 = this.cpu.get!T(instr.val1);
		auto result = --val1;
		this.cpu.write(instr.val1.val!string, result);
	}
}

class Subtract(T) : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	void exec(Instruction instr)	{
		auto val1 = this.cpu.get!T(instr.val1);
		auto val2 = this.cpu.get!T(instr.val2);
		auto result = val1 - val2;
		this.cpu.write(instr.val1.val!string, result);
	}
}

class Multiply(T) : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	void exec(Instruction instr)	{
		auto val1 = this.cpu.get!T(instr.val1);
		auto val2 = this.cpu.get!T(instr.val2);
		auto result = val1 * val2;
		this.cpu.write(instr.val1.val!string, result);
	}
}

class Divide(T) : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	void exec(Instruction instr)	{
		auto val1 = this.cpu.get!T(instr.val1);
		auto val2 = this.cpu.get!T(instr.val2);
		auto result = val1 / val2;
		this.cpu.write(instr.val1.val!string, result);
	}
}

class Move(T) : Operation {
	private {
		Cpu cpu;
		Stack stack;
	}

	this(Cpu cpu, Stack stack) {
		this.cpu = cpu;
		this.stack = stack;
	}

	void exec(Instruction instr) {
		T val2 = this.cpu.get!T(instr.val2);

		if (instr.val1.is_register()) {
			this.cpu.write(instr.val1.val!string, val2);
		} else {
			auto location = instr.val1.get_stack_location();
			this.stack.write(location, val2);
		}
	}
}

class Push(T) : Operation {
	private {
		Cpu cpu;
		Stack stack;
	}

	this(Cpu cpu, Stack stack) {
		this.cpu = cpu;
		this.stack = stack;
	}

	void exec(Instruction instr)	{
		T value = this.cpu.get!T(instr.val1);
		this.stack.push!T(value);
	}
}

class Pop(T) : Operation {
	private {
		Cpu cpu;
		Stack stack;
	}

	this(Cpu cpu, Stack stack) {
		this.cpu = cpu;
		this.stack = stack;
	}

	void exec(Instruction instr)	{
		auto value = this.stack.pop!T();
		this.cpu.write("r10", value);
	}
}