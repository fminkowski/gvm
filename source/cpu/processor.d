module cpu.processor;

import memory.stack;
import cpu.instruction;
import cpu.operation;

import std.conv;

struct Register {
	private {
		ubyte[4] buffer;		
	}

	@property T val(T)() {
		auto val = cast(T*)(&buffer[0]);
		return *val;
	}

	void write(T)(T value) {
		auto insert_point = cast(T*)(buffer.ptr);
		*insert_point = value;		
	}
}


class Cpu {
	private {
		Stack stack;
		Register[string] regs;
		Operation[OpCommand] ops;
		Instruction[] instructions;
	}

	static const string[] registers = ["r0", "r1", "r2", "r3",
								   	   "r4", "r5", "r6", "r7",
								   	   "r8", "r9", "r10", "r11", 
								   	   "r12", "r13", "r14", "r15"];

	this(Stack stack) {
		this.stack = stack;
		foreach (n; this.registers) {
			regs[n] = Register();
		}

		ops[OpCommand.mov_i32]  = new Move!int(this, this.stack);
		ops[OpCommand.mov_f32]  = new Move!float(this, this.stack);
		ops[OpCommand.add_i32]  = new Add!int(this);
		ops[OpCommand.add_f32]  = new Add!float(this);
		ops[OpCommand.inc_i32]  = new Increment!int(this);
		ops[OpCommand.sub_i32]  = new Subtract!int(this);
		ops[OpCommand.sub_f32]  = new Subtract!float(this);
		ops[OpCommand.dec_i32]  = new Decrement!int(this);
		ops[OpCommand.mul_i32]  = new Multiply!int(this);
		ops[OpCommand.mul_f32]  = new Multiply!float(this);
		ops[OpCommand.div_f32]  = new Divide!float(this);
		ops[OpCommand.push_i32] = new Push!int(this, this.stack);
		ops[OpCommand.push_f32] = new Push!float(this, this.stack);
		ops[OpCommand.pop_i32]  = new Pop!int(this, this.stack);
		ops[OpCommand.pop_f32]  = new Pop!float(this, this.stack);
	}

	Register get(string reg) {
		return regs[reg];
	}

	T get(T)(Command cmd) {
		if (cmd.is_register()) {
			return to!T(regs[cmd.val!string].val!T());
		} else if (cmd.is_stack_addr()) {
			return stack.get!T(cmd.get_stack_location());
		} else {
			return cmd.val!T();
		}
	}

	void write(T)(string reg, T value) {		
		regs[reg].write!T(value);
	}

	override string toString() {
		string dump_string = "[";
		foreach (i, n; registers) {
			dump_string ~= "\"" ~ n ~ "\":" ~ regs[n].val!int.to!string;
			if (i != registers.length - 1) {
				dump_string ~= ", ";
			}
		}
		dump_string ~= "]";
		return dump_string;
	}

	void load(Instruction[] instructions) {
		this.instructions = instructions.dup;
	}

	void run() {
		foreach (instr; this.instructions) {
			this.exec(instr);
		}
	}

	void exec(Instruction instr) {
		auto op = this.ops[instr.op_cmd];
		op.exec(instr);
	}
}