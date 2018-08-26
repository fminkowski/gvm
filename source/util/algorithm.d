module util.algorithm;

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