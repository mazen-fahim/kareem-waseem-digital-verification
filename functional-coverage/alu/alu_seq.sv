// this has the opcode enum type definition
import alu_seq_pkg::*;
module alu_seq (
    // This is verilog 1996 way of declaring ports
    // Where you have port names in port list and direction + type in body of
    // module
    operand1,
    operand2,
    clk,
    rst,
    opcode,
    out
);


  //ERROR: Ports can't be used with built-int datatypes like (bit, int, short,
  //etc...)
  //input byte operand1, operand2;
  input logic signed [7:0] operand1, operand2;

  input logic clk, rst;

  // type definition is in the package
  input opcode_e opcode;

  //ERROR: Ports can't be used with built-int datatypes like (bit, int, short,
  //etc...) and output width should be 9 bits to avoid overflow
  // output byte out;
  output logic signed [8:0] out;

  always @(posedge clk) begin
    if (rst) out <= 0;
    else
      case (opcode)
        ADD: out <= operand1 + operand2;
        SUB: out <= operand1 - operand2;
        MULT: out <= operand1 * operand2;
        DIV: out <=  operand1 / operand2;
        default: out <= 0;
      endcase
  end

endmodule
