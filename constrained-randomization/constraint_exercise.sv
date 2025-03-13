// slide 131
module tb;
  class Exercise1;
    rand bit [7:0] data;
    rand bit [3:0] address;

    constraint data_c {data == 5;}

    constraint addr_c {
      address dist {
        4'd0 :/ 10,
        [1 : 14] :/ 80,
        4'd15 :/ 10
      };
    }

  endclass : Exercise1

  Exercise1 e;
  real zero_cnt = 0;
  real fifteen_cnt = 0;
  real other_cnt = 0;
  initial begin
    e = new;
    for (integer i = 0; i < 10000; i++) begin
      assert (e.randomize());
      fifteen_cnt += (e.address == 15);
      zero_cnt += (e.address == 0);
      other_cnt += (e.address != 15 && e.address != 0);
      $display("zero_cnt = %d, other_cnt = %d, fifteen_cnt = %d", zero_cnt, other_cnt, fifteen_cnt);
    end
    $display("zero_prop = %f, other_prop = %f, fifteen_prop = %f", zero_cnt / 10000 * 100,
             other_cnt / 10000 * 100, fifteen_cnt / 10000 * 100);
    $finish;
  end

endmodule
