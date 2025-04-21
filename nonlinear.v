//############################################################################
//   2024 Digital Circuit and System Lab
//   HW04        : Single Cycle CPU
//   Author      : Ceres Lab 2024 MS1
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   Date        : 2024/05/28
//   Version     : v1.0
//   File Name   : CPU.v
//   Module Name : CPU
//############################################################################
//==============================================//
//           Top CPU Module Declaration         //
//==============================================//
module nonlinear(
	// Input Ports
    clk,
    rst_n,
    in_valid,
    mode,
    data_in,
    // Output Ports
    out_valid,
    data_out
);
					
input clk;
input rst_n;
input in_valid;
input mode;
input [31:0] data_in;

output reg out_valid;
output reg [31:0] data_out;

//Do not modify IEEE floating point parameter
parameter FP_ONE = 32'h3f800000;        // This is " 1.0 " in IEEE754 single precision
parameter FP_ZERO = 32'h00000000;       // This is " 0.0 " in IEEE754 single precision

parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;
//Do not modify IEEE floating point parameter


// start your design 

// INPUT
reg [31:0] input_buffer;
reg mode_buffer;
reg input_en;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        input_buffer <= 0;
        mode_buffer <= 0;
        input_en <= 0;
    end
    else begin
        if(in_valid) begin
            input_buffer <= data_in;
            mode_buffer <= mode;
            input_en <= 1;
        end
        else begin
            input_buffer <= input_buffer;
            mode_buffer <= mode_buffer;
            input_en <= 0;
        end
    end
end

// PIPE 1
reg [31:0] exp_num;
reg pipe1_en;
reg pipe1_mode;
reg [31:0] exp_func_input, exp_func_output;
wire [7:0] exp_func_temp;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        exp_num <= 0;
        pipe1_en <= 0;
        pipe1_mode <= 0;
    end
    else begin
        if(input_en) begin
            exp_num <= exp_func_output;
            pipe1_en <= 1;
            pipe1_mode <= mode_buffer;
        end
        else begin
            exp_num <= exp_num;
            pipe1_en <= 0;
            pipe1_mode <= pipe1_mode;
        end
    end
end

assign exp_func_temp = input_buffer[30:23] + 1'b1;

always @(*) begin
    if(!mode_buffer) exp_func_input = {~input_buffer[31], input_buffer[30:0]};     // sigmoid mode : -x
    else exp_func_input = {input_buffer[31], exp_func_temp, input_buffer[22:0]};     // tangent mode : 2x
end

DW_fp_exp #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) EXP1 (
.a(exp_func_input),
.z(exp_func_output));     // exponential function


// PIPE 2
reg pipe2_en;
reg pipe2_mode;
reg [31:0] numerator, denominator;
reg [31:0] add1_output, add2_output;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        numerator <= 0;
        denominator <= 0;
        pipe2_en <= 0;
        pipe2_mode <= 0;
    end
    else begin
        if(pipe1_en) begin
            numerator <= pipe1_mode ? add1_output : FP_ONE;
            denominator <= add2_output;
            pipe2_en <= 1;
            pipe2_mode <= pipe1_mode;
        end
        else begin
            numerator <= numerator;
            denominator <= denominator;
            pipe2_en <= 0;
            pipe2_mode <= pipe2_mode;
        end
    end
end

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
ADD1 ( .a(exp_num), .b({1'b1, FP_ONE[30:0]}), .rnd(3'd0), .z(add1_output));    // exp-1

DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance)
ADD2 ( .a(exp_num), .b(FP_ONE), .rnd(3'd0), .z(add2_output));    // exp+1


// PIPE 3
reg pipe3_en;
reg pipe3_mode; 
reg [31:0] output_buffer;
reg [31:0] div_output;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        output_buffer <= 0;
        pipe3_en <= 0;
        pipe3_mode <= 0;
    end
    else begin
        if(pipe2_en) begin
            output_buffer <= div_output;
            pipe3_en <= 1;
            pipe3_mode <= pipe2_mode;
        end
        else begin
            output_buffer <= output_buffer;
            pipe3_en <= 0;
            pipe3_mode <= pipe3_mode;
        end
    end
end

DW_fp_div #(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_faithful_round) DIV1
( .a(numerator), .b(denominator), .rnd(3'd0), .z(div_output));  //answer


// OUTPUT
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_out <= 32'b0;
        out_valid <= 0;
    end
    else begin
        if(pipe3_en) begin
            data_out <= output_buffer;
            out_valid <= 1;
        end
        else begin
            data_out <= 32'b0;
            out_valid <= 0;
        end
    end
end


endmodule


