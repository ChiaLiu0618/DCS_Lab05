//############################################################################
//   2024 Digital Circuit and System Lab
//   HW04        : IP and Pipeline
//   Author      : Ceres Lab 2025 MS1 Student
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   Date        : 2025/02/28
//   Version     : v1.0
//   File Name   : PATTERN.v
//   Module Name : PATTERN
//############################################################################
`define CYCLE_TIME 18
`define PAT_NUM 400

module PATTERN(
    // Output Ports
    clk,
    rst_n,
    in_valid,
    mode,
    data_in,
    // input Ports
    out_valid,
    data_out
);
//==============================================//
//               Parameter & Integer            //
//==============================================//
// PATTERN operation
parameter CYCLE = `CYCLE_TIME;

// PATTERN CONTROL
integer cycle_time = CYCLE;
integer total_latency;
integer latency;
integer MAX_LATENCY = 7;
integer pat_num = `PAT_NUM;
integer i_pat, j_pat;
integer i, j, k, l;
parameter PATNUM_SIMPLE = 100;
integer   SEED = 587;

parameter FP_ONE = 32'h3f800000;
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch_type = 0;
parameter inst_arch = 0;
parameter inst_faithful_round = 0;


//==============================================//
//          Input & Output Declaration          //
//==============================================//
output reg clk, rst_n;
output reg mode, in_valid;
output reg [inst_sig_width+inst_exp_width:0] data_in;

input out_valid;
input [inst_sig_width+inst_exp_width:0] data_out;



//==============================================//
//                 Signal Declaration           //
//==============================================//
reg [31:0] golden_out 	[0:1023];
reg [31:0] golden_in 	[0:1023];
reg 	   golden_mode 	[0:1023];
reg [31:0] golden_exp 	[0:1023];
reg [31:0] golden_nume 	[0:1023];
reg [31:0] golden_deno 	[0:1023];

//==============================================//
//                 String control               //
//==============================================//
// Should use %0s
string reset_color          = "\033[1;0m";
string txt_black_prefix     = "\033[1;30m";
string txt_red_prefix       = "\033[1;31m";
string txt_green_prefix     = "\033[1;32m";
string txt_yellow_prefix    = "\033[1;33m";
string txt_blue_prefix      = "\033[1;34m";
string txt_magenta_prefix   = "\033[1;35m";
string txt_cyan_prefix      = "\033[1;36m";

string bkg_black_prefix     = "\033[40;1m";
string bkg_red_prefix       = "\033[41;1m";
string bkg_green_prefix     = "\033[42;1m";
string bkg_yellow_prefix    = "\033[43;1m";
string bkg_blue_prefix      = "\033[44;1m";
string bkg_white_prefix     = "\033[47;1m";

//==============================================//
//                main function                 //
//==============================================//
// clock
always begin
	#(CYCLE/2);
	clk = ~clk;
end

initial begin
	reset_task;
	total_latency = 0;
	input_task;
end

initial begin
    wait_out_valid_task;
	check_ans_task;
    you_pass_task;
end
 

//==============================================//
//            Clock and Reset Function          //
//==============================================//
// reset task
task reset_task; begin	
	// initiaize signal
	clk = 0;
	rst_n = 1;
    in_valid = 1'b0;
	mode = 'dx;
    data_in = 'dx;

	// force clock to be 0, do not flip in half cycle
	force clk = 0;

	#(CYCLE*3);
	
	// reset
	rst_n = 0;  #(CYCLE*5); // wait 5 cycles to check output signal
	// check reset

    //check all outputs reset
    if(out_valid !== 0 || data_out !== 'd0) begin
        $display("%0s================================================================", txt_red_prefix);
		$display("                             FAIL"                           );
		$display("              All outputs should be restet to zero!   ");
		$display("================================================================%0s", reset_color);
		// #(CYCLE*8);
        $finish;
    end

	// release reset
	rst_n = 1; #(CYCLE*3);
	
	// release clock
	release clk; repeat(5) @ (negedge clk);
end endtask


//==============================================//
//            Generate input pattern            //
//==============================================//
// Utility
function[inst_sig_width+inst_exp_width:0] _randInput;
    input integer _pat;
    reg[6:0] fract_rand;
    integer dig_idx;
    begin
        _randInput = 0;
        if(_pat < PATNUM_SIMPLE) begin
            _randInput = 0;
            _randInput[inst_sig_width+:inst_exp_width] = {$random(SEED)} % 4 + 126;
            _randInput[inst_sig_width+inst_exp_width]  = {$random(SEED)} % 2;
        end
        else begin
            _randInput = 0;
            _randInput[inst_sig_width+:inst_exp_width] = {$random(SEED)} % 9 + 126;
            _randInput[inst_sig_width+inst_exp_width]  = {$random(SEED)} % 2;
            fract_rand = {$random(SEED)} % 128;
            for(dig_idx=0 ; dig_idx<7 ; dig_idx=dig_idx+1) begin
                _randInput[inst_sig_width-dig_idx] = fract_rand[6-dig_idx];
            end
        end
    end
endfunction

// input task 
task input_task; begin
    for (i_pat = 0; i_pat < pat_num; i_pat = i_pat + 1) begin
        in_valid = 1'b1;
		mode = {$random(SEED)} % 2;
		data_in = _randInput(i_pat);
		golden_mode[i_pat] = mode;
		golden_in[i_pat] = data_in;
        @(negedge clk);
    end

    in_valid = 1'b0;
	mode = 'dx;
    data_in = 'dx;
end endtask


// calculate golden output
reg [inst_sig_width+inst_exp_width:0] _x, _2x, _negx;
reg [inst_sig_width+inst_exp_width:0] _add1In1, _add1In2, _add2In1, _add2In2, _add1Out, _add2Out;
reg [inst_sig_width+inst_exp_width:0] _expIn, _expOut;
reg [inst_sig_width+inst_exp_width:0] _NM, _DM, _divOut;

always @(*) begin
	if(in_valid) begin
		_x = data_in;
		_2x = _x;
		_2x[inst_sig_width+:inst_exp_width] = _x[inst_sig_width+:inst_exp_width]+'d1;
		_negx = {~_x[inst_sig_width+inst_exp_width], _x[0+:(inst_sig_width+inst_exp_width)]};

		if(!mode) begin /*sigmoid*/
			_NM = FP_ONE; 			/*  +1  		 */
			_expIn = _negx;			/*  -x  		 */
			_add1In1 = FP_ONE;		/*  +1  		 */
			_add1In2 = _expOut;		/*  exp(-x)      */
			_DM = _add1Out;			/*  exp(-x) + 1  */
		end else begin /*tanh*/
			_expIn = _2x;			/*  2x  		 */
			_add1In1 = _expOut;		/*  exp(2x)  	 */
			_add1In2 = {~FP_ONE[inst_sig_width+inst_exp_width], FP_ONE[0+:(inst_sig_width+inst_exp_width)]}; /*  -1  */
			_NM = _add1Out;			/*  exp(2x) - 1  */

			_add2In1 = _expOut;		/*  exp(2x)		 */
			_add2In2 = FP_ONE;		/*  +1           */
			_DM = _add2Out;			/*  exp(2x) + 1  */	
		end

		golden_out[i_pat] = _divOut;
		golden_exp[i_pat] = _expOut;
		golden_nume[i_pat] = _NM;
		golden_deno[i_pat] = _DM;
	end
end

DW_fp_add#(inst_sig_width, inst_exp_width, inst_ieee_compliance)
	Add1 ( .a(_add1In1), .b(_add1In2), .rnd(3'b000), .z(_add1Out));

DW_fp_add#(inst_sig_width, inst_exp_width, inst_ieee_compliance)
 	Add2 ( .a(_add2In1), .b(_add2In2), .rnd(3'b000), .z(_add2Out));

DW_fp_exp#(inst_sig_width, inst_exp_width, inst_ieee_compliance, inst_arch) 
	Exp1 (.a(_expIn), .z(_expOut));

DW_fp_div#(inst_sig_width, inst_exp_width, inst_ieee_compliance) 
	Div1( .a(_NM), .b(_DM), .rnd(3'b000), .z(_divOut));


//==============================================//
//            Check design function             //
//==============================================//
// wait out_valid task
task wait_out_valid_task; begin
	latency = 0;
	
    // start counting latency after in_valid pulled high
    @(posedge in_valid);

    // wait out valid
	while(out_valid !== 1'b1) begin
		@ (negedge clk);
		latency = latency + 1;
		// check latency is over MAX_LATENCY
		if(latency > MAX_LATENCY) begin
			$display("%0s================================================================", txt_red_prefix);
			$display("                             FAIL"                           );
			$display("    the execution latency is over %4d cycles at %-8d ps  ", MAX_LATENCY, $time*1000);
			$display("================================================================%0s", reset_color);
            // #(CYCLE*8);
            $finish;
		end
	end
    total_latency = total_latency + latency;
end endtask

// // check answer task 
task check_ans_task; 
begin
    j_pat = 0;
    // @(negedge clk);

    while (j_pat < pat_num) begin
        // check out_valid continuity
        if(out_valid !== 1'b1) begin
            $display("%0s================================================================", txt_red_prefix);
		    $display("                             FAIL"                           );
		    $display("         out_valid should be pulled high continuously!  ");
		    $display("================================================================%0s", reset_color);
            #(CYCLE*8);
            $finish;
        end

		
        // check output correctness
        if(out_valid === 1'b1 && data_out !== golden_out[j_pat]) begin
            $display("%0s===========================================================================", txt_red_prefix);
		    $display("                             FAIL"                           );
		    $display("                       Output is incorret at PATTERN NO.%4d  ", j_pat);
            $display("                       Your output is    : %h", data_out);
            $display("                       Golden output is  : %h", golden_out[j_pat]);
			$display("                                                                              ");
			$display("####################   Internal node information for debug   ###############");
			$display("                                                                              ");
			$display("                       mode = %h, data_in = %h", golden_mode[j_pat], golden_in[j_pat]);
			if(!golden_mode[j_pat]) $display("                       exp(-x) = %h", golden_exp[j_pat]);
			else $display("                       exp(2x) = %h", golden_exp[j_pat]);
			$display("                       numerator = %h / denominator = %h", golden_nume[j_pat], golden_deno[j_pat]);
		    $display("=============================================================================%0s", reset_color);
            // #(CYCLE*8);
            $finish;
		end else begin
			$display("%0sPASS PATTERN NO.%4d %0s",txt_blue_prefix, j_pat, reset_color);
		end

        @(negedge clk);
        j_pat = j_pat + 1;
		total_latency = total_latency + 1;
    end
end endtask

//==============================================//
//            Pass and Finish Function          //
//==============================================//
// you_pass task
task you_pass_task; begin
	$display("                                           `:::::`                                                       ");
    $display("                                          .+-----++                                                      ");
    $display("                .--.`                    o:------/o                                                      ");
    $display("              /+:--:o/                   //-------y.          -//:::-        `.`                         ");
    $display("            `/:------y:                  `o:--::::s/..``    `/:-----s-    .:/:::+:                       ");
    $display("            +:-------:y                `.-:+///::-::::://:-.o-------:o  `/:------s-                      ");
    $display("            y---------y-        ..--:::::------------------+/-------/+ `+:-------/s                      ");
    $display("           `s---------/s       +:/++/----------------------/+-------s.`o:--------/s                      ");
    $display("           .s----------y-      o-:----:---------------------/------o: +:---------o:                      ");
    $display("           `y----------:y      /:----:/-------/o+----------------:+- //----------y`                      ");
    $display("            y-----------o/ `.--+--/:-/+--------:+o--------------:o: :+----------/o                       ");
    $display("            s:----------:y/-::::::my-/:----------/---------------+:-o-----------y.                       ");
    $display("            -o----------s/-:hmmdy/o+/:---------------------------++o-----------/o                        ");
    $display("             s:--------/o--hMMMMMh---------:ho-------------------yo-----------:s`                        ");
    $display("             :o--------s/--hMMMMNs---------:hs------------------+s------------s-                         ");
    $display("              y:-------o+--oyhyo/-----------------------------:o+------------o-                          ");
    $display("              -o-------:y--/s--------------------------------/o:------------o/                           ");
    $display("               +/-------o+--++-----------:+/---------------:o/-------------+/                            ");
    $display("               `o:-------s:--/+:-------/o+-:------------::+d:-------------o/                             ");
    $display("                `o-------:s:---ohsoosyhh+----------:/+ooyhhh-------------o:                              ");
    $display("                 .o-------/d/--:h++ohy/---------:osyyyyhhyyd-----------:o-                               ");
    $display("                 .dy::/+syhhh+-::/::---------/osyyysyhhysssd+---------/o`                                ");
    $display("                  /shhyyyymhyys://-------:/oyyysyhyydysssssyho-------od:                                 ");
    $display("                    `:hhysymmhyhs/:://+osyyssssydyydyssssssssyyo+//+ymo`                                 ");
    $display("                      `+hyydyhdyyyyyyyyyyssssshhsshyssssssssssssyyyo:`                                   ");
    $display("                        -shdssyyyyyhhhhhyssssyyssshssssssssssssyy+.                                      ");
    $display("                         `hysssyyyysssssssssssssssyssssssssssshh+                                        ");
    $display("                        :yysssssssssssssssssssssssssssssssssyhysh-                                       ");
    $display("                      .yyhhdo++oosyyyyssssssssssssssssssssssyyssyh/                                      ");
    $display("                      .dhyh/--------/+oyyyssssssssssssssssssssssssy:                                     ");
    $display("                       .+h/-------------:/osyyysssssssssssssssyyh/.                                      ");
    $display("                        :+------------------::+oossyyyyyyyysso+/s-                                       ");
    $display("                       `s--------------------------::::::::-----:o                                       ");
    $display("                       +:----------------------------------------y`                                      ");
	$display("%0s======================================================================================================", txt_magenta_prefix);
	$display("                                     Congratulations!!");
    $display("                                    All Pattern Test Pass");
	$display("                                      Cycle time = %-2d ns", cycle_time);
	$display("                         Your execution cycles = %-4d cycles", total_latency);
	$display("========================================================================================================= %0s", reset_color);
	$finish;
end	endtask


endmodule
