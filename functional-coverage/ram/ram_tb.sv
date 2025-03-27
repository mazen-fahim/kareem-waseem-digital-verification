module ram_tb ();
  bit clk, write, read;
  bit   [ 7:0] data_in;
  bit   [15:0] address;

  logic [ 7:0] data_out;

  localparam TEST = 100;

  // Dynamic arrays (random values to ram)
  bit [15:0] address_array[];
  bit [7:0] data_to_write_array[];

  // Associative arrays (expected data from ram)
  bit [7:0] data_read_expect_assoc[int];


  // Queue (actual data read from ram)
  bit [7:0] data_read_queue[$];


  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  ram DUT (.*);

  int error_cnt = 0, correct_cnt = 0;

  initial begin
    stimulus_gen();
    golden_model();
    write = 1;
    for (int i = 0; i < TEST; i++) begin
      @(negedge clk) begin
        address = address_array[i];
        data_in = data_to_write_array[i];
      end
    end
    write = 0;
    read  = 1;
    for (int i = 0; i < TEST; i++) begin
      address = address_array[i];
      @(negedge clk);
      check9bits();
      data_read_queue.push_back(data_out);
    end

    while (data_read_queue.size()) begin
      $display("Read data = %d", data_read_queue.pop_front());
    end

    $display("%t: Error count = %d, Correct Count = %d", $time, error_cnt, correct_cnt);
    $stop;
  end


  task static stimulus_gen;
    for (int i = 0; i < TEST; i++) begin
      automatic bit [15:0] rand_addr_in = $urandom;
      automatic bit [ 7:0] rand_data_in = $urandom;
      address_array = new[address_array.size() + 1] (address_array);
      address_array[address_array.size()-1] = rand_addr_in;
      data_to_write_array = new[data_to_write_array.size() + 1] (data_to_write_array);
      data_to_write_array[data_to_write_array.size()-1] = rand_data_in;
    end
  endtask

  task static golden_model;
    for (int i = 0; i < TEST; i++) begin
      data_read_expect_assoc[address_array[i]] = data_to_write_array[i];
    end
  endtask

  task static check9bits;
    if (data_read_expect_assoc[address] != data_out);
    else correct_cnt++;
  endtask


endmodule
