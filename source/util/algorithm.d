module util.algorithm;

bool null_or_empty(T)(T val) {
	return val is null || val == val.init;
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