`timescale 1ns/100ps
module tb_rx;

reg clk_tb, rst_tb;
reg in_serial_tb;

integer bit_cnt_tb;

wire [7:0] data_tb;
wire  out_drive_tb;

initial begin
    clk_tb = 1'b0;
    forever begin
        #10
        clk_tb = !clk_tb;
    end
end

initial begin
    clk_tb = 1;
    rst_tb = 1;
    
    bit_cnt_tb = 0;
    in_serial_tb = 1;

    #20

    rst_tb = 0;
    in_serial_tb = 0;

    while(bit_cnt_tb < 7) begin
        #200
        in_serial_tb = !in_serial_tb;
        bit_cnt_tb = bit_cnt_tb + 1;
    end


    
    /*
    #20
    in_serial_tb = 1;
    #20
    in_serial_tb = 1;
    #20
    in_serial_tb = 0;
    #20
    in_serial_tb = 1;
    #20
    in_serial_tb = 0;
    #20
    in_serial_tb = 0;
    #20
    in_serial_tb = 1;*/
     
    $display("--@%gns [SENT BYTE] %b", $time, data_tb);
end

rx_uart 
#(
    .CYCLE_PER_BIT(10)
) 
DUT
(
    .clk(clk_tb),
    .rst(rst_tb),

    .in_serial_rx(in_serial_tb),
    .out_drive_rx(out_drive_tb),

    .data_rx(data_tb)
);
endmodule