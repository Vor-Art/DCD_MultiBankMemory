`include "multiport_memory.sv"
`include "decoder.sv"
`default_nettype none

/* 
 * Random Access Memory (RAM) with
 * N read ports and N write ports and 
 * M banks of RAM
 */
module multibank_memory
  #(
    parameter  READ_PORTS  = 3,
    parameter  WRITE_PORTS = 3,
    parameter  DATA_WIDTH = 32,
    parameter  ADDR_WIDTH = 4,
    parameter  BANKS = 5,
    
    localparam ADDR_MAX   = {ADDR_WIDTH{1'b1}},     // 2 ^ ADDR_WIDTH -1
    localparam BANK_SIZE = (ADDR_MAX / BANKS) + 1,
    localparam BANK_WIDTH = $clog2(BANK_SIZE)
  )(
    input wire clk,
    input wire rst,

    // read ports
    input wire [READ_PORTS-1:0][ADDR_WIDTH-1:0]  r_addr,
    input wire [READ_PORTS-1:0]                  r_avalid,
    
    output wire [READ_PORTS-1:0]                 r_dvalid,
    output wire [READ_PORTS-1:0][DATA_WIDTH-1:0] r_data,
    output wire [READ_PORTS-1:0]                 r_aready,
    
    // write ports
    input wire [WRITE_PORTS-1:0][ADDR_WIDTH-1:0]  w_addr,
    input wire [WRITE_PORTS-1:0][DATA_WIDTH-1:0]  w_data,
    input wire [WRITE_PORTS-1:0]                  w_valid,
    
    output wire [WRITE_PORTS-1:0]                 w_ready
  );

  // array of valid from each decoder
  wire [BANKS-1:0]      r_decoder_valid [READ_PORTS-1:0];
  wire [BANKS-1:0]      w_decoder_valid [WRITE_PORTS-1:0];
  wire [READ_PORTS-1:0][BANK_WIDTH-1:0]  r_bank_addrress;
  wire [WRITE_PORTS-1:0][BANK_WIDTH-1:0] w_bank_addrress;
  
  // array of request to each bank
  wire [READ_PORTS-1:0]  r_req_to_bank [BANKS-1:0];
  wire [WRITE_PORTS-1:0] w_req_to_bank [BANKS-1:0];
  
  // array of (ready/data/dvalid) from each bank
  wire [READ_PORTS-1:0]                     r_dvalid_bank[BANKS-1:0];
  wire [READ_PORTS-1:0][DATA_WIDTH-1:0]     r_data_bank  [BANKS-1:0];
  wire [READ_PORTS-1:0]                     r_ready_bank [BANKS-1:0];
  wire [WRITE_PORTS-1:0]                w_ready_bank [BANKS-1:0];

  // connect the read requesters to their decoders
  decoder #(.ADDR_WIDTH(ADDR_WIDTH), .BANKS(BANKS)) r_dec [READ_PORTS-1:0] (
    .address_in (   r_addr              ),
    .valid_in   (   r_avalid            ),
    .valid_out  (   r_decoder_valid     ),
    .address_out(   r_bank_addrress     )
  );

  // connect the write requesters to their decoders
  decoder #(.ADDR_WIDTH(ADDR_WIDTH), .BANKS(BANKS)) w_dec [WRITE_PORTS-1:0] (
    .address_in (   w_addr              ),
    .valid_in   (   w_valid             ),
    .valid_out  (   w_decoder_valid     ),
    .address_out(   w_bank_addrress     )
  );

  // transpose the matrix to acquire read requests to each bank
  genvar i,j; generate
    for(i = 0; i < BANKS; i = i + 1 ) 
      for(j = 0; j < READ_PORTS; j = j + 1 ) 
        assign r_req_to_bank[i][j] = r_decoder_valid[j][i];
  endgenerate
  
  // transpose the matrix to acquire write requests to each bank
  generate
    for(i = 0; i < BANKS; i = i + 1 ) 
      for(j = 0; j < WRITE_PORTS; j = j + 1 ) 
        assign w_req_to_bank[i][j] = w_decoder_valid[j][i];
  endgenerate
  
  // bank generation
  multiport_memory 
  #( 
    .READ_PORTS(READ_PORTS), 
    .WRITE_PORTS(WRITE_PORTS),
    .DATA_WIDTH(DATA_WIDTH), 
    .ADDR_WIDTH(BANK_WIDTH)  // BANK_WIDTH!!!
  ) bank [BANKS-1:0] (

    // read ports
    .r_addr         (   r_bank_addrress     ),
    .r_avalid       (   r_req_to_bank       ),
    .r_dvalid       (   r_dvalid_bank       ),
    .r_data         (   r_data_bank         ),
    .r_aready       (   r_ready_bank        ),
    
    // write ports
    .w_valid        (   w_req_to_bank       ),
    .w_ready        (   w_ready_bank        ),
    .w_addr         (   w_bank_addrress     ),
    .*
  );


//  assigning output ports
//  assign r_dvalid = r_dvalid_bank.or();
//  assign r_data   = r_data_bank.or();
//  assign r_aready = r_ready_bank.or();
//  assign w_ready  = w_ready_bank.or();

logic [READ_PORTS-1:0]               r_dvalid_i;
logic [READ_PORTS-1:0][DATA_WIDTH-1:0] r_data_i;
logic [READ_PORTS-1:0]               r_aready_i;
logic [WRITE_PORTS-1:0]               w_ready_i;

assign r_dvalid = r_dvalid_i;
assign r_data   = r_data_i;
assign r_aready = r_aready_i;
assign w_ready  = w_ready_i;

  // assign r_dvalid[j] = | r_dvalid_bank[j];
  // assign r_aready[j] = | r_ready_bank[j];
  // assign w_ready[j]  = | w_ready_bank[j];
  always_comb begin
    r_dvalid_i = r_dvalid_bank[0];
    r_data_i   = r_data_bank[0];
    r_aready_i = r_ready_bank[0];
    w_ready_i  = w_ready_bank[0];

    for( int ii=1; ii<BANKS; ii++ ) begin
      r_dvalid_i = r_dvalid_i | r_dvalid_bank[ii];
      r_data_i   = r_data_i   | r_data_bank[ii];
      r_aready_i = r_aready_i | r_ready_bank[ii];
      w_ready_i  = w_ready_i  | w_ready_bank[ii];
    end
  end

endmodule

`default_nettype wire
