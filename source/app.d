import gvm.gvm;
 
void main(string[] args) {
	if (args.length < 2) {
		throw new Exception("File not specified.");
	}
	
	run(args);
}