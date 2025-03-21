import alsu_pkg::*;
module alsu_tb ();

  /***** STIMULUS SIGNAL DECLARATION *****/
  bit clk, rst, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in;
  opcode_e opcode;
  bit signed [2:0] A, B;
  bit signed [1:0] cin;
  bit red_op_A_reg, red_op_B_reg, bypass_A_reg, bypass_B_reg, direction_reg, serial_in_reg;
  opcode_e opcode_reg;
  bit signed [2:0] A_reg, B_reg;
  bit signed cin_reg;

  /***** RESPONSE SIGNAL DECLARATION *****/
  logic [15:0] leds;
  logic signed [5:0] out;

  /***** EXPECTED SIGNAL DECLARATION *****/
  logic [15:0] leds_expected;
  logic signed [5:0] out_expected;
  integer correct_cnt = 0, error_cnt = 0;



  /***** CLOCK GENERATION *****/
  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end


  /***** DUT INSTANTIATION *****/
  alsu DUT (
      .A(A),
      .B(B),
      .cin(cin),
      .serial_in(serial_in),
      .red_op_A(red_op_A),
      .red_op_B(red_op_B),
      .opcode(opcode),
      .bypass_A(bypass_A),
      .bypass_B(bypass_B),
      .clk(clk),
      .rst(rst),
      .direction(direction),
      .leds(leds),
      .out(out)
  );



  /***** STIMULUS GENERATION *****/
  transaction alsu_txn = new();

  always @(clk) begin
    alsu_txn.clk = clk;
  end

  initial begin
    rst = 1;
    golden_model();
    reset_internals();
    check_result();
    rst = 0;

    repeat (100000) begin
      assert (alsu_txn.randomize());
      cin = alsu_txn.cin;
      rst = alsu_txn.rst;
      red_op_A = alsu_txn.red_op_A;
      red_op_B = alsu_txn.red_op_B;
      bypass_A = alsu_txn.bypass_A;
      bypass_B = alsu_txn.bypass_B;
      direction = alsu_txn.direction;
      serial_in = alsu_txn.serial_in;
      opcode = alsu_txn.opcode;
      A = alsu_txn.A;
      B = alsu_txn.B;

      golden_model();

      if (rst) reset_internals();
      else update_internals();

      check_result();
    end

    $display("%t: Correct Count = %d, Error Count = %d", $time, correct_cnt, error_cnt);
    $stop;
  end


  function static is_invalid;
    if (opcode_reg == INVALID_1 || opcode_reg == INVALID_2) return 1;
    if ((red_op_A_reg == 1'b1 || red_op_B_reg == 1'b1) && (opcode_reg != OR && opcode_reg != XOR))
      return 1;
    return 0;
  endfunction

  task static golden_model;
    if (rst) begin
      out_expected  = 0;
      leds_expected = 0;
    end else begin
      if (is_invalid()) leds_expected = ~leds_expected;
      else leds_expected = 0;

      if (bypass_A_reg & ~bypass_B_reg) out_expected = A_reg;
      else if (bypass_B_reg & ~bypass_A_reg) out_expected = B_reg;
      else if (bypass_A_reg & bypass_B_reg)
        out_expected = (DUT.INPUT_PRIORITY == "A") ? A_reg : B_reg;
      else if (is_invalid()) begin
        out_expected = 0;
      end else begin
        case (opcode_reg)
          OR: begin
            if (red_op_A_reg & red_op_B_reg)
              out_expected = (DUT.INPUT_PRIORITY == "A") ? |A_reg : |B_reg;
            else if (red_op_A_reg) out_expected = |A_reg;
            else if (red_op_B_reg) out_expected = |B_reg;
            else out_expected = A_reg | B_reg;
          end
          XOR: begin
            if (red_op_A_reg & red_op_B_reg)
              out_expected = (DUT.INPUT_PRIORITY == "A") ? ^A_reg : ^B_reg;
            else if (red_op_A_reg) out_expected = ^A_reg;
            else if (red_op_B_reg) out_expected = ^B_reg;
            else out_expected = A_reg ^ B_reg;
          end
          ADD: begin
            //FIX: complete implementation for the full adder
            if (DUT.FULL_ADDER == "ON") out_expected = A_reg + B_reg + cin_reg;
            else out_expected = A_reg + B_reg;
          end
          MULT: out_expected = A_reg * B_reg;
          SHIFT: begin
            if (direction_reg) out_expected = {out_expected[4:0], serial_in_reg};
            else out_expected = {serial_in_reg, out_expected[5:1]};
          end
          ROTATE: begin
            if (direction_reg) out_expected = {out_expected[4:0], out_expected[5]};
            else out_expected = {out_expected[0], out_expected[5:1]};
          end
        endcase
      end
    end
  endtask

  task static reset_internals;
    cin_reg = 0;
    red_op_B_reg = 0;
    red_op_A_reg = 0;
    bypass_B_reg = 0;
    bypass_A_reg = 0;
    direction_reg = 0;
    serial_in_reg = 0;
    opcode_reg = OR;
    A_reg = 0;
    B_reg = 0;
  endtask

  task static update_internals;
    cin_reg = cin;
    red_op_B_reg = red_op_B;
    red_op_A_reg = red_op_A;
    bypass_B_reg = bypass_B;
    bypass_A_reg = bypass_A;
    direction_reg = direction;
    serial_in_reg = serial_in;
    opcode_reg = opcode;
    A_reg = A;
    B_reg = B;
  endtask

  task static check_result;
    @(negedge clk);
    if ((out != out_expected) || (leds != leds_expected)) begin
      $display("======================================");
      $display("ERROR OUT: Expected %d FOUND %d OPCODE %d A %d B %d", out_expected, out,
               opcode.name, A, B);
      $display("ERROR OUT: Expected %d FOUND %d OPCODE %d A_REG %d B_REG %d", out_expected, out,
               opcode.name, A_reg, B_reg);
      error_cnt++;
    end else begin
      correct_cnt++;
    end
  endtask


endmodule
