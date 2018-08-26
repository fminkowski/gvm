module memory.stack;

import std.conv;

class Stack {
	private {
		size_t location;
		const size_t memory_size = 4096;
		ubyte[memory_size] memory;
	}

	void write(T)(size_t loc, T value) {
		auto insert_point = cast(T*)(&memory[loc]);
		*insert_point = value;
	}

	void push(T)(T value) {
		this.write!T(this.location, value);
		location += value.sizeof;
	}

	T pop(T)() {
		this.location -= T.sizeof;
		auto value = cast(T)(memory[this.location]);
		return value;
	}

	T get(T)(size_t loc) {
		return *cast(T*)(&memory[loc]);
	}

	override string toString() {
		return to!string(memory);
	}
}