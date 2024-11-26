package LLC_defs;
	parameter int CACHE_SIZE_MB = 16;
    parameter int LINE_SIZE = 64;
    parameter int ASSOCIATIVITY = 16;
    parameter int NUM_SETS = (CACHE_SIZE_MB * 1024 * 1024) / (LINE_SIZE * ASSOCIATIVITY);
    parameter int P_LRU = ASSOCIATIVITY - 1;
    parameter int INDEX = 14;
    parameter int BYTE_OFFSET = 6;
    parameter int TAG_BITS = 32 - (INDEX + BYTE_OFFSET);

    typedef struct {
        logic [7:0] data [LINE_SIZE-1];
        logic [TAG_BITS - 1:0] tag;
        logic valid;
        logic dirty;
        logic [1:0] mesi;
    } cache;
endpackage