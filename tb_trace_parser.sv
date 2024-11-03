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
		end

		file_handle = $fopen(trace_file, "r");

		//if (file_handle == 0) begin
		//	$display("Error: Could not open file '%s'.", trace_file);
		//	$finish;
		//end

		$display("Reading and parsing trace file: %s", trace_file);

		while ($fscanf(file_handle, "%d %h", operation, address) == 2) begin
			line_number++;
			$display("Line %0d: Operation: %0d, Address: %h", line_number, operation, address);
		end
		//while (!$feof(file_handle)) begin
		//	line_number++;
		//	#2;
		//	$display("Line %0d: Operation: %0d, Address: %h", line_number, operation, address);
		//end

    	$fclose(file_handle);
    	$display("Finished reading the trace file.");

	end
endmodule