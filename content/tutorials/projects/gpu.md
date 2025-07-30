+++
title = "GPU"
inline_language = "lucid"
weight = 0
+++

![GPU Demo](https://cdn.alchitry.com/projects/gpu/GPU.gif)

This is by far the most complicated project/tutorial to date. 
On this first page I’ll be giving a rough overview of the main pieces, and in later pages I’ll be diving deep into how each one works.

This project is now built into Alchitry Labs.
It is the _Hd GPU_ template project available for the [Au V2](https://shop.alchitry.com/products/alchitry-au), or [Pt V2](https://shop.alchitry.com/products/alchitry-pt).

It outputs the video data through the [Hd](https://shop.alchitry.com/products/alchitry-hd) at 720p60.

# Basic Architecture

Before getting into any FPGA specific details, we need to go over what our goal is and what has to happen to get there.

The goal of this GPU is to take a 3D model and render it onto a 2D frame. 
When you put it like that, it doesn’t sound so bad. 
There are a few minor other details to consider first, though…

Graphics in general rely heavily on linear algebra. 
If you aren’t familiar with vectors and matrices, now would be a good time to freshen up. 
There are tons of tutorials out there about it. 
For most of this tutorial, you really only need to know how to multiply a vector by a matrix.

Our GPU will accept a few parameters.

First, we need something to draw. 
Our GPU, like every good GPU, will draw triangles. 
We will specify the triangles with two ROMs. 
The first ROM contains all the vertices (and colors of those vertices). 
The second ROM contains the faces. 
That is, the list of three vertices that make up a triangle.

While manually coming up with and typing out hundreds of vertices and faces sounds fun, we will use [Blender](https://www.blender.org/)
to model something, and some Java to convert it into a ROM.

Second, we need a model transformation matrix. 
This matrix is responsible for moving around objects. 
By multiplying our model’s 3D points by this matrix, we can rotate, translate, and scale the model however we want. 
Most renders will have two of these. 
One for the model and one for the camera (viewpoint into the scene). 
To keep things a bit simpler, our pipeline will only have one. 
Our camera will be stationary, but you could make it seem like it is moving by transforming the entire scene.

By using a matrix to specify the transformations, our GPU only needs to perform basic matrix multiplication instead of trig to rotate points! 
The trig functions still need to be calculated but only once (per object) to produce the matrix.

We also need some kind of lighting. 
We could have no lighting and just color every triangle its specified color, but this significantly reduces the 
perceived details of the model. 
There are huge numbers of ways to calculate lighting in a scene with the holy grail being ray tracing. 
That is where you simulate the actual rays of light and calculate how they bounce and interact with the objects in the scene. 
This is what you can get with a modern GPU and is not what we will be doing.

Instead, we will be taking a much simpler approach. 
Our GPU will accept a single light vector. 
That is, the direction light is coming from. 
We will then calculate the angle between each triangle and the light vector and use that to calculate the color. 
This method has no concept of shadows, which are substantially more complicated. 
It still produces a nice effect where we can make it look like things are illuminated from above.

Finally, we need a projection matrix for converting 3D points to 2D points. 
This matrix is set up in such a way that when a 3D point is multiplied by it, we will get the 2D coordinate of it.
We will be using a fixed frustum style projection. 
This projection works in such a way that further objects appear smaller. 
At the core of it, you divide the X and Y coordinates by their Z coordinate. 
Larger Z (further away) means the X and Y get pulled more into the center of the frame.

# The Pipeline

## Stage 1 - Generate the Model Matrix

I wouldn’t necessarily consider this part of the GPU’s job as this matrix would generally be provided to the GPU. 
However, our pipeline is self-contained and this matrix is the first thing needed for producing a frame.

As mentioned above, this matrix is responsible for all the translations, rotations, and scaling, we want to apply to our model.

The `matrix_generator` module is responsible for creating the matrix.

```lucid,short
module matrix_generator (
    input clk,  // clock
    input rst,  // reset
    output matrix[3][4][10], // 2.8 FP
    input stall,
    output valid
) {
    
    const N_PI = -10d402
    const PI = 10d402
    
    cordic cordic (.aclk(clk))
    
    .clk(clk) {
        .rst(rst) {
            dff angle[16] (#INIT(N_PI))
        }
    }
    
    sig cos[10]
    sig sin[10]
    
    always {
        cordic.s_axis_phase_tdata = angle.q
        cordic.s_axis_phase_tvalid = 1
        if (cordic.s_axis_phase_tready) {
            angle.d = angle.q + 5
            if ($signed(angle.q) >= $signed(PI - 5))
                angle.d = N_PI
        }
        
        cordic.m_axis_dout_tready = !stall
        sin = cordic.m_axis_dout_tdata[25:16]
        cos = cordic.m_axis_dout_tdata[9:0]
        valid = cordic.m_axis_dout_tvalid
        
        matrix = 3x{{4x{{10b0}}}}
        
        /*
        // Rotate Z
        matrix[0][0] = cos;
        matrix[0][1] = -sin;
        matrix[1][0] = sin;
        matrix[1][1] = cos;
        matrix[2][2] = 10h100; // 1
        */        
        
        
        // Rotate Y
        matrix[0][0] = cos
        matrix[0][2] = sin
        matrix[1][1] = 10h100 // 1
        matrix[2][0] = -sin
        matrix[2][2] = cos
        
        
        /*
        // Rotate X
        matrix[0][0] = 10h100 // 1
        matrix[1][1] = cos
        matrix[1][2] = -sin
        matrix[2][1] = sin
        matrix[2][2] = cos
        */        
        
        matrix[2][3] = 400 // 1
    }
}
```

For the demo, the matrix will rotate the model along a given axis. 
The default is Y. 
To perform any rotations, we need to calculate the sin and cos values for the angle we want to rotate.

We can calculate these on the FPGA by using the CORDIC core from Xilinx. 
CORDIC is a clever algorithm that can be used to calculate a few things, including sin and cos, efficiently in hardware. 
Check out the [Wikipedia page](https://en.wikipedia.org/wiki/CORDIC) for the nitty-gritty. 
All we care about here is Xilinx provides a module that uses this algorithm, and we can use it to get sin and cos values for an input angle.

We set up the CORDIC core to accept a radian angle input in 3.7 fixed point format. 
This means the input value is 10 bits wide, but the lower 7 bits are fractional. 
For example, `10b0010000000` is equal to 1 and `10b0001000000` is equal to 0.5.

We want to input values from -Pi to Pi. 
To get the value of Pi in 3.7 fixed point, we can multiply it by 2^7. 
Pi * 2^7 ≈ 402.

The output of the CORDIC is in 2.8 fixed point format as the values are bound to +/-1. 
To keep things simple, our matrix will also be in 2.8 fixed point with a minor exception.

You may have noticed the matrix is 3x4 and not 3x3. 
Each row has an extra dimension. 
This dimension is used for translating. 
Technically, a linear transformation can only rotate and scale the input vector. 
However, by working in four dimensions instead of three, we can effectively translate in the third dimension. 
If we force the fourth (aka _W_) value of each input vector to always be 1, we effectively just add the _W_ value of the matrix to it.

This is what happens on the last line of the module where the _Z_ row’s _W_ column is set to `400`. 
This pushes the object 400 units away. 
The _W_ values are 10.0 fixed point, meaning they are standard numbers without a fractional component.

## Stage 2 - Triangle Assembly

Now that we have a matrix to apply to our model, we need to start generating triangles. 
The ROMs that our model is stored in consist of vertices and faces. 
Each face is three numbers that point to a vertex in the vertex ROM. 
That means we first need to fetch the face entry and then use its contents to fetch each vertex to build the entire triangle.

The vertex data itself is in 16.16 fixed point. 
This is the format used through most of the pipeline.

This is all done in the `model_provider` module.

```lucid,short
module model_provider (
    input clk,  // clock
    input rst,  // reset
    input draw,
    input stall,
    output idle,
    output valid,
    output triangle[3]<Geo.p3d>,
    output color[3][16]
) {
    enum State {IDLE, WAIT_FACE, GV1, GV2, GV3, GV4, WAIT}
    
    .clk(clk) {
        suzanne_face_rom face
        suzanne_vert_rom vert
        
        .rst(rst) {
            dff state[$width(State)]
        }
        
        dff face_addr[$clog2(FaceRom.FACES)]
        dff t[3]<Geo.p3d>
        dff c[3][16]
    }
    
    always {
        vert.addr = bx
        face.addr = face_addr.q
        
        color = c.q
        triangle = t.q
        valid = 0   
        
        idle = state.q == State.IDLE
        
        case (state.q) {
            State.IDLE:
                face_addr.d = 0
                if (draw) {
                    state.d = State.WAIT_FACE
                }
            State.WAIT_FACE:
                state.d = State.GV1
            State.GV1:
                vert.addr = face.face[0]
                state.d = State.GV2
            State.GV2:
                vert.addr = face.face[1]
                t.d[0] = vert.vert
                c.d[0] = vert.color
                state.d = State.GV3
            State.GV3:
                vert.addr = face.face[2]
                t.d[1] = vert.vert
                c.d[1] = vert.color
                state.d = State.GV4
            State.GV4:
                t.d[2] = vert.vert
                c.d[2] = vert.color
                state.d = State.WAIT
            State.WAIT:
                if (!stall) {
                    valid = 1
                    if (face_addr.q == FaceRom.FACES-1) {
                        state.d = State.IDLE
                    } else {
                        state.d = State.WAIT_FACE
                        face_addr.d = face_addr.q + 1
                    }
                }
        }
    }
}
```

This module is an FSM that waits for a draw command, fetches a face, fetches each vertex, and then waits for the pipeline to not be stalled.

This is as good a time as any to talk about stalling and back pressure.

This GPU is architected as a pipeline. 
That means that there are many stages that work separately and concurrently from one another with each feeding into the next. 
This architecture allows as much work to be done on each clock cycle as possible, but it has one big caveat. 
Each stage in the pipeline doesn’t take the same amount of time to complete.

For example, it is way faster to fetch a triangle from the ROMs than it is to rasterize it pixel by pixel.

To compensate for this, we need our pipeline to support back pressure. 
This means that later stages can stall previous stages until they are ready for more data. 
This back pressure needs to flow back up through the entire pipeline to prevent lost data.

So when the `stall` signal is `1`, we _must_ wait to output the face and move onto the next one.

It’s worth noting that each vertex has its own color. 
Currently, only the first color is used for the entire triangle, but without too much extra work, each vertex color could be blended across the triangle.

These two stages are packed into the `model_drawer` module. 
This module is kind of like the client of our GPU. 
It makes the requests of what to draw.

```lucid,short
module model_drawer (
    input clk,  // clock
    input rst,  // reset
    input draw,
    output busy,
    output m[3]<Geo.p3d>,
    output color[3][16],
    output model_matrix[3][4][10],
    output valid,
    input stall
) {
    
    enum State {IDLE, GEN_MAT, DRAW}
    
    .clk(clk) {
        .rst(rst) {
            model_provider model
            matrix_generator mat_gen
            
            dff state[$width(State)]
        }
        
        dff matrix[3][4][10]
    }
    
    always {
        m = model.triangle
        color = model.color
        model_matrix = matrix.q
        valid = 0
        busy = state.q != State.IDLE
        
        mat_gen.stall = 1
        model.draw = 0
        model.stall = 1
        
        case (state.q) {
            State.IDLE:
                if (draw) {
                    state.d = State.GEN_MAT
                    model.draw = 1
                }
            State.GEN_MAT:
                mat_gen.stall = 0
                if (mat_gen.valid) {
                    matrix.d = mat_gen.matrix
                    state.d = State.DRAW
                }
            State.DRAW:
                model.stall = stall
                valid = model.valid
                if (model.idle) {
                    state.d = State.IDLE
                }
        }
    }
}
```

## Stage 3 - Transformation

The next stage in the pipeline is the model transformation. 
This stage takes the triangle and multiplies each coordinate by the model matrix.

This is done in the `model_transform` module.

```lucid,short
module model_transform (
    input clk,  // clock
    input rst,  // reset
    input m[3]<Geo.p3d>,
    input color_in[3][16],
    input model_matrix[3][4][10],
    output t[3]<Geo.p3d>,
    output color_out[3][16],
    output valid,
    input stall,
    input draw,
    output busy
) {
    
    enum State {IDLE, P1, P2, P3, P4, P5, P6}
    
    .clk(clk) {
        .rst(rst) {
            dff state[$width(State)] 
        }
        
        dff products[3][3][32]
        dff matrix[3][4][10]
        dff pt<Geo.p3d>
        dff opt<Geo.p3d>
        dff tri[3]<Geo.p3d>
        dff model[3]<Geo.p3d>
        dff color[3][16]
    }
    
    always {
        t = tri.q
        color_out = color.q
        valid = 0
        
        busy = state.q != State.IDLE
        
        
        repeat(i,3) {
            signed sig tmp[48] = $signed(matrix.q[i][0]) * $signed(pt.q.x)
            products.d[i][0] = tmp[8+:32]
            
            tmp = $signed(matrix.q[i][1]) * $signed(pt.q.y)
            products.d[i][1] = tmp[8+:32]
            
            tmp = $signed(matrix.q[i][2]) * $signed(pt.q.z)
            products.d[i][2] = tmp[8+:32]
        }
        
        opt.d.x = products.q[0][0] + products.q[0][1] + products.q[0][2] + c{matrix.q[0][3], 16b0}
        opt.d.y = products.q[1][0] + products.q[1][1] + products.q[1][2] + c{matrix.q[1][3], 16b0}
        opt.d.z = products.q[2][0] + products.q[2][1] + products.q[2][2] + c{matrix.q[2][3], 16b0}
        
        case (state.q) {
            State.IDLE:
                if (draw) {
                    state.d = State.P1
                    matrix.d = model_matrix
                    model.d = m
                    pt.d = m[0]
                    color.d = color_in
                }
            State.P1:
                pt.d = model.q[1]
                state.d = State.P2
            State.P2:
                pt.d = model.q[2]
                state.d = State.P3
            State.P3:
                tri.d[0] = opt.q
                state.d = State.P4
            State.P4:
                tri.d[1] = opt.q
                state.d = State.P5
            State.P5:
                tri.d[2] = opt.q
                state.d = State.P6
            State.P6:
                valid = 1
                if (!stall)
                    state.d = State.IDLE
        }
    }
}
```

When a triangle is fed into the module, each vertex is multiplied by the model matrix. 
This is done in three steps, assign the `pt` `dff` the vertex values, calculate the intermediate products of the multiplication, 
and finally sum them into the next vertex in `opt`.

Note that the _W_ coordinate of the matrix is added directly with the products since the _W_ coordinate of each vertex is implicitly 1 and can skip being multiplied by 1.
It is also shifted 16 bits to the left to convert the 10.0 fixed point format to 10.16 which can be added to the other 16.16 values.

The first three cycles of the FSM feed the values into the pipe, and the next three catch the results as they come out. 
Once all three vertices have been transformed, it attempts to output the new triangle.

Note that color data is passed in and out of this module, but nothing is done to it. 
This is done just to ensure that the color data associated with this triangle stays with this triangle.

## Stage 4 - Shader

The shader is responsible for calculating the color of each vertex.
In our case, this means calculating the cosine of the angle between a vector perpendicular to the triangle and the light source.
Then using this value to apply a shadow to the triangle.

This is done in the `shader` module.

```lucid,short
module shader (
    input clk,  // clock
    input rst,  // reset
    input t_in[3]<Geo.p3d>,
    input color_in[3][16],
    input in_valid,
    input stall,
    output stalled,
    output out_valid,
    output color_out[3][16],
    output t_out[3]<Geo.p3d>
) {
    
    .clk(clk) {
        .rst(rst) {
            dff valid_pipe[4]
            
            cross_product cross
            dot_product nn_dot
            dot_product nl_dot
            
            fifo color_fifo(#ENTRIES(32), #WIDTH(16*3))
            fifo tri_fifo(#ENTRIES(32), #WIDTH(3*3*32))
            dff tri_reg[3*3*32]
            dff color_reg[16*3]
        }
        
        dff u<Geo.p3d>
        dff v<Geo.p3d>
        dff frac[2][8]
        dff color[3][16]
    }
    
    sig pipe_stalled
    sig light<Geo.p3d>
    
    sqrt_calc sqrt(.aclk(clk))
    div_gen_16_16 div(.aclk(clk))
    
    always {
        light.x = Geo.LIGHT[0]
        light.y = Geo.LIGHT[1]
        light.z = Geo.LIGHT[2]
    }
    
    always {
        color_fifo.rget = 0
        color_fifo.wput = 0
        color_fifo.din = bx
        
        tri_fifo.wput = 0
        tri_fifo.din = bx
        tri_fifo.rget = 0
        
        repeat(i,3) {
            t_out[i].z = tri_reg.q[32*3*i+0+:32]
            t_out[i].y = tri_reg.q[32*3*i+32+:32]
            t_out[i].x = tri_reg.q[32*3*i+64+:32]
        }
        
        color_out = color.q
        out_valid = valid_pipe.q[3]
        pipe_stalled = stall
        
        /* Cycle 8 */
        pipe_stalled = pipe_stalled && valid_pipe.q[3]
        if (!pipe_stalled) {
            tri_fifo.rget = valid_pipe.q[2]
            valid_pipe.d[3] = valid_pipe.q[2]
            tri_reg.d = tri_fifo.dout
            
            repeat(i, 3) {
                sig r[5] = color_reg.q[i*16+11+:5]
                sig g[6] = color_reg.q[i*16+5+:6]
                sig b[5] = color_reg.q[i*16+0+:5]
                
                sig tmp[22] = r * frac.q[1]
                r = tmp[7+:5]
                
                tmp = g * frac.q[1]
                g = tmp[7+:6]
                
                tmp = b * frac.q[1]
                b = tmp[7+:5]
                
                color.d[i] = c{r,g,b}
            }
        }
        
        /* Cycle 7 */
        pipe_stalled = pipe_stalled && valid_pipe.q[2]
        
        if (!pipe_stalled) {
            color_fifo.rget = valid_pipe.q[1]
            color_reg.d = color_fifo.dout
            valid_pipe.d[2] = valid_pipe.q[1]
            frac.d[1] = frac.q[0]
        }
        
        /* Cycle 6 */
        pipe_stalled = pipe_stalled && valid_pipe.q[1]
        
        div.m_axis_dout_tready = !pipe_stalled
            
        signed sig quotient[16] = div.m_axis_dout_tdata[21:6]
        signed sig fractinal[6] = div.m_axis_dout_tdata[5:0]
        signed sig result[$width(quotient) + $width(fractinal) - 1]
        if (quotient == 0)
            result = c{16x{fractinal[-1]},fractinal[-2:0]}
        else if (quotient[-1])
            result = -c{-quotient, -fractinal[-2:0]}
        else
            result = c{quotient, fractinal[-2:0]}
        
        if (!pipe_stalled) {
            valid_pipe.d[1] = div.m_axis_dout_tvalid
            if (result[-1]) {
                frac.d[0] = 8h40 // 0.5 minimum
            } else {                         
                frac.d[0] = result[0+:8] + 8h40 // 1.7 fixed point between 0.5 and 1
            }
        }
        
        /* Cycle 5 */
        div.s_axis_dividend_tvalid = sqrt.m_axis_dout_tvalid
        div.s_axis_divisor_tvalid = sqrt.m_axis_dout_tvalid
        div.s_axis_dividend_tdata = sqrt.m_axis_dout_tuser   // normal and light dot product
        div.s_axis_divisor_tdata = sqrt.m_axis_dout_tdata    // normal vector magnitued
        sqrt.m_axis_dout_tready = div.s_axis_dividend_tready & div.s_axis_divisor_tready
        
        /* Cycle 4 */
        sqrt.s_axis_cartesian_tvalid = nn_dot.out_valid
        sqrt.s_axis_cartesian_tuser = nl_dot.dot[16+:16]
        sqrt.s_axis_cartesian_tdata = nn_dot.dot[16+:31]
        pipe_stalled = !sqrt.s_axis_cartesian_tready
        
        /* Cycle 3 */
        nn_dot.in_valid = cross.out_valid
        nn_dot.u = cross.ucv
        nn_dot.v = cross.ucv
        nn_dot.stall = pipe_stalled
        
        nl_dot.in_valid = cross.out_valid
        nl_dot.u = cross.ucv
        nl_dot.v = light
        nl_dot.stall = pipe_stalled
        
        pipe_stalled = nn_dot.stalled
        
        /* Cycle 2 */
        cross.in_valid = valid_pipe.q[0]
        cross.stall = pipe_stalled
        pipe_stalled = cross.stalled
        
        cross.u = u.q
        cross.v = v.q
        
        /* Cycle 1 */
        // calculate u and v
        pipe_stalled = pipe_stalled && valid_pipe.q[0]
        
        if (!pipe_stalled) {
            valid_pipe.d[0] = in_valid
            
            u.d.x = t_in[1].x - t_in[0].x
            u.d.y = t_in[1].y - t_in[0].y
            u.d.z = t_in[1].z - t_in[0].z
            
            v.d.x = t_in[2].x - t_in[0].x
            v.d.y = t_in[2].y - t_in[0].y
            v.d.z = t_in[2].z - t_in[0].z
            
            color_fifo.din = $flatten(color_in)
            color_fifo.wput = in_valid
            
            tri_fifo.din = $flatten(t_in)
            tri_fifo.wput = in_valid
        }
        
        if (color_fifo.full || tri_fifo.full) {
            if (!pipe_stalled)
                valid_pipe.d[0] = 0
            color_fifo.wput = 0
            tri_fifo.wput = 0
            pipe_stalled = 1
        }
        
        stalled = pipe_stalled
    }
}
```

The module starts by calculating the cross-product of two edges of the triangle.
This results in a vector that is perpendicular (aka _normal_) to the triangle. 

Dot products are then calculated between the normal vector and itself and the normal vector and light vector.
A dot product calculates the cosine between two vectors multiplied by their magnitudes.

The dot product of the normal vector and itself is the magnitude of the normal vector squared.
We can take the square-root of this using another CORDIC module.

If we then divide the dot product of the normal and light vectors by the magnitude of the normal vector, we get just
the cosine of the angle between the normal and the light vector.
This is because the light vector magnitude is defined to be 1, so we don't need to divide it out.

The cosine value is then clipped to be between 0.5 and 1.
By setting a minimum we make sure that even triangles facing away from the light source still have some color to them.

We multiply the vertices' colors by this fraction and output them as the new colors.

## Stage 5 - Projector

The projector stage is responsible for taking the 3D vertices and projecting them onto the 2D screenspace.

This is done in the `projector` module.

```lucid,short
module projector (
    input clk,  // clock
    input rst,  // reset
    input t[3]<Geo.p3d>,
    output p[3]<Geo.p3d>,
    input in_valid,
    output out_valid,
    output dr[32], // 1/((y1-y2)(x0-x2) + (x2-x1)(y0-y2)) in 8.24 FP
    input stall,
    output ready
) {
    
    enum State {IDLE, X, Y, Z, R1, R2, R3, R4}
    
    .clk(clk) {
        .rst(rst) {
            dff state[$width(State)]
        }
        signed dff a[32]
        signed dff b[32]
        signed dff c[32]
        signed dff d[32]
        signed dff mul[64]
        
        dff dp[3]<Geo.p4d>
        dff pt_ct[2]
        
        dff op[3]<Geo.p3d>
        dff odr[32]
        dff out_ready
    }
    
    div_gen_0 divider(.aclk(clk))
    
    always {
        if (!stall)
            out_ready.d = 0
        out_valid = out_ready.q
        dr = odr.q
        p = op.q
        
        divider.s_axis_divisor_tvalid = 0
        divider.s_axis_divisor_tuser = bx
        divider.s_axis_divisor_tdata = bx
        
        divider.s_axis_dividend_tvalid = 0
        divider.s_axis_dividend_tdata = bx
        
        signed sig quotient[32] = divider.m_axis_dout_tdata[50:19]
        signed sig fractinal[19] = divider.m_axis_dout_tdata[18:0]
        signed sig result[$width(quotient) + $width(fractinal) - 1]
        
        if (quotient == 0)
            result = c{32x{fractinal[-1]},fractinal[-2:0]}
        else if (quotient[-1])
            result = -c{-quotient, -fractinal[-2:0]}
        else
            result = c{quotient, fractinal[-2:0]}
        
        if (divider.m_axis_dout_tvalid) {
            case (divider.m_axis_dout_tuser[1:0]) {
                2d0:
                    op.d[divider.m_axis_dout_tuser[3:2]].x = result[0+:32]
                2d1:
                    op.d[divider.m_axis_dout_tuser[3:2]].y = result[0+:32]
                2d2:
                    op.d[divider.m_axis_dout_tuser[3:2]].z = result[2+:32]
                2d3:
                    odr.d = result[4+:32]
                    out_ready.d = 1
            }
        }
        
        ready = state.q == State.IDLE
        
        divider.m_axis_dout_tready = !stall
        
        sig div_ready = divider.s_axis_dividend_tready && divider.s_axis_divisor_tready
        
        case (state.q) {
            State.IDLE:
                if (in_valid) {
                    repeat(i,3) {
                        signed sig tmp[64] = $signed(t[i].x) * $signed(Geo.PROJ_MAT[0][0])
                        dp.d[i].x = tmp[18+:35]
                        tmp = $signed(t[i].y) * $signed(Geo.PROJ_MAT[1][1])
                        dp.d[i].y = tmp[18+:35]
                        tmp = $signed(t[i].z) * $signed(Geo.PROJ_MAT[2][2])
                        dp.d[i].z = tmp[16+:35] + $signed(Geo.PROJ_MAT[2][3])
                        dp.d[i].w = t[i].z
                    }
                    state.d = State.X
                }
                pt_ct.d = 0
            State.X:
                divider.s_axis_divisor_tuser = c{pt_ct.q, 2d0}
                divider.s_axis_dividend_tdata = dp.q[pt_ct.q].x // top number
                divider.s_axis_divisor_tdata = dp.q[pt_ct.q].w  // bottom number
                
                if (div_ready) {
                    state.d = State.Y
                    divider.s_axis_dividend_tvalid = 1
                    divider.s_axis_divisor_tvalid = 1
                }
            State.Y:
                divider.s_axis_divisor_tuser = c{pt_ct.q, 2d1}
                divider.s_axis_dividend_tdata = dp.q[pt_ct.q].y // top number
                divider.s_axis_divisor_tdata = dp.q[pt_ct.q].w  // bottom number
                
                if (div_ready) {
                    state.d = State.Z
                    divider.s_axis_dividend_tvalid = 1
                    divider.s_axis_divisor_tvalid = 1
                }
            State.Z:
                divider.s_axis_divisor_tuser = c{pt_ct.q, 2d2}
                divider.s_axis_dividend_tdata = dp.q[pt_ct.q].z // top number
                divider.s_axis_divisor_tdata = dp.q[pt_ct.q].w  // bottom number
                
                if (div_ready) {
                    divider.s_axis_dividend_tvalid = 1
                    divider.s_axis_divisor_tvalid = 1
                    
                    pt_ct.d = pt_ct.q + 1
                    if (pt_ct.q == 2) {
                        state.d = State.R1
                    } else {
                        state.d = State.X
                    }
                }
            State.R1:
                if (divider.m_axis_dout_tvalid && (divider.m_axis_dout_tuser[3:0] == 4b1010))
                    state.d = State.R2
            State.R2:
                a.d = op.q[1].y - op.q[2].y
                b.d = op.q[0].x - op.q[2].x
                c.d = op.q[2].x - op.q[1].x
                d.d = op.q[0].y - op.q[2].y
                state.d = State.R3
            State.R3:
                mul.d = ($signed(a.q) * $signed(b.q)) + ($signed(c.q) * $signed(d.q))
                state.d = State.R4
            State.R4:
                divider.s_axis_divisor_tuser = c{2b11, 2b11}
                divider.s_axis_dividend_tdata = 32h01000000 // 1 in 8.24
                divider.s_axis_divisor_tdata = mul.q[18+:32]  // bottom number
                
                if (div_ready) {
                    divider.s_axis_dividend_tvalid = 1
                    divider.s_axis_divisor_tvalid = 1
                    state.d = State.IDLE
                }
        }
    }
}
```

This module takes some shortcuts by making assumptions about the projection matrix.
It assumes that only values (0,0), (1,1), (2,2), and (2,3) hold meaningful data, (3,3) is 1, and everything else is 0.

Most values being 0 means we can save a lot of multiplications.

The projection matrix defined in `geometry_definitions` is for a frustum projection with z-clipping at 100-1000.

```lucid,linenos,linenostart=36
    // Z-Clip is 100 to 1000
    // reverse is used so that it can be typed in normal notaion and [0][0] is the top left
    const PROJ_MAT = $reverse({
            $reverse({32h06000000, 32d0, 32d0, 32d0}),
            $reverse({32d0, 32h06000000, 32d0, 32d0}),
            $reverse({32d0, 32d0, 32d80100, $resize(-32d14563556,32)}),
            $reverse({32d0, 32d0, FP1616_1, 32d0})
        })
```

After the vertex is multiplied by this matrix, we need to normalize it so that the _W_ component is 1.
This is how we end up scaling X and Y based on the Z value.
The matrix is set up so that the W value _is_ the original Z value.

The `X`, `Y`, and `Z` states of the FSM use the divider to divide each value by _W_.
The same divider is used to save resources as this isn't typically the bottleneck for rendering.

Finally, the module calculates the determinant for the triangle.
This doesn't really logically fit in the projection module, but it needs a divider to do the calculation.
By putting it here, we can reuse the same divider again.

We will get to what this value is and how it is used in the [rasterizer](#stage-7-rasterizer).

## Stage 6 - Bounding Box

The bounding box stage is relatively simple compared to what we've seen so far.
It takes in the triangle data and outputs the minimum bounding box that the rasterizer will need to scan over.

It takes into account the display resolution, so time isn't wasted looking at pixels off-screen.

```lucid,short
module bounding_box (
    input clk,  // clock
    input rst,  // reset
    input stall,
    input in_valid,
    output stalled,
    output out_valid,
    input it[3]<Geo.p3d>,
    output ot[3]<Geo.p3d>,
    output max<Geo.p2d>,
    output min<Geo.p2d>
) {
    
    .clk(clk) {
        .rst(rst) {
            dff valid_pipe
        }
        dff t_pipe[3]<Geo.p3d>
        dff dmax<Geo.p2d>
        dff dmin<Geo.p2d>
    }
    
    const DISP_BOUNDS_X = $fixed_point(Geo.DISP_H/2, 32, 16)
    const DISP_BOUNDS_Y = $fixed_point(Geo.DISP_V/2, 32, 16)
    
    always {
        ot = t_pipe.q
        out_valid = valid_pipe.q
        
        stalled = stall && valid_pipe.q
        
        if (!stall || !valid_pipe.q) {
            valid_pipe.d = in_valid
            t_pipe.d = it
            
            signed sig maxy[32] = it[0].y
            signed sig maxx[32] = it[0].x
            signed sig miny[32] = it[0].y
            signed sig minx[32] = it[0].x
            
            repeat(i, 2, 1) {
                if ($signed(maxy) < $signed(it[i].y))
                    maxy = it[i].y
                if ($signed(maxx) < $signed(it[i].x))
                    maxx = it[i].x
                if ($signed(miny) > $signed(it[i].y))
                    miny = it[i].y
                if ($signed(minx) > $signed(it[i].x))
                    minx = it[i].x
            }
            
            // clamp to display edges
            if ($signed(maxx) > $signed(DISP_BOUNDS_X))
                maxx = DISP_BOUNDS_X
            if ($signed(maxx) < $signed(-DISP_BOUNDS_X))
                maxx = -DISP_BOUNDS_X
            if ($signed(minx) > $signed(DISP_BOUNDS_X))
                minx = DISP_BOUNDS_X
            if ($signed(minx) < $signed(-DISP_BOUNDS_X))
                minx = -DISP_BOUNDS_X
            
            if ($signed(maxy) > $signed(DISP_BOUNDS_Y))
                maxy = DISP_BOUNDS_Y
            if ($signed(maxy) < $signed(-DISP_BOUNDS_Y))
                maxy = -DISP_BOUNDS_Y
            if ($signed(miny) > $signed(DISP_BOUNDS_Y))
                miny = DISP_BOUNDS_Y
            if ($signed(miny) < $signed(-DISP_BOUNDS_Y))
                miny = -DISP_BOUNDS_Y
            
            dmax.d.x = maxx[31:16]
            dmax.d.y = maxy[31:16]
            dmin.d.x = minx[31:16]
            dmin.d.y = miny[31:16]
        }
        
        max = dmax.q
        min = dmin.q
    }
}
```

## Stage 7 - Rasterizer

The rasterizer is the heart of the whole pipeline.
This stage is responsible for figuring out what pixels belong to the triangle.

It takes in the triangle data (vertices, colors, determinant, and bounding box) and outputs the barycentric 
weights for every display address that is covered by the triangle.

This is done in the `rasterizer` module.

```lucid,short
module rasterizer (
    input clk,  // clock
    input rst,  // reset
    input t[3]<Geo.p3d>,    // triangle points
    input dr[32],         // 1/((y1-y2)(x0-x2) + (x2-x1)(y0-y2)) in 8.24 FP
    input pt_min<Geo.p2d>,  // top left corner of bounding box
    input pt_max<Geo.p2d>,  // bottom right corner of bounding box
    input start,
    output disp_addr[28], // address data
    output valid,
    output weights[3][32],
    output z[3][32],
    input stall,
    output idle
) {
    
    .clk(clk) {
        .rst(rst) {
            dff active
            dff valid_pipe[7]
        }
        
        barycentric_calc bary
        
        dff min<Geo.p2d>
        dff max<Geo.p2d>
        dff triangle[3]<Geo.p3d>
        signed dff denom[32]
        dff current_point<Geo.p2d>
        dff covered_point[7]<Geo.p2d>
    }
    
    sig covered
    
    sig invY[28]
    sig dptx[16]
    sig dpty[16]
    
    always {
        valid = 0
        idle = !active.q && !stall && (valid_pipe.q == 0)
        
        bary.t = triangle.q
        bary.dr = denom.q
        bary.pt = current_point.q
        bary.stall = stall
        
        if (!stall) {
            valid_pipe.d = c{valid_pipe.q[-2:0], active.q}
            covered_point.d[0] = current_point.q
            covered_point.d[6:1] = covered_point.q[5:0]
            
            if (!active.q && (valid_pipe.q == 0) && start) {
                active.d = 1
                max.d = pt_max
                min.d = pt_min
                triangle.d = t
                denom.d = dr
                current_point.d = pt_min
            }
            
            if (active.q) {
                current_point.d.x = current_point.q.x + 1
                if (current_point.q.x == max.q.x) {
                    current_point.d.x = min.q.x
                    current_point.d.y = current_point.q.y + 1
                    if (current_point.q.y == max.q.y) {
                        active.d = 0
                    }
                }
            }
        }
        
        dptx = covered_point.q[6].x + (Geo.DISP_H/2)
        dpty = covered_point.q[6].y + (Geo.DISP_V/2)
        
        invY = Geo.DISP_V - 1 - dpty // flip y so up is up
        disp_addr = dptx + invY * Geo.DISP_H // x + y * X_RES
        
        repeat(i, 3)
            z[i] = triangle.q[i].z
        
        covered = bary.covered
        weights = bary.w
        
        valid = covered && !stall && valid_pipe.q[6]
    }
}
```

The core of the module lies in calculating the barycentric weights for each pixel.

This actually happens in a separate module, the `barycentric_calc` module.

```lucid,short
/* 7-cycle latency */
module barycentric_calc (
    input clk,  // clock
    input t[3]<Geo.p3d>,  // triangle points
    input dr[32],   // 1/((y1-y2)(x0-x2) + (x2-x1)(y0-y2)) in 8.24 FP
    input pt<Geo.p2d>,   // point to test
    input stall,
    output covered,
    output w[3][32] // weights in 8.24 FP
) {
    
    .clk(clk) {
        signed dff a[32]
        signed dff b[32]
        signed dff c[32]
        signed dff d[32]
        signed dff e[32]
        signed dff f[32]
        signed dff ara[32]
        signed dff arb[32]
        signed dff arc[32]
        signed dff ard[32]
        signed dff mar[64]
        signed dff mar1[2][64]
        signed dff mar2[2][64]
        signed dff m1[64]
        signed dff m2[64]
        signed dff dp[4][32]
        signed dff wp[3][32]
        signed dff mr1[2][64]
        signed dff mr2[2][64]
        signed dff mr3[2][64]
        signed dff mr4[2][64]
        signed dff wr1[2][32]
        signed dff wr2[2][32]
        signed dff wun1[64]
        signed dff wun2[64]
        signed dff wun3[64]
        dff covered_pipe[2]
    }
    
    always {
        if (!stall) {
            /* Cycle 1 */
            a.d = t[1].y - t[2].y
            b.d = t[2].x - t[1].x
            c.d = t[2].y - t[0].y
            d.d = t[0].x - t[2].x
            e.d = c{pt.x, 16b0} - t[2].x
            f.d = c{pt.y, 16b0} - t[2].y
            dp.d[0] = dr
            ara.d = t[1].y - t[2].y
            arb.d = t[0].x - t[2].x
            arc.d = t[2].x - t[1].x
            ard.d = t[0].y - t[2].y
            
            /* Cycle 2 */
            mr1.d[0] = $signed(a.q) * $signed(e.q)
            mr2.d[0] = $signed(b.q) * $signed(f.q)
            mr3.d[0] = $signed(c.q) * $signed(e.q)
            mr4.d[0] = $signed(d.q) * $signed(f.q)
            dp.d[1] = dp.q[0]
            mar1.d[0] = $signed(ara.q) * $signed(arb.q)
            mar2.d[0] = $signed(arc.q) * $signed(ard.q)
            
            /* Cycle 3 */
            mr1.d[1] = mr1.q[0]
            mr2.d[1] = mr2.q[0]
            mr3.d[1] = mr3.q[0]
            mr4.d[1] = mr4.q[0]
            dp.d[2] = dp.q[1]
            mar1.d[1] = mar1.q[0]
            mar2.d[1] = mar2.q[0]
            
            /* Cycle 4 */
            m1.d = mr1.q[1] + mr2.q[1]
            m2.d = mr3.q[1] + mr4.q[1]
            dp.d[3] = dp.q[2]
            mar.d = mar1.q[1] + mar2.q[1]
            
            /* Cycle 5 */
            wun1.d = m1.q
            wun2.d = m2.q
            wun3.d = mar.q - m1.q - m2.q
            
            sig tmp1[128] = $signed(m1.q[16+:32]) * $signed(dp.q[2])
            sig tmp2[128] = $signed(m2.q[16+:32]) * $signed(dp.q[2])
            wr1.d[0] = tmp1[16+:32] + tmp1[48]
            wr2.d[0] = tmp2[16+:32] + tmp2[48]
            
            /* Cycle 6 */
            wr1.d[1] = wr1.q[0]
            wr2.d[1] = wr2.q[0]
            if (wun1.q[63] || wun2.q[63] || wun3.q[63])
                covered_pipe.d[0] = 0
            else
                covered_pipe.d[0] = 1
            
            /* Cycle 7 */
            wp.d[0] = wr1.q[1]
            wp.d[1] = wr2.q[1]
            wp.d[2] = 32h01000000 - wr1.q[1] - wr2.q[1]
            covered_pipe.d[1] = covered_pipe.q[0]
        }
        
        w = wp.q
        covered = covered_pipe.q[1]
    }
}
```

OK, so what are barycentric weights or coordinates?
Without diving into the math, they're a way to represent the location of any point relative to the vertices of the triangle.

Each point has three weights.
They correspond to the signed area of the triangle formed from that point and a pair of points on the triangle divided by the 
area of the main triangle.

If all three weights are positive, then the point lies inside the triangle.
If any of them are negative, then the point lies outside the triangle and can be ignored.

This is only one way to check if a point lines within a triangle, but it has some nice properties.

By definition, the three weights sum to 1.
They also have the nice property of allowing for linear interpolation between the three triangle points.

This is critical in the next stage, the Z-buffer, as we need the Z coordinate for each pixel.
We can use the three barycentric weights to interpolate the triangle's vertices' Z coordinates to get the pixel's coordinates.

It can also be used for more advanced GPU features that aren't implemented here, like smooth shading.
To do smooth shading, each vertex has its own normal vector, and the three vectors are interpolated across the triangle.

## Stage 8 - Z-Buffer

If we were just drawing one triangle, then we could skip this stage.
However, we need to account for when triangles overlap.
We can do this by keeping track of how far away each pixel is on screen.

If the pixel we are about to draw is closer than the one on screen, we draw our new pixel.
If not, we throw away our pixel.

This is done in the `z_buffer` module.

```lucid,short
module z_buffer (
    input clk,  // clock
    input rst,  // reset
    input addr_in[28],
    input in_valid,
    input weights_in[3][32],
    input z[3][32],
    input color_in[3][16],
    output stalled,
    input stall,
    output addr_out[28],
    output out_valid,
    output weights_out[3][32],
    output color_out[3][16],
    input mem_out<Memory.out>,
    output mem_in<Memory.in>,
    input flush_cache,
    input frame[2]
) {
    const Z_MAX = 32d16777216  // 1
    const Z_MIN = -32d16777216 // -1
    
    const PIPE_LENGTH = 5
    
    enum State {IDLE, WAIT_READ}
    
    .clk(clk) {
        lru_cache cache(.rst(rst))
        .rst(rst) {
            dff valid_pipe[PIPE_LENGTH-1]
            dff read_valid
            dff state[$width(State)]
        }
        
        dff m[3][32]
        
        dff weight_pipe[PIPE_LENGTH][3][32]
        dff addr_pipe[PIPE_LENGTH][28]
        dff color_pipe[PIPE_LENGTH][3][16]
        
        dff wz[4][32]
        
        dff read_data[16]
    }
    
    always {
        sig pipe_stalled = stall
        
        cache.mem_out = mem_out
        mem_in = cache.mem_in
        cache.flush = flush_cache
        cache.wr_addr = addr_pipe.q[4] | Geo.Z_BUFFER_MASK | (frame << (Geo.FRAME_BITS+3))
        cache.wr_data = bx
        cache.wr_valid = 0
        cache.rd_addr = addr_pipe.q[2] | Geo.Z_BUFFER_MASK | (frame << (Geo.FRAME_BITS+3))
        cache.rd_cmd_valid = b0
        
        addr_out = addr_pipe.q[PIPE_LENGTH-1] | (frame << (Geo.FRAME_BITS+3))
        out_valid = valid_pipe.q[PIPE_LENGTH-2] && cache.wr_ready
        weights_out = weight_pipe.q[PIPE_LENGTH-1]
        color_out = color_pipe.q[PIPE_LENGTH-1]
        
        /* Cycle 6 */
        pipe_stalled = pipe_stalled || !cache.wr_ready
        
        if (!pipe_stalled) {
            cache.wr_valid = valid_pipe.q[3]
            cache.wr_data = wz.q[3][10+:16]
        }
        
        /* Cycle 4 & 5 */
        pipe_stalled = pipe_stalled && valid_pipe.q[3]
        
        case (state.q) {
            State.IDLE:
                if (!pipe_stalled)
                    valid_pipe.d[3] = 0
                if (valid_pipe.q[2] && cache.rd_ready) {
                    cache.rd_cmd_valid = 1
                    weight_pipe.d[3] = weight_pipe.q[2]
                    addr_pipe.d[3] = addr_pipe.q[2]
                    color_pipe.d[3] = color_pipe.q[2]
                    wz.d[2] = wz.q[1]
                    state.d = State.WAIT_READ
                }
            State.WAIT_READ:
                if (pipe_stalled && cache.rd_data_valid) {
                    read_data.d = cache.rd_data
                    read_valid.d = 1
                }
                
                if (!pipe_stalled) {
                    sig active = 0
                    signed sig comp_data[16] = bx
                    if (cache.rd_data_valid) {
                        active = 1
                        comp_data = cache.rd_data
                    } else if (read_valid.q) {
                        active = 1
                        comp_data = read_data.q
                        read_valid.d = 0
                    }
                    
                    valid_pipe.d[3] = 0
                    
                    if (active) {
                        if ($signed(comp_data) < $signed(wz.q[2][10+:16]))
                            valid_pipe.d[3] = 0
                        else
                            valid_pipe.d[3] = 1
                        
                        wz.d[3] = wz.q[2]
                        weight_pipe.d[4] = weight_pipe.q[3]
                        addr_pipe.d[4] = addr_pipe.q[3]
                        color_pipe.d[4] = color_pipe.q[3]
                        state.d = State.IDLE
                    }
                }
        }
        
        pipe_stalled = (state.q != State.IDLE) || !cache.rd_ready
        
        /* Cycle 3 */
        pipe_stalled = pipe_stalled && valid_pipe.q[2]
        
        if (!pipe_stalled) {
            if (($signed(wz.q[0]) > $signed(Z_MAX)) || ($signed(wz.q[0]) < $signed(Z_MIN))) // only write if in bounds
                valid_pipe.d[2] = 0
            else
                valid_pipe.d[2] = valid_pipe.q[1]
            weight_pipe.d[2] = weight_pipe.q[1]
            color_pipe.d[2] = color_pipe.q[1]
            addr_pipe.d[2] = addr_pipe.q[1]
            wz.d[1] = wz.q[0]
        }
        
        /* Cycle 2 */
        pipe_stalled = pipe_stalled && valid_pipe.q[1]
        
        if (!pipe_stalled) {
            addr_pipe.d[1] = addr_pipe.q[0]
            color_pipe.d[1] = color_pipe.q[0]
            valid_pipe.d[1] = valid_pipe.q[0]
            weight_pipe.d[1] = weight_pipe.q[0]
            wz.d[0] = m.q[0] + m.q[1] + m.q[2]
        }
        
        /* Cycle 1 */
        pipe_stalled = pipe_stalled && valid_pipe.q[0]
        
        if (!pipe_stalled) {
            addr_pipe.d[0] = addr_in
            color_pipe.d[0] = color_in
            valid_pipe.d[0] = in_valid
            weight_pipe.d[0] = weights_in
            repeat(i,3) {
                sig tmp[64] = z[i] * weights_in[i]
                m.d[i] = tmp[16+:32]
            }
        }
        
        stalled = pipe_stalled
    }
}
```

This module starts by calculating this pixel's Z value using the barycentric weights from the rasterizer and the 
triangle's Z values.
This is done using a weighted sum.

Once we have the Z value, we need to read the Z value from the Z-buffer.
The Z-buffer is stored in the DDR memory and has an entry for every pixel.

When a new frame is being prepared to be rendered, the buffer is filled with maximum distance at every pixel so any pixel will override it.

If a pixel is in front of the current z-buffer value, we output that pixel and its associated colors and barycentric weights.
We also need to write this pixel's Z value to the buffer so future pixels don't cover it unless they're in front.

Right now, the barycentric weights and two of the three vertex colors are ignored.
However, another module that interpolates the three colors with the weights could be added to allow blended colors on a single triangle.

The barycentric weights along with texture coordinates could be used to texture map the triangle.
If this was implemented, we would keep track of texture coordinates instead of color for each vertex.
At this stage, we would then interpolate the texture coordinates and use that to look up the color in the texture at that location.

As you can see, the barycentric weights provide a powerful tool beyond just calculating if a pixel is inside or outside the triangle.

## Stage 9 - Write Buffer

The last stage is writing the pixel to the framebuffer.

This isn't strictly part of the graphics pipeline, but since we are storing the framebuffer in the DDR memory we need to
spend a little effort in using it efficiently.

The DDR controller batches reads and writes in 128-bit chunks. 
Our values are only 16 bits wide, so we can batch eight of them to each memory access.

This is what the `write_buffer` does for us.

```lucid,short
module write_buffer (
    input clk,  // clock
    input rst,  // reset
    input addr[28],
    input data[16],
    input valid,
    input flush,
    output ready,
    input mem_out<Memory.out>,
    output mem_in<Memory.in>
) {
    
    enum State {IDLE, WRITE_DATA, WRITE_CMD}
    
    .clk(clk) {
        .rst(rst) {
            dff dirty[8]
            dff state[$width(State)]
        }
        dff buffer[8][16]
        dff address[25]
        dff tmp[16]
        dff new_addr[28]
        dff flushing
    }
    
    
    always {
        mem_in.enable = 0
        mem_in.wr_data = $flatten(buffer.q)
        mem_in.cmd = 0
        mem_in.addr = c{address.q, 3b000}
        mem_in.wr_enable = 0
        ready = state.q == State.IDLE
        
        repeat(i, 8)
            mem_in.wr_mask[i*2+:2] = 2x{~dirty.q[i]}
        
        case (state.q) {
            State.IDLE:
                if (flush && |dirty.q) {
                    flushing.d = 1
                    mem_in.wr_enable = 1
                    if (mem_out.wr_rdy) {
                        state.d = State.WRITE_CMD
                    } else {
                        state.d = State.WRITE_DATA
                    }
                }
                if (valid) {
                    if (addr[27:3] == address.q) {
                        buffer.d[addr[2:0]] = data
                        dirty.d[addr[2:0]] = 1
                    } else if (|dirty.q) {
                        tmp.d = data
                        new_addr.d = addr
                        
                        flushing.d = 0
                        mem_in.wr_enable = 1
                        if (mem_out.wr_rdy) {
                            state.d = State.WRITE_CMD
                        } else {
                            state.d = State.WRITE_DATA
                        }
                    } else {
                        buffer.d[addr[2:0]] = data
                        dirty.d[addr[2:0]] = 1
                        address.d = addr[27:3]
                    }
                }
            
            State.WRITE_DATA:
                mem_in.wr_enable = 1
                if (mem_out.wr_rdy) {
                    state.d = State.WRITE_CMD
                }
            
            State.WRITE_CMD:
                mem_in.enable = 1
                if (mem_out.rdy) {
                    if (!flushing.q) {
                        buffer.d[new_addr.q[2:0]] = tmp.q
                        dirty.d = 8b1 << new_addr.q[2:0]
                        address.d = new_addr.q[27:3]
                    } else {
                        dirty.d = 0
                    }
                    state.d = State.IDLE
                }
        }
    }
}
```

This module allows individual 16-bit values to be written arbitrarily to memory locations and only writes them out
when the next value doesn't reside in the same chunk.

It also keeps track of which pieces of the chunk have been written to so it can mask out the unwritten sections.
This prevents the need for it to read the current value when doing a partial write.

Since the stage before this is the rasterizer that checks each pixel in order, most of the writes will be sequential.
That means we will take advantage of batching writes under most conditions.

Once a full frame has been rendered, it is flipped and streamed over the HDMI port of the Hd.
The old dirty frame is cleaned up and the process starts again.