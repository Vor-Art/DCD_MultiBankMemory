`ifndef RANDOMIZE_SV
`define RANDOMIZE_SV

`define RND_MAX 16'hffff

function real get_rand(real max = 1.0);
  static longint seed = 10;
  return max * (1.0 * $dist_uniform(seed, 0, `RND_MAX) / `RND_MAX);
endfunction;

function longint uRandom(longint max = `RND_MAX);
  static longint seed = 2;
  return $dist_uniform(seed, 0, `RND_MAX) % (max + 1);  // has more stability 
  // return $dist_uniform(seed,0,max); 
endfunction;

function longint uRandomRange(longint min = 0, longint max = `RND_MAX);
  return uRandom(max - min) + min;
endfunction;

class randomize_full_t;
  longint number_of_ports;  // [1..REQUESTS]
  longint number_of_banks;  // [1..BANKS]
  real duty_cycle;      // (0..100] 100 -> without gap              {in percent}
  real scatter;         // [0..100]   0 -> constant gap probability   100 -> gap in {0:2gap} {in percent}
  real accuracy;        // [0..100]   1 -> access to own bank       {in percent}

  randc bit [$clog2(REQUESTERS):0] port;  // [0..number_of_ports-1]
  randc bit [$clog2(BANKS):0]      bank_index;  // [0..min(banks,ports)];
  rand  bit [DATA_WIDTH-1:0] data;
  bit       [ADDR_WIDTH-1:0] addr;
  longint delay;

  //   private:
  real gap_av;
  real gap_scatter;
  bit hit;

  task update();
    begin
      assert (this.randomize());
      gap_av = 100.0 / duty_cycle - 1;
      gap_scatter = gap_av * (1 + scatter * (2 * get_rand() - 1) / 100.0);
      // gap_s = (0:1)*2->(0:2)-1->(-1:1)*2->(-s:s)+1->(-s+1:s+1)*g->{s[0:1]}->([0:1]:[1:2])g->(0:2g);
      delay = $floor(gap_scatter) + ((get_rand() < (gap_scatter - $floor(gap_scatter))) ? 1 : 0);

      bank_index = port % number_of_banks;

      if (get_rand() < (accuracy / 100.0)) begin
        this.addr = uRandomRange(BANK_SIZE * bank_index, BANK_SIZE * (bank_index + 1));
        hit = 1;
      end else begin
        this.addr = uRandom(BANK_SIZE * (number_of_banks - 1));
        if (this.addr >= BANK_SIZE * bank_index) this.addr += BANK_SIZE;
        hit = 0;
      end
    end
  endtask

  function string str();
    string s;
    $sformat(s, " port:[%2d]  addr: [%h]  delay:[%-d]", port, addr, delay);
    $sformat(s, "%s | gap_av:[%p], gap_scatter[%p], bank_index[%2d] - %s  ", s, gap_av, gap_scatter, bank_index, hit ? "hit!" : "miss :(");
    return s;
  endfunction;

  //~~~~~~~~~~~constuctor begin~~~~~~~~~~//
  function new(test_params_t tp);
    number_of_ports = tp.Rq;
    number_of_banks = tp.Bk;
    duty_cycle      = tp.Dt;
    scatter         = tp.Sc;
    accuracy        = tp.Ac;
  endfunction
  //~~~~~~~~~~~~constuctor end~~~~~~~~~~~//

  constraint port_range { port < number_of_ports; }
  constraint bank_range { bank_index < number_of_ports; bank_index < number_of_banks;}
endclass;


task test_randomize();
  begin
    automatic test_params_t tp;
    automatic randomize_full_t r;
    automatic longint RANDOMIZE_LOOP;

    tp.Dt = 100;
    tp.Sc = 0;
    tp.Ac = 50;

    for (longint M = min_BANKS; M <= BANKS; M += step_BANKS)
      for (longint N = min_REQUESTERS; N <= REQUESTERS; N += step_REQUESTERS) begin
        RANDOMIZE_LOOP = AVERAGE_COUNT * N;
        tp.Rq = N;
        tp.Bk = M;
        r = new(tp);
        test_info(tp);
        if (DISPL) $display("@@@@@@@@@@@@@@@@@@@[%p]@@@@@@@@@@@@@@@@@@@@", N - 1 + REQUESTERS * (M - 1));

        for (longint rd = 0; rd < RANDOMIZE_LOOP; rd++) begin
          r.update();
          read_data(1 << r.port, r.addr, r.delay);
          if (DISPL) if (rd < (DISP_QUANTITY + 2)) $display("\t\top: [ read] %s", r.str());
        end
        for (longint wr = 0; wr < RANDOMIZE_LOOP; wr++) begin
          r.update();
          write_data(1 << r.port, r.addr, r.data, r.delay);
          if (DISPL) if (wr < (DISP_QUANTITY + 2)) $display("\t\top: [write] %s", r.str());
        end
        $display("!!!!!!!!!!!!!!!!!!!!!!!!");
        task_done();
      end

    $display("!!!!!!!!!!!!!!!!!!!!!!!!");
    finish_all();
  end
endtask;  // test_randomize


task test_randomize_split_full();
  begin
    $display("Runing empty test \"test_randomize_split_full()\" ");
  end
endtask;  //END test_randomize_split_full


task test_randomize_single();
  begin
    $display("Runing empty test \"test_randomize_single()\" ");
  end
endtask;  //END test_randomize_single


`endif  // RANDOMIZE_SV
