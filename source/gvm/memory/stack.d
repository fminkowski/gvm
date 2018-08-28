module gvm.memory.stack;

import std.conv;
import std.algorithm.iteration;

class Stack(T) {
	private {
		size_t size_location;
		size_t location;
		const size_t memory_size = 4096;
		T[memory_size] memory;
		size_t[memory_size] memory_sizes;
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

	T get(T)(size_t loc) {
		return *cast(T*)(&memory[loc]);
	}

	size_t ptr() {
		return this.location;
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

	@property size_t count() {
		return this.size_location;
	}

	override string toString() {
		return to!string(memory);
	}
}