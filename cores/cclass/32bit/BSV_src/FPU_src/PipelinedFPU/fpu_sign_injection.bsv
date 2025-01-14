/*

Copyright (c) 2013, IIT Madras
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met

*  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
*  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
*  Neither the name of IIT Madras  nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Module Name 	: Floating Point Sign Injection
Author Name 	: Vinod.G, Aditya Govardhan
e-mail Id	: g.vinod1993@gmail.com, dtgovardhan@gmail.com
Last updated on : 5th January, 2016

This module performs the sign injection on the floating point value taken from the rs1 register.
The different instructions work as follows
FSGNJ : Operation bit - 000, The final result is same as that of operand1 but has the sign of operand 2's sign.
FSGNJN :  Operation bit - 001, The final result is same as that of operand 1 but has the opposite sign of operand 2's sign
FSGNJX : Operation bit - 010, The final result is same as that of operand 1 but the sign bit is the exclusive-or of operand 1 and operand 2

*/

package fpu_sign_injection;

import defined_types::*;
import FIFO::*;
import defined_types::*;
import SpecialFIFOs::*;

interface Ifc_fpu_sign_injection#(numeric type fpinp, numeric type fpman, numeric type fpexp);
	method Action _start(Bit#(fpinp) operand1, Bit#(fpinp) operand2, Bit#(3) operation, Bit#(32) fsr);
        method Action _deque_buffer_();
        method Floating_output result_();
endinterface

module mkfpu_sign_injection(Ifc_fpu_sign_injection#(fpinp,fpman,fpexp))
	provisos (
		 Add#(TAdd#(fpexp,fpman),1,fpinp),	                //Defining fpinp to be fpexp + fpman + 1
                 Add#(fpexp,2,fpexp2),
                 Add#(a__,fpinp,64)
		 );

	let fPINP  = valueOf(fpinp);
        FIFO#(Floating_output) ff_final_out <- mkPipelineFIFO();


	method Action _start(Bit#(fpinp) operand1, Bit#(fpinp) operand2, Bit#(3) operation, Bit#(32) fsr);

         if(operation == 3'b000)                           //FSGNJ
	    operand1[fPINP-1] = operand2[fPINP-1];
	 else if(operation == 3'b001)			   //FSNGNJN
	    operand1[fPINP-1] = ~operand2[fPINP-1];
	 else 						   //FSGNJX
	    operand1[fPINP-1] = operand1[fPINP-1]^operand2[fPINP-1];

		Exception lv_exception = None;
	
	ff_final_out.enq(Floating_output { 
		fsr: fsr,
		final_result : zeroExtend(operand1),
		exception : lv_exception } );

	endmethod

	method Floating_output result_(); 
	     return ff_final_out.first();
	endmethod

method Action _deque_buffer_();	
	        ff_final_out.deq();
		endmethod


endmodule

// module mkTb_fpu_sign_injection();
// Ifc_fpu_sign_injection#(32,23,8) inst_fpu_sign_injection <- mkfpu_sign_injection();
// Reg#(Bit#(32)) rg_clock <- mkReg(0);
// Reg#(Bit#(32)) rg_operand1<-mkReg('hff800000); 
// Reg#(Bit#(32)) rg_operand2<-mkReg('hff800000); 

// rule get_input(rg_clock == 0);
// inst_fpu_sign_injection._start(rg_operand1,rg_operand2,'b000);
// rg_clock <= rg_clock + 1;
// endrule

// rule get_output;
// let lv_result = inst_fpu_sign_injection.result_();  
// $display("Result is: %h",lv_result.final_result);
// $display("Sign=%b Exponent=%b Mantissa=%b",lv_result.final_result[31],lv_result.final_result[30:23],lv_result.final_result[22:0]);
// $finish(0);
// endrule



// endmodule		 

     

endpackage
