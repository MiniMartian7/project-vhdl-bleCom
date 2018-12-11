module rx_uart(
    clk,
    rst,

    in_serial_rx,

    out_drive_rx,/*when receive is complete out_drive_rx will be driven high for one clock cycle*/
    
    data_rx
);

/*Set Generic g_CLKS_PER_BIT as follows:
-- g_CLKS_PER_BIT = (Frequency of i_Clk)/(Frequency of UART)
-- Example: 10 MHz Clock, 115200 baud UART
-- (10000000)/(115200) = 87
*/

input clk, rst;
input in_serial_rx;
output out_drive_rx;
/*output [7:0] data_rx;*/
output data_rx;

/*reg [7:0] buffer_rx_d, buffer_rx_ff;/*where the bits are first puted*/
reg buffer_rx_d, buffer_rx_ff;
integer bit_count_rx_d, bit_count_rx_ff;/*nr of cycles per bit*/
integer main_case_rx_d = 0, main_case_rx_ff = 0;/*main current case*/
integer buffer_index_rx_d, buffer_index_rx_ff;/*position of the bit in buffer*/
reg o_drive_rx_d, o_drive_rx_ff;/*driving the output*/

parameter DISABLE = 0;
parameter ENABLE = 1;
parameter CYCLE_PER_BIT = 1302;/*38400 baud rate on 50MHz clk*/

parameter IDLE = 0;
parameter START_BIT = 1;
parameter DATA_BIT = 2;
parameter STOP_BIT = 3;
parameter CLEANUP = 4;

/*Purpose: Double-register the incoming data.
  This allows it to be used in the UART RX Clock Domain.
  (It removes problems caused by metastability)
  reg income_reg1_rx = 1'b1;
    reg income_reg2_rx = 1'b1;
  */

always @(posedge clk or posedge rst) begin
    if(rst) begin
        buffer_rx_ff <= 0;
        bit_count_rx_ff <= 0;
        main_case_rx_ff <= 0;
        buffer_index_rx_ff <= 0;
        o_drive_rx_ff <= 0;
    end
    else begin
        buffer_rx_ff <= buffer_rx_d;
        bit_count_rx_ff <= bit_count_rx_d;
        main_case_rx_ff <= main_case_rx_d;
        buffer_index_rx_ff <= buffer_index_rx_d;
        o_drive_rx_ff <= o_drive_rx_d;
    end
end

always @(*) begin
    buffer_rx_d = buffer_rx_ff;
    bit_count_rx_d = bit_count_rx_ff;
    main_case_rx_d = main_case_rx_ff;
    buffer_index_rx_d = buffer_index_rx_ff;
    o_drive_rx_d = o_drive_rx_ff;

    case (main_case_rx_ff)
        IDLE : begin
            o_drive_rx_d = DISABLE;
            bit_count_rx_d = DISABLE;
            buffer_index_rx_d = DISABLE;

            if(in_serial_rx == 1'b0) begin
                main_case_rx_d = START_BIT;
            end
            else begin
                main_case_rx_d = IDLE;
            end
        end
        START_BIT : begin
            if(bit_count_rx_ff == (CYCLE_PER_BIT - 1) / 2) begin
                if(in_serial_rx == 1'b0) begin
                    bit_count_rx_d = 0;
                    main_case_rx_d = DATA_BIT;
                end 
                else begin
                    main_case_rx_d = IDLE;
                end
            end
            else begin
                bit_count_rx_d = bit_count_rx_d + 1;
                main_case_rx_d = START_BIT;
            end
        end

        DATA_BIT : begin
            if((bit_count_rx_ff < CYCLE_PER_BIT - 1)) begin
                bit_count_rx_d = bit_count_rx_d + 1;
                main_case_rx_d = DATA_BIT;
            end
            else begin
                bit_count_rx_d = 0;
                buffer_rx_d = in_serial_rx;
                /*buffer_rx_d[buffer_index_rx_d] = in_serial_rx;*/

                if(buffer_index_rx_ff < 7) begin
                    buffer_index_rx_d = buffer_index_rx_d + 1;
                    main_case_rx_d = DATA_BIT;
                end
                else begin
                    buffer_index_rx_d = 0;
                    main_case_rx_d = STOP_BIT;
                end
            end
        end
        
        STOP_BIT : begin
            if(bit_count_rx_ff < CYCLE_PER_BIT - 1) begin
                bit_count_rx_d = bit_count_rx_d + 1;
                main_case_rx_d = STOP_BIT;
            end
            else begin
                o_drive_rx_d = ENABLE;
                bit_count_rx_d = 0;
                main_case_rx_d = CLEANUP;
            end
        end

        CLEANUP : begin
            main_case_rx_d = IDLE;
            o_drive_rx_d = DISABLE;
        end
        default : begin
            main_case_rx_d = IDLE;
        end
    endcase
end

assign data_rx = buffer_rx_ff;
assign out_drive_rx = o_drive_rx_ff;

endmodule /*rx_uart*/