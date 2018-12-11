module rx_uart_byte_interpreter(
    input clk_b_interpreter,
    input rst_b_interpreter,

    input [7:0] in_byte,
    
    output [7:0] out_byte
);

reg [7:0] char_d, char_ff;
//reg [1:0] byte_status_d, byte_status_ff;

parameter [7:0] CARRIAGE_RETURN = 8'b00001101;
parameter [7:0] LINE_FEED = 8'b00001010;

/*parameter IDLE = 2'b00;
parameter CR = 2'b01;
parameter LF = 2'b10;
parameter BYTE_DRIVE = 2'b11;*/

parameter DISABLE = 0;
parameter ENABLE = 1;

always @(posedge clk_b_interpreter or posedge rst_b_interpreter) begin
    if(rst_b_interpreter) begin
        char_ff <= DISABLE;
        //byte_status_ff <= DISABLE;
    end
    else begin
        char_ff <= char_d;
        //byte_status_ff <= byte_status_d;
    end
end

always @(*) begin
    char_d = char_ff;
    //byte_status_d = byte_status_ff;

    if(in_byte == CARRIAGE_RETURN) begin
       
    end
    else if(in_byte == LINE_FEED) begin
       
    end
    else begin
        char_d = in_byte;
    end
end

assign out_byte = char_ff;

endmodule