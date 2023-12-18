`ifndef PARAMS_PKG
`define PARAMS_PKG

package params_pkg;

typedef enum { OFF = 0, ON = 1 } status;
localparam  DISPL = ON;

localparam  min_REQUESTERS = 1;  // min_REQUESTERS
localparam  REQUESTERS = 6;  // max_REQUESTERS
localparam  min_BANKS  = 1;  // min_BANKS
localparam  BANKS      = 6;  // max_BANKS

localparam  step_BANKS      = 1;
localparam  step_REQUESTERS = 1;

localparam  DATA_WIDTH = 17;
localparam  ADDR_WIDTH = 17;
localparam  MAX_TRANSACTION = 100000;
localparam  AVERAGE_COUNT = 25;  //the average number of transaction by port
localparam  DISP_QUANTITY = 10;  //the quantity of data that is displayed in the console
localparam  TIME_OUT = 30000;  // in clocs 


localparam ADDR_MAX  = 2 ** ADDR_WIDTH - 1;
localparam BANK_SIZE = (ADDR_MAX / BANKS) + 1;

typedef struct {
  longint  Rq; // number_of_ports
  longint  Bk; // number_of_banks
  real Dt;     // duty_cycle
  real Sc;     // scatter
  real Ac;     // accuracy
} test_params_t;

endpackage  //params_pkg

`endif  // PARAMS_PKG
