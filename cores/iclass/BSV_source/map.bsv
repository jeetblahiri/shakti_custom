/*
Copyright (c) 2013-2015, IIT Madras
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

*  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
*  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
*  Neither the name of IIT Madras  nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 

Author Names : Rahul Bodduna, N Sireesh.
Email ID : rahul.bodduna@gmail.com
*/

package map;

    import Vector ::*; 
    import FIFO ::*;
    import ConfigReg ::*;
    import GetPut::*;
    import SpecialFIFOs::*;
		import DefaultValue::*;

    `include  "defined_parameters.bsv"    
    import riscv_types::*;

interface IfcPrf_Map;

		interface Put#(IQ_to_map) frm_inst_Q;
		interface Put#(FRQ_to_map) frm_FRQ;
		interface Put#(Vector#(32, RAT_entry)) frm_fRAM;
		method Action map_and_rename(Decode_packet decoded_instruction); 
    method  Action broadcast_frm_fununits(Vector#(`FUN_UNITS, Broadcast_type) broadcast_data);
    method  Action get_load_q_tail(Bit#(TLog#(`MEMQ_SIZE)) load_q);
    method  Action get_store_q_tail(Bit#(TLog#(`MEMQ_SIZE)) store_q);
    
    
    //Output Methods
    method Imm_buf_entry imm_buf_entry_1;
    method Imm_buf_entry imm_buf_entry_2;
    method Maybe#(Bit#(TLog#(`IMM_BUF_SIZE))) update_imm_buf_tail;
    method Maybe#(Bit#(TLog#(`REGFILE_SIZE))) send_fRAM_slot_1;
    method Maybe#(Bit#(TLog#(`REGFILE_SIZE))) send_fRAM_slot_2;
    method RAT_entry send_fRAM_entry_1;
    method RAT_entry send_fRAM_entry_2;
    method Bit#(TAdd#(TLog#(`FETCH_WIDTH),1)) update_frq_head;
    method Entry_rob_type send_entry_rob_1; 
    method Entry_rob_type send_entry_rob_2; 
    method Maybe#(Update_map_prf) invalidate_prf_valid_1;
    method Maybe#(Update_map_prf) invalidate_prf_valid_2;
    method Prf_info send_entry_rob_op_1_ready_1;
    method Prf_info send_entry_rob_op_1_ready_2;
    method Prf_info send_entry_rob_op_2_ready_1;
    method Prf_info send_entry_rob_op_2_ready_2;
    method Bool send_entry_rob_execute_done_1;
    method Bool send_entry_rob_execute_done_2;
    method Bool send_entry_rob_squash_1;
    method Bool send_entry_rob_squash_2;
    method Bit#(`REG_WIDTH) send_squash_buf_1;
    method Bit#(`REG_WIDTH) send_squash_buf_2;
    method Bool send_selected_for_exec_1;
    method Bool send_selected_for_exec_2;
		method TrapCause send_if_exception_1;
		method TrapCause send_if_exception_2;
    method Bit#(TAdd#(TLog#(`FETCH_WIDTH),1)) send_update_rob_tail;
    method Maybe#(Vector#(`FETCH_WIDTH, Mem_type)) allot_mem_q;

endinterface


(*synthesize*)
module mkPrf_Map(IfcPrf_Map);

    FIFO#(Decode_packet) ff_decoded_instruction <- mkBypassFIFO();
    Wire#(Bool)   wr_load_q_full <- mkDWire(False) ;
    Wire#(Bool)   wr_store_q_full <- mkDWire(False);
    Wire#(Bool)   wr_erob_full <- mkDWire(False);
    Wire#(FRQ_to_map)   wr_frq_to_map <- mkDWire(defaultValue);
    Wire#(Prf_info)   wr_prf_valid[`PRF_SIZE];
	for(Integer i = 0; i < `PRF_SIZE; i = i + 1) 
	    wr_prf_valid[i] <- mkDWire(defaultValue);
    Wire#(Maybe#(Update_map_prf)) wr_dest_op_1 <- mkDWire(tagged Invalid);
    Wire#(Maybe#(Update_map_prf)) wr_dest_op_2 <- mkDWire(tagged Invalid);
    Wire#(Bit#(TLog#(`MEMQ_SIZE))) wr_load_q_tail <- mkDWire(0);
    Wire#(Bit#(TLog#(`MEMQ_SIZE))) wr_store_q_tail <- mkDWire(0);
    Wire#(Bit#(TLog#(`PRF_SIZE))) wr_fRAM[`REGFILE_SIZE];
	for(Integer i = 0; i < `REGFILE_SIZE; i=i+1)
	    wr_fRAM[i] <- mkDWire(0);
    Wire#(Bool)  wr_imm_buf_full <- mkDWire(False);
    Wire#(Bit#(TLog#(`IMM_BUF_SIZE)))  wr_imm_buf_tail_frm_IQ  <- mkDWire(0);
    Wire#(Maybe#(Bit#(TLog#(`IMM_BUF_SIZE))))  wr_imm_buf_tail  <- mkDWire(tagged Invalid);
    Wire#(Bit#(TLog#(`MEMQ_SIZE))) wr_allot_load_q <- mkDWire(0);
    Wire#(Bool) wr_increment_load_q <- mkDWire(False);
    Wire#(Bit#(TLog#(`MEMQ_SIZE))) wr_allot_store_q <- mkDWire(0);
    Wire#(Bool) wr_increment_store_q <- mkDWire(False);
    Wire#(Maybe#(Vector#(`FETCH_WIDTH, Mem_type))) wr_allot_mem_q <- mkDWire(tagged Invalid);
    Wire#(Bit#(TAdd#(TLog#(`FETCH_WIDTH),1)))  wr_update_frq_head <- mkDWire(0);
    Wire#(Imm_buf_entry) wr_imm_buf_entry_1 <- mkDWire(defaultValue);
    Wire#(Imm_buf_entry) wr_imm_buf_entry_2 <- mkDWire(defaultValue);
    Wire#(Maybe#(Bit#(TLog#(`REGFILE_SIZE)))) wr_fRAM_slot_1 <- mkDWire(tagged Invalid);
    Wire#(Maybe#(Bit#(TLog#(`REGFILE_SIZE)))) wr_fRAM_slot_2 <- mkDWire(tagged Invalid);
    Wire#(RAT_entry) wr_fRAM_entry_1 <-mkDWire(0);
    Wire#(RAT_entry) wr_fRAM_entry_2 <-mkDWire(0);
    Wire#(Entry_rob_type) wr_entry_rob_1 <- mkDWire(defaultValue);
    Wire#(Entry_rob_type) wr_entry_rob_2 <- mkDWire(defaultValue);
    Vector#(`FETCH_WIDTH, Wire#(Prf_info)) wr_entry_rob_op_1_msd <- replicateM(mkDWire(defaultValue));
    Vector#(`FETCH_WIDTH, Wire#(Prf_info)) wr_entry_rob_op_2_msd <- replicateM(mkDWire(defaultValue));
    Wire#(Bool) wr_entry_rob_execute_done_1 <- mkDWire(False);
    Wire#(Bool) wr_entry_rob_execute_done_2 <- mkDWire(False);
    Wire#(Bool) wr_entry_rob_squash_1 <- mkDWire(False);
    Wire#(Bool) wr_entry_rob_squash_2 <- mkDWire(False);
    Wire#(Bit#(`REG_WIDTH)) wr_squash_buf_1 <- mkDWire(0);
    Wire#(Bit#(`REG_WIDTH)) wr_squash_buf_2 <- mkDWire(0);
    Wire#(Bool) wr_selected_for_exec_1  <- mkDWire(False);
    Wire#(Bool) wr_selected_for_exec_2  <- mkDWire(False);
    Wire#(TrapCause) wr_entry_rob_exception_1 <- mkDWire(No_trap);
    Wire#(TrapCause) wr_entry_rob_exception_2 <- mkDWire(No_trap);
    Wire#(Bit#(`FETCH_WIDTH)) wr_update_rob_tail <- mkDWire(0); 


    Wire#(Broadcast_type) wr_broadcast[`FUN_UNITS];
    for(Integer i=0;i<`FUN_UNITS;i=i+1) 
	  wr_broadcast[i] <- mkDWire(
				Broadcast_type{          
				    valid	: False,
		 		    dest_tag	: 0});
	Reg#(bit) cntr <- mkReg(0);
	let rg_map_dump <- mkReg(InvalidFile);

	rule rl_file_write(cntr == 0);
		String map_dumpfile = "map_dump.txt";
		File fl_map <- $fopen(map_dumpfile, "w");
		rg_map_dump <= fl_map;
		cntr <= cntr + 1;
	endrule

	method Action map_and_rename(Decode_packet decoded_instruction); 

		Vector#(`FETCH_WIDTH, Bit#(TLog#(`MEMQ_SIZE))) lv_mem_q_index = replicate(0);
	  
		Vector#(`FETCH_WIDTH, Bit#(TLog#(`IMM_BUF_SIZE))) lv_imm_index;
		    for(Integer i = 0; i < `FETCH_WIDTH; i = i + 1)
			lv_imm_index[i] = wr_imm_buf_tail_frm_IQ + fromInteger(i);
				  
		//To check 'operand valid' forwarding from broadcast bus
		//vector of length 2 holds the forward bit for two operands  
		Vector#(2, Bool) lv_broadcast_op_1[`FUN_UNITS];
		Vector#(2, Bool) lv_broadcast_op_2[`FUN_UNITS];
		for(Integer j=0;j<`FETCH_WIDTH; j=j+1) begin
		    for(Integer i=0;i<`FUN_UNITS;i=i+1) begin
	  	           lv_broadcast_op_1[i][j] = False;
	  	           lv_broadcast_op_2[i][j] = False;
		    end 
		end 
	  	   
		//Set to 'True' when there is a match of dest of instr 0
	  	//with sources of instr 1
	  	Bool lv_match_dest_0_rs_1 = False;
	  	Bool lv_match_dest_0_rs_2 = False;

	  	
	  	//dequeue from decode fifo
	  	let lv_decode_packet = decoded_instruction;
	  	
	  	//holds the request to load-store queue allotment
	  	Vector#(`FETCH_WIDTH, Mem_type) mem_q_req = replicate(NOP);

		for(Integer i=0;i<`FETCH_WIDTH;i=i+1) begin
			if(lv_decode_packet.decode_packet[i].instruction_decoded.inst_op matches tagged Memory .memx)
	  		mem_q_req[i] = memx.mem_type;
		end

	  	//if instr 1 is invalid
	//	  if(!lv_decode_packet.valid[1])
	//		 mem_q_req[1] = NOP;
	  	
	  	//map source register 1
	  	Vector#(`FETCH_WIDTH, Bit#(TLog#(`PRF_SIZE))) lv_op_1;

	  	//'operand ready' hardware for op_1
	  	Vector#(`FETCH_WIDTH, Bool) lv_entry_rob_match_op_1;
	  	Vector#(`FETCH_WIDTH, Bit#(`MAX_LATENCY)) lv_entry_rob_delay_op_1;
	  	Vector#(`FETCH_WIDTH, Bit#(`MAX_LATENCY)) lv_entry_rob_shift_op_1;

		for(Integer i=0;i<`FETCH_WIDTH;i=i+1) begin
	  	   	lv_op_1[i] = wr_fRAM[lv_decode_packet.decode_packet[i].instruction_decoded.rs1];
	  	   	lv_entry_rob_match_op_1[i] = wr_prf_valid[lv_op_1[i]]._match;
	  	   	lv_entry_rob_delay_op_1[i] = wr_prf_valid[lv_op_1[i]]._delay;
	  	   	lv_entry_rob_shift_op_1[i] = wr_prf_valid[lv_op_1[i]]._shift;
	  	end

	  	//map source register 2
	  	Vector#(`FETCH_WIDTH, Bit#(TLog#(`PRF_SIZE))) lv_op_2;

	  	//'operand ready' hardware for op_2
	  	Vector#(`FETCH_WIDTH, Bool) lv_entry_rob_match_op_2;
	  	Vector#(`FETCH_WIDTH, Bit#(`MAX_LATENCY)) lv_entry_rob_delay_op_2;
	  	Vector#(`FETCH_WIDTH, Bit#(`MAX_LATENCY)) lv_entry_rob_shift_op_2;

	  	for(Integer i=0;i<`FETCH_WIDTH;i=i+1) begin
	  	   	lv_op_2[i] = wr_fRAM[lv_decode_packet.decode_packet[i].instruction_decoded.rs2];
	  	   	lv_entry_rob_match_op_2[i] = wr_prf_valid[lv_op_2[i]]._match;
	  	   	lv_entry_rob_delay_op_2[i] = wr_prf_valid[lv_op_2[i]]._delay;
	  	   	lv_entry_rob_shift_op_2[i] = wr_prf_valid[lv_op_2[i]]._shift;
	  	end

	  	//map dest registers
	  	Vector#(`FETCH_WIDTH, Bit#(TLog#(`PRF_SIZE))) lv_dest_op;
	  	lv_dest_op[0] = wr_frq_to_map.entry_1.free_reg;
	  	lv_dest_op[1] = wr_frq_to_map.entry_2.free_reg;
	  	
	  	$fwrite(rg_map_dump,"lv_dest_op_0 %d lv_dest_op_1 %d", lv_dest_op[0], lv_dest_op[1]);
	  	Bool lv_prf_match = False;
	  	
	  	Bit#(`MAX_LATENCY) lv_prf_shift = 0;
	  	
	  	Vector#(`FETCH_WIDTH, Bit#(`MAX_LATENCY)) lv_prf_delay;
	  	  
	  	//if an instruction takes N cycles to execute, delay is N-1.
	  	//This field has to be changed when new instructions with
	  	//multiple cycle latencies are added.
		for(Integer i=0;i<`FETCH_WIDTH;i=i+1) begin
	  	  	if(lv_decode_packet.decode_packet[i].instruction_decoded.inst_op matches tagged ALU .alux &&&
					alux.alu_type == MUL)
	  	  	   lv_prf_delay[i] = 6'b100000;
	  	  	else
	  	  	   lv_prf_delay[i] = 6'b111111;
	  	end	  

	  	//invalidate and remove it from FRQ
	  	
	  	//if instruction 1 in the packet is valid
		if(lv_decode_packet.valid[1]) begin
	  	  	wr_update_frq_head <= 2'b10;
	  	  	$fwrite(rg_map_dump,"frq head begin updated by %d", 2'b10);
	  	end
	  	else begin
	  	  wr_update_frq_head <= 2'b01;
	  	  $fwrite(rg_map_dump,"frq head begin updated by %d", 2'b01);
	  	end
	  	
	  	//mark it as invalid in 'prf_valid' hardware. Also note that
	  	//'prf_valid' is updated in writeback time with no conflict.
      	wr_dest_op_1 <= tagged Valid Update_map_prf{ prf_slot : lv_dest_op[0], prf_delay : lv_prf_delay[0]};
      	wr_dest_op_2 <= tagged Valid Update_map_prf{ prf_slot : lv_dest_op[1], prf_delay : lv_prf_delay[1]};


	  	//if rd on instruction 0 matches rs of instruction 1
		if(lv_decode_packet.valid[1])  begin
	  	
	  	  	//exclude comparing store and conditional branch instructions
	  	  	if(lv_decode_packet.decode_packet[0].instruction_decoded.rd != 0) begin
	  	
				//compare rs1 of instr1 with rd of instr0. rs1 of instr1 and rd of
				//instr0 should be valid values. Also, rs1 != 0 as it is hardwired
				//to zero.
				if(lv_decode_packet.decode_packet[1].instruction_decoded.rs1_valid &&
				   lv_decode_packet.decode_packet[0].instruction_decoded.rd==
				   lv_decode_packet.decode_packet[1].instruction_decoded.rs1) begin
				  	lv_op_1[1] = lv_dest_op[0];
				  	lv_entry_rob_match_op_1[1] = lv_prf_match;
				  	lv_entry_rob_delay_op_1[1] = lv_prf_delay[0];
				  	lv_entry_rob_shift_op_1[1] = lv_prf_shift;
				  	lv_match_dest_0_rs_1 = True;
				end

				//compare rs2 of instr1 with rd of instr0. rs2 of instr1 and rd of
				//instr0 should be valid values. Also, rs2 !=0 as it is hardwired
				//to zero.
				if(lv_decode_packet.decode_packet[1].instruction_decoded.rs2_valid &&
				   lv_decode_packet.decode_packet[0].instruction_decoded.rd==
				   lv_decode_packet.decode_packet[1].instruction_decoded.rs2) begin
				  		lv_op_2[1] = lv_dest_op[0];
				  		lv_entry_rob_match_op_2[1] = lv_prf_match;
				  		lv_entry_rob_delay_op_2[1] = lv_prf_delay[0];
				  		lv_entry_rob_shift_op_2[1] = lv_prf_shift;
				  		lv_match_dest_0_rs_2 = True;
				end
			end
		end
	  	
		//check for 'operand valid' forwarding from broadcast buses
	  	for(Integer i=0;i<`FUN_UNITS;i=i+1) begin
	  	  	for(Integer j=0;j<`FETCH_WIDTH;j=j+1) begin
	  	  		if(wr_broadcast[i].valid) begin
	  	  			if(wr_broadcast[i].dest_tag==lv_op_1[j]) begin
	  	  			   lv_broadcast_op_1[i][j] = True;
	  	  			end
	  	  			if(wr_broadcast[i].dest_tag==lv_op_2[j]) begin
	  	  			   lv_broadcast_op_2[i][j] = True;
	  	  			   $fwrite(rg_map_dump,"operand2 forwarded");
	  	  			end
	  	  		end
	  	  	end
		end
	  	
	  	
	  	//update operand 1 status of instruction 0
	  	//operand 1 is always ready for the instructions with invalid rs1
	  	//value i.e., for the instructions that don't use rs1 field
		if(lv_decode_packet.decode_packet[0].instruction_decoded.rs1_valid) begin 
			if(lv_broadcast_op_1[0][0] || lv_broadcast_op_1[1][0] ||
	  	   	lv_broadcast_op_1[2][0] || lv_broadcast_op_1[3][0] ||
			lv_broadcast_op_1[4][0]) begin

	  	  			 lv_entry_rob_match_op_1[0] = True;
	  	  			 lv_entry_rob_shift_op_1[0] = lv_entry_rob_delay_op_1[0];
	  	  	end
		end
	  	else begin
	  	  	lv_entry_rob_match_op_1[0] = True;
	  	  	lv_entry_rob_shift_op_1[0] = 6'b111111;
	  	end
	  	   

	  	if(isSystem(lv_decode_packet.decode_packet[0].instruction_decoded.inst_op) &&
	  	   lv_decode_packet.decode_packet[0].instruction_decoded.imm_valid)
	  	  		lv_entry_rob_match_op_1[0] = True;
	  	

	  	//update operand 1 status of instruction 1
	  	if(lv_decode_packet.decode_packet[1].instruction_decoded.rs1_valid) begin
	  	  	//else if the dest of instr 0 == rs1 of instr1
	  	  	 if(lv_broadcast_op_1[0][1] ||
	  	  	     lv_broadcast_op_1[1][1] || lv_broadcast_op_1[2][1] ||
	  	  	     lv_broadcast_op_1[3][1] || lv_broadcast_op_1[4][1]) begin
	  	  			 lv_entry_rob_match_op_1[1] = True;
	  	  			 lv_entry_rob_shift_op_1[1] = lv_entry_rob_delay_op_1[1];
	  	  	 end
      	end
		else begin
	  	  	lv_entry_rob_match_op_1[1] = True;
	  	  	lv_entry_rob_shift_op_1[1] = 6'b111111;
	  	end
	  	if(lv_decode_packet.valid[1] && 
			isSystem(lv_decode_packet.decode_packet[1].instruction_decoded.inst_op) &&
	  	  	lv_decode_packet.decode_packet[1].instruction_decoded.imm_valid)
	  	  		lv_entry_rob_match_op_1[1] = True;
	  	  	
	  	//update operand 2 status of instruction 0
	  	//operand 2 is 'ready' for insts with imm value except for stores
	  	//and conditional branches
	  	if(!(lv_decode_packet.decode_packet[0].instruction_decoded.imm_valid &&
	  	   lv_decode_packet.decode_packet[0].instruction_decoded.rd_valid)) begin
	  	    if(lv_broadcast_op_2[0][0] || lv_broadcast_op_2[1][0] || 
	  	       lv_broadcast_op_2[2][0] || lv_broadcast_op_2[3][0] ||
			   lv_broadcast_op_2[4][0]) begin
	  	  		  lv_entry_rob_match_op_2[0] = True;
	  	  		  lv_entry_rob_shift_op_2[0] = lv_entry_rob_delay_op_2[0];
	  	  	end
	  	end
		else begin
	  	  	lv_entry_rob_match_op_2[0] = True;
	  	  	lv_entry_rob_shift_op_2[0] = 6'b111111;
	  	end
	  	
	  	//update operand 2 status of instruction 1
	  	//operand 2 is 'ready' for instrs with imm value except for stores
	  	//and conditional branches
	  	if(!(lv_decode_packet.decode_packet[1].instruction_decoded.imm_valid &&
	  	     lv_decode_packet.decode_packet[1].instruction_decoded.rd_valid)) begin
	  	  	if( lv_broadcast_op_2[0][1] || lv_broadcast_op_2[1][1] ||
	  	  		lv_broadcast_op_2[2][1] || lv_broadcast_op_2[3][1] || 
	  	  		lv_broadcast_op_2[4][1]) begin
	  	  		  lv_entry_rob_match_op_2[1] = True;
	  	  		  lv_entry_rob_shift_op_2[1] = lv_entry_rob_delay_op_2[1];
			end
		end
		else begin
	  	  	lv_entry_rob_match_op_2[1] = True;
	  	  	lv_entry_rob_shift_op_2[1] = 6'b111111;
	  	end 

	  	//Allot entries in memory queues
	  	//if instr0 is 'load'
	  	if(lv_decode_packet.decode_packet[0].instruction_decoded.inst_op matches tagged Memory .memx0) begin

			if(lv_decode_packet.decode_packet[1].instruction_decoded.inst_op matches tagged Memory .memx1) begin
				
				if (memx0.mem_type == LD) begin 
	  	   			lv_mem_q_index[0] = wr_load_q_tail;
	  	   		 	//if instr0 and instr1 are 'loads'
	  	   		 	if(memx1.mem_type == LD)
	  	   		 		lv_mem_q_index[1] = wr_load_q_tail+1;
					else
	  	  				lv_mem_q_index[1] = wr_store_q_tail;
	  	   		end
	  	
	  			//if instr0 is not load and instr1 is 'load'
				else if(memx1.mem_type == LD) begin
	  	  			lv_mem_q_index[0] = wr_store_q_tail;
	  	   			lv_mem_q_index[1] = wr_load_q_tail;
				end
				else begin
	  	  			lv_mem_q_index[0] = wr_store_q_tail;
	  	  			lv_mem_q_index[1] = wr_store_q_tail+1;
				end
			end
			else if(memx0.mem_type == LD) 
	  	   		lv_mem_q_index[0] = wr_load_q_tail;
			else
	  	  		lv_mem_q_index[0] = wr_store_q_tail;

		end
		else if(lv_decode_packet.decode_packet[1].instruction_decoded.inst_op matches tagged Memory .memx1) begin
	  		//if instr0 is 'store'
	  		if(memx1.mem_type==STR)
	  	  		lv_mem_q_index[1] = wr_store_q_tail;
			else
	  	  		lv_mem_q_index[1] = wr_load_q_tail;
		end
	  	
	  	if(mem_q_req[0]!=NOP || mem_q_req[1]!=NOP) begin
	  	  	wr_allot_mem_q <= tagged Valid mem_q_req;
	  	  	$fwrite(rg_map_dump,"mem_q_req_0 %d mem_q_req_1 %d", mem_q_req[0], mem_q_req[1]);
		end
	  	
	  	
	  	//if instr0 has immediate value
			//For system instructions imm is the CSR address
	  	if(lv_decode_packet.decode_packet[0].instruction_decoded.imm_valid ||
						isSystem(lv_decode_packet.decode_packet[0].instruction_decoded.inst_op)) begin 
	  	  	wr_imm_buf_entry_1 <= Imm_buf_entry {
	  	  	   valid: True,
	  	  	   imm:lv_decode_packet.decode_packet[0].instruction_decoded.imm
	  	  	   };
	  	  	$fwrite(rg_map_dump,"imm_buf_tail %d value %h", wr_imm_buf_tail_frm_IQ, lv_decode_packet.decode_packet[0].instruction_decoded.imm);
	  	  	//if instr0 and instr1, both have immediate value
	  	  	//instr1 should be valid
	  	  	if(lv_decode_packet.valid[1] && 
						(isSystem(lv_decode_packet.decode_packet[1].instruction_decoded.inst_op) ||  
	  	  	   lv_decode_packet.decode_packet[1].instruction_decoded.imm_valid)) begin 
	  	  	$fwrite(rg_map_dump,"imm_buf_tail %d value %h", wr_imm_buf_tail_frm_IQ+1, lv_decode_packet.decode_packet[1].instruction_decoded.imm);
	  	  		  //wr_imm_buf_slot_2 <= tagged Valid lv_imm_index[1]; 
	  	  		  wr_imm_buf_entry_2 <= Imm_buf_entry {
	  	  			 valid: True,
	  	  			 imm:lv_decode_packet.decode_packet[1].instruction_decoded.imm
	  	  			 };
	  	  		  wr_imm_buf_tail <= tagged Valid (wr_imm_buf_tail_frm_IQ+2);
			end
	  	  	else
	  	  	   wr_imm_buf_tail <= tagged Valid (wr_imm_buf_tail_frm_IQ+1);
		end
	  	//if only instr1 has immediate value
	  	//instr1 should be valid
	  	else if(lv_decode_packet.valid[1] && 
	  	  	  (lv_decode_packet.decode_packet[1].instruction_decoded.imm_valid ||
						isSystem(lv_decode_packet.decode_packet[1].instruction_decoded.inst_op))) begin
	  	  	//wr_imm_buf_slot_2 <= tagged Valid lv_imm_index[0];
	  	  	wr_imm_buf_entry_1  <= Imm_buf_entry {
	  	  	   valid: True,
	  	  	   imm:lv_decode_packet.decode_packet[1].instruction_decoded.imm
	  	  	   };
	  	  	lv_imm_index[1] = wr_imm_buf_tail_frm_IQ;
	  	  	wr_imm_buf_tail <= tagged Valid (wr_imm_buf_tail_frm_IQ + 1);
		end
	  	
	  	//Update the destination register map in FRAM for instruction 0. It should
	  	//be done only if intr is not store or conditional branch. R0 is hardwired
	  	//to 0, hence FRAM is not updated if rd==0. Also, if dest of instr0
	  	//equals dest of instr1, we should not perform FRAM write for instr0.
	  	if(lv_decode_packet.decode_packet[0].instruction_decoded.rd!=0 && 
	  	   !((lv_decode_packet.valid[1] && 
	  	  	(lv_decode_packet.decode_packet[1].instruction_decoded.rd!=0)) &&
	  	     (lv_decode_packet.decode_packet[0].instruction_decoded.rd ==
			 lv_decode_packet.decode_packet[1].instruction_decoded.rd))) begin
	  	  		$fwrite(rg_map_dump,"FRAM index %d changed from %d to %d", lv_decode_packet.decode_packet[0].instruction_decoded.rd,
	  	  			 wr_fRAM[lv_decode_packet.decode_packet[0].instruction_decoded.rd], lv_dest_op[0]);
	  	  		wr_fRAM_slot_1 <= tagged Valid lv_decode_packet.decode_packet[0].instruction_decoded.rd;
	  	  		wr_fRAM_entry_1 <= lv_dest_op[0];
		end

	  	//Update the destination register map in FRAM for instruction 1. It should be
	  	//done only if instr is not store or conditional branch.
	  	if(lv_decode_packet.valid[1] &&
				lv_decode_packet.decode_packet[1].instruction_decoded.rd!=0) begin

	  	  	$fwrite(rg_map_dump,"FRAM index %d changed from %d to %d", lv_decode_packet.decode_packet[1].instruction_decoded.rd,
	  	  	wr_fRAM[lv_decode_packet.decode_packet[1].instruction_decoded.rd], lv_dest_op[1]);
	  	  	wr_fRAM_slot_2 <= tagged Valid lv_decode_packet.decode_packet[1].instruction_decoded.rd;
	  	  	wr_fRAM_entry_2 <= lv_dest_op[1];
		end
	  	
	  	//Create an EROB entry
	  	Vector#(`FETCH_WIDTH, Entry_rob_type) lv_entry_rob_type;
	  	for(Integer i=0;i<`FETCH_WIDTH;i=i+1)

	  	   lv_entry_rob_type[i] = Entry_rob_type {
	  	  	valid				: True,
	  	  	inst_op           : lv_decode_packet.decode_packet[i].instruction_decoded.inst_op,
	  	  	//mem_type            : lv_decode_packet.decode_packet[i].instruction_decoded.mem_type,
	  	  	//mem_size            : lv_decode_packet.decode_packet[i].instruction_decoded.mem_size,
	  	  	mem_q_index         : lv_mem_q_index[i],
	  	  	//alu_type            : lv_decode_packet.decode_packet[i].instruction_decoded.alu_type,
	  	  	//alu_op              : lv_decode_packet.decode_packet[i].instruction_decoded.alu_op,
	  	  	word_flag           : lv_decode_packet.decode_packet[i].instruction_decoded.word_flag,
	  	  	//branch_type         : lv_decode_packet.decode_packet[i].instruction_decoded.branch_type,
	  	  	//branch_op           : lv_decode_packet.decode_packet[i].instruction_decoded.branch_op,
	  	  	//csr_inst_type       : lv_decode_packet.decode_packet[i].instruction_decoded.csr_inst_type,
	  	  	imm_valid           : lv_decode_packet.decode_packet[i].instruction_decoded.imm_valid,
	  	  	//csr_valid			: lv_decode_packet.decode_packet[i].instruction_decoded.csr_addr_valid,
	  	  	op_1				: lv_op_1[i],
	  	  	op_2				: lv_op_2[i],
	  	  	imm_index           : lv_imm_index[i],
	  	  	dest_op				: lv_dest_op[i],
	  	  	dest_arch			: lv_decode_packet.decode_packet[i].instruction_decoded.rd,
	  	  	program_counter		: lv_decode_packet.decode_packet[i].program_counter,					
	  	  	prediction			: lv_decode_packet.decode_packet[i].prediction
	  	  	};
	  		  
	  	//enqueue it into EROB
	  	wr_entry_rob_1 <= lv_entry_rob_type[0];

	  	//update 'shift' harware fields in instruction queue
	  	wr_entry_rob_op_1_msd[0] <= Prf_info{ _match : lv_entry_rob_match_op_1[0],
	  	  								    _shift : lv_entry_rob_shift_op_1[0],
	  	  								    _delay : lv_entry_rob_delay_op_1[0]};
	

	  	wr_entry_rob_op_2_msd[0] <= Prf_info{ _match : lv_entry_rob_match_op_2[0],
	  	  								    _shift : lv_entry_rob_shift_op_2[0],
	  	  								    _delay : lv_entry_rob_delay_op_2[0]};
	

	  	wr_entry_rob_execute_done_1 <= False;
	  	wr_entry_rob_squash_1 <= False;
	  	wr_squash_buf_1 <= lv_decode_packet.decode_packet[0].program_counter;
	  	wr_selected_for_exec_1 <= False;
	  	wr_entry_rob_exception_1 <= lv_decode_packet.decode_packet[0].instruction_decoded.exception;

	  	
	  	//$display("Time:%d\nentry rob index %d filled", $time, wr_erob_tail);
		$display("\n \t \t \t \t \t ********************* MAP ************************\n");
	  	$display(fshow(lv_entry_rob_type[0]));

	  	if(lv_decode_packet.valid[1])
	  	   begin
	  	
	  	  	//$display("Time:%d\nentry rob index %d filled", $time, rg_erob_tail+1);
	  	  	$display(fshow(lv_entry_rob_type[1]));
		$display("\n \t \t \t \t \t *************************************************\n\n\n");
	  	
	  	  	wr_entry_rob_2 <= lv_entry_rob_type[1];

	  	  	//enable 'shifter' hardware fields in issue queue
	  	      wr_entry_rob_op_1_msd[1] <= Prf_info{ _match : lv_entry_rob_match_op_1[1],
	  	   										  _shift : lv_entry_rob_shift_op_1[1],
	  	   										  _delay : lv_entry_rob_delay_op_1[1]};
	  	   	
	  	
	  			wr_entry_rob_op_2_msd[1] <= Prf_info{ _match : lv_entry_rob_match_op_2[1],
	  	  									 	  _shift : lv_entry_rob_shift_op_2[1],
	  	  									 	  _delay : lv_entry_rob_delay_op_2[1]};
	
	  	  	wr_entry_rob_execute_done_2 <= False;
	  	  	wr_entry_rob_squash_2 <= False;
	  	  	wr_squash_buf_2 <= lv_decode_packet.decode_packet[1].program_counter;
	  	  	wr_selected_for_exec_2 <= False;
	  			wr_entry_rob_exception_2 <= lv_decode_packet.decode_packet[1].instruction_decoded.exception;
	  	   end
	  	
	  		  
	  	if(lv_decode_packet.valid[1])
	  	   wr_update_rob_tail <= 2'b10;	
	  	   
	  	else
	  	   wr_update_rob_tail <= 2'b01;	
	  	
	 endmethod 
	  
	  
	interface frm_inst_Q = interface Put
		method Action put(IQ_to_map _IQ_to_map);
			wr_imm_buf_tail_frm_IQ <= _IQ_to_map.imm_buf_tail;
			for(Integer i = 0; i < `PRF_SIZE; i = i + 1)
	    		wr_prf_valid[i] <= _IQ_to_map.prf_entries[i];
		endmethod
	endinterface;

	interface frm_FRQ = interface Put
		method Action put(FRQ_to_map _FRQ_to_map);
			wr_frq_to_map <= _FRQ_to_map;
		endmethod
	endinterface;

	interface frm_fRAM = interface Put
								method Action put(Vector#(32, RAT_entry) fRAM_entries);
									for(Integer i = 0; i < 32; i = i+1) begin
							    		wr_fRAM[i] <= fRAM_entries[i];
									end
								endmethod
						 endinterface;

    method  Action broadcast_frm_fununits(Vector#(`FUN_UNITS, Broadcast_type) broadcast_data);
	for(Integer i = 0; i < `FUN_UNITS; i = i + 1)
	    wr_broadcast[i] <= broadcast_data[i];
    endmethod

    method  Action get_load_q_tail(Bit#(TLog#(`MEMQ_SIZE)) load_q);
	wr_load_q_tail <= load_q;
    endmethod

    method  Action get_store_q_tail(Bit#(TLog#(`MEMQ_SIZE)) store_q);
	wr_store_q_tail <= store_q;
    endmethod

    method Imm_buf_entry imm_buf_entry_1;
	return wr_imm_buf_entry_1;
    endmethod

    method Imm_buf_entry imm_buf_entry_2;
	return wr_imm_buf_entry_2;
    endmethod

    method Maybe#(Bit#(TLog#(`IMM_BUF_SIZE))) update_imm_buf_tail;
	return wr_imm_buf_tail;
    endmethod

    method  Maybe#(Bit#(TLog#(`REGFILE_SIZE))) send_fRAM_slot_1;
	return  wr_fRAM_slot_1;
    endmethod

    method  Maybe#(Bit#(TLog#(`REGFILE_SIZE))) send_fRAM_slot_2;
	return  wr_fRAM_slot_2;
    endmethod

    method  RAT_entry send_fRAM_entry_1;
	return  wr_fRAM_entry_1;
    endmethod

    method  RAT_entry send_fRAM_entry_2;
	return  wr_fRAM_entry_2;
    endmethod

    method  Bit#(TAdd#(TLog#(`FETCH_WIDTH),1)) update_frq_head;
	 return wr_update_frq_head;
    endmethod

    method  Entry_rob_type send_entry_rob_1; 
	return wr_entry_rob_1;
    endmethod

    method  Entry_rob_type send_entry_rob_2; 
	return wr_entry_rob_2;
    endmethod

    method Maybe#(Update_map_prf) invalidate_prf_valid_1;
	return wr_dest_op_1;
    endmethod

    method Maybe#(Update_map_prf) invalidate_prf_valid_2;
	return wr_dest_op_2;
    endmethod

    method Prf_info send_entry_rob_op_1_ready_1;
	return wr_entry_rob_op_1_msd[0];
    endmethod
        	
    method Prf_info send_entry_rob_op_1_ready_2;
	return wr_entry_rob_op_1_msd[1];
    endmethod
        	
    method Prf_info send_entry_rob_op_2_ready_1;
	return wr_entry_rob_op_2_msd[0];
    endmethod
    
    method Prf_info send_entry_rob_op_2_ready_2;
	return wr_entry_rob_op_2_msd[1];
    endmethod
    
    method Bool send_entry_rob_execute_done_1;
	return wr_entry_rob_execute_done_1;
    endmethod

    method Bool send_entry_rob_execute_done_2;
	return wr_entry_rob_execute_done_2;
    endmethod

    method Bool send_entry_rob_squash_1;
	return wr_entry_rob_squash_1;
    endmethod

    method Bool send_entry_rob_squash_2;
	return wr_entry_rob_squash_2;
    endmethod

    method Bit#(`REG_WIDTH) send_squash_buf_1;
	return wr_squash_buf_1;
    endmethod

    method Bit#(`REG_WIDTH) send_squash_buf_2;
	return wr_squash_buf_2;
    endmethod

    method Bool send_selected_for_exec_1;
	return wr_selected_for_exec_1;
    endmethod

    method Bool send_selected_for_exec_2;
	return wr_selected_for_exec_2;
    endmethod

	method TrapCause send_if_exception_1;
		return wr_entry_rob_exception_1;
	endmethod

	method TrapCause send_if_exception_2;
		return wr_entry_rob_exception_2;
	endmethod

    method Bit#(`FETCH_WIDTH) send_update_rob_tail;
	return wr_update_rob_tail;
    endmethod

    method Maybe#(Vector#(`FETCH_WIDTH, Mem_type)) allot_mem_q;
	return wr_allot_mem_q;
    endmethod

endmodule

endpackage 
