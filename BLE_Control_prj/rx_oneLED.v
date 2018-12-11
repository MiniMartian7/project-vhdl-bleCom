module rx_uart(
    clk,
    rst,

    in_serial_rx,

    /*out_drive_rx,/*when receive is complete out_drive_rx will be driven high for one clock cycle*/
    
    data_rx
);

input clk, rst;
input in_serial_rx;
/*output out_drive_rx;*/
/*output [7:0] data_rx;*/
output data_rx;

reg data_rx_d, data_rx_ff;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        data_rx_ff <= 0;
        //o_drive_rx_ff <= 0;
    end
    else begin
        data_rx_ff <= data_rx_d;
        //o_drive_rx_ff <= o_drive_rx_d;
    end
end

always @(*) begin
    //o_drive_rx_d = o_drive_rx_ff;
    data_rx_d = data_rx_ff;

    data_rx_d = in_serial_rx;
end

assign data_rx = data_rx_ff;

endmodule