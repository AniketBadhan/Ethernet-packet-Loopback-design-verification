/*
Author: Aniket Badhan
Date: 04/13/2017
Ethernet Project File

*/

class eth_gen;
	eth_pkt ethPktQ[$];
	eth_pkt pkt, pktFromQ, pktFromBfm2Gen;
	bit compareFlag;

	task run();
		fork
			case(eth_config::testName)
			//Generating 10 good packets
			0		:	begin
							for(int i=0;i<10;i++) begin
								pkt = new();
								pkt.crc.rand_mode(0);
								assert(pkt.randomize) $display("Packet Randomized Successfully(while generation, legal packet)");
									else $error("Packet Randomization failed!!!!");
								eth_config::gen2bfm.put(pkt);
								ethPktQ.push_back(pkt);
							end
						end
			//generating 10 packets with random CRC(FCS), making the packets illegal
			1		:	begin
							for(int i=0;i<10;i++) begin
								pkt = new();
								pkt.crc.rand_mode(1);
								assert(pkt.randomize) $display("Packet Randomized Successfully(while generation, illegal CRC)");
									else $error("Packet Randomization failed!!!!");
								eth_config::gen2bfm.put(pkt);
								ethPktQ.push_back(pkt);
							end
						end
			//generating 10 packets with constraint on the number of bytes in payload disabled, making the packets illegal
			2		:   begin
							pkt = new();
							pkt.crc.rand_mode(0);													//disabling the randomization on crc
							pkt.payloadSize.constraint_mode(0);						//disabling the contraint on payload's size
							assert(pkt.randomize) $display("Packet Randomized Successfully(while generation, illegal payload size)");
								else $error("Packet Randomization failed!!!!");
							eth_config::gen2bfm.put(pkt);
							ethPktQ.push_back(pkt);
						end
			endcase

			//Comparing the packets transmitted at the output by the DUT with the generated packets
			begin
				while(1) begin
					eth_config::bfm2gen.get(pktFromBfm2Gen);
					pktFromQ = ethPktQ.pop_front();
					compareFlag = pktFromQ.compare(pktFromBfm2Gen);
					$display("Compare result (1-Equal, 0-Unequal) :- %b", compareFlag);
				end
			end
		join
	endtask
endclass
