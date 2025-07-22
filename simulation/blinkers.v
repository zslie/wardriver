module blinkers (
    input clk,
    input rstbtn,
    output reg led1, led2, led3 = 0
);

    reg clk_edge = 0;

    initial begin
        $dumpfile("../vcd/blinkers.vcd");
        $dumpvars(0, blinkers);

        // $monitor("Time = %0t clk = %0d sig = %0d", $time, clk, clk_edge);
        #1000 $finish;
    end

    always #1 begin 
        #10 clk_edge = ~clk_edge;
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
            $display("[$display]: Cycle Task: Cycle Count: %d, Blink Interval: %d", cycle_count, blink_interval);
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
