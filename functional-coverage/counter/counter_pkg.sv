package counter_pkg;

  // parameterized class
  class transaction #(
      int WIDTH = 4
  );

    rand bit rst_n, load_n, up_down, ce;
    randc bit [WIDTH-1:0] data_load;

    // these data members are set by the testbench.
    bit [WIDTH-1:0] count_out;
    bit clk;

    /***** CONSTRAINT DEFINITION *****/
    constraint counter_c {
      // COUNTER_1
      rst_n dist {
        1 :/ 70,
        0 :/ 30
      };

      // COUNTER_2
      load_n dist {
        1 :/ 30,
        0 :/ 70
      };

      // COUNTER_3
      ce dist {
        1 :/ 70,
        0 :/ 30
      };

      // COUNTER_4
      up_down dist {
        1 :/ 80,
        0 :/ 20
      };
    }

    covergroup counter_cg @(posedge clk);
      LOAD_DATA: coverpoint data_load iff (rst_n == 1 && load_n == 0);
      COUNT_OUT_1: coverpoint count_out iff (rst_n == 1 && ce == 1 && up_down == 1);
      COUNT_OUT_2: coverpoint count_out iff (rst_n == 1 && ce == 1 && up_down == 0);
      COUNT_OUT_3: coverpoint count_out iff (rst_n == 1 && ce == 1 && up_down == 1) {
        bins overflow = ({WIDTH{1'b1}} => 0); bins underflow = (0 => {WIDTH{1'b1}});
      }
    endgroup


    function new();
      counter_cg = new();
    endfunction

  endclass : transaction

endpackage
