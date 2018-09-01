# GVM is the Gi Virtual Machine
To run any of the examples in the examples directory, clone the project, cd to the cloned location and run
```
	dub -- ./examples/simple.gvm
```
To run a different example, replace `simple.gvm` with any file in the examples directory.

GVM has its own assembly like language. Currently a basic set of instructions are supported. See below documentation of instructions for more detail.

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

## push
Pushes value onto stack

```
push_f32 3;
```

## pop
Pops value from stack and sets popped value into register `pp`

```
pop_f32;
```

## put (Prints value)
Prints value to stdio. This is used for debugging programs.

```
mov_i32 r0 4;
put_i32 r0;
```
4 is printed to stdio.

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

## div (Divide)
Divide value in register with another value and sets result back in register. After the instructions

```
push_f32 2;
mov_f32 r0 5;
div_f32 r0 @$-1;
```
`r0` will contain the value 2.5;

## lt (Less Than)
Checks if value1 is less than value2, then sets 1 or 0 into register `cn`.

```
push_f32 2;
mov_f32 r0 1
lt r0 @$-1;
```
`cn` will contain the value 1;

## gt (Greater Than)
Checks if value1 is greater than value2, then sets 1 or 0 into register `cn`.

```
push_f32 2;
mov_f32 r0 1
gt r0 @$-1;
```
`cn` will contain the value 0;

## eq (Equal)
Checks if value1 is equal to value2, then sets 1 or 0 into register `cn`.

```
push_f32 2;
mov_f32 r0 2
eq r0 @$-1;
```
`cn` will contain the value 1;

## neq (Not Equal)
Checks if value1 is not equal to value2, then sets 1 or 0 into register `cn`.

```
push_f32 2;
mov_f32 r0 2
neq r0 @$-1;
```
`cn` will contain the value 0;

## and (Bitwise and)
Bitwise and two values, set result into destination register.

```
push_f32 3;
mov_f32 r0 6;
and r0 @$-1;
```
`r0` will contain the value 2;

## or (Bitwise or)
Bitwise or two values, set result into destination register.

```
push_f32 3;
mov_f32 r0 6;
or r0 @$-1;
```
`r0` will contain the value 7;

## xor (Bitwise xor)
Bitwise xor two values, set result into destination register.

```
push_f32 3;
mov_f32 r0 6;
or r0 @$-1;
```
`r0` will contain the value 5;

## func (Function)
A block of code can be declared with the `func` keyword. This enables code reusability. Follow the func keyword with name and end it with semi-colon.

```
func my_func;
...
ret;
```
Push the values that you want to access inside the function before you call it. As an example, to pass two values to a function and use them in the function do the following:

```
func my_func;
mov_i32 r0 @$-2;
mov_i32 r1 @$-3;
ret;

func main;
push_i32 1;
push_i32 2;
call my_func;
pop_i32;
pop_i32;
ret;
```
A return value should be set into register `rs` or moved onto the stack for the caller.

## ret (Return)
Marks a function as complete and returns to the callee. All values pushed onto the stack in the function must be popped off the stack before calling ret. This must be done so the correct return address is retrieved so `ret` jumps to the correct location. Support for automatic stack cleanup may be added in the future.

## call (Call function) 
Calls a function with a matching label. The return address is automatically pushed onto the stack for the callee. `call` unconditionally jump to the function specified and execute the first instruction after the function definition.