/*
  Author: Aniket Badhan
*/

class eth_env;
  eth_bfm bfm;
  eth_gen gen;
  eth_cov cov;
  eth_monitor monitor;
  eth_ref referenceDesign;

  function new();
    bfm = new();
    gen = new();
    cov = new();
    monitor = new();
    referenceDesign = new();
  endfunction

  task run();
    fork
      gen.run();
      bfm.run();
      monitor.run();
      cov.run();
      referenceDesign.run();
    join
  endtask

endclass
