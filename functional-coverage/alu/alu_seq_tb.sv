import alu_seq_pkg::*;
module alu_seq_tb ();

  /****** STIMULUS SIGNAL DECLARATION ******/
  byte operand1, operand2;
  bit clk;
  bit rst;
  opcode_e opcode;


  /****** RESPONSE SIGNAL DECLARATION ******/
  // the output should be logic to catch the case
  // if the design output is z or x if you use
  // bit then it will all implicitly covert to zero
  // and you wouldn't know whether or not this zero
  // is an actual output of the design or a z or x that
  // was converted to 0
  logic signed [8:0] out;

  /****** DUT INITIALIZATION ******/
  alu_seq DUT (.*);

  /****** CLOCK GENERATION ******/
  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  transaction alu_txn = new;

  initial begin
    alu_txn.alu_seq_cg.start();
  end

  always @(posedge clk) begin
    alu_txn.alu_seq_cg.sample();
  end



  /****** GENERATE STIMULUS ******/
  int error_cnt = 0, correct_cnt = 0;
  initial begin
    logic signed [8:0] expected_result;

    // ALU_1
    assert_reset();

    repeat (100) begin
      assert (alu_txn.randomize());
      operand1 = alu_txn.operand1;
      operand2 = alu_txn.operand2;
      opcode   = alu_txn.opcode;
      golden_model(expected_result);
      check_result(expected_result);
    end

    $display("%t: Error Count = %d, Correct Count = %d", $time, error_cnt, correct_cnt);
    $stop;
  end

  task golden_model(output bit [8:0] expected_result);
    case (opcode)
      ADD:  expected_result = operand1 + operand2;
      SUB:  expected_result = operand1 - operand2;
      MULT: expected_result = operand1 * operand2;
      DIV:  expected_result = operand1 / operand2;
    endcase
  endtask

  task check_result;
    input bit signed [8:0] expected_result;
    @(negedge clk);
    if (expected_result != out) begin
      error_cnt++;
      $display(
          "%t: Error: when OP1 = %d, OP2 = %d and opcode = %s expected output is %d but found %d",
          $time, operand1, operand2, opcode.name, expected_result, out);
    end else correct_cnt++;
  endtask


  task assert_reset;
    rst = 1;
    check_result(0);
    rst = 0;
  endtask


endmodule
