// Code your testbench here
// or browse Examples

`default_nettype none

`include "transaction_pkg.sv"
`include "golden_memory_pkg.sv"
`include "params_pkg.sv"

import transaction_pkg::*;
import golden_memory_pkg::*;
import params_pkg::*;

module tb ();
  
  // ............Variable declaration block...............//
  string    test_name[3:0]=
  {
    "randomize_single",
    "randomize_split_full",
    "randomize", 
    "direct" 
  };

  logic               clk=0;
  logic               rst;

  longint                 cnt_wr=0;
  longint                 cnt_rd=0;
  longint                 cnt_ok=0;  
  longint                 cnt_error=0;

  longint                 show_ok=0;
  longint                 show_error=0;

  longint                 test_id=0;
  logic               test_start=0;
  logic               test_timeout=0;
  logic               program_finish=0;

  longint                 tick_current=0;

  golden_memory_t     golden_memory;
  test_params_t       curr_test_params;

  type_transaction qa_transaction_drive_rd  [REQUESTERS-1:0]  [$];
  type_transaction qa_transaction_check_rd  [REQUESTERS-1:0]  [$];
  type_transaction current_drive_rd         [REQUESTERS-1:0];
  type_transaction current_check_rd         [REQUESTERS-1:0];

  type_transaction qa_transaction_drive_wr  [REQUESTERS-1:0]  [$];
  type_transaction current_drive_wr         [REQUESTERS-1:0];

  longint qa_rd_start                           [REQUESTERS-1:0]  [$];

  type_uut   u  [REQUESTERS-1:0];
  type_stat  st [REQUESTERS-1:0];
  
  //to good display on EPWave
  wire [15:0] r2_r_addr = u[2].r_addr;
  wire [15:0] r1_r_addr = u[1].r_addr;
  wire [15:0] r0_r_addr = u[0].r_addr;
  wire        r2_r_avalid = u[2].r_avalid;
  wire        r1_r_avalid = u[1].r_avalid;
  wire        r0_r_avalid = u[0].r_avalid;
  wire        r2_r_dvalid = u[2].r_dvalid;
  wire        r1_r_dvalid = u[1].r_dvalid;
  wire        r0_r_dvalid = u[0].r_dvalid;
  wire [15:0] r2_r_data = u[2].r_data;
  wire [15:0] r1_r_data = u[1].r_data;
  wire [15:0] r0_r_data = u[0].r_data;
  wire        r2_r_aready = u[2].r_aready;
  wire        r1_r_aready = u[1].r_aready;
  wire        r0_r_aready = u[0].r_aready;
  wire [15:0] r2_w_addr = u[2].w_addr;
  wire [15:0] r1_w_addr = u[1].w_addr;
  wire [15:0] r0_w_addr = u[0].w_addr;
  wire [15:0] r2_w_data = u[2].w_data;
  wire [15:0] r1_w_data = u[1].w_data;
  wire [15:0] r0_w_data = u[0].w_data;
  wire        r2_w_valid = u[2].w_valid;
  wire        r1_w_valid = u[1].w_valid;
  wire        r0_w_valid = u[0].w_valid;
  wire        r2_w_ready = u[2].w_ready;
  wire        r1_w_ready = u[1].w_ready;
  wire        r0_w_ready = u[0].w_ready;

  logic [2*REQUESTERS-1:0]                  mask_avaliable[REQUESTERS-1:0];
  logic [2*REQUESTERS-1:0][DATA_WIDTH-1:0]  expect_data[REQUESTERS-1:0];
  logic                                     flag_eq[REQUESTERS-1:0];
  
  // combine all ports together 
  wire [REQUESTERS-1:0][ADDR_WIDTH-1:0]     general_r_addr;
  wire [REQUESTERS-1:0]                     general_r_avalid;
  wire [REQUESTERS-1:0]                     general_r_dvalid; 
  wire [REQUESTERS-1:0][DATA_WIDTH-1:0]     general_r_data; 
  wire [REQUESTERS-1:0]                     general_r_aready; 

  wire [REQUESTERS-1:0][ADDR_WIDTH-1:0]     general_w_addr; 
  wire [REQUESTERS-1:0][DATA_WIDTH-1:0]     general_w_data; 
  wire [REQUESTERS-1:0]                     general_w_valid; 
  wire [REQUESTERS-1:0]                     general_w_ready; 

  generate
    for(genvar i = 0; i < REQUESTERS; i ++ ) begin
      assign general_r_addr[i]   =  u[i].r_addr;    
      assign general_r_avalid[i] =  u[i].r_avalid;      
      assign u[i].r_dvalid       =  general_r_dvalid[i];
      assign u[i].r_data         =  general_r_data[i];
      assign u[i].r_aready       =  general_r_aready[i];

      assign general_w_addr[i]   =  u[i].w_addr;
      assign general_w_data[i]   =  u[i].w_data;
      assign general_w_valid[i]  =  u[i].w_valid;   
      assign u[i].w_ready        =  general_w_ready[i];     
    end
  endgenerate

  //------------

  multibank_memory
  #(
    .READ_PORTS     (   REQUESTERS  ), 
    .WRITE_PORTS    (   REQUESTERS  ),
    .DATA_WIDTH     (   DATA_WIDTH  ),
    .ADDR_WIDTH     (   ADDR_WIDTH  ),
    .BANKS          (   BANKS       )
  ) uut
  (
    
    .r_addr         (   general_r_addr      ),
    .r_avalid       (   general_r_avalid    ),
    .r_dvalid       (   general_r_dvalid    ),
    .r_data         (   general_r_data      ),
    .r_aready       (   general_r_aready    ),

    .w_addr         (   general_w_addr      ),
    .w_data         (   general_w_data      ),
    .w_valid        (   general_w_valid     ),
    .w_ready        (   general_w_ready     ),

    .*

  );

  
  
  
  
  
  //..............Generations block....................
  // Fill memory 
  for( genvar jj=0; jj < BANKS; jj++ )
    initial begin
      for( longint ii=0; ii < BANK_SIZE; ii++ )
        uut.bank[jj].memory.memory[ii] = ii + BANK_SIZE * jj;
    end 
  //------------
  genvar ii;
  generate
    for( ii=0; ii<REQUESTERS; ii++ ) begin
      initial begin
        u[ii].r_avalid          <= #1 '0;
        u[ii].r_addr            <= #1 '0;
        while(1) begin

          while(qa_transaction_drive_rd[ii].size()==0) #1;

          current_drive_rd[ii] = qa_transaction_drive_rd[ii].pop_front();

          if( EXIT == current_drive_rd[ii].op ) break;  //EXIT
          if( SYNC == current_drive_rd[ii].op )         //SYNC      
            begin
              @(posedge clk iff tick_current==current_drive_rd[ii].sync_tick );
              show_ok=0;
              show_error=0;
              continue;
            end
          if( INFO == current_drive_rd[ii].op ) begin   // INFO
            curr_test_params <=#1 current_drive_rd[ii].tst_prm;
            @(posedge clk); continue;
          end
          if( CHECKPOINT == current_drive_rd[ii].op ) begin // CHECKPOINT
            st[ii].r_subtest_finish<= #1 1;
            @(negedge rst);
            continue;
          end

          st[ii].r_start_time <= #1 (-1 == st[ii].r_start_time)? tick_current : st[ii].r_start_time;

          u[ii].r_addr   <= #1 current_drive_rd[ii].addr;
          u[ii].r_avalid <= #1 '1;
          

          qa_rd_start[ii].push_back(tick_current);

          @(posedge clk iff u[ii].r_aready & u[ii].r_avalid);

          u[ii].r_avalid <= #1 '0;
          u[ii].r_addr   <= #1 '0;

          repeat(current_drive_rd[ii].delay) @(posedge clk);

        end
      end
    end
  endgenerate

  generate
    for( ii=0; ii<REQUESTERS; ii++ ) begin

      initial begin
        u[ii].w_valid       <= #1 '0;
        u[ii].w_addr        <= #1 '0;
        u[ii].w_data        <= #1 '0;
        while(1) begin

          while(qa_transaction_drive_wr[ii].size()<=0) #1;

          current_drive_wr[ii] = qa_transaction_drive_wr[ii].pop_front();

          if( EXIT == current_drive_wr[ii].op ) break;  //EXIT 
          if( SYNC == current_drive_wr[ii].op ) begin   //SYNC 
            @(posedge clk iff tick_current==current_drive_wr[ii].sync_tick )
            continue;
          end
          if( INFO == current_drive_wr[ii].op ) begin   // INFO
            curr_test_params <=#1 current_drive_wr[ii].tst_prm;
            @(posedge clk) continue;
          end
          if( CHECKPOINT == current_drive_wr[ii].op ) begin // CHECKPOINT
            st[ii].w_subtest_finish<= #1 1;
            @(negedge rst)
            continue;
          end

          st[ii].w_start_time <= #1 (-1 == st[ii].w_start_time)? tick_current : st[ii].w_start_time;

          u[ii].w_addr   <= #1 current_drive_wr[ii].addr;
          u[ii].w_data   <= #1 current_drive_wr[ii].data;
          u[ii].w_valid  <= #1 '1;
          st[ii].w_start =  tick_current; 

          @(posedge clk iff u[ii].w_ready & u[ii].w_valid)

          if( st[ii].w_cnt < MAX_TRANSACTION ) 
            begin
              st[ii].w_delay[st[ii].w_cnt] =  tick_current - st[ii].w_start; 
              st[ii].w_cnt++;
            end

          u[ii].w_valid  <= #1 '0;
          u[ii].w_addr   <= #1 '0;
          u[ii].w_data   <= #1 '0;

          repeat(current_drive_wr[ii].delay) @(posedge clk);

        end
      end
    end
  endgenerate

  // Monitor
  generate
    for( ii=0; ii<REQUESTERS; ii++ ) begin

      always @(posedge clk iff('1==u[ii].r_dvalid) ) begin

        if( 0==qa_transaction_check_rd[ii].size() ) begin
          if( cnt_error < DISP_QUANTITY ) begin
            if(DISPL) $display("Error: unexpected read data for port %d. read: %h. clk: %p", ii, u[ii].r_data, tick_current);
          end
          cnt_error++;
        end else begin

          st[ii].r_start = qa_rd_start[ii].pop_front();
          if( st[ii].r_cnt<MAX_TRANSACTION ) begin
            st[ii].r_delay[st[ii].r_cnt] = tick_current - st[ii].r_start;
            st[ii].r_cnt++;
          end

          current_check_rd[ii] = qa_transaction_check_rd[ii].pop_front();
          golden_memory.get_data( tick_current, ii, current_check_rd[ii].addr, 
                                 mask_avaliable[ii], expect_data[ii]
                                );
          flag_eq[ii]=0;
          for( longint jj=0; jj<2*REQUESTERS; jj++) begin
            if( mask_avaliable[ii][jj] &&  
               (u[ii].r_data == expect_data[ii][jj] )
              ) begin
              flag_eq[ii]=1;
              break;
            end
          end

          if( 1==flag_eq[ii] ) begin
            if( show_ok < DISP_QUANTITY ) begin
              if(DISPL)  $display("Read: ok: %-d error: %-d  port: %d  adr=%h read: %h mask_avaliable: %h  tick: %h - Ok",
                       cnt_ok, cnt_error, ii, current_check_rd[ii].addr, u[ii].r_data, mask_avaliable[ii], tick_current
                      ); 
              for( longint jj=0; jj<2*REQUESTERS; jj++) begin
                if( mask_avaliable[ii][jj] )  
                  if(DISPL)  $display( "   expect data: %h", expect_data[ii][jj] );

              end 
              show_ok++;
            end
            cnt_ok++;
          end else begin
            if(  show_error < DISP_QUANTITY ) begin
              if(DISPL)  $display("Read: ok: %-d error: %-d  port: %d adr: %h read: %h  mask_avaliable: %h  tick: %h - Error",
                       cnt_ok, cnt_error, ii, current_check_rd[ii].addr, u[ii].r_data, mask_avaliable[ii], tick_current
                      );
              for( longint jj=0; jj<2*REQUESTERS; jj++) begin
                if( mask_avaliable[ii][jj] )  
                  if(DISPL) $display( "   expect data: %h", expect_data[ii][jj] );

              end
              show_error++; 
            end
            cnt_error++;
          end

        end
      end

      // Golden Memory
      always @(posedge clk iff u[ii].w_valid & u[ii].w_ready ) begin
        golden_memory.write_mem( tick_current, ii, u[ii].w_addr, u[ii].w_data );
      end

    end
  endgenerate
  
  
  
  
  
  
  //..............Always' block.................
  always #5 clk = ~clk;
  always @(posedge clk)  tick_current <= #1 tick_current+1;  
  
  
  //.................Initials' block............
  `include "direct_test.sv" //  is it crutch? - Yes it is!  
  `include "randomize.sv" //  it's  too  
  `include "sub_functions.sv" //  and this  

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(3);
  end

  initial begin
    repeat(TIME_OUT) #1;
    $display( "Timeout");
    test_timeout = '1;
  end

  initial begin
    while (1) begin
      @(posedge clk iff are_ports_done())
        
      capture_progress(curr_test_params);
      restart();
    end
  end

  // Generate test sequence 
  initial begin
    @(posedge clk iff test_start=='1)
    $display("Test %p: %s", test_id, test_name[test_id]);
    
    case( test_id )
      0: direct_test();
      1: test_randomize();
      2: test_randomize_split_full();
      3: test_randomize_single();
    endcase
  end

  initial begin  
    static longint args=-1;
    if( $value$plusargs( "test_id=%0d", args )) begin
      if( args>=0 && args< $size(test_name) ) test_id = args;
    end

    $display("Test multi_memory test_id=%p  name: %p", test_id, test_name[test_id] );

    golden_memory = new();
    restart();

    @(posedge clk iff program_finish =='1 || test_timeout=='1)
    if( test_timeout ) cnt_error++;
    
    $display( "cnt_wr: %d", cnt_wr );
    $display( "cnt_rd: %d", cnt_rd );
    $display( "cnt_ok: %d", cnt_ok );
    $display( "cnt_error: %d", cnt_error );
    $display("");
    if( 0==cnt_error && cnt_ok>0 )
      test_finish( test_id, test_name[test_id], 1 );  // test passed
    else
      test_finish( test_id, test_name[test_id], 0 );  // test failed
  end


endmodule

`default_nettype wire
