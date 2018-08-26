module memory.stack;

import std.conv;
import std.algorithm.iteration;

class Stack {
	private {
		size_t size_location;
		size_t location;
		const size_t memory_size = 4096;
		ubyte[memory_size] memory;
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

	T get(T)(size_t loc) {
		return *cast(T*)(&memory[loc]);
	}

	size_t ptr() {
		return this.location;
	}

	@property size_t last_loc() {
		return this.memory_sizes[0 .. this.size_location - 1].reduce!((a,b) => a + b);
	}

	override string toString() {
		return to!string(memory);
	}
}