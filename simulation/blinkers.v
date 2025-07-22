/*
This module is meant as a way for me to learn some basic Verilog and have an 
easily verifiable test bench.

The idea is that 3 LEDs are on a chip
LED 1 : Blink every 10 cycles
LED 2 : Blink every 5 cycles
LED 3 : (TODO) Blink every <random_interval> cycles
        Since verilog does not synthesize $random, one needs to implement a 
        LFSR to get a random value
        https://en.wikipedia.org/wiki/Linear-feedback_shift_register
        https://simplefpga.blogspot.com/2013/02/random-number-generator-in-verilog-fpga.html
*/
module blinkers (
    input clk,
    input rstbtn,
    output reg led1 = 0, led2 = 0, led3 = 0
);

    reg clk_edge = 0;

    initial begin
        $dumpfile("../vcd/blinkers.vcd");
        $dumpvars(0, blinkers);

        // $monitor("Time = %0t clk = %0d sig = %0d", $time, clk, clk_edge);
        #1000 $finish;
    end

    always #10 begin 
        clk_edge = ~clk_edge;
    end

    reg [3:0] cycle_count_led1 = 'b0;
    reg [3:0] cycle_count_led2 = 'b0;

    reg [3:0] LED_1_BLINK_INTERVAL = 'b1010; // 10
    reg [3:0] LED_2_BLINK_INTERVAL = 'b0101; // 5

    // TODO - led 3 on randomized interval

    task cycle_led (
        output led,
        input reg [3:0] blink_interval,
        inout reg [3:0] cycle_count
    );
        if (cycle_count > 0 && cycle_count % blink_interval == 0) begin
            cycle_count = 0;
            led = 1;
        end else begin
            // $display("Cycle Task: Cycle Count: %d, Blink Interval: %d", cycle_count, blink_interval);
            cycle_count += 1;
            led = 0;
        end
    endtask

    always @(posedge clk_edge) begin
        if (rstbtn) begin 
            led1 = 0;
            led2 = 0;
            led3 = 0;
            cycle_count_led1 = 0;
            cycle_count_led2 = 0;
        end else begin 
            cycle_led(led1, LED_1_BLINK_INTERVAL, cycle_count_led1);
            cycle_led(led2, LED_2_BLINK_INTERVAL, cycle_count_led2);
        end
    end
endmodule
