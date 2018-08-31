module gvm.gvm;

import gvm.processor.cpu;
import gvm.processor.operation;
import gvm.processor.instruction;
import gvm.memory.stack;
import gvm.program.program;

void run(string[] args) {

	auto program = parse_file(args[1]);

	auto stack = new Stack!ubyte();
	auto cpu = new Cpu(stack);

	cpu.load(program);
	cpu.run();	
}