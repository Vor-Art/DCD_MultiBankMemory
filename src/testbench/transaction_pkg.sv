`include "params_pkg.sv"

package transaction_pkg;
import params_pkg::*;

typedef enum { READ, SYNC, EXIT, WRITE, CHECKPOINT, INFO} e_op;

typedef struct {
  logic [ADDR_WIDTH-1:0] addr;
  logic [DATA_WIDTH-1:0] data;
  longint                delay;
  e_op                   op;         // read, sync, exit, write, CHECKPOINT
  longint                sync_tick;
  test_params_t          tst_prm;
} type_transaction;


typedef struct {
  logic [ADDR_WIDTH-1:0] r_addr;
  logic                  r_avalid;
  logic                  r_dvalid;
  logic [DATA_WIDTH-1:0] r_data;
  logic                  r_aready;

  logic [ADDR_WIDTH-1:0] w_addr;
  logic [DATA_WIDTH-1:0] w_data;
  logic                  w_valid;
  logic                  w_ready;
} type_uut;


typedef struct {
  longint r_delay[MAX_TRANSACTION];
  longint r_cnt;
  longint r_start;
  longint r_delay_min;
  longint r_delay_max;
  real    r_delay_avr;
  real    r_velocity;
  longint r_start_time;
  longint r_work_time;
  bit     r_subtest_finish;

  longint w_delay[MAX_TRANSACTION];
  longint w_cnt;
  longint w_start;
  longint w_delay_min;
  longint w_delay_max;
  real    w_delay_avr;
  real    w_velocity;
  longint w_start_time;
  longint w_work_time;
  bit     w_subtest_finish;
} type_stat;


endpackage
