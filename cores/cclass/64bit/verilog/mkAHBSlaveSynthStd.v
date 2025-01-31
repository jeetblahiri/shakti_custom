//
// Generated by Bluespec Compiler, version 2015.09.beta2 (build 34689, 2015-09-07)
//
// On Mon Dec 19 16:36:58 IST 2016
//
//
// Ports:
// Name                         I/O  size props
// tlm_tx_get                     O   173
// RDY_tlm_tx_get                 O     1
// RDY_tlm_rx_put                 O     1
// HRDATA                         O    64
// HREADY                         O     1
// HRESP                          O     2
// addrMatch                      O     1 const
// CLK                            I     1 clock
// RST_N                          I     1 reset
// tlm_rx_put                     I    89
// HADDR                          I    64
// HWDATA                         I    64
// HWRITE                         I     1
// HTRANS                         I     2
// HBURST                         I     3
// HSIZE                          I     3
// HPROT                          I     4
// addrMatch_value                I    64 unused
// HSEL                           I     1
// EN_tlm_rx_put                  I     1
// EN_tlm_tx_get                  I     1
//
// Combinational paths from inputs to outputs:
//   (tlm_rx_put, EN_tlm_rx_put) -> HRDATA
//   (tlm_rx_put, EN_tlm_rx_put) -> HREADY
//   (tlm_rx_put, EN_tlm_rx_put) -> HRESP
//   HWDATA -> RDY_tlm_tx_get
//   HWDATA -> tlm_tx_get
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

module mkAHBSlaveSynthStd(CLK,
			  RST_N,

			  EN_tlm_tx_get,
			  tlm_tx_get,
			  RDY_tlm_tx_get,

			  tlm_rx_put,
			  EN_tlm_rx_put,
			  RDY_tlm_rx_put,

			  HADDR,

			  HWDATA,

			  HWRITE,

			  HTRANS,

			  HBURST,

			  HSIZE,

			  HPROT,

			  HRDATA,

			  HREADY,

			  HRESP,

			  addrMatch_value,
			  addrMatch,

			  HSEL);
  input  CLK;
  input  RST_N;

  // actionvalue method tlm_tx_get
  input  EN_tlm_tx_get;
  output [172 : 0] tlm_tx_get;
  output RDY_tlm_tx_get;

  // action method tlm_rx_put
  input  [88 : 0] tlm_rx_put;
  input  EN_tlm_rx_put;
  output RDY_tlm_rx_put;

  // action method fabric_bus_hADDR
  input  [63 : 0] HADDR;

  // action method fabric_bus_hWDATA
  input  [63 : 0] HWDATA;

  // action method fabric_bus_hWRITE
  input  HWRITE;

  // action method fabric_bus_hTRANS
  input  [1 : 0] HTRANS;

  // action method fabric_bus_hBURST
  input  [2 : 0] HBURST;

  // action method fabric_bus_hSIZE
  input  [2 : 0] HSIZE;

  // action method fabric_bus_hPROT
  input  [3 : 0] HPROT;

  // value method fabric_bus_hRDATA
  output [63 : 0] HRDATA;

  // value method fabric_bus_hREADY
  output HREADY;

  // value method fabric_bus_hRESP
  output [1 : 0] HRESP;

  // value method fabric_selector_addrMatch
  input  [63 : 0] addrMatch_value;
  output addrMatch;

  // action method fabric_selector_select
  input  HSEL;

  // signals for module outputs
  wire [172 : 0] tlm_tx_get;
  wire [63 : 0] HRDATA;
  wire [1 : 0] HRESP;
  wire HREADY, RDY_tlm_rx_put, RDY_tlm_tx_get, addrMatch;

  // inlined wires
  wire [173 : 0] fifo_tx_rv$port0__write_1,
		 fifo_tx_rv$port1__read,
		 fifo_tx_rv$port1__write_1,
		 fifo_tx_rv$port2__read;
  wire [89 : 0] fifo_rx_rv$port0__write_1,
		fifo_rx_rv$port1__read,
		fifo_rx_rv$port1__write_1,
		fifo_rx_rv$port2__read;
  wire [67 : 0] ifc_response_wire$wget;
  wire fifo_op_rv$port1__read, fifo_op_rv$port2__read, ifc_response_wire$whas;

  // register ctrl_reg
  reg [77 : 0] ctrl_reg;
  wire [77 : 0] ctrl_reg$D_IN;
  wire ctrl_reg$EN;

  // register fifo_op_rv
  reg fifo_op_rv;
  wire fifo_op_rv$D_IN, fifo_op_rv$EN;

  // register fifo_rx_rv
  reg [89 : 0] fifo_rx_rv;
  wire [89 : 0] fifo_rx_rv$D_IN;
  wire fifo_rx_rv$EN;

  // register fifo_tx_rv
  reg [173 : 0] fifo_tx_rv;
  wire [173 : 0] fifo_tx_rv$D_IN;
  wire fifo_tx_rv$EN;

  // register first
  reg first;
  wire first$D_IN, first$EN;

  // register start
  reg start;
  wire start$D_IN, start$EN;

  // rule scheduling signals
  wire CAN_FIRE_RL_default_response,
       CAN_FIRE_RL_first__dreg_update,
       CAN_FIRE_RL_grab_ctrl,
       CAN_FIRE_RL_grab_response,
       CAN_FIRE_RL_not_selected,
       CAN_FIRE_RL_send_request,
       CAN_FIRE_fabric_bus_hADDR,
       CAN_FIRE_fabric_bus_hBURST,
       CAN_FIRE_fabric_bus_hPROT,
       CAN_FIRE_fabric_bus_hSIZE,
       CAN_FIRE_fabric_bus_hTRANS,
       CAN_FIRE_fabric_bus_hWDATA,
       CAN_FIRE_fabric_bus_hWRITE,
       CAN_FIRE_fabric_selector_select,
       CAN_FIRE_tlm_rx_put,
       CAN_FIRE_tlm_tx_get,
       WILL_FIRE_RL_default_response,
       WILL_FIRE_RL_first__dreg_update,
       WILL_FIRE_RL_grab_ctrl,
       WILL_FIRE_RL_grab_response,
       WILL_FIRE_RL_not_selected,
       WILL_FIRE_RL_send_request,
       WILL_FIRE_fabric_bus_hADDR,
       WILL_FIRE_fabric_bus_hBURST,
       WILL_FIRE_fabric_bus_hPROT,
       WILL_FIRE_fabric_bus_hSIZE,
       WILL_FIRE_fabric_bus_hTRANS,
       WILL_FIRE_fabric_bus_hWDATA,
       WILL_FIRE_fabric_bus_hWRITE,
       WILL_FIRE_fabric_selector_select,
       WILL_FIRE_tlm_rx_put,
       WILL_FIRE_tlm_tx_get;

  // inputs to muxes for submodule ports
  wire [77 : 0] MUX_ctrl_reg$write_1__VAL_1, MUX_ctrl_reg$write_1__VAL_2;
  wire [67 : 0] MUX_ifc_response_wire$wset_1__VAL_1,
		MUX_ifc_response_wire$wset_1__VAL_2;
  wire MUX_ctrl_reg$write_1__SEL_1;

  // remaining internal signals
  reg [7 : 0] value__h2424;

  // actionvalue method tlm_tx_get
  assign tlm_tx_get = fifo_tx_rv$port1__read[172:0] ;
  assign RDY_tlm_tx_get = fifo_tx_rv$port1__read[173] ;
  assign CAN_FIRE_tlm_tx_get = fifo_tx_rv$port1__read[173] ;
  assign WILL_FIRE_tlm_tx_get = EN_tlm_tx_get ;

  // action method tlm_rx_put
  assign RDY_tlm_rx_put = !fifo_rx_rv[89] ;
  assign CAN_FIRE_tlm_rx_put = !fifo_rx_rv[89] ;
  assign WILL_FIRE_tlm_rx_put = EN_tlm_rx_put ;

  // action method fabric_bus_hADDR
  assign CAN_FIRE_fabric_bus_hADDR = 1'd1 ;
  assign WILL_FIRE_fabric_bus_hADDR = 1'd1 ;

  // action method fabric_bus_hWDATA
  assign CAN_FIRE_fabric_bus_hWDATA = 1'd1 ;
  assign WILL_FIRE_fabric_bus_hWDATA = 1'd1 ;

  // action method fabric_bus_hWRITE
  assign CAN_FIRE_fabric_bus_hWRITE = 1'd1 ;
  assign WILL_FIRE_fabric_bus_hWRITE = 1'd1 ;

  // action method fabric_bus_hTRANS
  assign CAN_FIRE_fabric_bus_hTRANS = 1'd1 ;
  assign WILL_FIRE_fabric_bus_hTRANS = 1'd1 ;

  // action method fabric_bus_hBURST
  assign CAN_FIRE_fabric_bus_hBURST = 1'd1 ;
  assign WILL_FIRE_fabric_bus_hBURST = 1'd1 ;

  // action method fabric_bus_hSIZE
  assign CAN_FIRE_fabric_bus_hSIZE = 1'd1 ;
  assign WILL_FIRE_fabric_bus_hSIZE = 1'd1 ;

  // action method fabric_bus_hPROT
  assign CAN_FIRE_fabric_bus_hPROT = 1'd1 ;
  assign WILL_FIRE_fabric_bus_hPROT = 1'd1 ;

  // value method fabric_bus_hRDATA
  assign HRDATA =
	     ifc_response_wire$whas ?
	       ifc_response_wire$wget[65:2] :
	       64'h0000000000000123 ;

  // value method fabric_bus_hREADY
  assign HREADY = MUX_ctrl_reg$write_1__SEL_1 ;

  // value method fabric_bus_hRESP
  assign HRESP =
	     ifc_response_wire$whas ? ifc_response_wire$wget[67:66] : 2'd0 ;

  // value method fabric_selector_addrMatch
  assign addrMatch = 1'd1 ;

  // action method fabric_selector_select
  assign CAN_FIRE_fabric_selector_select = 1'd1 ;
  assign WILL_FIRE_fabric_selector_select = 1'd1 ;

  // rule RL_not_selected
  assign CAN_FIRE_RL_not_selected = !HSEL ;
  assign WILL_FIRE_RL_not_selected = CAN_FIRE_RL_not_selected ;

  // rule RL_send_request
  assign CAN_FIRE_RL_send_request =
	     !fifo_tx_rv[173] && !fifo_op_rv && ctrl_reg[77] &&
	     (ctrl_reg[69:68] == 2'd3 || ctrl_reg[69:68] == 2'd2) ;
  assign WILL_FIRE_RL_send_request = CAN_FIRE_RL_send_request ;

  // rule RL_grab_response
  assign CAN_FIRE_RL_grab_response =
	     fifo_rx_rv$port1__read[89] && fifo_op_rv$port1__read &&
	     ctrl_reg[77] &&
	     (ctrl_reg[69:68] == 2'd3 || ctrl_reg[69:68] == 2'd2) ;
  assign WILL_FIRE_RL_grab_response = CAN_FIRE_RL_grab_response ;

  // rule RL_default_response
  assign CAN_FIRE_RL_default_response =
	     ctrl_reg[77] &&
	     (ctrl_reg[69:68] == 2'd0 || ctrl_reg[69:68] == 2'd1) ;
  assign WILL_FIRE_RL_default_response = CAN_FIRE_RL_default_response ;

  // rule RL_grab_ctrl
  assign CAN_FIRE_RL_grab_ctrl = !ctrl_reg[77] ;
  assign WILL_FIRE_RL_grab_ctrl =
	     CAN_FIRE_RL_grab_ctrl && !WILL_FIRE_RL_not_selected ;

  // rule RL_first__dreg_update
  assign CAN_FIRE_RL_first__dreg_update = 1'd1 ;
  assign WILL_FIRE_RL_first__dreg_update = 1'd1 ;

  // inputs to muxes for submodule ports
  assign MUX_ctrl_reg$write_1__SEL_1 =
	     WILL_FIRE_RL_default_response || WILL_FIRE_RL_grab_response ;
  assign MUX_ctrl_reg$write_1__VAL_1 =
	     { HSEL, HWRITE, HSIZE, HBURST, HTRANS, HPROT, HADDR } ;
  assign MUX_ctrl_reg$write_1__VAL_2 =
	     { 1'd1, HWRITE, HSIZE, HBURST, HTRANS, HPROT, HADDR } ;
  assign MUX_ifc_response_wire$wset_1__VAL_1 =
	     { 2'd0,
	       fifo_rx_rv$port1__read[86:23],
	       1'd0,
	       1'b0 /* unspecified value */  } ;
  assign MUX_ifc_response_wire$wset_1__VAL_2 =
	     { 67'd582, 1'b0 /* unspecified value */  } ;

  // inlined wires
  assign ifc_response_wire$wget =
	     WILL_FIRE_RL_grab_response ?
	       MUX_ifc_response_wire$wset_1__VAL_1 :
	       MUX_ifc_response_wire$wset_1__VAL_2 ;
  assign ifc_response_wire$whas =
	     WILL_FIRE_RL_grab_response || WILL_FIRE_RL_default_response ;
  assign fifo_rx_rv$port0__write_1 = { 1'd1, tlm_rx_put } ;
  assign fifo_rx_rv$port1__read =
	     EN_tlm_rx_put ? fifo_rx_rv$port0__write_1 : fifo_rx_rv ;
  assign fifo_rx_rv$port1__write_1 =
	     { 1'd0, 89'h0AAAAAAAAAAAAAAAAAAAAAA /* unspecified value */  } ;
  assign fifo_rx_rv$port2__read =
	     CAN_FIRE_RL_grab_response ?
	       fifo_rx_rv$port1__write_1 :
	       fifo_rx_rv$port1__read ;
  assign fifo_tx_rv$port0__write_1 =
	     { 2'd2,
	       ctrl_reg[76] ? 2'd1 : 2'd0,
	       2'd0,
	       ctrl_reg[63:0],
	       HWDATA,
	       15'd2044,
	       value__h2424[2:0],
	       18'd0,
	       ctrl_reg[67:64] } ;
  assign fifo_tx_rv$port1__read =
	     CAN_FIRE_RL_send_request ?
	       fifo_tx_rv$port0__write_1 :
	       fifo_tx_rv ;
  assign fifo_tx_rv$port1__write_1 =
	     { 1'd0,
	       173'h0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA /* unspecified value */  } ;
  assign fifo_tx_rv$port2__read =
	     EN_tlm_tx_get ?
	       fifo_tx_rv$port1__write_1 :
	       fifo_tx_rv$port1__read ;
  assign fifo_op_rv$port1__read = CAN_FIRE_RL_send_request || fifo_op_rv ;
  assign fifo_op_rv$port2__read =
	     !CAN_FIRE_RL_grab_response && fifo_op_rv$port1__read ;

  // register ctrl_reg
  assign ctrl_reg$D_IN =
	     MUX_ctrl_reg$write_1__SEL_1 ?
	       MUX_ctrl_reg$write_1__VAL_1 :
	       MUX_ctrl_reg$write_1__VAL_2 ;
  assign ctrl_reg$EN =
	     WILL_FIRE_RL_default_response || WILL_FIRE_RL_grab_response ||
	     WILL_FIRE_RL_grab_ctrl ;

  // register fifo_op_rv
  assign fifo_op_rv$D_IN = fifo_op_rv$port2__read ;
  assign fifo_op_rv$EN = 1'b1 ;

  // register fifo_rx_rv
  assign fifo_rx_rv$D_IN = fifo_rx_rv$port2__read ;
  assign fifo_rx_rv$EN = 1'b1 ;

  // register fifo_tx_rv
  assign fifo_tx_rv$D_IN = fifo_tx_rv$port2__read ;
  assign fifo_tx_rv$EN = 1'b1 ;

  // register first
  assign first$D_IN = 1'b0 ;
  assign first$EN = 1'd1 ;

  // register start
  assign start$D_IN = 1'b0 ;
  assign start$EN = 1'b0 ;

  // remaining internal signals
  always@(ctrl_reg)
  begin
    case (ctrl_reg[75:73])
      3'd0: value__h2424 = 8'd0;
      3'd1: value__h2424 = 8'd1;
      3'd2: value__h2424 = 8'd3;
      3'd3: value__h2424 = 8'd7;
      3'd4: value__h2424 = 8'd15;
      3'd5: value__h2424 = 8'd31;
      3'd6: value__h2424 = 8'd63;
      3'd7: value__h2424 = 8'd127;
    endcase
  end

  // handling of inlined registers

  always@(posedge CLK)
  begin
    if (RST_N == `BSV_RESET_VALUE)
      begin
        ctrl_reg <= `BSV_ASSIGNMENT_DELAY
	    { 1'd0, 77'h0AAAAAAAAAAAAAAAAAAA /* unspecified value */  };
	fifo_op_rv <= `BSV_ASSIGNMENT_DELAY 1'd0;
	fifo_rx_rv <= `BSV_ASSIGNMENT_DELAY
	    { 1'd0, 89'h0AAAAAAAAAAAAAAAAAAAAAA /* unspecified value */  };
	fifo_tx_rv <= `BSV_ASSIGNMENT_DELAY
	    { 1'd0,
	      173'h0AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA /* unspecified value */  };
	first <= `BSV_ASSIGNMENT_DELAY 1'd0;
	start <= `BSV_ASSIGNMENT_DELAY 1'd1;
      end
    else
      begin
        if (ctrl_reg$EN) ctrl_reg <= `BSV_ASSIGNMENT_DELAY ctrl_reg$D_IN;
	if (fifo_op_rv$EN)
	  fifo_op_rv <= `BSV_ASSIGNMENT_DELAY fifo_op_rv$D_IN;
	if (fifo_rx_rv$EN)
	  fifo_rx_rv <= `BSV_ASSIGNMENT_DELAY fifo_rx_rv$D_IN;
	if (fifo_tx_rv$EN)
	  fifo_tx_rv <= `BSV_ASSIGNMENT_DELAY fifo_tx_rv$D_IN;
	if (first$EN) first <= `BSV_ASSIGNMENT_DELAY first$D_IN;
	if (start$EN) start <= `BSV_ASSIGNMENT_DELAY start$D_IN;
      end
  end

  // synopsys translate_off
  `ifdef BSV_NO_INITIAL_BLOCKS
  `else // not BSV_NO_INITIAL_BLOCKS
  initial
  begin
    ctrl_reg = 78'h2AAAAAAAAAAAAAAAAAAA;
    fifo_op_rv = 1'h0;
    fifo_rx_rv = 90'h2AAAAAAAAAAAAAAAAAAAAAA;
    fifo_tx_rv = 174'h2AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
    first = 1'h0;
    start = 1'h0;
  end
  `endif // BSV_NO_INITIAL_BLOCKS
  // synopsys translate_on
endmodule  // mkAHBSlaveSynthStd

