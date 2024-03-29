+++
title = "Verilog Operators"
weight = 0
inline_language = "verilog"
+++

This tutorial covers the various operators available in Verilog. If you have programmed in C/C++ or Java, then many of these operators will be familiar. However, there are a few new usages that are handy for dealing with hardware.

### Bitwise Operators

| Function | Operator   |
| -------- | ---------- |
| NOT      | ~          |
| AND      | &          |
| OR       | \|         |
| XOR      | ^          |
| XNOR     | \~^ or ^\~ |

These operators are called bitwise operators because they operate on each bit individually. These are used to perform basic logic functions and they get synthesized into their equivalent logic gate.

Take a look at the following example.

```verilog
wire [3:0] a,b,c;
assign a = 4'b1010;
assign b = 4'b1100;
assign c = a & b;
```

**c** will now have the value 4'b1000. This is because the most-significant bits of **a** and **b** are the only ones that are both 1.

When you perform a bitwise operator on multi-bit values like above, you are essentially using multiple gates to perform the bitwise operation. In this case, we need four **AND** gates to _and_ each bit of **a** and **b** together. The results of each **AND** gate is the value **c**.

All of these operators are used on two values except the **NOT** (**~**) operator which only takes one value. Take a look at this example where we replace the last line of the previous example.

```verilog
assign c = ~a;
```

 Now **c** will have the value 4'b0101. Again, this is because each bit of **a** is individually inverted and assigned to **c**.

If the two values used by a bitwise operator are different in length, the shorter one is filled with zeros to make the lengths match.

### Reduction Operators

| Function | Operator   |
| -------- | ---------- |
| AND      | &          |
| NAND     | ~&         |
| OR       | \|         |
| NOR      | ~\|        |
| XOR      | ^          |
| XNOR     | \~^ or ^\~ |

Reduction operators are very similar to the bitwise operators, except they are performed on all the bits of a single value. They are used to **reduce** the number of bits to one by performing the specified function on every bit.

Take a look at this example.

```verilog
wire [3:0] a;
wire b;
assign a = 4'b1010;
assign b = &a;
```

 In this example **b** will be 0. This is because each bit of **a** is anded with each other. In other words, it is equivalent to the following.

```verilog
assign b = a[0] & a[1] & a[2] & a[3];
```

 This essentially synthesizes a large single logic gate with enough inputs to fit the input value. In this case, a four input **AND** gate would be synthesized.

### Shift Operators

|Function|Operator|
|---|---|
|Shift Right|>>|
|Shift Left|<<|
|Arithmetic Shift Right|>>>|
|Arithmetic Shift Left|<<<|

The shift operators in Verilog are very similar to the ones in other languages. They simply _shift_ the bits in a value over that many times to the right of left.

The basic shift operators are **zero-filling** meaning that bits that don't have a value shifted into them are replaced with zeros. Take a look at the following example.

```verilog
wire [4:0] a,b,c;
assign a = 5'b10100;
assign b = a << 2;
assign c = a >> 2;
```

In this example **b** will have the value `5'b10000` and **c** will have the value `5'b00101`. You can see with **b** the top two bits of **a** are lost, and with **c** the bottom two bits are lost.

Now let's take a look at the arithmetic shift operators. These vary from the basic shift operators because they perform **sign-extended** shifts. When shifting left, it performs exactly the same as the basic shift operator, but when shifting to the right,  the most-significant bit (the **sign** **bit**) plays a role.

If the sign bit is 0, then the arithmetic shift operator acts the same way as the basic shift operator. However, if the sign bit is 1, the shift will fill the left side with ones.

Take a look at this example.

```verilog
wire [4:0] a,b,c;
assign a = 5'b10100;
assign b = a <<< 2;
assign c = a >>> 2;
```

 Now **b** will have the value `5'b10000` just like before, but **c** will have the value `5'b11101`.

Why would you ever want to fill the left side with the most-significant bit? The reason is because shifting bits is a very cheap way to perform multiplication and division by powers of two. Take the value 6 (4'b0110). If we shift it to the left one bit we get `4'b1100` or `12` and if we shift it to the right one bit we get 4'b0011 or 3. Now what about the value -4 (4'b1100)? If we shift it to the left one bit we get 4'b1000 or -8. However if we shift it to the right one bit we get 4'b0110 or 6! This is because we need to use the arithmetic shift. If we use the arithmetic shift we get 4'b1110 or -2!

Shift operations are very cheap! This is because they are essentially just a signal renaming.

### Concatenation and Replication Operators

|Function|Operator|
|---|---|
|Concatenation|{ , }|
|Replication|{ { } }|

These are two very useful operators for manipulating bits.

The **concatenation** operator is used to merge two values together into a wider value. 

```verilog
wire [3:0] a,b;
wire [7:0] c;
assign a = 4'b1100;
assign b = 4'b1010;
assign c = {a,b};
```

In this example **c** has the value `8'b11001010`. You can concatenate as many signals together as you want by adding them to the comma-separated list.

The **replication** operator is used to duplicate a value multiple times.

```verilog
wire [1:0] a;
wire [7:0] b;
assign a = 4'b10;
assign b = {4{a}};
```

In this example **a** is replicated 4 times making the value of **b** be 8'b10101010.

### Arithmetic Operators

|Function|Operator|
|---|---|
|Addition|+|
|Subtraction|-|
|Multiply|*|
|Divide|/|
|Modulus|%|
|Power|**|

Verilog provides these six basic arithmetic operators to make basic math simpler. However, it is important to remember when using these operators how they will be implemented in hardware.

The most important thing to remember is that not all of these operators can be synthesized! Only addition, subtraction, and multiplication are synthesizable! Some synthesizers will allow you to use divide if you are dividing by a power of two, but you should use a shift operator for that anyways. The reason the other three aren't synthesizable is because the circuits required to implement them are quite complicated. There are many trade offs that as a designer you need to make if you need to use divide, modulous, or power, that the synthesizer can't make for you. In most cases these operations will be pipe-lined to provide speed or reduce the amount of hardware used. This is something that the synthesizer can't do for you.

When using addition and subtraction, the synthesizer will probably synthesize a circuit similar to the one shown in [this tutorial](@/tutorials/background/addition.md). However, the synthesizer is free to make optimizations as long as it adds the two values.

For multiplication, many FPGAs (including the one used by the Mojo) have special resources dedicated to fast math. If these are available they will be used, however, if you run out of them a multiplication circuit will have to be generated which can be large and slow. Because of this you should never multiply by a power of two, but shift instead. Most synthesizers will be smart enough to do this for you but it is good practice not to rely on that.

Also note that the **-** operator can be used to negate a number.

When two N-bit numbers are added or subtracted, an N+1-but number is produced. If you add or subtract two N-bit numbers and store the value in an N-bit number you need to think about overflow. For example, if you have a two bit number 3 (2'b11) and you add it to 2 (2'b10) the result will be 5 (3'b101) but if you store the value in a two bit number you get 1 (2'b01).

For multiplication of two N-bit numbers, the result will be an N*2-bit number. For example, 7 (3'b111) * 6 (3'b110) = 42 (6'b101010).

### Comparison Operators

|Function|Operator|
|---|---|
|Less Than|<|
|Greater Than|>|
|Less Than or Equal|<=|
|Greater Than or Equal|>=|
|Equality|==|
|Inequality|!=|
|Case Equality|===|
|Case Inequality|!==|

These operators compare two values and produce a single bit to represent the result. A 1 is true and a 0 is false.

The only strange thing to note is the case version of the equality tests. Bits in Verilog aren't only **0** or **1**, but they can also be **x** or **z**. For the standard equality tests, if either value has an **x** or **z** in it the result will be an **x**. However, for the case equality tests, it will test to see if these are matched in the other value. For example 4'b01x0 == 4'b01x0 produces an **x**, but 4'b01x0 === 4'b01x0 produces a **1**.

In reality, hardware can't have an **x** value so the case equality tests are not synthesizable but are useful for simulations.

### Logical Operators

|Function|Operator|
|---|---|
|Logical And|&&|
|Logical Or|\||
|Logical Not|!|

These operators are used for combining multiple comparison operations. Take a look at this example.

```verilog
if ((4'b1100 > 4'b1011) && (4'b0111 == 4'b0111)) begin
    ...
end
```

It is important to note that these operators will produce a single bit value like the comparison operators. Also anything that is not zero is considered to be true while zero is false.

```verilog
wire [3:0] a,b;
wire c;
assign a = 4'b1010;
assign b = 4'b1110;
assign c = a && b;
```

In this example, **c** will have the value 1 because **a** and **b** are both non-zero.

### Conditional Operator

|Function|Operator|
|---|---|
|Conditional|?|

The conditional operator is a way to write compact if statements. It is used to select a value based on a logical value.

```verilog
wire [3:0] a,b,c,d;
assign a = 4'b1000;
assign b = 4'b0111;
assign c = 4'b1010;
assign d = a > b ? c : 4'b0000;
```

In this example **d** will have the value 4'b1010. When the expression on the left of the **?** is true (non-zero) the value on the left of the **:** will be assigned. If the expression is false the value on the right is used. In this case since **a** is greater than **b**, the value of **c** was assigned to **d**.