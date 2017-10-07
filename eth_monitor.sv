/*
Author: Aniket Badhan
Date: 04/13/2017
Ethernet Project File
Functionality: Monitoring the receiver and transmitter interface. Receiver Interface is monitored at Valid_in==1 and Ready_out==1 whereas transmitter interface is monitored at valid_out==1 and ready_in==1
*/

class eth_monitor;
	int txCount = 0;
	int rxCount = 0;
	int lenRx;
	int lenTx;

	byte ethRxQ[$];
	byte ethTxQ[$];
	eth_pkt ethPktRx, ethPktTx;

	virtual eth_inteface vif;

	function new();
		ethPktRx = new();
		ethPktTx = new();
	endfunction

	task run();
		while(1) begin
			@(posedge vif.clk);
			if(vif.valid_in == 1 && vif.ready_out == 1) begin
				ethRxQ.push_back(vif.data_in);
				rxCount++;
				if(rxCount==22) begin
					lenRx = {ethRxQ[20],ethRxQ[21]};
				end
				if(rxCount == 22+lenRx+4) begin
					$display("Packet Received Correctly");
					ethPktRx.unpack(ethRxQ);
					ethPktRx.rx_tx = 1'b1;
					mon2cov.put(ethPktRx);
					mon2ref.put(ethPktRx);
					rxCount = 0;								//reception of one packet completed, start new packet
					ethRxQ.delete();
				end
			end
			if(vif.valid_out == 1 && vif.ready_in == 1) begin
				ethTxQ.push_back(vif.data_out);
				txCount++;
				if(txCount==22) begin
					lenTx = {ethTxQ[20],ethTxQ[21]};
				end
				if(txCount == 22+lenTx+4) begin
					$display("Packet transmitted Correctly");
					ethPktTx.unpack(ethTxQ);
					ethPktTx.rx_tx = 1'b1;
					mon2cov.put(ethPktTx);
					mon2ref.put(ethPktTx);
					txCount = 0; 							//Tranmission of one packet completed and look for other packet now
					ethTxQ.delete();
				end
			end
		end
	endtask

endclass
