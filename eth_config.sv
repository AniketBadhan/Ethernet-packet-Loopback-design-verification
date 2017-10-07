/*
Author: Aniket Badhan
Date: 04/13/2017
Ethernet Project File
*/
class eth_config;
	static mailbox gen2bfm = new();
	static mailbox bfm2gen = new();
	static mailbox mon2cov = new();
	static mailbox mon2ref = new();

	static int testName;

	static int pktMatch = 0;
	static int pktMismatch = 0;
endclass
