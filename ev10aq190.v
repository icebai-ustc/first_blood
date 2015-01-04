`timescale 1ns/1ps

module ev10aq190 (
    input clk_in_60M,
    input AD1_ADR_P,
    input AD1_ADR_N,
    output AD1_SPI_RSTn,

    output   AD1_SYNCP,
    output   AD1_SYNCN,
    output AD1_SPI_MOSI, 
    input  AD1_SPI_MISO, 
    output AD1_SPI_SCLK, 
    output AD1_SPI_CSn ,

    input [9:0] AD1_AP,
    input [9:0] AD1_AN
    //output debug_data_out

);
//------------------------Parameter----------------------

//------------------------Local signal-------------------
wire    clk_156M ;
wire    [79:0] data_parallel;

wire    clk_615M_P;
wire    clk_615M_N;
wire    spi_miso;
wire    spi_mosi;
wire    spi_clk;
wire    spi_cs_n;

reg     spi_sync;
wire    [9:0]   series_data_in_P;
wire    [9:0]   series_data_in_N;

reg     reset_n ;
reg     [3:0] clk_count;


//------------------------Instantiation------------------

//------------------------Body---------------------------

assign AD1_SPI_RSTn  = reset_n;

assign clk_615M_P = AD1_ADR_P;
assign clk_615M_N = AD1_ADR_N;

assign spi_miso = AD1_SPI_MISO;
assign AD1_SPI_MOSI = spi_mosi;
assign AD1_SPI_SCLK = spi_clk;
assign AD1_SPI_CSn  = spi_cs_n;

//assign AD1_SPI_MOSI = 1'b1;
//assign AD1_SPI_SCLK = 1'b1;
//assign AD1_SPI_CSn  = 1'b1;

assign series_data_in_P = AD1_AP ;
assign series_data_in_N = AD1_AN ;

OBUFDS #(
      .IOSTANDARD("LVDS_25") // Specify the output I/O standard
   ) OBUFDS_inst (
      .O(AD1_SYNCP ),     // Diff_p output (connect directly to top-level port)
      .OB(AD1_SYNCN ),   // Diff_n output (connect directly to top-level port)
      .I(spi_sync)      // Buffer input 
   );

//  dcm dcm_inst
//   (// Clock in ports
//    .CLK_IN1_P(clk_615M_P),    // IN
//    .CLK_IN1_N(clk_615M_N),    // IN
//    // Clock out ports
//    .CLK_OUT1(clk_78M));    // OUT   
BUFG
    bufg_inst
    (.O (clk),
     .I (clk_in_60M));

always @ (posedge clk)
begin
    if(clk_count == 4'b1111)
        spi_sync <= 1'b0;
    else
        spi_sync <= 1'b1;
end


always @ (posedge clk)
begin
    if(clk_count[3] == 1'b1)
        reset_n <= 1'b1;
    else
        reset_n <= 1'b0;
end

always @ (posedge clk)
begin
    if(clk_count != 4'b1111)
        clk_count = clk_count + 1'b1;
end

ISERDESE  iserdese_inst
   (
    // From the system into the device
    .DATA_IN_FROM_PINS_P(series_data_in_P), //Input pins
    .DATA_IN_FROM_PINS_N(series_data_in_N), //Input pins
    .DATA_IN_TO_DEVICE(data_parallel), //Output pins

    .BITSLIP(1'b0),       // Bitslip module is enabled in NETWORKING mode
                                    // User should tie it to '0' if not needed
 
    .CLK_IN_P(clk_615M_P),      // Differential clock from IOB
    .CLK_IN_N(clk_615M_N),      // Differential clock from IOB
    .CLK_DIV_OUT(clk_156M),   // Slow clock output
    .CLK_RESET(1'b0), //clocking logic reset
    .IO_RESET(1'b0)  //system reset
    );

configf_wrap configf_wrap_inst
(
    .clk (clk),
    .reset_n (reset_n ),
    .spi_cs_n (spi_cs_n ),
    .spi_clk (spi_clk ),
    .spi_mosi (spi_mosi ),
    .spi_miso (spi_miso )
);


// ++++++++++++++ debug +++++++++++++++++++++++++++++++++++//
wire    [35:0] control;
icon icon_inst(
    .CONTROL0(control) // INOUT BUS [35:0]
);

ila ila_inst(
    .CONTROL(control ), // INOUT BUS [35:0]
    .CLK(clk_156M), // IN
    .TRIG0(data_parallel[9:0]), // IN BUS [9:0]
    .TRIG1(data_parallel[19:10]), // IN BUS [9:0]
    .TRIG2(data_parallel[29:20]), // IN BUS [9:0]
    .TRIG3(data_parallel[39:30]), // IN BUS [9:0]
    .TRIG4(data_parallel[49:40]), // IN BUS [9:0]
    .TRIG5(data_parallel[59:50]), // IN BUS [9:0]
    .TRIG6(data_parallel[69:60]), // IN BUS [9:0]
    .TRIG7(data_parallel[79:70]) // IN BUS [9:0]
);
assign debug_data_out = ^data_parallel;

endmodule

