module alu_tb;
  reg clk, reset;
  reg [1:0] Opcode;
  reg signed [3:0] A, B;
  wire signed [4:0] C;

  alu a (.*);

  // variables
  integer error_count = 0;
  integer correct_count = 0;

  // clock generation
  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  // Exercise the DUT
  initial begin

    // ALU_1
    assert_reset;

    //ALU_2



    $display("%t: correct_count = %d, error_count = %d", $time, correct_count, error_count);
    $stop;
  end

  task static check_result;
    input signed [4:0] expected_result;
    @(negedge clk);
    if (expected_result !== C) begin
      error_count++;
      $display("%t: Error: when A = %d, B = %d, Expected = %d but found %d", $time, A, B,
               expected_result, C);
    end else begin
      correct_count++;
    end
  endtask

  task static assert_reset;
    reset = 1;
    check_result(0);
    reset = 0;
  endtask




endmodule
