package LLC_defs;
	parameter int CACHE_SIZE_MB = 16;
    parameter int LINE_SIZE = 64;
    parameter int ASSOCIATIVITY = 16;
    parameter int NUM_SETS = (CACHE_SIZE_MB * 1024 * 1024) / (LINE_SIZE * ASSOCIATIVITY);
    parameter int P_LRU = ASSOCIATIVITY - 1;
    parameter int INDEX = 14;
    parameter int BYTE_OFFSET = 6;
    parameter int TAGS = 32 - (INDEX + BYTE_OFFSET);

    typedef struct {
        logic [7:0] data [0: BYTE_OFFSET-1];
        logic [TAGS - 1:0] tags;
        logic [INDEX - 1:0] index;
        logic valid;
        logic dirty;
    } cache;
endpackage