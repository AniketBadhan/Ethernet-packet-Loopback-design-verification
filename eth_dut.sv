module eth_dut(
	input bit clk,
	input bit rst,
	input bit [7:0] data_in,
	input bit valid_in,
	output reg ready_out,
	output reg [7:0] data_out,
	output reg valid_out,
	input bit ready_in
);
	int count = 0;
	//1. Receive the packet
	//2. transmit packet
	byte byteQ[$];
	byte byteQ_tx[$];
	int len_temp = 0;
	semaphore smp;
	int checkFlag = 0;

	initial begin
		smp = new(1);
	end

	always @(posedge clk) begin
		if (valid_in == 1'b0) ready_out = 1'b0;
	end

	always @(posedge clk) begin
		if (valid_in == 1'b1) begin
			byteQ.push_back(data_in);
			ready_out <= 1'b1;
			count = count + 1; //wait for byte no 20, 21 which will give number of data bytes to come
			if (count == 22) begin
				len_temp = {byteQ[20], byteQ[21]}; //concatenation
				$display("DUT LEN = %d", len_temp);
			end
			if (count == 26 + len_temp) begin
				$display("One packet is collected");
				//foreach(byteQ[i]) begin
				//	$display("byteQ[%d] = %h", i, byteQ[i]);
				//end
				byteQ_tx = byteQ;
				byteQ.delete();
				count = 0;
				checkFlag = checkPkt(byteQ_tx);
				if(checkFlag) begin
					fork
						tranmit_pkt(byteQ_tx);
					join_none
				end
				else begin
					$display("Bad Packet. Hence Packet Dropped!!!");
				end
			end
		end
	end

	//Implement the functionality to verify of the packet is a good packet or bad packet
	function bit checkPkt(byte byteQ[$]);
		return 1;
	endfunction

	task tranmit_pkt(byte byteQ[$]);
		smp.get(1);
		foreach(byteQ[i]) begin
			valid_out = 1'b1;
			data_out = byteQ[i];
			@(posedge clk);
			wait (ready_in);
		end
		valid_out = 1'b0;
		byteQ.delete();
		smp.put(1);
	endtask

endmodule
