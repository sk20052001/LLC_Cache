import LLC_defs::*;

module tb_LLC_cache #(parameter string Default = "./Files/default.din");
	logic clk;
	string trace_file;
	int file_handle;
	integer operation, cacheRds, cacheWrs, cacheHits, cacheMisses, hold, set;
	logic [31:0] address;
	int line_number = 0;
	busOperation busOp;
    snoopResults snoopResult;
    messages message;
	cache LLC_cache [NUM_SETS][ASSOCIATIVITY];
	logic [ASSOCIATIVITY - 2:0] plru [NUM_SETS];

	LLC DUT(
		.clk(clk),
		.addr(address),
		.op(operation),
		.cacheRds(cacheRds),
		.cacheWrs(cacheWrs),
		.cacheHits(cacheHits),
		.cacheMisses(cacheMisses),
		.busOp(busOp),
		.snoopResult(snoopResult),
		.message(message),
		.LLC_cache(LLC_cache),
		.hold(hold),
		.plru(plru)
	);

	initial begin
		clk = 0;
		forever #3 clk = ~clk;
	end

	initial begin
		if (!$value$plusargs("trace_file=%s", trace_file)) begin
			trace_file = Default;
			`ifdef DEBUG
				$display("No intput from user. Tracing default file from '%s'", trace_file);
		end else begin
				$display("Tracing file from '%s'", trace_file);
			`endif
		end
		
		`ifdef DEBUG
			$display("Opening file '%s'", trace_file);
		`endif

		if(trace_file != Default) begin
			file_handle = $fopen(trace_file, "r");
			if (file_handle == 0) begin
				`ifdef DEBUG
					$display("Error in opening file '%s'", trace_file);
					$display("Tracing and opening the default file from '%s'", Default);
				`endif
				trace_file = Default;
				file_handle = $fopen(trace_file, "r");
				if (file_handle == 0) begin
					`ifdef DEBUG
						$display("Error in opening default file '%s'.", trace_file);
					`endif
					$stop;
				end else begin
					`ifdef DEBUG
						$display("File opened successfully");
					`endif
				end
			end else begin
				`ifdef DEBUG
					$display("File opened successfully");
				`endif
			end
		end else begin
			file_handle = $fopen(trace_file, "r");
			if (file_handle == 0) begin
				`ifdef DEBUG
					$display("Error in opening file '%s'.", trace_file);
				`endif
				$stop;
			end else begin
				`ifdef DEBUG
					$display("File opened successfully");
				`endif
			end
		end
		
		`ifdef DEBUG
			$display("Reading and parsing file");
		`endif

		operation = 8;
		@(negedge clk) begin
		end

		while ($fscanf(file_handle, "%d %h", operation, address) == 2) begin
			line_number++;
			`ifdef DEBUG
				$display("Time: %t, Operation: %d, Address: %h", $realtime, operation, address);
			`endif
			@(negedge clk) begin
				if (hold == 1) begin
					@(negedge clk) begin
					end
				end
			end
		end

		#5;
		$display("Output:");
		$display("Number of Cache Reads: %d", cacheRds);
		$display("Number of Cache Writes: %d", cacheWrs);
		$display("Number of Cache Hits: %d", cacheHits);
		$display("Number of Cache Misses: %d", cacheMisses);
		$display("Cache hit ratio: %0.1f %%", cacheHits == 0 ? cacheHits : (real'(cacheHits)/(cacheHits + cacheMisses)) * 100);
		
		`ifdef DEBUG
			if (line_number == 0)
				$display("File is empty");
			else
				$display("Finished reading the file");
		`endif

    	$fclose(file_handle);
		`ifdef DEBUG
			$display("File closed successfully");
		`endif
		$stop();
	end

	`ifdef DEBUG
		always@(negedge clk) begin
			if (operation != 8) begin
				if (operation == 9) begin
					$display("Cache contents:");
					for(int i = 0; i < NUM_SETS; i++) begin
						set = 1;
						for(int j = 0; j < ASSOCIATIVITY; j++) begin
							if(LLC_cache[i][j].valid) begin
								if (set) begin
									$display();
									$display("Index: %d", i);
									$display("PLRU: %b", plru[i]);
									set = 0;
								end
								$display("Line: %d: Tag: %h, MESI State: %s", j, LLC_cache[i][j].tag, LLC_cache[i][j].mesi);
							end
						end
					end
				end else begin
					if (operation >= 0 && operation <= 2 && busOp != NOBUSOP) begin
						$display("Simulate a Bus Operation and Snoop Results of LLC of other processors");
						$display("BusOp: %s, Address: %h, Snoop Result: %s", busOp, address, snoopResult);
					end else if (operation >= 3 && operation <= 6 && snoopResult != NORESULT) begin
						$display("Reporting result of our Snooping bus operation performed by other caches");
						if (busOp != NOBUSOP) begin
							$write("BusOp: %s, ", busOp);
						end
						$display("Address: %h, Snoop Result: %s", address, snoopResult);
					end
					if (message != NOMESSAGE) begin
						$display("Communication to L1 Cache");
						$display("Message: %s, Address: %h", message, address);
					end
				end
				$display();
			end
		end
	`endif

endmodule
