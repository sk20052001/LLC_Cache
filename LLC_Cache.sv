import LLC_defs::*;

module LLC(
    input logic clk,
    input logic reset,
    input logic [31:0] addr,
    input logic wr,
    input logic [7:0] data_in,
    output logic hit,
    output logic [7:0] data_out
);

    logic [BYTE_OFFSET - 1:0] byte_offset;
    logic [INDEX - 1:0] index;
    logic [TAG_BITS - 1:0] tag;

    assign tag <= addr[31:32-TAG_BITS];
    assign index <= addr[31-TAG_BITS:BYTE_OFFSET];
    assign byte_offset <= addr[BYTE_OFFSET-1:0];

    cache LLC_cache [NUM_SETS][ASSOCIATIVITY];

    logic [ASSOCIATIVITY - 2:0] p_lru [NUM_SETS];

    logic [ASSOCIATIVITY - 1:0] hit_line;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            for (int i = 0; i < NUM_SETS; i++) begin
                plru_tree[i] <= ASSOCIATIVITY - 1'b0;
                for (int j = 0; j < ASSOCIATIVITY; j++) begin
                    LLC_cache[i][j].valid <= 0;
                    LLC_cache[i][j].dirty <= 0;
                    LLC_cache[i][j].tag <= 0;
                    for (int k = 0; k < LINE_SIZE; k++) begin
                        LLC_cache[i][j].data[k] <= 0;
                    end
                end
            end
        end else begin
            hit_line = 0;
            for (int i = 0; i < ASSOCIATIVITY; i++) begin
                if (LLC_cache[index][i].valid && LLC_cache[index][i].tag == tag) begin
                    hit_line[i] = 1'b1;
                end
            end
            if (|hit_line) begin
                if (wr)
                    LLC_cache[index][$clog(hit_line)].data[byte_offset] <= data_in;
                else
                    data_out <= LLC_cache[index][$clog(hit_line)].data[byte_offset];
                int node = 0;
                for (int i = 3)
            end
        end
    end

endmodule
