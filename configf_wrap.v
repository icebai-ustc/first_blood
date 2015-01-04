`timescale 1ns/1ps

module configf_wrap (
    input clk,
    input reset_n,

    output  spi_cs_n,
    output  spi_clk,
    output  spi_mosi,
    input   spi_miso
);

//------------------------Parameter----------------------

//------------------------Local signal-------------------
wire            user_cmd_en_out    ;
wire    [7:0]   user_addr_out      ;
wire    [15:0]  user_wrrd_num_out  ;
wire            hst_cmd_done_out   ;
wire            hst_cmd_en_out     ;
wire    [7:0]   hst_addr_out       ;
wire    [15:0]  hst_wrrd_num_out   ;
wire            entity_cmd_done_out;

//------------------------Instantiation------------------

//------------------------Body---------------------------

configf_user configf_user_inst(
     .clk (clk ),
     .reset_n (reset_n ),
     .user_cmd_done_in (hst_cmd_done_out ), 
     .user_cmd_en_out (user_cmd_en_out ),
     .user_addr_out (user_addr_out ), 
     .user_wrrd_num_out (user_wrrd_num_out ) 
);

configf_host configf_host_inst (
     .clk (clk ),
     .reset_n (reset_n ),
     .hst_cmd_done_in (entity_cmd_done_out ),
     .hst_cmd_en_out (hst_cmd_en_out ),
     .hst_addr_out (hst_addr_out ), 
     .hst_wrrd_num_out (hst_wrrd_num_out ),
     .hst_cmd_en_in (user_cmd_en_out ),
     .hst_addr_in (user_addr_out ), 
     .hst_wrrd_num_in (user_wrrd_num_out ) ,
     .hst_cmd_done_out (hst_cmd_done_out)
);

configf_entity configf_entity_inst(
    .clk (clk ),
    .reset_n (reset_n ),
    .entity_cmd_en_in (hst_cmd_en_out ),
    .entity_addr_in (hst_addr_out ),
    .entity_wrrd_num_in (hst_wrrd_num_out ),
    .entity_cmd_done_out (entity_cmd_done_out ),
    .entity_cs_n (spi_cs_n ),
    .entity_clk  (spi_clk ), 
    .entity_mosi (spi_mosi ),
    .entity_miso (spi_miso )
);

endmodule

