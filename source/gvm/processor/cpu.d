module gvm.processor.cpu;

import gvm.memory.stack;
import gvm.processor.instruction;
import gvm.processor.operation;
import gvm.util.algorithm;
import gvm.program;
import gvm.util.test;
import gvm.processor.register;

import std.conv;

class Cpu {
	private {
		Program program;
		Stack!ubyte stack;
		Register[string] regs;
		Operation[OpCommand] ops;
		static const string static_data_func_name = "static_data";
		static const string main_func_name = "main";
	}
	Stack!FuncDef call_stack;

	//r0, r1 general registers
	//rs - func return result
	//ip - instruction pointer
	//rp - return pointer
	//pp - value popped from stack
	//cn - conditional result
	static const string[] registers = ["r0", "r1", "pp", "rs", "ip", "rp", "cn"];

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
		this.program = program;
		this.create_operations();
	}

	void run() {
		this.run_static_func();
		this.run_main_func();
	}

	void run_static_func() {
		auto static_data_func = this.program.func_defs.first!FuncDef(f => f.name == static_data_func_name);
		if (static_data_func !is null) {
			push_call(static_data_func, static_data_func.ptr);
			run_simple_func(static_data_func);
		}
	}

	void run_main_func() {
		auto main_func = this.program.func_defs.first!FuncDef(f => f.name == main_func_name);		
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
	
	void run_func(FuncDef func) {
		auto func_ip = func.ptr + 1;
		this.write_instr_ptr(func_ip);
		size_t ip = -1;
		while (ip != func.ptr) {
			ip = this.read_instr_ptr;
			auto instr = this.program.instructions[ip];
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
			auto instr = this.program.instructions[ip];
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

	int read_instr_ptr() {
		return this.get("ip").val!int;
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
		ops[OpCommand.div_i32]  = new Divide!int(this);
		ops[OpCommand.div_f32]  = new Divide!float(this);
		ops[OpCommand.lt]   	= new LessThan(this);
		ops[OpCommand.gt]   	= new GreaterThan(this);
		ops[OpCommand.eq]   	= new Equal(this);
		ops[OpCommand.neq]   	= new NotEqual(this);
		ops[OpCommand.and]   	= new And(this);
		ops[OpCommand.or]   	= new Or(this);
		ops[OpCommand.xor]   	= new XOr(this);
		ops[OpCommand.push_i32] = new Push!int(this, this.stack);
		ops[OpCommand.push_f32] = new Push!float(this, this.stack);
		ops[OpCommand.pop_i32]  = new Pop!int(this, this.stack);
		ops[OpCommand.pop_f32]  = new Pop!float(this, this.stack);
		ops[OpCommand.put_i32]  = new Put!int(this);
		ops[OpCommand.put_f32]  = new Put!float(this);
		ops[OpCommand.call]  	= new Call(this, this.program.func_defs);
		ops[OpCommand.ret]  	= new Return(this, this.stack);
		ops[OpCommand.jmp]  	= new Jump(this);
		ops[OpCommand.cjmp]  	= new ConditionalJump(this);
	}
}

import gvm.util.test;

@test("Can read and write to cpu register")
unittest {
	auto val = 42;
	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	cpu.write!int("r0", val);
	auto result = cpu.get!int(Command("r0"));
	areEqual(val, result);
}

@test("Can read from stack")
unittest {
	auto val = 42;
	auto cmd = Command("@$-2");
	auto stack = new Stack!ubyte();
	stack.push(val);
	stack.push(1);
	auto cpu = new Cpu(stack);
	auto result = cpu.get!int(cmd);
	areEqual(val, result);
}

@test("Get for command that is not a register or stack address return command value")
unittest {
	auto expected = 2;
	auto cmd = Command(expected.to!string);
	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	auto result = cpu.get!int(cmd);
	areEqual(expected, result);
}

@test("writes instruction pointer")
unittest {
	auto expected = 42;
	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	cpu.write_instr_ptr(expected);
	auto result = cpu.get("ip");
	areEqual(expected, result.val!int);
}

@test("reads instruction pointer")
unittest {
	auto expected = 42;
	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	cpu.write_instr_ptr(expected);
	auto result = cpu.read_instr_ptr;
	areEqual(expected, result);
}

@test("writes return pointer")
unittest {
	auto expected = 42;
	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	cpu.write_ret_ptr(expected);
	auto result = cpu.get("rp");
	areEqual(expected, result.val!int);
}

@test("reads return pointer")
unittest {
	auto expected = 42;
	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	cpu.write_ret_ptr(expected);
	auto result = cpu.read_ret_ptr;
	areEqual(expected, result);
}

@test("pushes function call onto call stack and return addr onto stack")
unittest {
	auto expected_ret_addr = 42;
	auto func_name = "my_func";
	auto func_def = new FuncDef(func_name, 43);

	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);

	cpu.push_call(func_def, expected_ret_addr);
	auto call_stack = cpu.call_stack;

	auto pushed_func = call_stack.top!FuncDef;
	areEqual(func_name, pushed_func.name);

	auto actual_ret_addr = stack.top!int;
	areEqual(expected_ret_addr, actual_ret_addr);
}

@test("pops function call from call stack and return addr from stack")
unittest {
	auto expected_ret_addr = 42;
	auto func_name = "my_func";
	auto func_def = new FuncDef(func_name, 43);

	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);

	cpu.push_call(func_def, expected_ret_addr);
	cpu.push_call(new FuncDef("Test", 0), 44);
	cpu.pop_call();

	auto call_stack = cpu.call_stack;

	auto pushed_func = call_stack.top!FuncDef;
	areEqual(func_name, pushed_func.name);

	auto actual_ret_addr = stack.top!int;
	areEqual(expected_ret_addr, actual_ret_addr);
}

@test("increase instruction pointer by 1")
unittest {
	auto current_ip = 42;
	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);

	cpu.write("ip", current_ip);
	cpu.inc_instruction_ptr();

	auto result = cpu.get("ip").val!int;
	areEqual(current_ip + 1, result);
}

@test("reads instruction pointer")
unittest {
	auto current_ip = 42;
	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);
	
	cpu.write("ip", current_ip);
	cpu.inc_instruction_ptr();

	auto result = cpu.read_instr_ptr;
	areEqual(current_ip + 1, result);
}