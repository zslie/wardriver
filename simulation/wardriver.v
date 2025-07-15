module wardriver(
        input d,
        input clk,
        input rstn
    );

    network n1(.d (d), .clk (clk), .rstn (rstn));

    parameter DATA_WIDTH = 8; // Example: 8-bit signals
    parameter MEM_DEPTH = 100; // Example: 100 samples

    // Declare a memory to store the signal data
    reg [DATA_WIDTH-1:0] signal_memory [0:MEM_DEPTH-1];    
    logic [DATA_WIDTH-1:0] current_signal;

    integer i;

    initial begin
        $dumpfile("../vcd/test.vcd");
        $dumpvars(0, wardriver);

        $readmemb("../input/8wire.txt", signal_memory);

        // Example of how you might use the data over time
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            current_signal = signal_memory[i];
            #10 if (current_signal !== 'x) begin
                $display("Time %0t: \n\t\tSignal = %b", $time, current_signal);
                $display("\t\tSignal[0] = %b", current_signal[0]);
            end 
        end
        $display("Hello, World");

        $finish ;
    end

endmodule
