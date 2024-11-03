module trace(
	input string trace_file,
	output int file_handle
);
	always_comb begin
		if (!$value$plusargs("trace_file=%s", trace_file)) begin
			trace_file = "./Files/default.din";
			file_handle = $fopen(trace_file, "r");
		end
		//if (!file_status) begin
			//file_handle = $fopen(trace_file, "r");
		//end else if (file
	end
endmodule

module parser(
	input int line_number,
	input int file_handle,
	output int operation,
	output logic [31:0] address
);
	always_comb begin
		$fscanf(file_handle, "%d %h", operation, address);
	end
endmodule