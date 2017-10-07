/*
Author: Aniket Badhan
Date: 04/13/2017
Ethernet Project File
*/

interface eth_interface(input clk, rst);

	logic [7:0] data_in;
	logic valid_in;
	logic ready_out;
	logic [7:0] data_out;
	logic valid_out;
	logic ready_in;

	modport dut(input clk, input rst, input data_in, input valid_in, output ready_out, output data_out, output valid_out, input ready_in);
	modport bfm(input clk, input rst, output data_in, output valid_in, input ready_out, input data_out, input valid_out, output ready_in);

endinterface
