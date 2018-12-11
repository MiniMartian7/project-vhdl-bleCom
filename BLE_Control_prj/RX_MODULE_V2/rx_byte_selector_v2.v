module rx_uart_byte_selector(
    input clk_b_selector,
    input rst_b_selector,

    input in_bit_serial,

    output out_interpreter_en,

    output [7:0] out_byte
);

reg out_enable_d, out_enable_ff;

reg [7:0] data_d, data_ff;/*byte obtained*/
reg [1:0] bit_case_d, bit_case_ff;

reg[3:0] bit_index_d, bit_index_ff;/*from 0 to 9, which means 10 positions*/
reg[31:0] bit_cnt_d, bit_cnt_ff;/*counts the number clocks represented by a bit duration*/

parameter DISABLE = 0;
parameter ENABLE = 1;

parameter CLK_PER_BIT = 5208;/*115200 baud rate on 50MHz clk*/

parameter IDLE = 2'b00;
parameter START_BIT = 2'b01;
parameter DATA_BIT = 2'b10;
parameter STOP_BIT = 2'b11;

always @(posedge clk_b_selector or posedge rst_b_selector) begin
    if(rst_b_selector) begin
        data_ff <= DISABLE;
        bit_index_ff <= DISABLE;
        bit_cnt_ff <= DISABLE;
        bit_case_ff <= DISABLE;
        out_enable_ff <= DISABLE;
    end
    else begin
        data_ff <= data_d;
        bit_index_ff <= bit_index_d;
        bit_cnt_ff <= bit_cnt_d;
        bit_case_ff <= bit_case_d;
        out_enable_ff <= out_enable_d;
    end
end

always @(*) begin 
    data_d = data_ff;
    bit_index_d = bit_index_ff;
    bit_cnt_d = bit_cnt_ff;
    bit_case_d = bit_case_ff;
    out_enable_d = out_enable_ff;

    case (bit_case_ff)  
        IDLE : begin
            bit_index_d = DISABLE;
            bit_cnt_d = DISABLE;

            if(in_bit_serial == 0) begin
                bit_case_d= START_BIT;
                //data_d = 0;
            end
            else begin
                bit_case_d = IDLE;
            end
        end

        START_BIT : begin
            if(in_bit_serial == 0 && (bit_cnt_ff < (CLK_PER_BIT - 1) / 2)) begin
                bit_cnt_d = bit_cnt_d + 1;
                bit_case_d = START_BIT;
            end
            else begin
                bit_index_d = 0;
                bit_cnt_d = 0;
                bit_case_d = DATA_BIT;
            end
        end

        DATA_BIT : begin
            if(bit_cnt_ff < CLK_PER_BIT - 1) begin
                bit_cnt_d = bit_cnt_d + 1;
                bit_case_d = DATA_BIT;
            end
            else begin
                if(bit_index_ff == 8) begin
                    bit_index_d = DISABLE;
                    bit_cnt_d = DISABLE;
                    bit_case_d = STOP_BIT;
                end
                else begin
                    data_d[bit_index_d] = in_bit_serial;
                    bit_index_d = bit_index_d + 1;
                    bit_cnt_d = 0;
                    bit_case_d = DATA_BIT;
                end
            end
        end

        STOP_BIT : begin
            /*clock care sa dea enable la citire in urmatorul modul*/
            if(out_enable_ff) begin
                out_enable_d = DISABLE;
                bit_case_d = IDLE;
            end
            else begin
                out_enable_d = ENABLE;
            end
        end

        default: begin
            bit_case_d = IDLE;
        end
    endcase
end

assign out_byte = data_ff;
assign out_interpreter_en = out_enable_ff;

endmodule