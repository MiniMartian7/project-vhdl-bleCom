module test_3v3(
    set,
    out_port
);

input set;
output out_port;

reg out;

always @(*) begin
    if(set == 1) begin
        out = 1;
    end
    else begin
        out = 0; 
    end
end

assign out_port = out;

endmodule