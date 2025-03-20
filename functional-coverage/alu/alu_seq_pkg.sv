package alu_seq_pkg;

  typedef enum logic [1:0] {
    ADD,
    SUB,
    MULT,
    DIV
  } opcode_e;

  // define an enum for corner casses that will
  // be used while setting the weight distrbution
  // for both operands 1 and 2
  typedef enum {
    MAXPOS = 127,
    MAXNEG = -128,
    ZERO   = 0
  } corner_e;

  class transaction;
    rand byte operand1, operand2;
    rand bit rst;
    rand corner_e corner_case_1;
    rand corner_e corner_case_2;
    rand opcode_e opcode;

    // define constraints
    constraint alu_inputs_c {
      // ALU_2, ALU_3, ALU_4, ALU_5
      operand1 dist {
        corner_case_1 :/ 80,
        [-128 : 127]  :/ 20
      };

      // ALU_2, ALU_3, ALU_4, ALU_5
      operand2 dist {
        corner_case_2 :/ 80,
        [-128 : 127]  :/ 20
      };

      // ALU_1
      rst dist {
        0 :/ 98,
        1 :/ 2
      };
    }

    // define coveragepoints of interest
    covergroup alu_seq_cg;
      CP_OP1: coverpoint operand1 iff (!rst) {
        bins maxpos = {MAXPOS}; bins maxneg = {MAXNEG}; bins zero = {ZERO};
      }
      CP_OP2: coverpoint operand2 iff (!rst) {
        bins maxpos = {MAXPOS}; bins maxneg = {MAXNEG}; bins zero = {ZERO};
      }
      CP_CORNERS: cross CP_OP1, CP_OP2;

      CP_OPCODE: coverpoint opcode {illegal_bins opcode_nodiv = {DIV};}


    endgroup

    function new();
      alu_seq_cg = new();
    endfunction

  endclass

endpackage
