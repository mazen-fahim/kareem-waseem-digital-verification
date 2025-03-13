module alu (
    input clk,
    input reset,
    input [1:0] Opcode,  // The opcode
    input signed [3:0] A,  // Input data A in 2's complement
    input signed [3:0] B,  // Input data B in 2's complement

    output reg signed [4:0] C  // ALU output in 2's complement

);

  reg signed [4:0] Alu_out;  // ALU output in 2's complement

  localparam ADD = 2'b00;  // A + B
  localparam SUB = 2'b01;  // A - B
  localparam NOT_A = 2'b10;  // ~A
  localparam REDUCTIONOR_B = 2'b11;  // |B

  // Do the operation
  always @* begin
    case (Opcode)
      ADD:           Alu_out = A + B;
      SUB:           Alu_out = A - B;
      NOT_A:         Alu_out = ~A;
      REDUCTIONOR_B: Alu_out = |B;
      default:       Alu_out = 5'b0;
    endcase
  end  // always @ *

  // Register output C
  always @(posedge clk or posedge reset) begin
    if (reset) C <= 5'b0;
    else C <= Alu_out;
  end

endmodule
