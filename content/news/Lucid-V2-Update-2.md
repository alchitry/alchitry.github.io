+++
title = "Lucid V2 - Update 2 - Test Benches"
date = "2023-06-01"
+++

Test benches are here!

I just pushed a working draft of the test bench code that has the necessities for writing quick tests for you modules!

## Test Bench Example

Take a look at this revolutionary counter module I created.

```
module counter (
    input clk,
    output count[8]
) {
    dff counter[8] (.clk(clk))
    
    always {
        counter.d = counter.q + 1
        count = counter.q
    }
}
```

I designed it so that the output `count` will increment by one on every rising edge of the `clk` input. However, does 
it actually work?!? There's no way to know. Oh wait, we could test it.

Here is my test bench that does just that.

```
testBench myTestBench {
    sig clk // signal to use as my clock
    
    counter dut (.clk(clk)) // device under test
    
    fun tickClock() {
        clk = 1
        $tick()
        clk = 0
        $tick()
    }
    
    test simpleTest {
        clk = 0 // initialize the clock
        $tick()
        
        repeat(100, i) {
            $print(dut.count)
            $assert(dut.count == i)
            $tickClock()
        }
        
        $assert(dut.count == 100)
    }
}
```

The insides of a `testBench` are very similar to a `module` with a couple of key differences. There are no ports
or parameters and instead of `always` blocks you use `test` and `fun` blocks.

On line 2, we create a signal named `clk` that will act as our clock.

On line 4, we instantiate the device under test or "dut". It is convention to call the module being tested "dut" but 
there is nothing special about the name.

Next, we have our function declaration. Functions have the same properties as tests, but they aren't run directly. 
Instead, functions are little pieces of helper code that can be called from tests.

Here I defined the very common function of toggling the clock and called it `tickClock`. This function doesn't have any
parameters, but it could.

For example, we could give it a parameter to repeat a specified number of times.

```
fun tickClock(times[32]) {
    repeat(times) {
        clk = 1
        ${"$"}tick()
        clk = 0
        ${"$"}tick()
    }
}
```

Function arguments act the same as module inputs and can be multidimensional arrays or structs.

### Test Bench Functions

Before we move on, let me quickly go over the couple of test bench specific functions that I'm using.

The function `$tick()` is at the very core of the simulation. It initiates a simulation tick. So what is a simulation
tick? This is when the simulator publishes all signal changes and recalculates the outputs for all the pieces in the 
design whose input signals changed. Those output changes then trigger other updates if they are used as inputs. This 
continues until the results of everything stabilize.

The only time it won't stabilize is if you have some kind of dependency loop like `a = b` and `b = ~a`. In this case, 
the simulator will quit after 1000 iterations. I chose this number as a seemingly nice upper bound, but it may change if
I find designs often need more or fewer iterations. A loop like this would result in faulty hardware, and anything 
requiring too many iterations to resolve would likely be too complicated to do in a single real clock cycle.

So back to the test bench. Before we call `$tick()`, first we need to set a value to all signals we are using. Signals 
default to having a `bx` value so bad things will happen if we call `$tick()` before setting a real value. By bad things,
I mean that `bx` value will propagate throughout the design contaminating our counter.

With `clk` set to 0, we call `$tick()` to initialize the design.

Next, we hit a `repeat` block that will repeat its contents 100 times and use the signal `i` as the iteration index.

The first line in the loop prints the value of `dut.count` using the `$print()` function. This function takes one
argument, the value to print. It currently outputs the value in the format `dut.count = {00011100} : 28` where the value
is shown in its binary form as well as its decimal value (if it has one).

The next line uses the `$assert()` function to check that the value of the counter matches the loop iteration we are on.
The argument to `$assert()` can be anything, and it is treated as a boolean. That means if it is non-zero, nothing 
happens, but if it is zero, the simulation is aborted and the `$assert()` that caused it is called out.

This is very useful for checking values quickly without having to look back through the simulation manually to see if 
values make sense.

The last line in the loop is the call to the function `$tickClock()` that we already defined.

Finally, we end our test by checking that the counter output is 100 after the 100 cycles.

This example is from one of the tests and can be found in the 
[repo here](https://github.com/alchitry/LucidParserV2/blob/9795d9dcea1a769be7567025b15607549c36edc3/src/test/kotlin/TestBenchTests.kt#L45).

## Next Step

The next step is to add snapshots of the entire design every time `$tick()` is called. This will allow for the 
simulation results to be shown after it is run. Currently, it just runs discarding all intermediate values.

I also plan to have a `$silentTick()` or similarly named function that does a tick without taking a snapshot. This way
you can use that when making the clock fall for most designs and avoid the overhead of an entire snapshot.

As before, there is a [discussion page](https://github.com/alchitry/LucidParserV2/discussions) setup as part of the repo
where you can let me know your thoughts.