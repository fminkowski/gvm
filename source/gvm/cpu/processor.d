module gvm.cpu.processor;

import gvm.memory.stack;
import gvm.cpu.instruction;
import gvm.cpu.operation;
import gvm.util.algorithm;
import gvm.program.program;
import gvm.program.func_def;
import gvm.util.test;

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

@test("Can write int value to register")
unittest {
	auto val = 4;
	auto register = Register();
	register.write!int(val);
	auto result = register.val!int;

	areEqual(val, result);
}

@test("Can write float value to register")
unittest {
	auto val = 4.2f;
	auto register = Register();
	register.write!float(val);
	auto result = register.val!float;

	areEqual(val, result);
}

class Cpu {
	private {
		FuncDef[] func_defs;
		Stack!ubyte stack;
		Stack!FuncDef call_stack;
		Register[string] regs;
		Operation[OpCommand] ops;
		Instruction[] instructions;
		static const string static_data_func_name = "static_data";
		static const string main_func_name = "main";
	}

	//r0 - r11 gen registers
	//rs - func return result
	//ip - instruction pointer
	//rp - return pointer
	//cn - conditional result
	static const string[] registers = ["r0", "r1", "r2", "r3",
								   	   "pp", "r5", "r6", "r7",
								   	   "r8", "r9", "r10", "r11", 
								   	   "rs", "ip", "rp", "cn"];

	this(Stack!ubyte stack) {
		this.stack = stack;
		this.call_stack = new Stack!FuncDef();
		foreach (n; this.registers) {
			regs[n] = Register();
		}
	}

	Register get(string reg) {
		return regs[reg];
	}

	T get(T)(Command cmd) {
		if (cmd.is_register) {
			return to!T(regs[cmd.val!string].val!T());
		} else if (cmd.is_stack_addr) {
			auto location = this.stack.offset(cmd.offset);
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

	void load(Program program) {
		this.instructions = program.instructions;
		this.func_defs = program.func_defs;
		this.create_operations();
		auto static_data_func = this.func_defs.first!FuncDef(f => f.name == static_data_func_name);
		if (static_data_func !is null) {
			push_call(static_data_func, static_data_func.ptr);
			run_simple_func(static_data_func);
		}
	}

	void run() {
		auto main_func = this.func_defs.first!FuncDef(f => f.name == main_func_name);		
		push_call(main_func, main_func.ptr);
		this.run_func(main_func);
	}

	void exec(Instruction instr) {
		auto op = this.ops[instr.op_cmd];
		op.exec(instr);
	}

	void write_instr_ptr(int val) {
		this.write("ip", val);
	}

	int read_instr_ptr() {
		return this.get("ip").val!int;
	}
	
	void run_func(FuncDef func) {
		auto func_ip = func.ptr + 1;
		this.write_instr_ptr(func_ip);
		size_t ip = -1;
		while (ip != func.ptr) {
			ip = this.read_instr_ptr;
			auto instr = this.instructions[ip];
			this.exec(instr);
			ip = this.read_instr_ptr;
			this.inc_instruction_ptr();
		}
	}

	void run_simple_func(FuncDef func) {
		auto func_ip = func.ptr + 1;
		this.write_instr_ptr(func_ip);
		size_t ip;
		while (true) {
			ip = this.read_instr_ptr;
			auto instr = this.instructions[ip];
			if (instr.op_cmd == OpCommand.ret) break; 
			this.exec(instr);
			this.inc_instruction_ptr();
		}
	}

	void write_ret_ptr(int val) {
		this.write("rp", val);
	}

	int read_ret_ptr() {
		return this.get("rp").val!int;
	}

	void push_call(FuncDef func, int ret_addr) {
		this.call_stack.push(func);
		this.stack.push(ret_addr);
	}

	void pop_call() {
		this.call_stack.pop!FuncDef();
		this.stack.pop!int();
	}

	private void inc_instruction_ptr() {
		auto next_instr_ptr = this.read_instr_ptr + 1;
		write_instr_ptr(next_instr_ptr);
	}

	private void create_operations() {
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
		ops[OpCommand.call]  	= new Call(this, this.func_defs);
		ops[OpCommand.ret]  	= new Return(this, this.stack);
		ops[OpCommand.jmp]  	= new Jump(this);
		ops[OpCommand.cjmp]  	= new ConditionalJump(this);
	}
}