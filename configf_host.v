`timescale 1ns/1ps

module configf_host (
    input           clk,
    input           reset_n,

    // with configf_entity
    input                       hst_cmd_done_in,
    output     reg              hst_cmd_en_out,
    output     reg      [7:0]  hst_addr_out ,
    output     reg      [15:0]  hst_wrrd_num_out,
    // whith user 
    input                       hst_cmd_en_in,
    input               [7:0]  hst_addr_in ,
    input               [15:0]  hst_wrrd_num_in ,
    output     reg              hst_cmd_done_out
);

//------------------------Parameter----------------------
localparam 
   WAIT_CMD             =   8'b0000_0100,     
   CMD_EXE              =   8'b0000_1000,     
   HST_CMD_DONE_OUT     =   8'b0001_0000;       

//------------------------Local signal-------------------
reg     [7:0]       current_state;
reg     [7:0]       next_state;
reg     [3:0]       stand_count;// to keep cs high when one command done
reg                 hst_cmd_en_out_level ;// the pulse rise when state transfer to CMD_EXE

//------------------------Instantiation------------------

//------------------------Body---------------------------

// ++++++++ FSM +++++++++++++
always @(posedge clk  )
begin
    if (!reset_n)
        current_state <= WAIT_CMD;
    else
        current_state <= next_state;
end
always @(*)
begin
   case (current_state)
        WAIT_CMD :
                 if (hst_cmd_en_in == 1'b1)
                     next_state = CMD_EXE;
                  else
                      next_state = WAIT_CMD;
        CMD_EXE :
                 if (hst_cmd_done_in == 1'b1)
                     next_state = HST_CMD_DONE_OUT;
                  else
                      next_state = CMD_EXE;
         HST_CMD_DONE_OUT:
                 if (stand_count == 4'he )
                     next_state = WAIT_CMD;
                 else
                     next_state = HST_CMD_DONE_OUT;
         default :
                     next_state = WAIT_CMD;
    endcase
end

// +++++ stand_count ++++
always @ (posedge clk   )
begin
     if ( ! reset_n )
         stand_count <= 4'b0;
     else
         if ( current_state != HST_CMD_DONE_OUT )
             stand_count <= 4'b0;
          else
                if (stand_count != 4'hf )
                     stand_count <=stand_count + 4'b1;
end

// +++++++++ hst_cmd_en_out_level +++++++++
always @ (posedge clk   )
begin
    if ( ! reset_n )
        hst_cmd_en_out_level <= 1'b0;
    else
        if (current_state== WAIT_CMD && next_state == CMD_EXE /*|| current_state == WR_QUAD_BIT*/ )
                hst_cmd_en_out_level <= 1'b1;
        else
                hst_cmd_en_out_level <= 1'b0; 
end

always @ (posedge clk )
    hst_cmd_en_out <= hst_cmd_en_out_level ;

// ++++++++++ hst_addr_out +++++++
always @ (posedge clk   )
begin
     if (! reset_n )
         hst_addr_out <= 8'h0;
     else
         if (current_state == CMD_EXE )
             hst_addr_out <= hst_addr_in;
         else
             hst_addr_out <= 8'h0;
end

// ++++++++ hst_wrrd_num_out  ++++++++
always @ (posedge clk   )
begin
    if (! reset_n )
        hst_wrrd_num_out <= 16'h0;
     else
         if(current_state == CMD_EXE )
            hst_wrrd_num_out  <= hst_wrrd_num_in;
         else
            hst_wrrd_num_out  <= 16'h0;
end

// ++++++++ hst_cmd_done_out ++++++++
always @ (posedge clk   )
begin
    if (! reset_n )
        hst_cmd_done_out <= 1'b0;
    else
        if (stand_count == 4'he)
            hst_cmd_done_out <= 1'b1;
        else
            hst_cmd_done_out <= 1'b0;
end

endmodule

