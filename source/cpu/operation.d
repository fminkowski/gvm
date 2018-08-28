module cpu.operation;

import cpu.processor;
import cpu.instruction;

import memory.stack;

import std.algorithm;
import std.conv;
import util.algorithm;

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
	lt,
	gt,
	eq,
	neq,
	div_f32,
	push_i32,
	push_f32,
	pop_i32,
	pop_f32,
	put_i32,
	put_f32,
	func,
	call,
	ret,
	jmp,
	cjmp
}

struct Command {
	private {
		string _val;
		string _stack_addr_sym = "@";
		string _stack_sym = "$";
	}

	bool is_stack_addr() {
		return _val.startsWith(_stack_addr_sym);
	}

	bool is_register() {
		return Cpu.registers.canFind(_val);
	}

	int get_stack_location() {
		import std.string;
		import std.array;

		if (_val.null_or_empty) {
			return 0;
		}

		auto loc = _val[1 .. $];
		if (loc.startsWith(_stack_sym)) {
			auto expr = loc.split("-").map!(s => s.strip()).array;
			if (expr.length > 1) {
				auto offset = -(expr[1].to!int);
				return offset;
			}
			expr = loc.split("+").map!(s => s.strip()).array;
			if (expr.length > 1) {
				auto offset = (expr[1].to!int);
				return offset;
			}
			return 0;
		}
		return to!int(loc);
	}

	bool is_func() {
		return _val.startsWith(":");
	}

	@property T val(T)(){
		return to!(T)(_val);
	}
}

abstract class Operation {
	string label;
	void exec(Instruction instr);
}

class Add(T) : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	override void exec(Instruction instr)	{
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

	override void exec(Instruction instr)	{		
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

	override void exec(Instruction instr)	{
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

	override void exec(Instruction instr)	{
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

	override void exec(Instruction instr)	{
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

	override void exec(Instruction instr)	{
		auto val1 = this.cpu.get!T(instr.val1);
		auto val2 = this.cpu.get!T(instr.val2);
		auto result = val1 / val2;
		this.cpu.write(instr.val1.val!string, result);
	}
}

class LessThan : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	override void exec(Instruction instr)	{
		auto val1 = this.cpu.get!int(instr.val1);
		auto val2 = this.cpu.get!int(instr.val2);
		auto result = (val1 < val2) ? 1 : 0;
		this.cpu.write(instr.val1.val!string, result);
	}
}

class GreaterThan : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	override void exec(Instruction instr)	{
		auto val1 = this.cpu.get!int(instr.val1);
		auto val2 = this.cpu.get!int(instr.val2);
		auto result = (val1 > val2) ? 1 : 0;
		this.cpu.write(instr.val1.val!string, result);
	}
}

class Equal : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	override void exec(Instruction instr)	{
		auto val1 = this.cpu.get!int(instr.val1);
		auto val2 = this.cpu.get!int(instr.val2);

		auto result = (val1 == val2) ? 1 : 0;
		this.cpu.write(instr.val1.val!string, result);
	}
}

class NotEqual : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	override void exec(Instruction instr)	{
		auto val1 = this.cpu.get!int(instr.val1);
		auto val2 = this.cpu.get!int(instr.val2);
		auto result = (val1 != val2) ? 1 : 0;
		this.cpu.write(instr.val1.val!string, result);
	}
}

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
			auto location = instr.val1.get_stack_location();
			this.stack.write(location, val2);
		}
	}
}

class Push(T) : Operation {
	private {
		Cpu cpu;
		Stack!ubyte stack;
	}

	this(Cpu cpu, Stack!ubyte stack) {
		this.cpu = cpu;
		this.stack = stack;
	}

	override void exec(Instruction instr)	{
		T value = this.cpu.get!T(instr.val1);
		this.push!T(value);
	}

	void push(T)(T val)	{
		this.stack.push!T(val);
	}
}

class Pop(T) : Operation {
	private {
		Cpu cpu;
		Stack!ubyte stack;
	}

	this(Cpu cpu, Stack!ubyte stack) {
		this.cpu = cpu;
		this.stack = stack;
	}

	override void exec(Instruction instr) {
		auto val = this.stack.pop!T();
		this.cpu.write!T("pp", val);
	}
}

class Put(T) : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	override void exec(Instruction instr)	{
		auto val = this.cpu.get!T(instr.val1);
		import std.stdio; writeln(val);
	}	
}

class Jump : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	override void exec(Instruction instr)	{
		auto offset = instr.val1.get_stack_location();
		this.cpu.write_instr_ptr(instr.ptr + offset);
	}	
}

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

class Call : Operation {
	private {
		Cpu cpu;
		FuncDef[] func_defs;
		Jump jump;
	}

	this(Cpu cpu, Stack!ubyte stack, FuncDef[] func_defs) {
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

class Ret : Operation {
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

class FuncDef {
	string name;
	int ptr;

	this(string name, int ptr) {
		this.name = name;
		this.ptr = ptr;
	}

	override string toString() {
		return "FuncDef("~this.name~", "~this.ptr.to!string~")";
	}
}
