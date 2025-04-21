//############################################################################
//   2024 Digital Circuit and System Lab
//   HW04        : IP and Pipeline
//   Author      : Ceres Lab 2025 MS1
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   Date        : 2025/02/28
//   Version     : v1.0
//   File Name   : TESTBED.v
//   Module Name : TESTBED
//############################################################################

`timescale 1ns/10ps

`include "PATTERN.v"
`ifdef RTL
  `include "nonlinear.v"
`endif
`ifdef GATE
  `include "nonlinear_SYN.v"
`endif

	  		  	
module TESTBED;

wire          clk, rst_n;
wire          in_valid, mode;
wire [31:0]   data_in;

wire          out_valid;
wire [31:0]   data_out;

initial begin
  `ifdef RTL
    $fsdbDumpfile("nonlinear.fsdb");
    $fsdbDumpvars(0,"+mda");
    $fsdbDumpvars();
  `endif
  `ifdef GATE
    $sdf_annotate("nonlinear_SYN.sdf", u_nonlinear);
    $fsdbDumpfile("nonlinear_SYN.fsdb");
    $fsdbDumpvars();    
  `endif
end

`ifdef RTL
nonlinear u_nonlinear(
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .mode(mode),
    .data_in(data_in),
    .out_valid(out_valid),
    .data_out(data_out)
    );
`endif

`ifdef GATE
nonlinear u_nonlinear(
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .mode(mode),
    .data_in(data_in),
    .out_valid(out_valid),
    .data_out(data_out)
    );
`endif

PATTERN u_PATTERN(
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .mode(mode),
    .data_in(data_in),
    .out_valid(out_valid),
    .data_out(data_out)
    );
  
 
endmodule
