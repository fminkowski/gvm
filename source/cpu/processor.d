module cpu.processor;

import memory.stack;
import cpu.instruction;
import cpu.operation;
import util.algorithm;

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
		Stack static_data;
		Register[string] regs;
		Operation[OpCommand] ops;
		Instruction[] instructions;
		const string static_data_func = "static_data";
		const string main_func = "main";
	}
	FuncDef[] func_defs;

	static const string[] registers = ["r0", "r1", "r2", "r3",
								   	   "pp", "r5", "r6", "r7",
								   	   "r8", "r9", "r10", "r11", 
								   	   "r12", "r13", "r14", "r15", 
								   	   "ip", "rp", "cn"];

	this(Stack stack, Stack static_data) {
		this.stack = stack;
		this.static_data = static_data;
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
		ops[OpCommand.lt]   	= new LessThan(this);
		ops[OpCommand.gt]   	= new GreaterThan(this);
		ops[OpCommand.eq]   	= new Equal(this);
		ops[OpCommand.neq]   	= new NotEqual(this);
		ops[OpCommand.div_f32]  = new Divide!float(this);
		ops[OpCommand.push_i32] = new Push!int(this, this.stack);
		ops[OpCommand.push_f32] = new Push!float(this, this.stack);
		ops[OpCommand.pop_i32]  = new Pop!int(this, this.stack);
		ops[OpCommand.pop_f32]  = new Pop!float(this, this.stack);
		ops[OpCommand.put_i32]  = new Put!int(this);
		ops[OpCommand.put_f32]  = new Put!float(this);
		ops[OpCommand.call]  	= new Call(this);
		ops[OpCommand.ret]  	= new Ret(this);
		ops[OpCommand.jmp]  	= new Jump(this);
		ops[OpCommand.cjmp]  	= new ConditionalJump(this);
	}

	Register get(string reg) {
		return regs[reg];
	}

	T get(T)(Command cmd) {
		if (cmd.is_register()) {
			return to!T(regs[cmd.val!string].val!T());
		} else if (cmd.is_stack_addr()) {
			auto location = cmd.get_stack_location();
			if (location == -1) 			{
				location = this.stack.last_loc;
			}
			return stack.get!T(location);
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

	void load(Instruction[] instructions, FuncDef[] func_defs) {
		this.instructions = instructions.dup;
		this.func_defs = func_defs.dup;
		auto static_data_func = this.func_defs.first!FuncDef(f => f.name == static_data_func);
		if (static_data_func !is null) {
			auto static_data_ip = static_data_func.ptr + 1;
			this.write_instr_ptr(static_data_ip);
			run_static_data();
		}
		auto main_func = this.func_defs.first!FuncDef(f => f.name == main_func);
		auto ip = main_func.ptr + 1;
		this.write_instr_ptr(ip);
	}

	void run() {
		while (this.read_instr_ptr < this.instructions.length) {
			auto ip = this.read_instr_ptr;
			auto instr = this.instructions[ip];
			this.exec(instr);
			this.inc_instruction_ptr();
		}
	}

	void exec(Instruction instr) {
		auto op = this.ops[instr.op_cmd];
		op.exec(instr);
	}

	void write_instr_ptr(int val) {
		this.write("ip", val);
	}

	void run_static_data() {
		while (true) {
			auto ip = this.read_instr_ptr;
			auto instr = this.instructions[ip];
			if (instr.op_cmd == OpCommand.ret) break;
			this.exec(instr);
			this.inc_instruction_ptr();
		}
	}

	int read_instr_ptr() {
		return this.get("ip").val!int;
	}

	void write_ret_ptr(int val) {
		this.write("rp", val);
	}

	int read_ret_ptr() {
		return this.get("rp").val!int;
	}

	private void inc_instruction_ptr() {
		auto next_instr_ptr = this.read_instr_ptr + 1;
		write_instr_ptr(next_instr_ptr);
	}
}