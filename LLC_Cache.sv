import LLC_defs::*;

module LLC(
    input logic clk,
    input logic reset,
    input logic [31:0] addr,
    input logic wr,
    input logic cs,
    input logic [7:0] data_in,
    output logic hit,
    output logic [7:0] data_out
);

    cache LLC_cache [NUM_SETS][ASSOCIATIVITY];

    always @(posedge clk) begin
        if (!reset) begin
            LLC_cache <= '{default:0};
        end else if (cs) begin
            logic [BYTE_OFFSET - 1:0] byte_offset <= addr[5:0];
            logic [INDEX - 1:0] index <= addr[19:6];
            logic [TAGS - 1:0] tags <= addr[31:20];
            for (int i = 0 ; i < ASSOCIATIVITY ; i++) begin
                if (LLC_cache[index][i].tags == tags && LLC_cache[index][i].valid) begin
                    hit <= 1'b1;
                    if (wr)
                        LLC_cache[index][i].data[byte_offset] <= data_in;
                    else
                        LLC_cache[index][i].data[byte_offset] <= LLC_cache[index][i].data[byte_offset];
                        data_out <= LLC_cache[index][i].data[byte_offset];
                end else begin
                    hit = 1'b0;
                    if (!wr)
                end
            end
        end
    end

endmodule
