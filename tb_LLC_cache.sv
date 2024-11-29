import LLC_defs::*;

module tb_LLC_cache #(parameter string Default = "./Files/default.din");
	string trace_file;
	int file_handle;
	int operation, cacheRds, cacheWrs, cacheHits, cacheMisses;
	logic [31:0] address;
	int line_number = 0;
	busOperation busOp;
    snoopResults snoopResult;
    messages message;
	cache LLC_cache;

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
		.cache(LLC_cache)
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

		while ($fscanf(file_handle, "%d %h", operation, address) == 2) begin
			line_number++;
			$display("Line %0d: Operation: %0d, Address: %h", line_number, operation, address);
		end
		
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
	end

	always@(negedge clk) begin
	end

endmodule