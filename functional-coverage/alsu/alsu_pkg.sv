package alsu_pkg;

  typedef enum bit [2:0] {
    OR,
    XOR,
    ADD,
    MULT,
    SHIFT,
    ROTATE,
    INVALID_1,
    INVALID_2
  } opcode_e;
  typedef enum {
    MAXPOS = 3,
    MAXNEG = -4,
    ZERO   = 0
  } corner_e;

  class transaction;
    bit clk;
    rand bit cin, rst, red_op_A, red_op_B, bypass_A, bypass_B, direction, serial_in;
    rand opcode_e opcode;
    rand bit signed [2:0] A, B;

    bit [2:0] walking_ones[] = {3'b100, 3'b010, 3'b001};
    rand bit [2:0] walking_ones_t;
    rand bit [2:0] walking_ones_f;

    rand corner_e a_corner;
    rand corner_e b_corner;
    rand bit [3:0] a_remaining;
    rand bit [3:0] b_remaining;


    constraint alsu_c {
      a_remaining != MAXPOS;
      a_remaining != 0;
      a_remaining != MAXNEG;
      b_remaining != MAXPOS;
      b_remaining != 0;
      b_remaining != MAXNEG;

      walking_ones_t inside {walking_ones};
      !(walking_ones_f inside {walking_ones});

      // ALSU_1 (CONSTRAINT RESET)
      rst dist {
        0 := 98,
        1 := 2
      };

      // ALSU_2 (CONSTRAINT INVALID CASES)
      opcode dist {
        [INVALID_1 : INVALID_2] := 20,
        [OR : ROTATE] := 80
      };

      if (opcode == OR || opcode == XOR) {
        red_op_A dist {
          0 := 80,
          1 :/ 20
        };

        red_op_B dist {
          0 := 80,
          1 := 20
        };
      }

      // ALSU_3 (CONSTRAINT BYPASS)
      bypass_A dist {
        0 :/ 98,
        1 :/ 2
      };

      bypass_B dist {
        0 :/ 98,
        1 :/ 2
      };

      // ALUS_4, ALSU_5 (CONSTRAINT OPERANDS WHEN OR or XOR opcode)
      if (opcode == OR || opcode == XOR) {
        if (red_op_A) {
          // a should be constrained to have a single bit as one
          A dist {
            walking_ones_t :/ 80,
            walking_ones_f :/ 20
          };

          // b should be constrained to all zeros
          B == 0;
        } else
        if (red_op_B) {
          // a should be constrained to all zeros
          A == 0;
          // b should be constrained to have a single bit as one
          B dist {
            walking_ones_t :/ 80,
            walking_ones_f :/ 20
          };
        }
      }

      // ALSU_6, ALSU_7 (CONSTRAINT TO CORNER CASES WHEN ADD OR MULT)
      if (opcode == ADD || opcode == MULT) {
        A dist {
          a_corner :/ 70,
          a_remaining :/ 30
        };
        B dist {
          b_corner :/ 70,
          b_remaining :/ 30
        };
      }
    }


    covergroup alsu_cg @(posedge clk);
      A_cp_1: coverpoint A {
        bins A_data_0 = {ZERO};
        bins A_data_max = {MAXPOS};
        bins A_data_min = {MAXNEG};
        bins A_data_default = default;
      }
      A_cp_2: coverpoint A iff (red_op_A) {bins A_data_walkingones[] = walking_ones;}

      B_cp_1: coverpoint A {
        bins B_data_0 = {ZERO};
        bins B_data_max = {MAXPOS};
        bins B_data_min = {MAXNEG};
        bins B_data_default = default;
      }
      B_cp_2: coverpoint B iff (red_op_B & ~red_op_A) {bins A_data_walkingones[] = walking_ones;}

      OPCODE_cp: coverpoint opcode {
        bins Bins_shift[] = {SHIFT, ROTATE};
        bins Bins_arith[] = {ADD, MULT};
        bins Bins_bitwise[] = {OR, XOR};
        illegal_bins Bins_invalid = {INVALID_1, INVALID_2};
        bins Bins_trans = (0 => 1 => 2 => 3 => 4 => 5);
      }
    endgroup


    // we have 6 opcodes that we need to randomize under the following
    // constraints
    // 1. Each one has a valid opcode (one of the six possibilities)
    // 2. Each one is unique
    rand opcode_e arr[6];
    constraint arr_c {
      unique {arr};  //each element of the array will be unique
      foreach (arr[i]) {arr[i] inside {OR, XOR, ADD, MULT, SHIFT, ROTATE};}
    }





    function new();
      alsu_cg = new();
    endfunction

  endclass

endpackage
