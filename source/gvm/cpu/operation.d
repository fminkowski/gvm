module gvm.cpu.operation;

import gvm.cpu.processor;
import gvm.cpu.instruction;
import gvm.memory.stack;
import gvm.util.test;

import std.algorithm;
import std.conv;
import gvm.util.algorithm;

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
		string _location_sym = "$";
	}

	bool is_stack_addr() {
		return _val.startsWith(_stack_addr_sym) && offset <= 0;
	}

	bool is_register() {
		return Cpu.registers.canFind(_val);
	}

	@property int offset() {
		import std.string;
		import std.array;

		if (_val.null_or_empty || _val.length == 1) {
			return 0;
		}

		auto loc = _val[1 .. $];
		if (loc.startsWith(_location_sym)) {
			auto expr = loc.split("-").map!(s => s.strip()).array;
			int offset;
			if (expr.length > 1) {
				offset = -(expr[1].to!int);
			}
			expr = loc.split("+").map!(s => s.strip()).array;
			if (expr.length > 1) {
				offset = (expr[1].to!int);
			}
			return offset;
		}
		return to!int(loc);
	}

	@property T val(T)(){
		return to!(T)(_val);
	}
}

@test("get offset returns 0 for empty value")
unittest {
	auto cmd = Command();
	auto offset = cmd.offset;
	areEqual(0, offset);
}

@test("get offset returns 0 for only current location symbol")
unittest {
	auto cmd = Command("$");
	auto offset = cmd.offset;
	areEqual(0, offset);
}

@test("get offset returns correct value for negative offset")
unittest {
	auto cmd = Command("@$-2");
	auto offset = cmd.offset;
	areEqual(-2, offset);
}

@test("get offset returns correct value for positive offset")
unittest {
	auto cmd = Command("@$+2");
	auto offset = cmd.offset;
	areEqual(2, offset);
}

@test("Check if command is a stack value")
unittest {
	auto cmd1 = Command("@0");
	isTrue(cmd1.is_stack_addr);

	auto cmd2 = Command("r0");
	isFalse(cmd2.is_stack_addr);
}

@test("Check if command is a register value")
unittest {
	auto cmd1 = Command("r0");
	isTrue(cmd1.is_register);

	auto cmd2 = Command("@0");
	isFalse(cmd2.is_register);
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

@test("Add operation adds value and sets result in register")
unittest {
	auto val1 = 2;
	auto val2 = 3;
	auto expected_result = val1 + val2;

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	cpu.write("r0", val1);
	auto instr = Instruction(OpCommand.add_i32, Command("r0"), Command(val2.to!string));

	auto add = new Add!int(cpu);
	add.exec(instr);

	auto register = cpu.get("r0");
	areEqual(expected_result, register.val!int);
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

@test("Increment operation increases value by 1 and sets result in register")
unittest {
	auto val1 = 2;
	auto expected_result = val1 + 1;

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	cpu.write("r0", val1);
	auto instr = Instruction(OpCommand.inc_i32, Command("r0"), Command(val1.to!string));

	auto increment = new Increment!int(cpu);
	increment.exec(instr);

	auto register = cpu.get("r0");
	areEqual(expected_result, register.val!int);
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

@test("Decrement operation decreases value by 1 and sets result in register")
unittest {
	auto val1 = 2;
	auto expected_result = val1 - 1;

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	cpu.write("r0", val1);
	auto instr = Instruction(OpCommand.dec_i32, Command("r0"), Command(val1.to!string));

	auto decrement = new Decrement!int(cpu);
	decrement.exec(instr);

	auto register = cpu.get("r0");
	areEqual(expected_result, register.val!int);
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

@test("Subtract operation subtracts values and sets result in register")
unittest {
	auto val1 = 5;
	auto val2 = 2;
	auto expected_result = val1 - val2;

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	cpu.write("r0", val1);
	auto instr = Instruction(OpCommand.sub_i32, Command("r0"), Command(val2.to!string));

	auto subtract = new Subtract!int(cpu);
	subtract.exec(instr);

	auto register = cpu.get("r0");
	areEqual(expected_result, register.val!int);
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

@test("Multiply operation multiplies values and sets result in register")
unittest {
	auto val1 = 5;
	auto val2 = 2;
	auto expected_result = val1 * val2;

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	cpu.write("r0", val1);
	auto instr = Instruction(OpCommand.mul_i32, Command("r0"), Command(val2.to!string));

	auto multiply = new Multiply!int(cpu);
	multiply.exec(instr);

	auto register = cpu.get("r0");
	areEqual(expected_result, register.val!int);
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

@test("Divide operation divides values and sets result in register")
unittest {
	auto val1 = 5;
	auto val2 = 2;
	auto expected_result = val1 / val2;

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	cpu.write("r0", val1);
	auto instr = Instruction(OpCommand.div_f32, Command("r0"), Command(val2.to!string));

	auto divide = new Divide!float(cpu);
	divide.exec(instr);

	auto register = cpu.get("r0");
	areEqual(expected_result, register.val!int);
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

@test("LessThan operation checks if value is less than other value and sets it in register")
unittest {
	auto val1 = 1;
	auto val2 = 2;
	auto expected_result = 1;

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	cpu.write("r0", val1);
	auto instr = Instruction(OpCommand.lt, Command("r0"), Command(val2.to!string));

	auto less_than = new LessThan(cpu);
	less_than.exec(instr);

	auto register = cpu.get("r0");
	areEqual(expected_result, register.val!int);
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

@test("GreaterThan operation checks if value is greater than other value and sets it in register")
unittest {
	auto val1 = 3;
	auto val2 = 2;
	auto expected_result = 1;

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	cpu.write("r0", val1);
	auto instr = Instruction(OpCommand.gt, Command("r0"), Command(val2.to!string));

	auto greater_than = new GreaterThan(cpu);
	greater_than.exec(instr);

	auto register = cpu.get("r0");
	areEqual(expected_result, register.val!int);
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

@test("Equal operation checks if values are equal and sets it in register")
unittest {
	auto val1 = 2;
	auto val2 = 2;
	auto expected_result = 1;

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	cpu.write("r0", val1);
	auto instr = Instruction(OpCommand.eq, Command("r0"), Command(val2.to!string));

	auto equal = new Equal(cpu);
	equal.exec(instr);

	auto register = cpu.get("r0");
	areEqual(expected_result, register.val!int);
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

@test("NotEqual operation checks if values are not equal and sets it in register")
unittest {
	auto val1 = 3;
	auto val2 = 2;
	auto expected_result = 1;

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	cpu.write("r0", val1);
	auto instr = Instruction(OpCommand.neq, Command("r0"), Command(val2.to!string));

	auto not_equal = new NotEqual(cpu);
	not_equal.exec(instr);

	auto register = cpu.get("r0");
	areEqual(expected_result, register.val!int);
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
			auto location = instr.val1.offset;
			this.stack.write(location, val2);
		}
	}
}

@test("Move operation moves value to register")
unittest {
	auto val1 = 3;
	auto register_name = "r1";

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	auto instr = Instruction(OpCommand.mov_i32, Command(register_name), Command(val1.to!string));

	auto move = new Move!int(cpu, stack);
	move.exec(instr);

	auto register = cpu.get(register_name);
	areEqual(val1, register.val!int);
}

@test("Move operation moves value to stack")
unittest {
	auto val1 = 3;
	auto stack_location = "@0";

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	auto instr = Instruction(OpCommand.mov_i32, Command(stack_location), Command(val1.to!string));

	auto move = new Move!int(cpu, stack);
	move.exec(instr);

	auto stack_value = cpu.get!int(Command(stack_location));
	areEqual(val1, stack_value);
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

@test("Push operation pushes value onto stack")
unittest {
	auto val1 = 6;

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	auto instr = Instruction(OpCommand.push_i32, Command(val1.to!string), Command());

	auto push = new Push!int(cpu, stack);
	push.exec(instr);

	auto stack_value = stack.top!int;
	areEqual(val1, stack_value);
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

@test("Pop operation pops value from stack")
unittest {
	auto val1 = 6;
	auto val2 = 7;

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	stack.push!int(val1);
	stack.push!int(val2);
	auto instr = Instruction(OpCommand.pop_i32, Command(val1.to!string), Command());

	auto stack_value = stack.top!int;
	areEqual(val2, stack_value);

	auto pop = new Pop!int(cpu, stack);
	pop.exec(instr);

	stack_value = stack.top!int;
	areEqual(val1, stack_value);
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
		auto offset = instr.val1.offset;
		this.cpu.write_instr_ptr(instr.ptr + offset);
	}	
}

@test("Jump operation updates instruction pointer to new instruction")
unittest {
	auto offset = 3;
	auto offset_str = offset.to!string;
	auto offset_cmd = "@$+" ~ offset_str;

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	auto instr = Instruction(OpCommand.jmp, Command(offset_cmd), Command());

	auto jump = new Jump(cpu);
	jump.exec(instr);

	auto ip = cpu.read_instr_ptr;
	areEqual(offset, ip);
}

@test("Jump operation updates instruction pointer to new pointer address")
unittest {
	auto func_ptr = 42;
	auto func_def = new FuncDef("function", func_ptr);

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	auto instr = Instruction(OpCommand.jmp, Command(), Command());
	instr.ptr = func_def.ptr;

	auto jump = new Jump(cpu);
	jump.exec(instr);

	auto ip = cpu.read_instr_ptr;
	areEqual(func_ptr, ip);
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

@test("Conditional jump operation updates instruction pointer if conditional register is set")
unittest {
	auto func_ptr = 42;
	auto func_def = new FuncDef("function", func_ptr);

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
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
	auto expected_func_ptr = 0;
	auto func_ptr = 42;
	auto func_def = new FuncDef("function", func_ptr);

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	auto cpu = new Cpu(stack, func_defs);
	cpu.write("cn", 0);
	
	auto instr = Instruction(OpCommand.cjmp, Command(), Command());
	instr.ptr = func_def.ptr;

	auto conditional_jump = new ConditionalJump(cpu);
	conditional_jump.exec(instr);

	auto ip = cpu.read_instr_ptr;
	areEqual(expected_func_ptr, ip);
}

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
	auto func_ptr = 42;
	auto func_name = "test_func";
	auto func_def = new FuncDef(func_name, func_ptr);

	auto stack = new Stack!ubyte();
	FuncDef[] func_defs;
	func_defs ~= func_def;
	auto cpu = new Cpu(stack, func_defs);
	
	auto instr = Instruction(OpCommand.call, Command(func_name), Command());
	instr.ptr = func_def.ptr;

	auto call = new Call(cpu, func_defs);
	call.exec(instr);

	auto ip = cpu.read_instr_ptr;
	areEqual(func_ptr, ip);
}

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
	auto expected_return_addr = 42;
	auto func_def = new FuncDef("test_func", 0);

	auto stack = new Stack!ubyte();
	stack.push(expected_return_addr);

	FuncDef[] func_defs;
	func_defs ~= func_def;
	auto cpu = new Cpu(stack, func_defs);
	cpu.push_call(func_def, expected_return_addr);
	auto instr = Instruction(OpCommand.call, Command(), Command());

	auto ret = new Return(cpu, stack);
	ret.exec(instr);

	auto ip = cpu.read_instr_ptr;
	areEqual(expected_return_addr, ip);
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
