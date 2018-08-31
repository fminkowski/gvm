module gvm.processor.operation.definition;

import gvm.processor.instruction;

enum OpCommand {
	none,
	mov_i32,
	mov_f32,
	add_i32,
	add_f32,
	inc_i32,
	sub_i32,
	sub_f32,
	dec_i32,
	mul_i32,
	mul_f32,
	lt,
	gt,
	eq,
	neq,
	and,
	or,
	xor,
	div_f32,
	push_i32,
	push_f32,
	pop_i32,
	pop_f32,
	put_i32,
	put_f32,
	func,
	call,
	ret,
	jmp,
	cjmp
}

abstract class Operation {
	string label;
	void exec(Instruction instr);
}