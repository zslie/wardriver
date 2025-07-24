/*
This module is meant as a way for me to learn some basic Verilog and have an 
easily verifiable test bench.

The idea is that 3 LEDs are on a chip
LED 1 : Blink every 10 cycles
LED 2 : Blink every 5 cycles
LED 3 : Blink every <random_interval> cycles
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
    wire [4:0] random_interval ;
    LFSR lfsr_calc(clk_edge, rstbtn, random_interval);
    assign is_undefined_byte = (random_interval == 5'bx);

    initial begin
        $dumpfile("./blinkers.vcd");
        $dumpvars(0, blinkers);
        // $monitor("Random Interval Update: %b", random_interval);
        // $monitor("LED 3 Interval Update: %b", LED_3_BLINK_INTERVAL);
        #10000 $finish;
    end

    always #10 begin 
        clk_edge = ~clk_edge;
    end

    reg [3:0] cycle_count_led1 = 'b0;
    reg [3:0] cycle_count_led2 = 'b0;
    reg [3:0] cycle_count_led3 = 'b0;

    reg [3:0] LED_1_BLINK_INTERVAL = 'b1001; // 9
    reg [3:0] LED_2_BLINK_INTERVAL = 'b0100; // 4
    reg [3:0] LED_3_BLINK_INTERVAL = 'b1111; // Cycle after first run to immediately get new value

    task cycle_led (
        output led,
        input reg [3:0] blink_interval,
        inout reg [3:0] cycle_count
    );
        if (cycle_count > 0 && cycle_count % blink_interval == 0) begin
            cycle_count = 0;
            led = 1;
        end else begin
            cycle_count += 1;
            led = 0;
        end
    endtask

    always @(posedge clk_edge, negedge clk_edge, posedge rstbtn) begin
        if (rstbtn) begin 
            led1 <= 0;
            led2 <= 0;
            led3 <= 0;
            cycle_count_led1 <= 0;
            cycle_count_led2 <= 0;
        end else begin 
            cycle_led(led1, LED_1_BLINK_INTERVAL, cycle_count_led1);
            cycle_led(led2, LED_2_BLINK_INTERVAL, cycle_count_led2);
            // cycle_led(led3, LED_3_BLINK_INTERVAL[3:0], cycle_count_led3);
            if (cycle_count_led3 > 0 && cycle_count_led3 % LED_3_BLINK_INTERVAL == 0) begin
                cycle_count_led3 <= 0;
                led3 <= 1;
                if (random_interval !== 5'bx && random_interval[3:0] !== 'b0) begin 
                    LED_3_BLINK_INTERVAL <= random_interval[3:0]; // remove largest bit
                end
                // $display("RANDOM_INTERVAL: %d, %d, %d", random_interval, is_undefined_byte, random_interval === 5'bx);
            end else begin
                cycle_count_led3 <= cycle_count_led3 + 1;
                led3 <= 0;
            end
        end
    end
endmodule

module LFSR (
    clk,
    rst,
    rnd 
);
    parameter RANDOM_BIT_LENGTH = 5; // >= 5
    output [4:0] rnd;
    input clk, rst;
    wire feedback = random[RANDOM_BIT_LENGTH-1] ^ random[3] ^ random[2] ^ random[0]; 
    reg [RANDOM_BIT_LENGTH-1:0] random = 'b1, random_next, random_done;
    reg [3:0] count = 0, count_next; //to keep track of the shifts

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            random <= 'b1; //An LFSR cannot have an all 0 state, thus rst to full
            count <= 0;
        end else begin
            random <= random_next;
            count <= count_next;
        end
        // $display("random: %d count: %d, random_next: %d, count_next: %d, feedback: %d", random, count, random_next, count_next, feedback);
    end

    always @ (*) begin
        random_next = random; //default state stays the same
        count_next = count;

        random_next = {random[RANDOM_BIT_LENGTH-2:0], feedback}; //shift left the xor'd every posedgeclk 
        count_next = count + 1;

        if (count == RANDOM_BIT_LENGTH) begin
            count = 0;
            random_done = random; //assign the random number to output after RANDOM_BIT_LENGTH shifts
        end
    end
    
    assign rnd = random_done;
endmodule
