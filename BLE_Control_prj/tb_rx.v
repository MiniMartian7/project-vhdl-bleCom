`timescale 1ns/100ps
module tb_rx;

reg clk_tb, rst_tb;

reg [7:0] data_rx;

reg in_serial_tb;

initial begin
    clk_tb = 1'b0;
    forever begin
        #20
        clk_tb = !clk_tb;
    end
end

initial begin
    clk_tb = 1;
    rst_tb = 1;

    data_rx = 0;
    in_serial_tb = 1;

    #40

    rst_tb = 0;

    #80
    in_serial_tb = 0;
    #40
    in_serial_tb = 1;
    #40
    in_serial_tb = 1;
    #40
    in_serial_tb = 0;
    #40
    in_serial_tb = 1;
    #40
    in_serial_tb = 0;
    #40
    in_serial_tb = 0;
    #40
    in_serial_tb = 1;
end

rx_uart DUT(
    .clk(clk_tb),
    .rst_rx(rst_tb),

    .in_serial_tx(in_serial_tb),
    .data_rx(data_tb)
);
endmodule