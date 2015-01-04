`timescale 1ns/1ps
module test(
    output   spi_cs_n,
    output   spi_clk,// clk/4
    input    spi_miso,//io_0
    output   spi_mosi
);
//------------------------Parameter----------------------

//------------------------Local signal-------------------
reg     clk_p;
reg     clk_n;
reg     reset_n;
//------------------------Instantiation------------------

//------------------------Body---------------------------
always 
begin
    #0.8;
    clk_p= 1'b1;
    clk_n=1'b0;
    #0.8;
    clk_p= 1'b0;
    clk_n= 1'b1;
end

initial
begin
    reset_n = 1'b0;
#200;
    reset_n = 1'b1;
end


 ev10aq190 ev10aq190_inst(

    .clk_615M_P (clk_p),
    .clk_615M_N (clk_n ),
    .reset_n (reset_n ),
    .spi_cs_n (spi_cs_n ),
    .spi_clk (spi_clk ),
    .spi_mosi (spi_mosi ),
    .spi_miso (spi_miso ),
    .series_data_in_P (10'h2aa),
    .series_data_in_N (~(10'h2aa)),
    .debug_data_out (debug_data_out )

);

endmodule

