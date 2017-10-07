/*
  Author: Aniket Badhan
*/
program eth_tb;

  eth_env env;

	initial begin
		$value$plusargs("testname=%d", eth_config::testName);       //testName argument is read from the command line
		env.run();
	end

	final begin
		if (eth_config::pktMismatch != 0) begin
			$display("Test failed");
		end
		else begin
			$display("Test Passed, Match = %d", eth_config::pktMatch);
		end
	end

endprogram
