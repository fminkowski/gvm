module gvm.processor.register;

import gvm.util.test;

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