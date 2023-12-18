`ifndef SUB_FUNCTIONS_SV
`define SUB_FUNCTIONS_SV


task read_data(longint qn, longint addr, longint delay);
  begin
    automatic type_transaction tr_rd;
    tr_rd.addr  = addr;
    tr_rd.delay = delay;
    tr_rd.op    = READ;

    for (longint ii = 0; ii < REQUESTERS; ii++)
      if (qn[ii]) begin
        qa_transaction_drive_rd[ii].push_back(tr_rd);
        qa_transaction_check_rd[ii].push_back(tr_rd);
      end
  end
endtask;  // read_data


task write_data(longint qn, longint addr, longint data, longint delay);
  begin
    automatic type_transaction tr_wr;
    tr_wr.addr  = addr;
    tr_wr.data  = data;
    tr_wr.delay = delay;
    tr_wr.op    = WRITE;

    for (longint ii = 0; ii < REQUESTERS; ii++)
      if (qn[ii]) begin
        qa_transaction_drive_wr[ii].push_back(tr_wr);
      end
  end
endtask;  // write_data


task sync(longint qr, longint qw, longint sync_tick);
  begin
    automatic type_transaction tr_rd;
    tr_rd.op        = SYNC;
    tr_rd.sync_tick = sync_tick;

    for (longint ii = 0; ii < REQUESTERS; ii++) begin
      if (qr[ii]) qa_transaction_drive_rd[ii].push_back(tr_rd);
      if (qw[ii]) qa_transaction_drive_wr[ii].push_back(tr_rd);
    end
  end
endtask;  // sync


task q_end(longint qr, longint qw);
  begin
    automatic type_transaction tr_rd;
    tr_rd.op = EXIT;
    for (longint i = 0; i < REQUESTERS; i++)
      if (qr & (1 << i)) 
        qa_transaction_drive_rd[i].push_back(tr_rd);
  end
endtask;  // q_end

task test_info(test_params_t tp);
  begin
    automatic type_transaction tr_rd;
    tr_rd.op = INFO;
    tr_rd.tst_prm = tp;

    for (longint ii = 0; ii < REQUESTERS; ii++) begin
      qa_transaction_drive_rd[ii].push_back(tr_rd);
      qa_transaction_drive_wr[ii].push_back(tr_rd);
    end
  end
endtask;  //test_info

task task_done();
  begin
    automatic type_transaction tr_rd;
    tr_rd.op = CHECKPOINT;
    for (longint ii = 0; ii < REQUESTERS; ii++) begin
      qa_transaction_drive_rd[ii].push_back(tr_rd);
      qa_transaction_drive_wr[ii].push_back(tr_rd);
    end
  end
endtask;  //task_done

task reset_var();
  begin
    test_start   = 0;
    tick_current = 0;

    for (longint i = 0; i < REQUESTERS; i++) begin
      st[i].w_start_time     = -1;
      st[i].r_start_time     = -1;
      st[i].r_cnt            = 0;
      st[i].w_cnt            = 0;
      st[i].r_subtest_finish = 0;
      st[i].w_subtest_finish = 0;
    end
  end
endtask;  // reset_var


task restart();
  begin
    reset_var();
    @(posedge clk) assert (0 == are_ports_done());

    rst = '1;
    #50;
    rst = '0;

    @(posedge clk) test_start = '1;
  end
endtask;  // restart



task capture_progress(test_params_t tp);
  begin
    automatic longint Rq = tp.Rq;
    automatic longint Bk = tp.Bk;
    automatic real Dt = tp.Dt;
    automatic real Sc = tp.Sc;
    automatic real Ac = tp.Ac;

    static longint test_count = 0;
    automatic longint f_data = $fopen("output_randomize_test.txt", "a");
    automatic real r_full_av_delay = 0;
    automatic real w_full_av_delay = 0;

    //~~~~~~~~~~~FIRST INFO~~~~~~~~~~
    static logic first_run = 1;
    if (first_run) begin
      first_run = 0;
      $fdisplay(f_data, "MAX_banks: %p  MAX_requests: %p \n\n", BANKS, REQUESTERS);
    end

    //~~~~~~~~~~~~READ~~~~~~~~~~~~~~~
    for (longint ii = 0; ii < Rq; ii++) begin
      automatic longint curr_delay = st[ii].r_delay[0];
      automatic longint cnt        = st[ii].r_cnt;
      automatic longint min_delay = curr_delay;
      automatic longint max_delay = curr_delay;
      automatic longint avr_delay = curr_delay;
      if (cnt > MAX_TRANSACTION) cnt = MAX_TRANSACTION;
      if (DISPL) $display(" read-port: %2d  cnt: %-4d", ii, cnt);
      if (cnt == 0) return;

      for (longint jj = 1; jj < cnt; jj++) begin
        curr_delay = st[ii].r_delay[jj];
        if (curr_delay < min_delay) min_delay = curr_delay;
        if (curr_delay > max_delay) max_delay = curr_delay;
        avr_delay += curr_delay;
      end
      st[ii].r_delay_min = min_delay;
      st[ii].r_delay_max = max_delay;
      st[ii].r_delay_avr = 1.0 * avr_delay / cnt;
      st[ii].r_work_time = tick_current - st[ii].r_start_time - 1;
      st[ii].r_velocity  = 1.0 * st[ii].r_cnt / st[ii].r_work_time;

      r_full_av_delay += st[ii].r_delay_avr;
    end

    //~~~~~~~~~~~~WRITE~~~~~~~~~~~~~
    for (longint ii = 0; ii < Rq; ii++) begin
      automatic longint curr_delay   = st[ii].w_delay[0];
      automatic longint cnt    = st[ii].w_cnt;
      automatic longint min_delay  =  curr_delay;
      automatic longint max_delay  =  curr_delay;
      automatic real avr_delay   =  curr_delay;
      if (cnt > MAX_TRANSACTION) cnt = MAX_TRANSACTION;
      if (DISPL) $display("write-port: %2d  cnt: %-4d", ii, cnt);

      for (longint jj = 1; jj < cnt; jj++) begin
        curr_delay = st[ii].w_delay[jj];
        if (curr_delay < min_delay) min_delay = curr_delay;
        if (curr_delay > max_delay) max_delay = curr_delay;
        avr_delay += curr_delay;
      end

      st[ii].w_delay_min = min_delay;
      st[ii].w_delay_max = max_delay;
      st[ii].w_delay_avr = 1.0 * avr_delay / cnt;
      st[ii].w_work_time = tick_current - st[ii].w_start_time - 1;
      st[ii].w_velocity  = 1.0 * st[ii].w_cnt / st[ii].w_work_time;

      w_full_av_delay += st[ii].w_delay_avr;
    end
    r_full_av_delay /= 1.0 * Rq;
    w_full_av_delay /= 1.0 * Rq;
    //~~~~~~~~~~~~~~PRINT~~~~~~~~~~~~
    if(DISPL) $display( "~~~~~~~~~SUBTEST#%p: REQ %p, BANK %p  | tick_cur[%p]~~~~~~~~~~",test_count, Rq, Bk, tick_current);
    if(DISPL) $display( "         PARAM: Dt[%p], Sc[%p], Ac[%p], AV_CNT[%p]", Dt,Sc,Ac,AVERAGE_COUNT);
    if(DISPL) $display( "         G_AV_DELAY: READ_ALL[%p], WRITE_ALL[%p]", r_full_av_delay, w_full_av_delay);
    if(DISPL) $display( "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");

    $fdisplay( f_data, "~~~~~~~~~SUBTEST#%p: REQ %p, BANK %p  | tick_cur[%p]~~~~~~~~~~", test_count, Rq, Bk, tick_current);
    if(DISPL)$fdisplay( f_data, "         PARAM: Dt[%p], Sc[%p], Ac[%p], AV_CNT[%p]",Dt,Sc,Ac,AVERAGE_COUNT);
    $fdisplay( f_data, "         G_AV_DELAY: READ_ALL[%p], WRITE_ALL[%p]", r_full_av_delay, w_full_av_delay);
    if(DISPL)$fdisplay( f_data, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");

    test_count++;

    for (longint ii = 0; ii < Rq; ii++)
      if (DISPL) $fdisplay(f_data, "READ  port[%p]   - count: %-5d   min_delay: %-4d  max_delay: %-4d  avr_delay: %f velocity: %f [Tr/clock]", ii, st[ii].r_cnt, st[ii].r_delay_min, st[ii].r_delay_max, st[ii].r_delay_avr, st[ii].r_velocity);
    if (DISPL) $fdisplay( f_data, "\n");

    for (longint ii = 0; ii < Rq; ii++)
      if (DISPL) $fdisplay(f_data,"WRITE port[%p]   - count: %-5d   min_delay: %-4d  max_delay: %-4d  avr_delay: %f velocity: %f [Tr/clock]", ii, st[ii].w_cnt, st[ii].w_delay_min, st[ii].w_delay_max, st[ii].w_delay_avr, st[ii].w_velocity);
    if(DISPL) $fdisplay( f_data, "\n\n");

//     // ~~~~~RESET~~~~~~~~~~~
//     for( int ii=0; ii < Rq; ii++ )
//       st[ii].r_cnt = 0;
//     tick_current = 0;
    $fclose(f_data);
  end
endtask;  // chek_point

task test_finish(longint test_id, string test_name, longint result);
  begin
    automatic longint fd = $fopen("test_results.txt", "a");

    if (1 == result) begin
      $fdisplay(fd, "test_id=%-5d test_name: %15s         TEST_PASSED", test_id, test_name);
      $display("test_id=%-5d test_name: %15s         TEST_PASSED", test_id, test_name);
    end else begin
      $fdisplay(fd, "test_id=%-5d test_name: %15s         TEST_FAILED *******", test_id, test_name);
      $display("test_id=%-5d test_name: %15s         TEST_FAILED *******", test_id, test_name);
    end
    $display(""); $display("");
    $fclose(fd);
    $stop();
  end 
endtask // END test_finish();


function longint are_queues_empty();
  begin
    for (longint ii = 0; ii < REQUESTERS; ii++)
      if (qa_transaction_check_rd[ii].size() > 0)
        return 0;
    return 1;
  end
endfunction;  // are_queues_empty

function longint are_ports_done();
  begin
    for (longint ii = 0; ii < REQUESTERS; ii++)
      if (st[ii].r_subtest_finish == 0 || st[ii].w_subtest_finish == 0)
        return 0;
    return 1;
  end
endfunction;  // are_ports_done


task finish_all();
  begin
    q_end({REQUESTERS{1'b1}}, {REQUESTERS{1'b1}});
    
    @(posedge clk iff are_queues_empty())
    #100

    capture_progress(curr_test_params);
    program_finish = '1;
  end
endtask;  //finish_all


`endif  // SUB_FUNCTIONS_SV
