module gvm.memory.stack;

import std.conv;
import std.algorithm.iteration;

import gvm.util.test;

class Stack(T) {
	private {
		size_t size_location;
		size_t location;
		const size_t memory_size = 4096;
		T[memory_size] memory;
		size_t[memory_size] memory_sizes;
	}

	T get(T)(size_t loc) {
		return *cast(T*)(&memory[loc]);
	}

	void write(T)(size_t loc, T value) {
		auto insert_point = cast(T*)(&memory[loc]);
		*insert_point = value;
		this.memory_sizes[this.size_location] = value.sizeof;
	}

	void push(T)(T value) {
		this.write!T(this.location, value);
		this.size_location++;
		location += value.sizeof;
	}

	T pop(T)() {
		this.location -= T.sizeof;
		this.size_location--;
		auto val = cast(T*)(&memory[this.location]);
		return *val;
	}

	@property T top(T)() {
		return *cast(T*)(&memory[this.offset(-1)]);
	}

	@property size_t offset(int i) {
		if (-i >= this.size_location) {
			return 0;
		}
		return this.memory_sizes[0 .. this.size_location + i].reduce!((a,b) => a + b);
	}

	@property bool empty() {
		return this.size_location == 0;
	}
	
	@property int size() {
		if (this.size_location == 0) {
			return 0;
		}
		return this.memory_sizes[0 .. this.size_location].reduce!((a, b) => a + b);
	}

	@property int count() {
		return this.size_location;
	}

	override string toString() {
		return to!string(memory);
	}
}

@test("Value is pushed onto stack")
unittest {
	auto val = 42;
	auto stack = new Stack!int();
	stack.push!int(val);
	areEqual(val, stack.get!int(0));
}

@test("Value is popped from stack")
unittest {
	auto val = 42;
	auto stack = new Stack!int();
	stack.push!int(val);
	areEqual(int.sizeof, stack.size);
	auto popped_val = stack.pop!int();
	areEqual(val, popped_val);
	areEqual(0, stack.size);
}

@test("Can get memory size of stack") 
unittest{
	auto stack = new Stack!int();
	stack.push!int(1);
	stack.push!int(1);
	stack.push!int(1);
	areEqual(3 * int.sizeof, stack.size);
}

@test("Can get count of elements on stack")
unittest {
	auto stack = new Stack!int();
	stack.push!int(1);
	stack.push!int(1);
	stack.push!int(1);
	areEqual(3, stack.count);
}

@test("Can get element at the top of the stack")
unittest {
	auto stack = new Stack!int();
	stack.push!int(1);
	stack.push!int(2);
	stack.push!int(3);
	areEqual(3, stack.top!int);
}

@test("Test for empty stack")
unittest {
	auto stack = new Stack!int();
	isTrue(stack.empty);
	stack.push!int(1);
	isFalse(stack.empty);
}