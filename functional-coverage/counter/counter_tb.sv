import counter_pkg::*;
module counter_tb ();
  parameter WIDTH = 4;

  /***** STIMULUS SIGNALS DECLARATION *****/
  bit clk, rst_n, load_n, up_down, ce;
  bit   [WIDTH-1:0] data_load;

  /***** RESPONSE SIGNALS DECLARATION *****/
  logic [WIDTH-1:0] count_out;
  logic max_count, zero;

  /***** GOLDEN MODEL EXPECTED SIGNALS DECLARATION *****/
  bit [WIDTH-1:0] count_out_expected;
  bit max_count_expected, zero_expected;

  /***** ERROR/CORRECT COUNTERS *****/
  int correct_cnt = 0, error_cnt = 0;

  /***** DUT INSTANTIONATION *****/
  counter #(WIDTH) DUT (.*);


  transaction #(WIDTH) counter_txn = new;

  /***** CLOCK GENERATION *****/
  initial begin
    clk = 0;
    forever begin
      #1;
      clk = ~clk;
    end
  end

  // sync the class clk with the actual clk
  always @(clk) begin
    counter_txn.clk = clk;
  end

  // sync the class count_out with the actual count_out
  always @(count_out) begin
    counter_txn.count_out = count_out;
  end

  /***** STIMULATE THE DUT *****/
  initial begin
    // COUNTER_1
    check_reset();

    repeat (1000) begin
      assert (counter_txn.randomize());
      rst_n = counter_txn.rst_n;
      load_n = counter_txn.load_n;
      up_down = counter_txn.up_down;
      ce = counter_txn.ce;
      data_load = counter_txn.data_load;
      golden_model();
      check_result();
    end

    $display("%t: Error Count = %d, Correct Count = %d", $time, error_cnt, correct_cnt);
    $stop;
  end

  /***** COMPARE DUT OUT AGAINST EXPECTED RESULT *****/



  task static golden_model();
    if (rst_n == 0) count_out_expected = 0;
    else if (load_n == 0) count_out_expected = data_load;
    else if (ce) begin
      if (up_down == 1) count_out_expected++;
      else count_out_expected--;
    end
    max_count_expected = (count_out_expected == {WIDTH{1'b1}}) ? 1 : 0;
    zero_expected = (count_out_expected == 0) ? 1 : 0;
  endtask

  task static check_result;
    @(negedge clk);
    if (count_out_expected != count_out ||
        max_count_expected != max_count ||
        zero_expected != zero) begin
      error_cnt++;
    end else correct_cnt++;
  endtask


  /***** CHECK RESET BEHAVIOR *****/
  task static check_reset;
    rst_n = 0;
    @(negedge clk);
    if (count_out != 0 && zero != 1 && max_count != 0) error_cnt++;
    else correct_cnt++;
    rst_n = 1;
  endtask


endmodule

