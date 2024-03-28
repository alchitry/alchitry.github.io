+++
title = "Subtraction"
weight=7
+++

Subtraction almost doesn't need its own page. That is because if you remember your basic math you never actually need to subtract anything! Subtraction is really just an easy way to write _add the opposite_. When we subtract we are really not performing a special operation, but really we are just adding the opposite of the second operand.

For example, if you want to do 5 - 3, you could equivalently do 5 + -3. That means to subtract we can use the same circuit that we used for addition! We first just have to negate the second operand.

## Subtraction by Addition

If you can remember back a few tutorials ago we covered how to represent negative numbers in 2's complement form. If you don't remember then you can go back to the [encodings tutorial](@/tutorials/background/encodings.md).

Just as a refresher,  2's complement representation allows you to easily negate a number by simply inverting all the bits then adding 1.

That leads to this basic circuit that uses only adders and not gates.

![subtraction_unoptimized.png](https://cdn.alchitry.com/background/subtraction_unoptimized.png)

Input **b** is fed into an inverter (shown as the circle) which flips all the bits. Then 1 is added to it making the output of the first adder **-b**. Finally, we just add **a** and **-b** together to get **a - b.**

While this circuit will work perfectly fine, it is very wasteful. Do we really need an entire adder just to add 1 to **b**? To answer this question, we need to revisit how the adder works.

![adder.png](https://cdn.alchitry.com/background/adder.png)

This is a basic 4 bit adder. All it does is add **a** and **b**. The thing to notice is that the first bit uses a half-adder to add the two bits together. That was because there was no carry in signal from a previous addition. What exactly does the carry in signal of a full adder do though? 

The carry in of a full adder tells that adder if it should **add an extra 1** to the sum of the bits or not. Now, what if instead of a half adder for the first two bits we used a full adder and fed a 1 into the carry in signal? Instead of outputting **a + b** it would output **a + b + 1**! That's almost what we need except, but we still have to invert **b**. 

![subtractor.png](https://cdn.alchitry.com/background/subtractor.png)

This circuit will now perform the operation **a - b**.

If for some reason you need to sometimes add a number and other times subtract it, you can make some modifications to this circuit to allow you to _select_ if you want to add or subtract! All you have to do is use a multiplexer to select to feed in either **b** for addition or **inverted b**  for subtraction and feed a 0 into the carry in for addition and a 1 for subtraction.