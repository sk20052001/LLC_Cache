package cache_create;

parameter SILENT_MODE = 0,
		  NORMAL_MODE = 1;
		  
parameter ADDR_SIZE = 32
parameter CACHE_SIZE = 16000000; //Capacity = 16MB
parameter ASSOCIATIVITY = 16;
parameter CACHE_LINE = 64; //Cache line_size = 64 bytes

parameter BYTE_SELECT = $clog2(CACHE_LINE);
parameter  SETS = (CACHE_SIZE/(ASSOCIATIVITY*CACHE_LINE));
parameter INDEX = $clog2(SETS);
parameter TAG_BITS = ADDR_SIZE-(BYTE_SELECT+INDEX);

parameter PSEUDO_LRU = ASSOCIATIVITY - 1;

parameter CACHE_HIT = 1;
parameter CACHE_MISS = 0;

parameter DATA_READ = 0;
parameter DATA_WRITE = 1;

endpackage