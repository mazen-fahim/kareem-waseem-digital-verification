module priority_enc_tb;

  reg clk, reset;
  reg [3:0] D;

  wire [1:0] Y;
  wire valid;

  integer error_count, correct_count;


  priority_enc pe (
      .clk(clk),
      .rst(reset),
      .D(D),
      .Y(Y),
      .valid(valid)
  );

  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  static integer i = 0;
  initial begin
    error_count = 0;
    correct_count = 0;

    D = 4'b1000;
    // PE_1
    assert_reset;

    // PE_2
    D = 0;
    check_valid(0);

    // PE_3
    for (i = 1; i < 16; i = i + 1) begin
      D = i;
      for (integer j = 0; j < 4; j = j + 1) begin
        if (D & (1 << j)) begin
          check_result(3 - j);
          check_valid(1);
          break;
        end
      end
    end



    $display("%t: Error count = %d, Correct count = %d", $time, error_count, correct_count);
    $stop;
  end


  task static check_result;
    input [1:0] expected_result;

    @(negedge clk);
    if (expected_result !== Y) begin
      error_count++;
      $display("%t: Error: For D = %d Y should equal %d but is %d", $time, D, expected_result, Y);
    end else correct_count++;
  endtask

  task static check_valid;
    input expected_valid;
    @(negedge clk);
    if (expected_valid !== valid) begin
      error_count++;
      $display("%t: Error: valid should equal %d but is %d", $time, expected_valid, valid);
    end else correct_count++;
  endtask

  task static assert_reset;
    reset = 1;
    check_result(0);
    reset = 0;
  endtask

endmodule
