`timescale 1ns/100ps
module tb_rx;

reg clk_tb, rst_tb;
reg in_bit_serial_tb;

wire [7:0] data_tb;

always
    #10 clk_tb = !clk_tb;

initial begin
    clk_tb = 1;
    rst_tb = 1;
    in_bit_serial_tb = 1;

    #20

    rst_tb = 0;

    #20

    /*---------------------------------------------------------------------------char*/
    in_bit_serial_tb = 0;/*start bit*/

    #200
    in_bit_serial_tb = 1;
    #200
    in_bit_serial_tb = 0;
    #200
    in_bit_serial_tb = 0;
    #200
    in_bit_serial_tb = 0;
    #200
    in_bit_serial_tb = 0;
    #200
    in_bit_serial_tb = 0;
    #200
    in_bit_serial_tb = 1;
    #200
    in_bit_serial_tb = 0;
    #200

    in_bit_serial_tb = 1;/*stop bit*/
    #200
    /*---------------------------------------------------------------------------line_feed*/
    in_bit_serial_tb = 0;/*start bit*/

    #200
    in_bit_serial_tb = 0;
    #200
    in_bit_serial_tb = 1;
    #200
    in_bit_serial_tb = 0;
    #200
    in_bit_serial_tb = 1;
    #200
    in_bit_serial_tb = 0;
    #200
    in_bit_serial_tb = 0;
    #200
    in_bit_serial_tb = 0;
    #200
    in_bit_serial_tb = 0;
    #200

    in_bit_serial_tb = 1;/*stop bit*/
    #200
    /*---------------------------------------------------------------------------carriage_return*/
    in_bit_serial_tb = 0;/*start bit*/

    #200
    in_bit_serial_tb = 1;
    #200
    in_bit_serial_tb = 0;
    #200
    in_bit_serial_tb = 1;
    #200
    in_bit_serial_tb = 1;
    #200
    in_bit_serial_tb = 0;
    #200
    in_bit_serial_tb = 0;
    #200
    in_bit_serial_tb = 0;
    #200
    in_bit_serial_tb = 0;
    #200

    in_bit_serial_tb = 1;/*stop bit*/
    #200
    /*--------------------------------------------------------------------------*/
     
    $display("--@%gns [SENT BYTE] %b", $time, data_tb);
end

rx_uart_top DUT(
    .clk(clk_tb),
    .rst(rst_tb),

    .bit_serial(in_bit_serial_tb),
    .out_to_leds_top(data_tb)
);
endmodule