module tb_trace_parser;
	string trace_file;
	int file_handle;
	int operation;
	logic [31:0] address;
	int line_number = 0;
	
	//trace traceINST(.trace_file(trace_file), .file_handle(file_handle));
	//parser parserINST(.file_handle(file_handle), .line_number(line_number), .operation(operation), .address(address));

	initial begin
		if (!$value$plusargs("trace_file=%s", trace_file)) begin
			trace_file = "./Files/default.din";
			`ifdef DEBUG
				$display("No intput from user. Tracing default file from %s", trace_file);
			`endif
		end else begin
			`ifdef DEBUG
				$display("Tracing file from %s", trace_file);
			`endif
		end
		
		`ifdef DEBUG
			$display("Opening file %s", trace_file);
		`endif
		
		file_handle = $fopen(trace_file, "r");
		
		`ifdef DEBUG
			if (file_handle == 0) begin
				$display("Error in opening file '%s'.", trace_file);
				$stop;
			end else begin
				$display("File opened successfully");
			end
		`endif
		
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
		//while (!$feof(file_handle)) begin
		//	line_number++;
		//	#2;
		//	$display("Line %0d: Operation: %0d, Address: %h", line_number, operation, address);
		//end

    	$fclose(file_handle);
		`ifdef DEBUG
			$display("File closed successfully");
		`endif
	end
endmodule