package counter_pkg;

  // parameterized class
  class transaction #(
      int WIDTH = 4
  );

    rand bit clk;
    rand bit rst_n, load_n, up_down, ce;
    rand bit [WIDTH-1:0] data_load;

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


  endclass : transaction

endpackage
