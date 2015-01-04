`timescale 1ns/1ps

module configf_user (
    input           clk,
    input           reset_n,

    // whith host 
    input                           user_cmd_done_in, 
    output    reg                   user_cmd_en_out,
    output    reg           [7:0]  user_addr_out ,
    output    reg           [15:0]  user_wrrd_num_out 
);
//------------------------Parameter----------------------
localparam 
        S_IDLE          = 8'b1000_0000,
        S_CRM           = 8'b0000_0001;

localparam
        BW_ADCMODE      = 8'h01;

//------------------------Local signal-------------------
reg     [7:0]       current_state ;
reg     [7:0]       next_state ;
reg                 user_start ;

//------------------------Instantiation------------------

//------------------------Body---------------------------

// FSM
always @ (posedge clk or negedge reset_n)
begin
    if (! reset_n )
        current_state <= S_IDLE;
    else
        current_state <= next_state;
end
always @ *
begin
    case (current_state)
        S_IDLE :
            if ( user_start== 1'b1)
                next_state = S_CRM;
            else
                next_state = S_IDLE;
        S_CRM:
            if( user_cmd_done_in == 1'b1)
                next_state = S_CRM;
            else
                next_state = S_CRM;
                
        default: 
                next_state = S_IDLE ;
    endcase
end

// ++++++++++++ user_start ++++++++//
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        user_start <= 1'b0;
    else
         if ( current_state == S_IDLE )
             user_start <= 1'b1;
         else
             user_start <= 1'b0;
end

//+++++++++++ user_cmd_en_out ++++++++//
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        user_cmd_en_out <= 1'b0;
    else
        if (current_state != next_state )
            user_cmd_en_out <= 1'b1;
        else
            user_cmd_en_out <= 1'b0;
end

//++++++++ user_addr_out +++++++++//
always @(posedge clk or negedge reset_n)
begin
    if (!reset_n)
        user_addr_out <= 8'h00;
    else
        case(current_state)
            S_CRM:
                  user_addr_out <= 8'b1000_0000 | 8'h01;
            default:
                  user_addr_out <= 8'b0;
        endcase
end

//+++++++++ user_wrrd_num_out ++++++//
always @ (posedge clk or negedge reset_n )
begin
    if (! reset_n )
        user_wrrd_num_out <= 16'h0;
    else
        case(current_state)
            S_CRM: //[12] test  [8] BDW [7] B/G  [5-4] STDBY [3-0] ADCMODE
                user_wrrd_num_out <= 16'b0000_0001_0011_0000;
            default:
                user_wrrd_num_out <= 16'b0;
        endcase

end

endmodule



