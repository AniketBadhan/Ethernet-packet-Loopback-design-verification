/*
  Author: Aniket Badhan
  Description: reference design for generating the correct output according the random input, which will be then used to compare with the output generated from the DUT
*/

class eth_ref;

  eth_pkt ethPkt_mon2Ref, ethPktTx, ethPktRx;
  eth_pkt ethPktTx_Q[$];
  eth_pkt ethPktRx_Q[$];
  eth_pkt ethPktRxBad_Q[$];
  int txCount = 0;
  int rxCount = 0;

  task run();
    fork
      while(1) begin
        eth_config::mon2ref.get(ethPkt_mon2Ref);
        if(ethPkt_mon2Ref.rx_tx == 1) begin     //pkt is received
          if(checkPkt(ethPkt_mon2Ref)) begin
            ethPktRx_Q.push_back(ethPkt_mon2Ref);
          end
          else begin
            ethPktRxBad_Q.push_back(ethPkt_mon2Ref);
          end
        end
        if(ethPkt_mon2Ref.rx_tx == 0) begin     //pkt is transmitted
          ethPktRx_Q.push_back(ethPkt_mon2Ref);
        end
      end
      while(1) begin
        if(ethPktRx_Q.size() > 0 && ethPktTx_Q.size() > 0) begin    //process only when size of both the queues is greater than 0
          ethPktTx = ethPktTx_Q.pop_front();
          ethPktRx = ethPktRx_Q.pop_front();
          if(ethPktRx.compare(ethPktTx)) begin
            eth_config::pktMatch++;
            $display("Packet Matched");
          end
          else begin
            eth_config::pktMismatch++;
            $display("Packet Mismatched");
            $display("------- Transmitted Packet ------- ");
            ethPktTx.print("Ethernet Packet Transmitted");
            $display("------- Recevied Packet ------- ");
            ethPktRx.print("Ethernet Packet Recevied");
          end
        end
      end
    join
  endtask

  function bit checkPkt(eth_pkt pkt);
    if(pkt.len == pkt.payload.size()) begin
      return 1;
    end
    else begin
      return 0;
    end
  endfunction

endclass
