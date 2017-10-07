/*
Author: Aniket Badhan
Date: 04/13/2017
Ethernet Project File
*/

class eth_pkt;
	rand bit [55:0] preamble;
	rand bit [7:0] sof;
	rand bit [47:0] da;
	rand bit [47:0] sa;
	rand bit [15:0] len;
	rand byte payload[];
	rand bit [31:0]	crc;

	bit rx_tx; //1 : Received packet, 0 : transmitted packet

	//Function to print the elements of the class object
	function void print(string name="eth_pkt");
		$display("Printed from: %s", name);
		$display("Preamble: %b", preamble);
		$display("Sof: %d", sof);
		$display("DA: %d", da);
		$display("SA: %d", sa);
		$display("Length: %d", len);
		$display("Packets: %p", payload);
		$display("CRC: %b", crc);
	endfunction

	//as payload should be 42-1500 bytes
	constraint lenSize{
		//len >41;
		//len < 1501;
		len inside {[10:100], [200:300]};
	}

	constraint payloadSize{
		payload.size() == len;
	}

	//deep copy function
	function deepCopy(output eth_pkt pkt1);
		pkt1 = new();
		pkt1.preamble = this.preamble;
		pkt1.sof = this.sof;
		pkt1.da = this.da;
		pkt1.sa = this.sa;
		pkt1.len = this.len;
		pkt1.payload = this.payload;
	endfunction

	//Function to compare the 2 ethernet packets
	function bit compare(input eth_pkt pkt1);
		if(pkt1.preamble!=this.preamble) begin
			return 0;
		end
		if(pkt1.sof!= this.sof)begin
			return 0;
		end
		if(pkt1.da!=this.da) begin
			return 0;
		end
		if(pkt1.sa!=this.sa) begin
			return 0;
		end
		if(pkt1.len!=this.len) begin
			return 0;
		end
		for(int i=0;i<len;i++) begin
			if(pkt1.payload[i]!=this.payload[i]) begin
				return 0;
			end
		end
		return 1;
	endfunction

	//Pack the object into a queue of bytes
	function void pack(output byte byteQ[$]); //$: queuebyte
		//byteQ = {<<byte{preamble, sof, da, sa, len, payload, crc}};	//starts packing from crc
		byteQ = {>>byte{preamble, sof, da, sa, len, payload, crc}};	//starts packing from preamble
	endfunction

	//Unpack the queue of bytes
	function void unpack(input byte byteQ[$]);
		preamble = {byteQ[0], byteQ[1], byteQ[2], byteQ[3], byteQ[4], byteQ[5], byteQ[6]};
		sof = byteQ[7];
		da = {byteQ[8], byteQ[9], byteQ[10], byteQ[11], byteQ[12], byteQ[13]};
		sa = {byteQ[14], byteQ[15], byteQ[16], byteQ[17], byteQ[18], byteQ[19]};
		len = {byteQ[20], byteQ[21]};
		payload = new[len];	//dynamic array. so allocate memory to the dynamic array first before using it
		for(int i=0;i < len; i++) begin
			payload[i] = byteQ[22+i];
		end
		crc = {byteQ[22+len], byteQ[23+len], byteQ[24+len], byteQ[25+len]};
	endfunction

	function void pre_randomize();
		$display("Before Randomization");
		if(eth_config::testName == 1) begin
			preamble.rand_mode(0);				//sample example to turn off the randomization for a variable
		end
	endfunction

	function void post_randomize();

	endfunction


endclass
