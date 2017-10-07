/*
  Author : Aniket Badhan
*/
`timescale 1ns / 1ps

`include "eth_config.sv"
`include "eth_pkt.sv"
`include "eth_interface.sv"
`include "eth_gen.sv"
`include "eth_bfm.sv"
`include "eth_monitor.sv"
`include "eth_ref.sv"
`include "eth_cov.sv"
`include "eth_env.sv"
`include "eth_dut.sv"
`include "eth_tb.sv"

module top;

  reg clk, rst;

  eth_intf intf(clk, rst);
  eth_dut dut(clk, rst , intf.data_in, intf.valid_in , intf.ready_out, intf.data_out, intf.valid_out, intf.ready_in );
  eth_tb tb();
  eth_assertion ass_inst(clk, rst , intf.data_in, intf.valid_in , intf.ready_out, intf.data_out, intf.valid_out, intf.ready_in );

  initial begin
     clk = 0;
     rst = 1;
     #10;
     rst = 0;
  end

  initial begin
    #20000;
    $finish;
  end

  always #5 clk = ~clk;

endmodule

module eth_assertion(
  input clk,
  input rst,
  input data_in,
  input valid_in,
  input  ready_out,
  input data_out,
  input valid_out,
  input ready_in
  );

  property valid_ready_rx;
  	@(posedge clk) (valid_in==1'b1) ##[0:2] $rose(ready_out);
  endproperty

  property valid_ready_tx;
  	@(posedge clk) (valid_out==1'b1) ##[0:2] $rose(ready_in);
  endproperty

endmodule
