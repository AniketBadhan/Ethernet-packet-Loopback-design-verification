/*
Author: Aniket Badhan
Date: 04/13/2017
Ethernet Project File
*/
class eth_bfm;
	virtual eth_interface.bfm vifBFM;				//using the modport from the interface class
	eth_pkt pktFromGen2Bfm, pktRecd;

	task run();
		byte byteQ[$];
		int recdCount = 0;
		int lengthCount;
		fork
			//Get pkt from Mailbox and send it to driver task for mapping with the interface
			while(1) begin
				eth_config::gen2bfm.get(pktFromGen2Bfm);
				driver_tx(pktFromGen2Bfm);
			end
			//
			while(1) begin
				@(negedge vifBFM.valid_out);
				vifBFM.ready_in = 1'b0;
			end
			//Accept data from Transmission Interface
			while(1) begin
				@(posedge vifBFM.clk);
				if (vifBFM.valid_out == 1'b1) begin
					vifBFM.ready_in = 1'b1;
					byteQ.push_back(vifBFM.data_out);
					recdCount = recdCount + 1;
					if (recdCount == 22) begin		//26+len
						lengthCount = {byteQ[20], byteQ[21]};
					end
					if (recdCount == lengthCount+26) begin
						$display("BFM : packet is received");
						pktRecd = new();
						pktRecd.unpack(byteQ);
						byteQ.delete();
						pktRecd.print();
						eth_config::bfm2gen.put(pktRecd);
					end
				end
			end
		join
	endtask

	task driver_tx(eth_pkt pkt);
		byte byteUnpackQ[$];
		pkt.unpack(byteUnpackQ);
		foreach(byteUnpackQ[i]) begin
			vifBFM.valid_in <= 1'b1;						//valid_in is made 1 so that DUT can accept the packets
			vifBFM.data_in <= byteUnpackQ[i];		//sending the data to the reception
			@(posedge vifBFM.clk);
			wait (vifBFM.ready_out == 1'b1);		//wait until DUT starts accpeting bytes
		end
		intf.valid_in <= 0;										//So that DUT doesn't keep accpeting data
		@(posedge intf.clk);
	endtask
endclass
