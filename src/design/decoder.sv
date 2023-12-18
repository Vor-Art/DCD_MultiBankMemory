`default_nettype none
/*
 * Sets the valid_in value only on one of the output ports (valid_out),
 * depending on the address.
 */
module decoder #(
    parameter ADDR_WIDTH = 4,
    parameter BANKS = 3,

    localparam ADDR_MAX   = {ADDR_WIDTH{1'b1}},     // 2 ^ ADDR_WIDTH -1
    localparam BANK_SIZE = (ADDR_MAX / BANKS) + 1,
    localparam BANK_WIDTH = $clog2(BANK_SIZE),
    localparam LOG2_BANK =  $clog2(BANKS)
) (
    input wire [ADDR_WIDTH-1:0] address_in,
    input wire                  valid_in,

    output wire [     BANKS-1:0] valid_out,
    output wire [BANK_WIDTH-1:0] address_out
);

  wire [LOG2_BANK-1:0] BANK_INDEX = address_in / BANK_SIZE;

  genvar i; generate
    for (i = 0; i < BANKS; i = i + 1) 
      assign valid_out[i] = (i == BANK_INDEX) ? valid_in : 0;
  endgenerate

  assign address_out = address_in - BANK_INDEX * BANK_SIZE;

endmodule

`default_nettype wire
