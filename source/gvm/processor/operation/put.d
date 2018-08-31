module gvm.processor.operation.put;

import gvm.processor.operation.definition;
import gvm.processor.cpu;
import gvm.processor.instruction;

class Put(T) : Operation {
	private {
		Cpu cpu;
	}

	this(Cpu cpu) {
		this.cpu = cpu;
	}

	override void exec(Instruction instr)	{
		auto val = this.cpu.get!T(instr.val1);
		import std.stdio; writeln(val);
	}	
}