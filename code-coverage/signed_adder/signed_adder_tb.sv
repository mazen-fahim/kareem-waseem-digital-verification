module signed_adder_tb;
  reg clk, reset;
  reg signed [3:0] A, B;

  wire signed [4:0] C;

  reg signed  [4:0] expected_sum;
  integer error_count, correct_count;

  localparam MAXPOS = 7, ZERO = 0, MAXNEG = -8;

  signed_adder a1 (
      .clk(clk),
      .reset(reset),
      .A(A),
      .B(B),
      .C(C)
  );

  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  initial begin
    error_count = 0;
    correct_count = 0;
    expected_sum = 0;

    A = 1;
    B = 1;
    reset = 0;

    // ADDER_1
    assert_reset;

    // ADDER_2
    A = -8;
    for (integer i = 0; i < 16; i++) begin
      B = -8;
      for (integer j = 0; j < 16; j++) begin
        expected_sum = A + B;
        check_result(expected_sum);
        B++;
      end
      A++;
    end

    $display("%t: Error count = %d, Correct count = %d", $time, error_count, correct_count);
    $stop;
  end


  task static check_result;
    input signed [4:0] expected_result;

    @(negedge clk);
    if (expected_result !== C) begin
      error_count++;
      $display("%t: Error: For A = %d, B = %d, C should equal %d but is %d", $time, A, B,
               expected_result, C);
    end else correct_count++;
  endtask


  task static assert_reset;
    reset = 1;
    check_result(0);
    reset = 0;
  endtask

endmodule
