module gvm.util.algorithm;
import gvm.util.test;

bool null_or_empty(string val) {
	return val is null || val == val.init;
}

@test("Null or empty checks value")
unittest {
	isTrue("".null_or_empty);
	isFalse("a".null_or_empty);
}

T first(T)(T[] collection, bool delegate(T) cmp) {
	T result;
	foreach (ref T c; collection) {
		if (cmp(c)) {
			result = c;
			break;
		}
	}
	return result;
}

@("first returns first value in simple array")
unittest {
	auto collection = [1,2,3];
	auto result = collection.first!int(x => x == 2);
	areEqual(2, result);
}

@("first returns first value in array with complex types")
unittest {
	struct Test {
		int id;
		string name;
	}

	Test[] test_structs = [	Test(1, "test1"),
						   	Test(2, "test2"),
						   	Test(3, "test1"),
						   	Test(4, "test2")];

	auto result = test_structs.first!Test(t => t.name == "test2");
	areEqual(2, result.id);
}