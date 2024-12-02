import LLC_defs::*;

module tb_LLC_cache #(parameter string Default = "./Files/default.din");
	logic clk;
	string trace_file;
	int file_handle;
	int operation, cacheRds, cacheWrs, cacheHits, cacheMisses, action;
	logic [31:0] address;
	int line_number = 0;
	busOperation busOp;
    snoopResults snoopResult;
    messages message;
	cache LLC_cache [NUM_SETS][ASSOCIATIVITY];

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
		.LLC_cache(LLC_cache)
	);

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
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
			$display("Opening file %s", trace_file);
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

		while ($fscanf(file_handle, "%d %h", action, address) == 2) begin
			line_number++;
			// $display("Line %0d: Operation: %0d, Address: %h", line_number, operation, address);
			@(negedge clk) begin
				if (action >= 0 && action <= 8) begin
					operation = action;
				end
			end
		end

		$display("Output:");
		$display("Number of Cache Reads: %d", cacheRds);
		$display("Number of Cache Writes: %d", cacheWrs);
		$display("Number of Cache Hits: %d", cacheHits);
		$display("Number of Cache Misses: %d", cacheMisses);
		$display("Cache hit ratio: %0.1f", real'(cacheHits)/line_number);
		
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

	always@(negedge clk) begin
		if (operation >= 0 && operation <= 2) begin
			$display("Simulate a Bus Operation and Snoop Results of LLC of other processors");
		end else if (operation >= 3 && operation <= 6) begin
			$display("Reporting result of our Snooping bus operation performed by other caches");
		end
		$display("BusOp: %s, Address: %h, Snoop Result: %s", busOp, address, snoopResult);
		$display("Communication to L1 Cache");
		$display("Message: %s, Address: %h\n", message, address);
		if (operation == 9) begin
			$display("Cache contents:");
			for(int i = 0; i < NUM_SETS; i++) begin
				for(int j = 0; j < ASSOCIATIVITY; j++) begin
					if(LLC_cache[i][j].valid) begin
						$display("Tag: %h, MESI State: %s", LLC_cache[i][j].tag, LLC_cache[i][j].mesi);
					end
				end
			end
			$display();
			$stop();
		end
	end

endmodule
