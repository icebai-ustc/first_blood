///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2014 Xilinx, Inc.
// All Rights Reserved
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor     : Xilinx
// \   \   \/     Version    : 14.2
//  \   \         Application: Xilinx CORE Generator
//  /   /         Filename   : ila.v
// /___/   /\     Timestamp  : Tue Dec 30 13:06:43 中国标准时间 2014
// \   \  /  \
//  \___\/\___\
//
// Design Name: Verilog Synthesis Wrapper
///////////////////////////////////////////////////////////////////////////////
// This wrapper is used to integrate with Project Navigator and PlanAhead

`timescale 1ns/1ps

module ila(
    CONTROL,
    CLK,
    TRIG0,
    TRIG1,
    TRIG2,
    TRIG3,
    TRIG4,
    TRIG5,
    TRIG6,
    TRIG7);


inout [35 : 0] CONTROL;
input CLK;
input [9 : 0] TRIG0;
input [9 : 0] TRIG1;
input [9 : 0] TRIG2;
input [9 : 0] TRIG3;
input [9 : 0] TRIG4;
input [9 : 0] TRIG5;
input [9 : 0] TRIG6;
input [9 : 0] TRIG7;

endmodule
