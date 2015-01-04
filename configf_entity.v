// 实现与配置芯片的交互
`timescale 1ns/1ps

module configf_entity (
    input       clk,
    input       reset_n,

    // with configf_host
    input                   entity_cmd_en_in,
    input           [7:0]   entity_addr_in, 
    input           [15:0]  entity_wrrd_num_in,
    output   reg            entity_cmd_done_out,

    // with configf_entity
    output  reg     entity_cs_n,
    output  reg     entity_clk,// clk/4
    output  reg     entity_mosi,//io_0
    input           entity_miso//io_1
);

//------------------------Parameter----------------------
localparam// the FSM state
        IDLE   = 8'b0000_0001,
        ADDR   = 8'b0000_0010,
        RD_CMD = 8'b0000_0100,
        WR_CMD = 8'b0000_1000,
        END    = 8'b0001_0000;

//------------------------Local signal-------------------

reg [7:0] current_state;
reg [7:0] next_state; 

reg     addr_end;
reg     wr_cmd_end;
reg     rd_cmd_end;

reg [15:0] sr_out;

reg       clk_start;
reg [2:0] clk_count;
reg [3:0] data_cnt;
//------------------------Instantiation------------------

//------------------------Body---------------------------

//+++++ FSM
always @ (posedge clk or negedge reset_n )
begin
     if ( ! reset_n )
         current_state <= IDLE;
     else
         current_state <= next_state;
end
//
always @ (*)
begin
    case (current_state )
        IDLE :  
                if ( entity_cmd_en_in )
                    next_state = ADDR;
                else
                    next_state = IDLE;
        ADDR : 
                if ( addr_end== 1'b1 )
                    begin
                        if (entity_addr_in[7] ==1'b0 )
                            next_state = RD_CMD;
                         else
                            next_state = WR_CMD;
                    end
                else
                    next_state = ADDR;

        RD_CMD:
                if (rd_cmd_end == 1'b1 )
                    next_state = END;
                else
                    next_state = RD_CMD;
        WR_CMD:
                if (wr_cmd_end== 1'b1 )
                    next_state = END;
                else
                    next_state = WR_CMD;

        END :  if (clk_count == 3'b100 && entity_cs_n == 1'b1) 
                    next_state = IDLE;
               else
                    next_state = END;

        default : next_state = IDLE ;
    endcase
end
 
//++++++++++++++++++ sr_out +++++++++++++++++++++++++//
always @(posedge clk)
begin
    if(! reset_n)
        sr_out <= 16'b0;
    else
        if(current_state == IDLE && next_state == ADDR)
            sr_out <= { entity_addr_in,8'b0};
        else
            if(current_state == ADDR && next_state != ADDR)
                sr_out <= entity_wrrd_num_in;
            else
                if(clk_count == 3'b10)
                    sr_out <={sr_out[14:0],sr_out[15]};
end

//+++++++++++++++++++ entity_miso ++++++++++++++++++++//
always @(posedge clk)
begin
    if(! reset_n)
        entity_mosi <= 1'b0;
    else
        entity_mosi <= sr_out[15];
end

//++++++++++++++++++ entity_clk +++++++++++++++//
always @ (posedge clk)
begin
    if(!reset_n )
        entity_clk <= 1'b0;
    else
        if(clk_count == 3'b10)
            entity_clk <= 1'b1;
        else
            if(clk_count == 3'b100)
                entity_clk <= 1'b0;
end

//+++++++++++++ entity_cs_n ++++++++++++++++//
always @ (posedge clk)
begin
    if(! reset_n )
        entity_cs_n <= 1'b1;
    else
        if(entity_cmd_en_in == 1'b1)
            entity_cs_n <= 1'b0;
        else
            if(current_state != next_state && next_state == END)
                entity_cs_n <= 1'b1;
end

//+++++++++++++++ entity_cmd_done_out +++++++++++++++//
always @ (posedge clk)
begin
    if(!reset_n )
        entity_cmd_done_out <= 1'b0;
    else
        if(current_state == END && next_state == IDLE)
            entity_cmd_done_out <= 1'b1;
        else
            entity_cmd_done_out <= 1'b0;
end

//+++++++++++++++++++ addr_end ++++++++++++++++++++++//
always @ (posedge clk)
begin
    if(! reset_n )
        addr_end <= 1'b0;
    else
        if(current_state == ADDR && clk_count == 3'b10 && data_cnt == 4'b0111)
            addr_end <= 1'b1;
        else
            addr_end <= 1'b0;
end

//+++++++++++++++++++ rd_cmd_end ++++++++++++++++++++++//
// need modify ,without consider the latency from the ad to fpga
always @ (posedge clk)
begin
    if(! reset_n )
        rd_cmd_end <= 1'b0;
    else
        if(current_state == RD_CMD && clk_count == 3'b10 && data_cnt == 4'b1111)
            rd_cmd_end <= 1'b1;
        else
            rd_cmd_end <= 1'b0;
end

//+++++++++++++++++++ wr_cmd_end ++++++++++++++++++++++//
always @ (posedge clk)
begin
    if(! reset_n )
        wr_cmd_end <= 1'b0;
    else
        if(current_state == WR_CMD && clk_count == 3'b10 && data_cnt == 4'b1111)
            wr_cmd_end <= 1'b1;
        else
            wr_cmd_end <= 1'b0;
end

//++++++++++++++++++ clk_count +++++++++++++++++++++//
always @ (posedge clk)
begin
    if(! reset_n )
        clk_count <= 3'b0;
    else
        if(clk_count == 3'b100)
            clk_count <= 3'b1;
        else
            if(clk_start == 1'b1)
                clk_count <= clk_count+3'b1;
            else
                clk_count <= 1'b0;
end

// +++++++++++++++ clk_start +++++++++++++++++++//
always @ (posedge clk)
begin
    if(! reset_n )
        clk_start <= 1'b0;
    else
        if(entity_cmd_en_in == 1'b1)
            clk_start <= 1'b1;
        else
            if(clk_count == 3'b100 && entity_cs_n == 1'b1)
                clk_start <= 1'b0;
end

//+++++++++++++++ data_cnt +++++++++++++++++//
always @ (posedge clk)
begin
    if(! reset_n )
        data_cnt <= 4'b0;
    else
        if(current_state != next_state )
            data_cnt <= 4'b0;
        else
            if( clk_count == 3'b10)
                data_cnt <= data_cnt +1'b1;
end

// ++++++++++++++++++

endmodule 


