`include "arbiter.sv"
`include "memory.sv"
`default_nettype none

/* 
 * Random Access Memory (RAM) with
 * N read ports and N write ports
 */
module multiport_memory #(
    parameter READ_PORTS = 3,
    parameter WRITE_PORTS = 3,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4,

    localparam ADDR_MAX = {ADDR_WIDTH{1'b1}},  // 2 ^ ADDR_WIDTH -1
    localparam DATA_LAT = 1  //( >=1 ) delay in cycles between data request and data output 
) (
    input wire clk,
    input wire rst,

    // read ports
    input wire [READ_PORTS-1:0][ADDR_WIDTH-1:0] r_addr,
    input wire [READ_PORTS-1:0]                 r_avalid,

    output wire [READ_PORTS-1:0]                 r_dvalid,
    output wire [READ_PORTS-1:0][DATA_WIDTH-1:0] r_data,
    output wire [READ_PORTS-1:0]                 r_aready,

    // write ports
    input wire [WRITE_PORTS-1:0][ADDR_WIDTH-1:0] w_addr,
    input wire [WRITE_PORTS-1:0][DATA_WIDTH-1:0] w_data,
    input wire [WRITE_PORTS-1:0]                 w_valid,

    output wire [WRITE_PORTS-1:0]                w_ready
);

  // -----
  logic [ READ_PORTS-1:0][ADDR_WIDTH-1:0] pre_mem_r_addr;
  logic                  [ADDR_WIDTH-1:0] mem_r_addr;
  logic [ READ_PORTS-1:0]                 pre_mem_r_avalid;
  logic                                   mem_r_avalid;

  logic [WRITE_PORTS-1:0][ADDR_WIDTH-1:0] pre_mem_w_addr;
  logic                  [ADDR_WIDTH-1:0] mem_w_addr;
  logic [WRITE_PORTS-1:0][DATA_WIDTH-1:0] pre_mem_w_data;
  logic                  [DATA_WIDTH-1:0] mem_w_data;
  logic [WRITE_PORTS-1:0]                 pre_mem_w_valid;
  logic                                   mem_w_valid;
  // -----
  wire  [ DATA_WIDTH-1:0]                 mem_r_data;

  // memory
  pseudo_dual_port_memory #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH),
      .DATA_LAT  (DATA_LAT)
  ) memory (
      .r_addr(mem_r_addr),
      .r_avalid(mem_r_avalid),
      .r_dvalid(),  // not used
      .r_data(mem_r_data),
      .w_addr(mem_w_addr),
      .w_data(mem_w_data),
      .w_valid(mem_w_valid),
      .*
  );

  // Read data from memory with latency
  reg [READ_PORTS-1:0] r_dvalid_shift [DATA_LAT-1:0];

  // read arbiter
  arbiter #( .N(READ_PORTS) ) r_arbiter (
      .req  (r_avalid),
      .grant(r_aready),
      .*
  );

  // write arbiter
  arbiter #( .N(WRITE_PORTS) ) w_arbiter (
      .req  (w_valid),
      .grant(w_ready),
      .*
  );


  always @(posedge clk) begin
    if (rst) r_dvalid_shift <= #1 '{DATA_LAT{0}};
    else begin
      // Shift
      r_dvalid_shift[0] <= #1 r_aready;
      for (int i = 1; i < DATA_LAT; i++) 
        r_dvalid_shift[i] <= #1 r_dvalid_shift[i-1];
    end
  end

  assign r_dvalid = r_dvalid_shift[DATA_LAT-1];

  // connect all requesters to the data wire
  genvar i; generate
    for (i = 0; i < READ_PORTS; i = i + 1) 
      assign r_data[i] = r_dvalid[i] ? mem_r_data : 0;
  endgenerate

  //-------------------
  genvar j; generate
    for (j = 0; j < READ_PORTS; j++) begin
      assign pre_mem_r_addr[j]   = (r_aready[j]) ? r_addr[j]   : 0;
      assign pre_mem_r_avalid[j] = (r_aready[j]) ? r_avalid[j] : 0;
    end
    for (j = 0; j < WRITE_PORTS; j++) begin
      assign pre_mem_w_addr[j]  = (w_ready[j]) ? w_addr[j]  : 0;
      assign pre_mem_w_data[j]  = (w_ready[j]) ? w_data[j]  : 0;
      assign pre_mem_w_valid[j] = (w_ready[j]) ? w_valid[j] : 0;
    end
  endgenerate

  // read
  always_comb begin
    mem_r_addr = pre_mem_r_addr[0];
    for (int ii = 1; ii < READ_PORTS; ii++) mem_r_addr = mem_r_addr | pre_mem_r_addr[ii];
  end
  always_comb begin
    mem_r_avalid = pre_mem_r_avalid[0];
    for (int ii = 1; ii < READ_PORTS; ii++) mem_r_avalid = mem_r_avalid | pre_mem_r_avalid[ii];
  end

  // write
  always_comb begin
    mem_w_addr = pre_mem_w_addr[0];
    for (int ii = 1; ii < WRITE_PORTS; ii++) mem_w_addr = mem_w_addr | pre_mem_w_addr[ii];
  end
  always_comb begin
    mem_w_data = pre_mem_w_data[0];
    for (int ii = 1; ii < WRITE_PORTS; ii++) mem_w_data = mem_w_data | pre_mem_w_data[ii];
  end
  always_comb begin
    mem_w_valid = pre_mem_w_valid[0];
    for (int ii = 1; ii < WRITE_PORTS; ii++) mem_w_valid = mem_w_valid | pre_mem_w_valid[ii];
  end

endmodule

`default_nettype wire
