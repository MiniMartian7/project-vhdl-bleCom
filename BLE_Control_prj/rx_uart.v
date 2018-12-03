module rx_uart(
    clk,
    rst_rx,

    in_serial_rx,

    data_rx

    /*out_ack_rx, sent to the rx when the receive is complete*/
);

/*Set Generic g_CLKS_PER_BIT as follows:
-- g_CLKS_PER_BIT = (Frequency of i_Clk)/(Frequency of UART)
-- Example: 10 MHz Clock, 115200 baud UART
-- (10000000)/(115200) = 87
*/

input clk, rst_rx;
input in_serial_rx;
output [7:0] data_rx;

reg [7:0] data_d, data_ff;
reg [7:0] clk_count_d, clk_count_ff;
reg [1:0] sm_main_d, sm_main_ff;
reg clk_rx;

integer data_index_d, data_index_ff;

parameter DISABLE = 1'b0;
parameter ENABLE = 1'b1;
parameter CYCLE_PER_BIT = 217;/*115200 baud rate on 25MHz clk*/
parameter LAST_BIT_SEND = 'd8;

parameter IDLE = 'b00;
parameter START_BIT = 'b01;
parameter DATA_BIT = 'b10;
parameter STOP_BIT = 'b11;

always @(posedge clk) begin
    clk_rx <= ~clk_rx;
end

always @(posedge clk_rx or posedge rst_rx) begin
    if(rst_rx) begin
        data_ff <= DISABLE;
        clk_count_ff <= DISABLE;
        sm_main_ff <= DISABLE;
        data_index_ff <= DISABLE;
    end
    else begin
        data_ff <= data_d;
        clk_count_ff <= clk_count_d;
        sm_main_ff <= sm_main_d;
        data_index_ff <= data_index_d;
    end
end

always @(*) begin
    data_d = data_ff;
    clk_count_d = clk_count_ff;
    sm_main_d = sm_main_ff;
    data_index_d = data_index_ff;

    case (sm_main_ff)
        IDLE : begin
            if(in_serial_rx) begin
                clk_count_d = 0;
                data_index_d = 0;
            end
            else begin
                sm_main_d = START_BIT;
            end
        end
        START_BIT : begin
            if(clk_count_ff < (CYCLE_PER_BIT - 1) / 2) begin
                if(in_serial_rx == 1'b0) begin
                    clk_count_d = 0;
                    sm_main_d = DATA_BIT;
                end
                else begin
                    sm_main_d = IDLE;
                end
            end
            else begin
                clk_count_d = clk_count_d + 1;
                sm_main_d = START_BIT;
            end
        end

        DATA_BIT : begin
            if(clk_count_ff < CYCLE_PER_BIT - 1) begin
                clk_count_d = clk_count_d + 1;
                sm_main_d = DATA_BIT;
            end
            else begin
                clk_count_d = 0;
                data_d[data_index_d] = in_serial_rx;

                if(data_index_d < LAST_BIT_SEND - 1) begin
                    data_index_d = data_index_d + 1;
                    sm_main_d = DATA_BIT;
                end
                else begin
                    data_index_d = 0;
                    sm_main_d = STOP_BIT;
                end
            end
        end
        
        STOP_BIT : begin
            if(clk_count_ff < CYCLE_PER_BIT - 1) begin
                clk_count_d = clk_count_d + 1;
                sm_main_d = STOP_BIT;
            end
            else begin
                clk_count_d = 0;
                sm_main_d = STOP_BIT;
            end
        end
        default: begin
            clk_count_d = 0;
            sm_main_d = IDLE;
        end
    endcase
end

assign data_rx = data_ff;

endmodule