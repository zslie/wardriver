module network (
        input d,
        input clk,
        input rstn
    );
    initial begin
        $display("Welcome to the network mod, %d, %d, %rstn", d, clk, rstn);
    end
endmodule
