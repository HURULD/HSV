// Designed by Michalis Pardalos
// Modified by John Wickerson

module multiplier (
      input 	        rst,
      input 	        clk,
      input [7:0] 	  in1,
      input [7:0] 	  in2,
      output [15:0]   out
                  );
  reg [3:0]  stage = 0;
  reg [15:0] accumulator = 0;
  reg [7:0]  in1_shifted = 0;
  reg [15:0] in2_shifted = 0;


   // Logic for controlling the stage
  always @(posedge clk) 
    if (rst || stage == 9)
      stage <= 0;
    else
      stage <= stage + 1;
  
   // Logic for in1_shifted and in2_shifted
  always @(posedge clk) 
    if (rst) begin
      in1_shifted <= 0;
      in2_shifted <= 0;
    end else if (stage == 0) begin
        in1_shifted <= in1;
        in2_shifted <= in2;
    end else begin
        in1_shifted <= in1_shifted >> 1;
        in2_shifted <= in2_shifted << 1;
    end

   // Logic for the accumulator
  always @(posedge clk)
    if (rst || stage == 9) begin
      accumulator <= 0;
    end else if (in1_shifted[0]) begin
        accumulator <= accumulator + in2_shifted;
    end

   // Output logic
  assign out = accumulator;


`ifdef FORMAL

  always @(posedge clk) begin
    // 255*255+1 cannot be exceeded
    assert(out < 65026 && out >= 0); 

    // stage is always increasing or wrap to zero
    assert(stage == 0 || stage > $past(stage)); 

    // if stage is 9 then output is in1 * in2
    if(stage == 9)
      assert((stage == 9 && out == $past(in1,9) * $past(in2,9)));

    // out should monatonically increase during the computation
    if (stage > 0)
      assert(out >= $past(out));

    // By the fourth stage of the computation (stage = 5) accumulator should be the lower 4 bits of in1 * in2
    if (stage == 5)
      assert(accumulator == $past(in2, 5) * $past(in1[3:0], 5));

    
  end

`endif


endmodule
