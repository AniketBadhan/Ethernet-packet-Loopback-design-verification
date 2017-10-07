/*
  Author: Aniket Badhan
  Description: Coverage for the test bench architecture

*/
typedef enum {
  goodpkt,
  badpkt
  } packetType;

typedef enum {
  False = 0,
  True = 1
  } pktCheck;

class eth_cov;
  eth_pkt ethPkt_mon2cov;
  packetType pkttype, goodPacket, badPacket;
  pktCheck goodPktFlag, badPktFlag;
  int goodCount = 0;
  int badCount = 0;
  event pktRecd;

  //cover group for coverpoints of len of the payload and the sa
  covergroup eth_cg @ (pktRecd);
    LEN_PAYLOAD : coverpoint ethPkt_mon2cov.len{
      bins LOW_RANGE        = {[0:50]};
      bins MID_RANGE        = {[51:100]};
      bins NORMAL_RANGE     = {[100:1500]};
      bins INVALID_RANGE    = {[1500:2000]};
    }
    SA  : coverpoint ethPkt_mon2cov.sa{
      options.auto_bin_max = 10;
      options.at_least = 2;
    }
  endgroup

  //covergroup for coverpoints on good packet and bad packet count
  covergroup ethPacketType;
    GOOD_PACKET : coverpoint goodCount iff (goodPktFlag == True){
      ignore_bins LOW_RANGE   = {[0:3]};
      bins MEDIUM_RANGE       = {[4:9]};
      bins HIGH_RANGE         = default;
    }
    BAD_PACKET : coverpoint badCount iff (badPktFlag == True){
      ignore_bins LOW_RANGE   = {[0:3]};
      bins MEDIUM_RANGE       = {[4:9]};
      bins HIGH_RANGE         = default;
    }
  endgroup

  function new();
    eth_cg = new();
    ethPacketType = new();
  endfunction

  //receive the packet from the mon2cov
  task run();
    while(1) begin
      eth_config::mon2cov.get(ethPkt_mon2cov);
      checkPacket(ethPkt_mon2cov);
      ->pktRecd;
    end
  endtask

  //Function to check if the packet is good or bad and then accordingly update the good or bad packet count
  function void checkPacket(eth_pkt pkt);
		pkttype = calcCRC(pkt);
		if (pkttype == goodpkt) begin
			goodCount++;
      goodPktFlag = True;
      ethPacketType.sample();
      goodPktFlag = False;
		end
		if (pkttype == badpkt) begin //8
			badCount++;
			badPktFlag = True;
      ethPacketType.sample();
      badPktFlag = False;
		end
	endfunction

	function packetType calcCRC(eth_pkt pkt);

	endfunction

endclass
