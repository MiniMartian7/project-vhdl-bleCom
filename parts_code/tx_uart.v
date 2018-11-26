module tx_uart(
    clk_tx,
    rst_tx,

    /*ack_tx, sent from receiver after the stop bit*/
    enable_tx, /* for a tri-state situation in a half-duplex system*/

    in_byte_tx,
    out_serial_tx, /*the one by one bit serial sending*/

    /*out_done_tx is set to one when everything is sent, including the stop bit*/
);

input clk_tx, rst_tx;
input /*ack_tx,*/ enable_tx;
input [7:0] in_byte_tx;
output out_serial_tx;
/*output out_done_tx;*/

reg [7:0] data_d, data_ff;
reg out_serial_d, out_serial_ff;
reg [7:0] clk_count_d, clk_count_ff;
reg [1:0] sm_main_d, sm_main_ff;

reg [2:0] data_index_d, data_index_ff;

/*reg out_done_d, out_done_ff;*/

parameter DISABLE = 1'b0;
parameter ENABLE = 1'b1;
parameter CYCLE_PER_BIT = 115;

parameter IDLE = 'b00;
parameter START_BIT = 'b01;
parameter DATA_BIT = 'b10;
parameter STOP_BIT = 'b11;



always @(posedge clk_tx or posedge rst_tx) begin
    if(rst_tx) begin
        /*ack_ff <= DISABLE;*/
        data_ff <= DISABLE;
        out_serial_ff <= DISABLE;
        sm_main_ff <= DISABLE;
        clk_count_ff <= DISABLE;
        data_index_ff <= DISABLE;
        /*out_done_ff <= DISABLE;*/
    end
    else begin
        /*ack_ff <= ack_d;*/
        data_ff <= data_d;
        out_serial_ff <= out_serial_d;
        sm_main_ff <= sm_main_d;
        clk_count_ff <= clk_count_d;
        data_index_ff <= data_index_d;
        /*out_done_ff <= out_done_d;*/
    end
end

/*the URAT_TX module has the states: 
IDLE = 2'b00 
SEND_START_BIT = 2'b01
SEND_DATA_BIT = 2'b10
SEND_STOP_BIT = 2'b11
*/

always @(*) begin
    /*ack_d <= ack_ff;
    out_done_d <= out_done_ff;*/
    data_d = data_ff;
    out_serial_d = out_serial_ff;
    sm_main_d = sm_main_ff;
    clk_count_d = clk_count_ff;
    data_index_d = data_index_ff;

     case (sm_main_ff)
        IDLE : begin
            data_d = 'b0;
            out_serial_d = 'b1;/*so says the protocol*/
            clk_count_d = 0;

            if(enable_tx == 1 && data_index_ff == 8) begin/*verifica la valoare buna pt ultimul bit*/
                sm_main_d = START_BIT;
                data_d = in_byte_tx;
            end
            else if(enable_tx == 0) begin
                sm_main_d = IDLE;
                data_index_d = 0;
            end
        end
        START_BIT : begin
            out_serial_d = 0;

            if(clk_count_ff <  CYCLE_PER_BIT - 1) begin
                clk_count_d = clk_count_d + 1;
                sm_main_d = START_BIT;
            end
            else begin
                clk_count_d = 0;
                sm_main_d = DATA_BIT;
            end
        end
        DATA_BIT : begin
            out_serial_d = data_d[data_index_d];

            if(clk_count_ff < CYCLE_PER_BIT - 1) begin
                clk_count_d = clk_count_d + 1;
                sm_main_d = DATA_BIT;
            end
            else if(data_index_ff < 8) begin
                clk_count_d = 0;
                data_index_d = data_index_d + 1;
                sm_main_d = DATA_BIT;
            end
            else begin
                clk_count_d = 0;
                data_index_d = data_index_d + 1;
                sm_main_d = STOP_BIT;
            end
        end
        STOP_BIT : begin
            out_serial_d = 1;

            if(clk_count_ff < CYCLE_PER_BIT - 1) begin
                clk_count_d = clk_count_d + 1;
                sm_main_d = STOP_BIT;
            end
            else begin
                sm_main_d = IDLE;
                clk_count_d = 0;
            end
        end
        default: begin
            sm_main_d = IDLE;
        end
    endcase
    
end

assign out_serial_tx = out_serial_ff;
endmodule