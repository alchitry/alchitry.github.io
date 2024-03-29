+++
title = "GPU"
inline_language = "lucid"
weight = 0
+++

{{ video(url="https://cdn.alchitry.com/projects/gpu/gpu.mp4") }}
# Design Your Own GPU

This project has been a long time coming. For quite a while I was waiting until I finished some Alchitry Labs features that would allow me to embed the entire project as an example project, but, those features have been on the back burner for too long! It was time to just get this project out there!

This is by far the most complicated project/tutorial I’ll ever have created. On this first page I’ll be giving a rough overview of the main pieces and in later pages I’ll be diving deep into how each one works.

Without further ado, you can download the [entire project by clicking here](https://cdn.alchitry.com/projects/gpu/GPU%20Demo.zip).

The project is an Alchitry Labs project and is for the [Alchitry Au](@/boards/au.md). In those files, I also included the Blender file for the Suzanne (the monkey) model and the Java program I wrote to convert the .ply Blender export to multiple Lucid ROMs. I build it with Vivado 2020.2. If you use a newer version of Vivado you may need to regenerate the IP Cores.

The LCD I used is [this 3.5” 320x480 model](https://www.adafruit.com/product/2050) from Adafruit. The actual output you use isn’t particularly important and the project could be modified to output the stream to just about anything. This LCD was nice as it allows you to write directly to the GRAM and Adafruit’s board made it easy to hook up. If you buy this board and wire it to a Br element as outlined in the lcd.acf constraint file, you should be able to just build and load the project to get the demo running.

## Basic Architecture

Before getting into any FPGA specific details, we need to go over what our goal is and what has to happen to get there.

The goal of this GPU is to take a 3D model and render it onto a 2D frame. When you put it like that it doesn’t sound so bad. There are a few minor other details to consider first though…

Graphics in general rely heavily on linear algebra. If you aren’t familiar with vectors and matrices, now would be a good time to freshen up. There are tons of tutorials out there about it. For most of this tutorial, you really only need to know how to multiply a vector by a matrix.

Our GPU will accept a few parameters.

First, we need something to draw. Our GPU, like every good GPU, will draw triangles. We will specify the triangles with two ROMs. The first ROM contains all the vertices (and colors of those vertices). The second ROM contains the faces. That is, the list of three vertices that make up a triangle.

While manually coming up with and typing out hundreds of vertices and faces sounds fun, this is where Blender and the Java code mentioned above come in handy. A model created in Blender can be exported and converted into these ROM files so our GPU can draw anything pretty easily.

Second, we need a model transformation matrix. This matrix is responsible for moving around objects. By multiplying our model’s 3D points by this matrix, we can rotate, translate, and scale the model however we want. Most render’s will have two of these. One for the model and one for the camera (viewpoint into the scene). To keep things a bit simpler, our pipeline will only have one. Our camera will be stationary but you could make it seem like it is moving by transforming the entire scene.

By using a matrix to specify the transformations, our GPU only needs to perform basic matrix multiplication instead of trig to rotate points! The trig functions still need to be calculated but only once (per object) to produce the matrix.

We also need some kind of lighting. We could have no lighting and just color every triangle its specified color but this significantly reduces the perceived details of the model. There are huge numbers of ways to calculate lighting in a scene with the holy grail being ray tracing. That is where you simulate the actual rays of light and calculate how they bounce and interact with the objects in the scene. This is what you can get with a modern GPU and is not what we will be doing.

Instead, we will be taking a much simpler approach. Our GPU will accept a single light vector. That is, the direction light is coming from. We will then calculate the angle between each triangle and the light vector and use that to calculate the color. This method has no concept of shadows which are substantially more complicated. It still produces a nice effect where we can make it look like things are illuminated from above.

Finally we need a projection matrix for converting 3D points to 2D points. This matrix is setup in such a way that when a 3D point is multiplied by it, we will get the 2D coordinate of it. We will be using a fixed frustum style projection. This project works in such a way that further objects appear smaller. At the core of it, you basically just divide the X and Y coordinates by their Z coordinate. Larger Z (further away) means the X and Y get pulled more into the center of the frame.

## The Pipeline

### Stage 1 - Generate the Model Matrix

I wouldn’t necessarily consider this part of the GPU’s job as this matrix would generally be provided to the GPU. However, our pipeline is self contained and this matrix is the first thing needed for producing a frame.

As mentioned above, this matrix is responsible for all the translations, rotations, and scaling, we want to apply to our model.

The _matrix_generator_ module is responsible for creating the matrix.

```lucid,short
module matrix_generator (
    input clk,  // clock
    input rst,  // reset
    output matrix[3][4][10],
    input stall,
    output valid
  ) {
   
  const N_PI = -10d402;
  const PI = 10d402;
   
  cordic cordic (.aclk(clk));
   
  .clk(clk) {
    .rst(rst) {
      dff angle[16] (#INIT(N_PI));
    }
  }
   
  sig cos[10], sin[10];
   
  always {
    cordic.s_axis_phase_tdata = angle.q;
    cordic.s_axis_phase_tvalid = 1;
    if (cordic.s_axis_phase_tready) {
      angle.d = angle.q + 5;
      if ($signed(angle.q) >= $signed(PI - 5))
        angle.d = N_PI;
    }
     
    cordic.m_axis_dout_tready = !stall;
    sin = cordic.m_axis_dout_tdata[25:16];
    cos = cordic.m_axis_dout_tdata[9:0];
    valid = cordic.m_axis_dout_tvalid;
     
    matrix = 3x{{4x{{10b0}}}};
     
    /*
    // Rotate Z
    matrix[0][0] = cos;
    matrix[0][1] = -sin;
    matrix[1][0] = sin;
    matrix[1][1] = cos;
    matrix[2][2] = 10h100; // 1
    */
     
    /*
    // Rotate Y
    matrix[0][0] = cos;
    matrix[0][2] = sin;
    matrix[1][1] = 10h100; // 1
    matrix[2][0] = -sin;
    matrix[2][2] = cos;
    */
     
     
    // Rotate X
    matrix[0][0] = 10h100; // 1
    matrix[1][1] = cos;
    matrix[1][2] = -sin;
    matrix[2][1] = sin;
    matrix[2][2] = cos;
     
     
    matrix[2][3] = 400;
  }
}
```

For the demo, the matrix will rotate the model along a given axis. The default is X. To perform any rotations, we need to calculate the sin and cos values for the angle we want to rotate.

We can calculate these on the FPGA by using the CORDIC core from Xilinx. CORDIC is a clever algorithm that can be used to calculate a few things, including sin and cos, efficiently in hardware. Checkout the [Wikipedia page](https://en.wikipedia.org/wiki/CORDIC) for the nitty gritty. All we care about here is Xilinx provides a module that uses this algorithm and we can use it get sin and cos values for an input angle.

We set up the CORDIC core to accept a radian angle input in 3.7 fixed point format. This means the input value is 10 bits wide but the lower 7 bits are fractional. For example, 10b0010000000 is equal to 1 and 10b0001000000 is equal to 0.5.

We want to input values from -Pi to Pi. To get the value of Pi in 3.7 fixed point, we can multiply it by 2^7. Pi * 2^7 ≈ 402.

The output of the CORDIC is in 2.8 fixed point as the values are bound to +/-1. To keep things simple, our matrix will also be in 2.8 fixed point with a minor exception.

You may have noticed the matrix is 3x4 and not 3x3. Each row has an extra dimension. This dimension is used for translating. Technically, a linear transformation can only rotate and scale the input vector. However, by working in four dimensions instead of 3, we can effectively translate in the 3rd dimension. If we force the 4th (aka _W_) value of each input vector to always be 1, we effectively just add the _W_ value of the matrix to it.

This is what happens on the last line of the module where the _Z_ row’s _W_ column is set to 400. This pushes the object 400 units away. The _W_ values are 10.0 fixed point, meaning they are standard numbers without a fractional component.

### Stage 2 - Triangle Assembly

Now that we have a matrix to apply to our model, we need to start generating triangles. The ROMs that our model is stored in consist of vertices and faces. Each face is three numbers that point to a vertex in the vertex ROM. That means we first need to fetch the face entry and then use its contents to fetch each vertex to build the entire triangle.

The vertex data itself is in 16.16 fixed point. This is the format used through most of the pipeline.

This is all done in the _model_provider_ module.

```lucid,short
module model_provider (
    input clk,  // clock
    input rst,  // reset
    input draw,
    input stall,
    output idle,
    output valid,
    output<Geo.p3d> triangle[3],
    output color[3][16]
  ) {
   
  .clk(clk) {
    suzanne_face_rom face;
    suzanne_vert_rom vert;
     
    .rst(rst) {
      fsm state = {IDLE, WAIT_FACE, GV1, GV2, GV3, GV4, WAIT};
    }
     
    dff face_addr[$clog2(FaceRom.FACES)];
    dff<Geo.p3d> t[3];
    dff c[3][16];
  }
   
  always {
    vert.addr = bx;
    face.addr = face_addr.q;
     
    color = c.q;
    triangle = t.q;
    valid = 0;   
     
    idle = state.q == state.IDLE;
     
    case (state.q) {
      state.IDLE:
        face_addr.d = 0;
        if (draw) {
          state.d = state.WAIT_FACE;
        }
      state.WAIT_FACE:
        state.d = state.GV1;
      state.GV1:
        vert.addr = face.face[0];
        state.d = state.GV2;
      state.GV2:
        vert.addr = face.face[1];
        t.d[0] = vert.vert;
        c.d[0] = vert.color;
        state.d = state.GV3;
      state.GV3:
        vert.addr = face.face[2];
        t.d[1] = vert.vert;
        c.d[1] = vert.color;
        state.d = state.GV4;
      state.GV4:
        t.d[2] = vert.vert;
        c.d[2] = vert.color;
        state.d = state.WAIT;
      state.WAIT:
        if (!stall) {
          valid = 1;
          if (face_addr.q == FaceRom.FACES-1) {
            state.d = state.IDLE;
          } else {
            state.d = state.WAIT_FACE;
            face_addr.d = face_addr.q + 1;
          }
        }
    }
  }
}
```

This module is pretty simple and is just an FSM that waits for a draw command, fetches a face, fetches each vertex, and then waits for the pipeline to not be stalled.

This is as good a time as any to talk about stalling and back pressure.

This GPU is architected as a pipeline. That means that there are many stages that work separately and concurrently from one another with each feeding into the next. This architecture allows as much work to be done on each clock cycle as possible but it has one big caveat. Each stage in the pipeline doesn’t take the same amount of time to complete.

For example, it is way faster to fetch a triangle from the ROMs than it is to rasterize it pixel by pixel.

To compensate for this, we need our pipeline to support back pressure. This means that later stages can stall previous stages until they are ready for more data. This back pressure needs to flow back up through the entire pipeline to prevent lost data and keep everything flowing well.

So when the _stall_ signal is 1, we **must** wait to output the face and move onto the next one.

It’s worth noting that each vertex has its own color. Currently, only the first color is used for the entire triangle, but without too much extra work, each vertex color could be blended across the triangle.

These two stages are packed into the pretty simple _model_drawer_ module. This module is kind of like the client of our GPU. It makes the requests of what to draw.

```lucid,short
module model_drawer (
    input clk,  // clock
    input rst,  // reset
    input draw,
    output busy,
    output<Geo.p3d> m[3],
    output color[3][16],
    output model_matrix[3][4][10],
    output valid,
    input stall
  ) {
   
  .clk(clk) {
    .rst(rst) {
      model_provider model;
      matrix_generator mat_gen;
       
      fsm state = {IDLE, GEN_MAT, DRAW};
    }
     
    dff matrix[3][4][10];
  }
   
  always {
    m = model.triangle;
    color = model.color;
    model_matrix = matrix.q;
    valid = 0;
    busy = state.q != state.IDLE;
     
    mat_gen.stall = 1;
    model.draw = 0;
    model.stall = 1;
     
    case (state.q) {
      state.IDLE:
        if (draw) {
          state.d = state.GEN_MAT;
          model.draw = 1;
        }
      state.GEN_MAT:
        mat_gen.stall = 0;
        if (mat_gen.valid) {
          matrix.d = mat_gen.matrix;
          state.d = state.DRAW;
        }
      state.DRAW:
        model.stall = stall;
        valid = model.valid;
        if (model.idle) {
          state.d = state.IDLE;
        }
    }
  }
}
```

### Stage 3 - The Transformation

The next stage in the pipeline is the model transformation. This stage takes the triangle and multiplies each coordinate by the model matrix.

This is done in the _model_transform_ module.

```lucid,short
module model_transform (
    input clk,  // clock
    input rst,  // reset
    input<Geo.p3d> m[3],
    input color_in[3][16],
    input model_matrix[3][4][10],
    output<Geo.p3d> t[3],
    output color_out[3][16],
    output valid,
    input stall,
    input draw,
    output busy
  ) {
   
  .clk(clk) {
    .rst(rst) {
      fsm state = {IDLE, P1, P2, P3, P4, P5, P6};
    }
     
    dff products[3][3][32];
    dff matrix[3][4][10];
    dff<Geo.p3d> pt;
    dff<Geo.p3d> opt;
    dff<Geo.p3d> tri[3];
    dff<Geo.p3d> model[3];
    dff color[3][16];
  }
   
  signed sig tmp[48];
  var i;
   
  always {
    t = tri.q;
    color_out = color.q;
    valid = 0;
     
    busy = state.q != state.IDLE;
     
    for (i = 0; i < 3; i++) {
      tmp = $signed(matrix.q[i][0]) * $signed(pt.q.x);
      products.d[i][0] = tmp[8+:32];
       
      tmp = $signed(matrix.q[i][1]) * $signed(pt.q.y);
      products.d[i][1] = tmp[8+:32];
       
      tmp = $signed(matrix.q[i][2]) * $signed(pt.q.z);
      products.d[i][2] = tmp[8+:32];
    }
     
    opt.d.x = products.q[0][0] + products.q[0][1] + products.q[0][2] + c{matrix.q[0][3], 16b0};
    opt.d.y = products.q[1][0] + products.q[1][1] + products.q[1][2] + c{matrix.q[1][3], 16b0};
    opt.d.z = products.q[2][0] + products.q[2][1] + products.q[2][2] + c{matrix.q[2][3], 16b0};
     
    case (state.q) {
      state.IDLE:
        if (draw) {
          state.d = state.P1;
          matrix.d = model_matrix;
          model.d = m;
          pt.d = m[0];
          color.d = color_in;
        }
      state.P1:
        pt.d = model.q[1];
        state.d = state.P2;
      state.P2:
        pt.d = model.q[2];
        state.d = state.P3;
      state.P3:
        tri.d[0] = opt.q;
        state.d = state.P4;
      state.P4:
        tri.d[1] = opt.q;
        state.d = state.P5;
      state.P5:
        tri.d[2] = opt.q;
        state.d = state.P6;
      state.P6:
        valid = 1;
        if (!stall)
          state.d = state.IDLE;
    }
  }
}
```

When a triangle is fed into the module, each vertex is multiplied by the model matrix. This is done in three steps, assign the _pt_ _dff_ the vertex values, calculate the intermediate products of the multiplication, and finally sum them into the next vertex in _opt_.

Note that the _W_ coordinate of the matrix is added directly with the products since the _W_ coordinate of each vertex is implicitly 1 and can skip being multiplied by 1. It is also shifted 16 bits to the left to convert the 10.0 fixed point format to 10.16 which can be added to the other 16.16 values.

The first three cycles of the FSM feed the values into the pipe and the next three catch the results as they come out. Once all three vertices have been transformed, it attempts to output the new triangle.

Note that color data is passed in and out of this module but nothing is done to it. This is done just to ensure that the color data associated with this triangle stays with this triangle.

### Stage 4 - The Shader

Coming soon…