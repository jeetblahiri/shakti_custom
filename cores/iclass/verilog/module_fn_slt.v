//
// Generated by Bluespec Compiler, version 2014.07.A (build 34078, 2014-07-30)
//
// On Mon Sep 14 23:06:34 IST 2015
//
//
// Ports:
// Name                         I/O  size props
// fn_slt                         O    64
// fn_slt__in1                    I    64
// fn_slt__in2                    I    64
//
// Combinational paths from inputs to outputs:
//   (fn_slt__in1, fn_slt__in2) -> fn_slt
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
  `define BSV_ASSIGNMENT_DELAY
`endif

`ifdef BSV_POSITIVE_RESET
  `define BSV_RESET_VALUE 1'b1
  `define BSV_RESET_EDGE posedge
`else
  `define BSV_RESET_VALUE 1'b0
  `define BSV_RESET_EDGE negedge
`endif

module module_fn_slt(fn_slt__in1,
		     fn_slt__in2,
		     fn_slt);
  // value method fn_slt
  input  [63 : 0] fn_slt__in1;
  input  [63 : 0] fn_slt__in2;
  output [63 : 0] fn_slt;

  // signals for module outputs
  wire [63 : 0] fn_slt;

  // remaining internal signals
  wire fn_comparator___d7, x__h115;

  // value method fn_slt
  assign fn_slt =
	     (fn_slt__in1[63] && !fn_slt__in2[63] ||
	      ~x__h115 && fn_comparator___d7) ?
	       64'd1 :
	       64'd0 ;

  // remaining internal signals
  module_fn_comparator instance_fn_comparator_0(.fn_comparator__op1(fn_slt__in1),
						.fn_comparator__op2(fn_slt__in2),
						.fn_comparator(fn_comparator___d7));
  assign x__h115 = fn_slt__in1[63] ^ fn_slt__in2[63] ;
endmodule  // module_fn_slt
