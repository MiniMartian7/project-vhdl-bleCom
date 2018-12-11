module rx_uart_top(
    input clk,
    input rst,

    input bit_serial,

    output [7:0] out_to_leds_top
);

wire [7:0] byte_to_interpreter;
wire interpreter_en_top;

rx_uart_byte_selector RX_B_SEL(
    .clk_b_selector(clk),
    .rst_b_selector(rst),

    .in_bit_serial(bit_serial),

    .out_interpreter_en(interpreter_en_top),

    .out_byte(byte_to_interpreter)
);

rx_uart_byte_interpreter RX_B_INTER(
    .clk_b_interpreter(interpreter_en_top),
    .rst_b_interpreter(rst),

    .in_byte(byte_to_interpreter),

    .out_byte(out_to_leds_top)
);
    
endmodule