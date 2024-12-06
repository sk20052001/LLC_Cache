import LLC_defs::*;

module LLC(
    input logic clk,
    input logic [31:0] addr,
    input integer op,
    output integer cacheRds, cacheWrs, cacheHits, cacheMisses,
    output busOperation busOp,
    output snoopResults snoopResult,
    output messages message,
    output cache LLC_cache [NUM_SETS][ASSOCIATIVITY],
    output integer hold
);

    logic [BYTE_OFFSET - 1:0] byte_offset;
    logic [INDEX - 1:0] index;
    logic [TAG_BITS - 1:0] tag;

    assign tag = addr[31:32-TAG_BITS];
    assign index = addr[31-TAG_BITS:BYTE_OFFSET];
    assign byte_offset = addr[BYTE_OFFSET-1:0];

    logic [ASSOCIATIVITY - 2:0] plru [NUM_SETS];

    int validLine, emptyLine, node;
    logic [3:0] accessed_way;

    always_ff @(posedge clk) begin
        if(op == 8) begin
            cacheHits = 0;
            cacheMisses = 0;
            cacheRds = 0;
            cacheWrs = 0;
            for (int i = 0; i < NUM_SETS; i++) begin
                plru[i] <= 0;
                for (int j = 0; j < ASSOCIATIVITY; j++) begin
                    LLC_cache[i][j].valid = 0;
                    LLC_cache[i][j].dirty = 0;
                    LLC_cache[i][j].tag = 0;
                    LLC_cache[i][j].mesi = INVALID;
                end
            end
        end else begin
            is_Present();
            if (validLine >= 0 && op != 9) begin
                cacheHits = op != 5 ? cacheHits + 1 : cacheHits;
                case(op)
                    0: begin
                        cacheRds += 1;
                        update_PLRU();
                        message = SENDLINE;
                        busOp = NOBUSOP;
                        snoopResult = NORESULT;
                    end
                    1: begin
                        cacheWrs += 1;
                        if (LLC_cache[index][validLine].mesi == SHARED) begin
                            update_PLRU();
                            LLC_cache[index][validLine].mesi = MODIFIED;
                            LLC_cache[index][validLine].dirty = 1;
                            message = GETLINE;
                            busOp = INVALIDATE;
                            snoopResult = NORESULT;
                        end else if (LLC_cache[index][validLine].mesi == EXCLUSIVE) begin
                            update_PLRU();
                            LLC_cache[index][validLine].mesi = MODIFIED;
                            LLC_cache[index][validLine].dirty = 1;
                            message = GETLINE;
                            busOp = NOBUSOP;
                            snoopResult = NORESULT;
                        end else begin
                            update_PLRU();
                            message = NOMESSAGE;
                            busOp = NOBUSOP;
                            snoopResult = NORESULT;
                        end
                    end
                    2: begin
                        cacheRds += 1;
                        update_PLRU();
                        message = SENDLINE;
                        busOp = NOBUSOP;
                        snoopResult = NORESULT;
                    end
                    3: begin
                        cacheRds += 1;
                        if (LLC_cache[index][validLine].mesi == MODIFIED) begin
                            LLC_cache[index][validLine].mesi = SHARED;
                            LLC_cache[index][validLine].dirty = 0;
                            message = GETLINE;
                            busOp = WRITE;
                            snoopResult = HITM;
                        end else begin
                            LLC_cache[index][validLine].mesi = SHARED;
                            message = NOMESSAGE;
                            busOp = NOBUSOP;
                            snoopResult = HIT;
                        end
                    end
                    4: begin
                        cacheRds += 1;
                        LLC_cache[index][validLine].mesi = INVALID;
                        LLC_cache[index][validLine].valid = 0;
                        message = INVALIDATELINE;
                        busOp = NOBUSOP;
                        snoopResult = NORESULT;
                    end
                    5: begin
                        if (LLC_cache[index][validLine].mesi == MODIFIED) begin
                            if (LLC_cache[index][validLine].dirty == 1) begin
                                cacheHits += 1;
                                cacheWrs += 1;
                                hold = 1;
                                LLC_cache[index][validLine].dirty = 0;
                                message = GETLINE;
                                busOp = WRITE;
                                snoopResult = NORESULT;
                            end else begin
                                hold = 0;
                                LLC_cache[index][validLine].mesi = INVALID;
                                LLC_cache[index][validLine].valid = 0;
                                message = INVALIDATELINE;
                                busOp = NOBUSOP;
                                snoopResult = NORESULT;
                            end
                        end else begin
                            cacheHits += 1;
                            cacheWrs += 1;
                            LLC_cache[index][validLine].mesi = INVALID;
                            LLC_cache[index][validLine].valid = 0;
                            message = INVALIDATELINE;
                            busOp = NOBUSOP;
                            snoopResult = NORESULT;
                        end
                    end
                    6: begin
                        cacheWrs += 1;
                        LLC_cache[index][validLine].mesi = INVALID;
                        LLC_cache[index][validLine].valid = 0;
                        message = INVALIDATELINE;
                        busOp = NOBUSOP;
                        snoopResult = NORESULT;
                    end
                endcase
            end else begin
                validLine = emptyLine;
                case(op)
                    0: begin
                        if (emptyLine == -1) begin
                            evictLine();
                        end else begin
                            cacheMisses += 1;
                            cacheRds += 1;
                            hold = 0;
                            busOp = READ;
                            message = SENDLINE;
                            update_PLRU();
                            LLC_cache[index][validLine].tag = tag;
                            getSnoopResult();
                            LLC_cache[index][validLine].mesi = snoopResult == NOHIT ? EXCLUSIVE : SHARED;
                            LLC_cache[index][validLine].valid = 1;
                        end
                    end
                    1: begin
                        if (emptyLine == -1) begin
                            evictLine();
                        end else begin
                            cacheMisses += 1;
                            cacheWrs += 1;
                            hold = 0;
                            busOp = RWIM;
                            message = SENDLINE;
                            update_PLRU();
                            LLC_cache[index][validLine].tag = tag;
                            LLC_cache[index][validLine].dirty = 1;
                            LLC_cache[index][validLine].mesi = MODIFIED;
                            LLC_cache[index][validLine].valid = 1;
                        end
                    end
                    2: begin
                        if (emptyLine == -1) begin
                            evictLine();
                        end else begin
                            cacheMisses += 1;
                            cacheRds += 1;
                            hold = 0;
                            busOp = READ;
                            message = SENDLINE;
                            update_PLRU();
                            LLC_cache[index][validLine].tag = tag;
                            getSnoopResult();
                            LLC_cache[index][validLine].mesi = snoopResult == NOHIT ? EXCLUSIVE : SHARED;
                            LLC_cache[index][validLine].valid = 1;
                        end
                    end
                    3: begin
                        cacheMisses += 1;
                        cacheRds += 1;
                        busOp = NOBUSOP;
                        message = NOMESSAGE;
                        snoopResult = NOHIT;
                    end
                    4: begin
                        cacheMisses += 1;
                        cacheRds += 1;
                        busOp = NOBUSOP;
                        message = NOMESSAGE;
                        snoopResult = NORESULT;
                    end
                    5: begin
                        cacheMisses += 1;
                        cacheWrs += 1;
                        busOp = NOBUSOP;
                        message = NOMESSAGE;
                        snoopResult = NORESULT;
                    end
                    6: begin
                        cacheMisses += 1;
                        cacheWrs += 1;
                        busOp = NOBUSOP;
                        message = NOMESSAGE;
                        snoopResult = NORESULT;
                    end
                endcase
            end
        end
    end

    function void is_Present();
        emptyLine = -1;
        for (int i = 0; i < ASSOCIATIVITY; i++) begin
            if (LLC_cache[index][i].tag == tag && LLC_cache[index][i].mesi != INVALID) begin
                validLine = i;
                return;
            end
            if (LLC_cache[index][i].mesi == INVALID && emptyLine == -1) begin
                emptyLine = i;
            end
        end
        validLine = -1;
        return;
    endfunction

    function void evictLine();
        findLRU();
        if (LLC_cache[index][validLine].mesi == MODIFIED) begin
            hold = 1;
            LLC_cache[index][validLine].mesi = INVALID;
            LLC_cache[index][validLine].valid = 0;
            LLC_cache[index][validLine].dirty = 0;
            message = EVICTLINE;
            busOp = WRITE;
            snoopResult = NORESULT;
        end else begin
            hold = 1;
            LLC_cache[index][validLine].mesi = INVALID;
            LLC_cache[index][validLine].valid = 0;
            message = INVALIDATELINE;
            busOp = NOBUSOP;
            snoopResult = NORESULT;
        end
    endfunction

    function void update_PLRU();
        node = 0;
        accessed_way = validLine;
        for (int i = 3; i >= 0; i--) begin
            plru[index][node] = accessed_way[i];
            node = node * 2 + 1 + accessed_way[i];
        end
    endfunction

    function void findLRU();
        node = 0;
        for (int i = 3; i >= 0; i--) begin
            node = (node * 2) + 1 + !plru[index][node];
        end
        validLine = node - ASSOCIATIVITY - 1;
    endfunction

    function void getSnoopResult();
        if (!byte_offset[0] && !byte_offset[1]) begin
            snoopResult = HIT;
        end else if (byte_offset[0] && !byte_offset[1]) begin
            snoopResult = HITM;
        end else begin
            snoopResult = NOHIT;
        end
    endfunction

endmodule
