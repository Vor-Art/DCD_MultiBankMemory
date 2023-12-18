`include "params_pkg.sv"

package golden_memory_pkg;
import params_pkg::*;

class golden_memory_t;
  
typedef struct
{
    logic   [DATA_WIDTH-1:0]        data_curr [REQUESTERS-1:0];
    logic   [DATA_WIDTH-1:0]        data_last [REQUESTERS-1:0];
    longint                         tick_curr [REQUESTERS-1:0];
    longint                         tick_last [REQUESTERS-1:0];

} type_mem;

type_mem  mem[ 2 ** ADDR_WIDTH-1:0];


logic [DATA_WIDTH-1:0]          memory[REQUESTERS*2-1:0];

function new();
    for( longint ii=0; ii< 2**ADDR_WIDTH; ii++ ) begin
        for( longint jj=0; jj<REQUESTERS; jj++ ) begin
            mem[ii].data_curr[jj]=0;
            mem[ii].data_last[jj]=0;
            mem[ii].tick_curr[jj]=0;
            mem[ii].tick_last[jj]=0;
        end

        mem[ii].data_curr[0]=ii;
        mem[ii].tick_curr[0]=10;

    end

endfunction

function void write_mem(

    input longint                       tick_current,
    input longint                       port,
    input logic [ADDR_WIDTH-1:0]    addr,
    input logic [DATA_WIDTH-1:0]    data
);

    longint ii=addr;
    mem[ii].data_last[port] = mem[ii].data_curr[port];
    mem[ii].tick_last[port] = mem[ii].tick_curr[port];

    mem[ii].data_curr[port] = data;
    mem[ii].tick_curr[port] = tick_current;

endfunction

function void get_data(
    input longint                                       tick_current,
    input longint                                       port,
    input  logic [ADDR_WIDTH-1:0]                   addr,
    output logic [2*REQUESTERS-1:0]                 mask_avaliable,
    output logic [2*REQUESTERS-1:0][DATA_WIDTH-1:0] data
);

longint flag;
longint tick_max=0;
longint port_tick_max=0;

type_mem  m = mem[addr];
mask_avaliable[2*REQUESTERS-1:0] = '0;


    for( longint ii=0; ii<REQUESTERS; ii++ ) begin
        if( m.tick_curr[ii] >tick_max ) begin
            tick_max = m.tick_curr[ii];
            port_tick_max = ii;
        end 
        data[ii] = 0;
        data[REQUESTERS+ii]=0;
    end

    mask_avaliable[port_tick_max] = '1; // first value;
    data[port_tick_max] = m.data_curr[port_tick_max];

    // check write data at same time
    for( longint ii=0; ii<REQUESTERS; ii++ ) begin
        if( ii==port_tick_max )
            continue;

        if( (tick_max-m.tick_curr[ii]) < 16 ) begin
            mask_avaliable[ii] = '1; // value at the same time in the another ports;
            data[ii] = m.data_curr[ii];
        end 
    end

    // // compare time for write data and time for read data
    // for( int ii=0; ii<REQUESTERS; ii++ ) begin

    //  if( tick_current-m.tick_curr[ii] < 16 ) begin
    //      mask_avaliable[REQUESTERS+ii] = '1; // value for previouse value for all ports ;
    //      data[REQUESTERS+ii] = m.data_last[ii];
    //  end 
    // end

    // compare time for write data and time for read data
    flag=0;
    for( longint ii=0; ii<REQUESTERS; ii++ ) begin

        if( tick_current-m.tick_curr[ii] < 16 ) begin
            flag=1;
        end 
    end

    if( flag ) begin

        for( longint ii=0; ii<REQUESTERS; ii++ ) begin
            mask_avaliable[ii] = '1; // value for previouse value for all ports ;
            data[ii] = m.data_curr[ii];

            mask_avaliable[REQUESTERS+ii] = '1; // value for previouse value for all ports ;
            data[REQUESTERS+ii] = m.data_last[ii];

        end

        // for( int ii=0; ii<REQUESTERS; ii++ ) begin
        //  if( tick_current-m.tick_last[ii] < 16 ) begin
        //      mask_avaliable[REQUESTERS+ii] = '1; // value for previouse value for all ports ;
        //      data[REQUESTERS+ii] = m.data_last[ii];
        //  end
        // end
    end

endfunction




endclass



endpackage
