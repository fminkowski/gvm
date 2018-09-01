# GVM is the Gi Virtual Machine
To run any of the examples in the examples directory, clone the project, cd to the cloned location and run
```
	dub -- ./examples/simple.gvm
```
To run a different example, replace `simple.gvm` with any file in the examples directory.

GVM has its own assembly like language. Currently a limited set of instructions are supported. Some instructions include 
1. mov (mov a value to a stack address or register)
2. jmp (jump to instruction)
3. cjmp (conditionally jump to instruction)
4. add
5. sub
6. inc (increment a value by 1)
7. dec (decrement a value by 1)
8. mul (multiply)
9. div (divide)
10. lt (less than check)
11. gt (greater than check)
12. eq (equality check)
13. neq (not equal check)
14. and (bit and)
15. or (bit or)
16. xor (bit xor)
17. push (push value onto stack)
18. pop (pop value from stack)
19. put (prints value to stdio - for debugging)
20. func (creates a function defintion)
21. call (call a function)
22. ret (return from a function)

Operations that depend on the size of the operand are appended with a type, currently i32 for 32 bit wide ints and f32 for 32 bit floats. This syntax is subject to change. To see some examples, refer to the examples directory. 

Comments are created by starting a line with // and ending it with ;.

The @ symbol means that the following expression will be an offset command. The $ symbol means relative to the current position (depends on context, in a mov command it will be relative to the top of the stack, but in a jmp command it will mean relative to the current instruction). So, the command

```
push_i32 1;
push_i32 2;
mov_i32 r0 @$-2;
```

will move an int value of 1 into register r0. While

```
push_i32 1;
jmp @$+2;
push_i32 2;
put_i32 1234;
push_i32 3;
put_i32 @$-1;
push_i32 4;
push_i32 5;
```

will jump to instruction `put_i32 1234;`, not output 1234, move on to push 3 onto the stack, then print 3.

# Operations
## mov (Move)
Moves values between the stack and registers. Some operations include:

1. Constant values can be moved to a stack location or a register. 
	* to stack location `mov_i32 @$-1 4;`
	* to register `mov_i32 r0 4;`
2. Stack values can be moved to other stack locations. 
	* `mov_i32 @$-2 @$-1;`
3. Stack values can be moved to a register. 
	* `mov_i32 r0 @$-1;`
4. Register values can be moved to a stack location. 
	* `mov_i32 @$-1 r0;`
5. Register values can be moved to other registers.
	* `mov_i32 r0 r1;`

## jmp (Jump)
Jump unconditionally to an instruction. The instruction jumped to is not executed, the next instruction will be executed.

`jmp @$+2;`

will jump forward two instructions.

## cjmp (Conditionally Jump)
Conditionally jumps to an instruction based on the value set in the `cn` register. If the `cn` register is non-zero, then the jump will happen.

```
mov_i32 cn 1;
cjmp @$+2;
```

This jump will happen since the `cn` register is non-zero.

## add (Addition)
Adds value in register to another value and sets result back in register. After the instructions

```
push_i32 1;
mov_i32 r0 4;
add_i32 r0 @$-1;
```
`r0` will contain the value 5.

## sub (Subtraction)
Subtracts value in register from another value and sets result back in register. After the instructions

```
push_i32 1;
mov_i32 r0 4;
sub_i32 r0 @$-1;
```
`r0` will contain the value 3.

## inc (Increment)
Increments value in register by one, and sets result back in register. After the instructions

```
push_i32 1;
mov_i32 r0 @$-1;
inc r0;
```
`r0` will contain the value 2.

## dec (Decrement)
Decrements value in register by one, and sets result back in register. After the instructions

```
push_i32 3;
mov_i32 r0 @$-1;
dec r0;
```
`r0` will contain the value 2.

## mul (Multiply)
Multiply value in register with another value and sets result back in register. After the instructions

```
push_i32 2;
mov_i32 r0 4;
add_i32 r0 @$-1;
```
`r0` will contain the value 8;

## mul (Multiply)
Multiply value in register with another value and sets result back in register. After the instructions

```
push_i32 2;
mov_i32 r0 4;
add_i32 r0 @$-1;
```
`r0` will contain the value 8;