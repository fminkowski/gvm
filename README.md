# GVM is the Gi Virtual Machine
It has its own assembly like language. Currently a limited set of instructions are supported. Some instructions include 
1. mov (mov a value a stack address or register)
2. jmp (jump to instruction)
3. cjmp (conditionally jump to instruction)
4. add (add two values)
5. sub (subtract two values)
6. inc (increment a value by 1)
7. dec (decrement a value by 1)
8. mul (multiply two values)
9. div (divide two values)
10. lt (less than check)
11. gt (greater than check)
12. eq (equality check)
13. neq (not equal check)
14. push (push value onto stack)
15. pop (pop value from stack)
16. put (prints value to stdio - for debugging)
17. func (creates a function defintion)
18. call (call a function)
19. ret (return from a function)

Operations that depend on the size of the operand are appended with a type, currently i32 for 32 bit wide ints and f32 for 32 bit floats. This syntax is subject to change. To see some examples, please refer to the examples directory. 

Comments are created by starting a line with // and ending it with ;.


The @ symbol means that the following expression will be an offset command. The $ symbol means relative to the current position (depends on context, in a mov command it will be relative to the top of the stack, but in a jmp command it will mean relative to the current instruction). So, the command

```
push_i32 1;
push_i32 2;
mov_i32 r0 @$-2;
```

will move a int value of 1 into register r0. While

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

will jump to instruction `put_i32 1234;`, not output any result, move on to push 3 onto the stack, then print 3;