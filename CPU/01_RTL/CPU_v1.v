//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2021 Final Project: Customized ISA Processor 
//   Author              : Hsi-Hao Huang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : CPU.v
//   Module Name : CPU.v
//   Release version : V1.0 (Release Date: 2021-May)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module CPU(

				clk,
			  rst_n,
  
		   IO_stall,

         awid_m_inf,
       awaddr_m_inf,
       awsize_m_inf,
      awburst_m_inf,
        awlen_m_inf,
      awvalid_m_inf,
      awready_m_inf,
                    
        wdata_m_inf,
        wlast_m_inf,
       wvalid_m_inf,
       wready_m_inf,
                    
          bid_m_inf,
        bresp_m_inf,
       bvalid_m_inf,
       bready_m_inf,
                    
         arid_m_inf,
       araddr_m_inf,
        arlen_m_inf,
       arsize_m_inf,
      arburst_m_inf,
      arvalid_m_inf,
                    
      arready_m_inf, 
          rid_m_inf,
        rdata_m_inf,
        rresp_m_inf,
        rlast_m_inf,
       rvalid_m_inf,
       rready_m_inf 

);
// Input port
input  wire clk, rst_n;
// Output port
output reg  IO_stall;

parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=2, WRIT_NUMBER=1;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
  your AXI-4 interface could be designed as convertor in submodule(which used reg for output signal),
  therefore I declared output of AXI as wire in CPU
*/



// axi write address channel 
output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf;
output  wire [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf;
output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf;
output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf;
output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf;
output  wire [WRIT_NUMBER-1:0]                awvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                awready_m_inf;
// axi write data channel 
output  wire [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf;
output  wire [WRIT_NUMBER-1:0]                  wlast_m_inf;
output  wire [WRIT_NUMBER-1:0]                 wvalid_m_inf;
input   wire [WRIT_NUMBER-1:0]                 wready_m_inf;
// axi write response channel
input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf;
input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf;
input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf;
output  wire [WRIT_NUMBER-1:0]                 bready_m_inf;
// -----------------------------
// axi read address channel 
output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf;
output  wire [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf;
output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf;
output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf;
output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf;
output  wire [DRAM_NUMBER-1:0]               arvalid_m_inf;
input   wire [DRAM_NUMBER-1:0]               arready_m_inf;
// -----------------------------
// axi read data channel 
input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf;
input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf;
input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf;
input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf;
input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf;
output  wire [DRAM_NUMBER-1:0]                 rready_m_inf;
// -----------------------------

//
//
// 
/* Register in each core:
  There are sixteen registers in your CPU. You should not change the name of those registers.
  TA will check the value in each register when your core is not busy.
  If you change the name of registers below, you must get the fail in this lab.
*/

reg signed [15:0] core_r0 , core_r1 , core_r2 , core_r3 ;
reg signed [15:0] core_r4 , core_r5 , core_r6 , core_r7 ;
reg signed [15:0] core_r8 , core_r9 , core_r10, core_r11;
reg signed [15:0] core_r12, core_r13, core_r14, core_r15;
reg signed [15:0] reg_file [0:15];
always @(*) begin
  core_r0 = reg_file[0];
  core_r1 = reg_file[1];
  core_r2 = reg_file[2];
  core_r3 = reg_file[3];
  core_r4 = reg_file[4];
  core_r5 = reg_file[5];
  core_r6 = reg_file[6];
  core_r7 = reg_file[7];
  core_r8 = reg_file[8];
  core_r9 = reg_file[9];
  core_r10 = reg_file[10];
  core_r11 = reg_file[11];
  core_r12 = reg_file[12];
  core_r13 = reg_file[13];
  core_r14 = reg_file[14];
  core_r15 = reg_file[15];
end
//###########################################
//
// Wrtie down your design below
//
//###########################################

//####################################################
//               reg & wire
//####################################################
reg   [1:0]   load_store;
wire  i_cpu_stall, d_cpu_stall;
wire  [6:0]   IM_addr, DM_addr;
wire  [15:0]  IM_di, IM_do, DM_di, DM_do;
wire          IM_web, DM_web;
// IF STAGE
reg [15:0] IF_pc, pc_jump, pc_branch;
wire [15:0] pc_next;
wire [15:0] IF_inst;
reg [1:0] pc_src;
wire       pc_stall;
// IF/ID
reg [15:0] IF_ID_pc, IF_ID_inst;
reg        IF_ID_stall, IF_ID_stall_ff;
reg        IF_ID_flush, IF_ID_flush_ff;
// ID STAGE
reg [15:0] ID_inst;
reg signed [15:0] ID_rs_data, ID_rt_data;
reg [15:0] WB_write_data;
integer i;
// decoder
wire [2:0]  ID_opcode;
wire [3:0]  ID_rs, ID_rt, ID_rd;
wire        ID_func;
wire signed [15:0]  ID_imm;
wire [12:0] ID_addr; 
// controller
reg ID_RegWrite, ID_MemtoReg, ID_MemWrite, ID_ALUsrc, ID_jump, ID_branch, ID_dst_src, ID_MemRead, ID_use_rs, ID_use_rt, ID_inst_valid;
reg [3:0] ID_reg_dst;
reg [1:0] ID_ALUop; 
// ID/EXE
reg ID_EXE_RegWrite, ID_EXE_MemtoReg, ID_EXE_MemWrite, ID_EXE_MemRead, ID_EXE_ALUsrc, ID_EXE_jump, ID_EXE_branch, ID_EXE_dst_src;
reg [3:0] ID_EXE_reg_dst, ID_EXE_rs, ID_EXE_rt;
reg [1:0] ID_EXE_ALUop; 
reg [15:0] ID_EXE_rs_data, ID_EXE_rt_data;
reg [15:0] ID_EXE_pc;
reg [15:0] ID_EXE_imm;
reg [12:0] ID_EXE_addr;
wire ID_EXE_stall;
wire ID_EXE_flush;
// EXE STAGE
reg [15:0] forwarding_rs_data1, forwarding_rs_data2;
reg [15:0] forwarding_rt_data1, forwarding_rt_data2; 
reg [1:0] forwarding_rs_sel, forwarding_rt_sel;
reg signed [15:0] alu_in_1, alu_in_2, alu_out;
reg [15:0] rt_data, rs_data;
reg EXE_inst_valid;
// BRANCH
wire branch_taken;
// EXE/MEM
reg [15:0] EX_MEM_alu_out, EX_MEM_rt_data;
reg [3:0] EX_MEM_reg_dst;
reg EX_MEM_RegWrite, EX_MEM_MemtoReg, EX_MEM_MemWrite, EX_MEM_MemRead, EX_MEM_dst_src, EX_MEM_inst_valid;
wire EX_MEM_stall;
// MEM/WB
reg [15:0] MEM_WB_alu_out, MEM_WB_mem_out;
reg [3:0] MEM_WB_reg_dst;
reg       MEM_WB_MemtoReg, MEM_WB_RegWrite;
reg MEM_WB_inst_valid, MEM_WB_inst_valid_ff;
wire MEM_WB_stall;
reg MEM_WB_stall_ff;
// FORWARDING
wire EX_hazard_rs, MEM_hazard_rs;
wire EX_hazard_rt, MEM_hazard_rt;
// HAZARD
wire load_use;
// AXI
wire  cpu_stall;
assign cpu_stall = i_cpu_stall || d_cpu_stall;
reg cpu_stall_ff;
reg [15:0] fetch_addr, write_data;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    cpu_stall_ff <= 0;
  else
    cpu_stall_ff <= cpu_stall;
end
// IO stall counter
reg [3:0] IO_stall_cnt;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    IO_stall_cnt <= 0;
  else if (!IO_stall) begin
    if (IO_stall_cnt == 'd10)
      IO_stall_cnt <= 0;
    else
      IO_stall_cnt <= IO_stall_cnt + 'd1;
  end 
  else
    IO_stall_cnt <= IO_stall_cnt;
end
// // FSM
// reg c_state, n_state;
// localparam NORMAL = 1'd0, CHECK = 1'd1;
// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n)
//     c_state <= NORMAL;
//   else
//     c_state <= n_state;
// end
// always @(*) begin
//   case(c_state)
//     NORMAL: begin
//       if (MEM_WB_inst_valid)
//         n_state = CHECK;
//       else
//         n_state = NORMAL;
//     end
//     CHECK: begin
//       n_state = NORMAL;
//     end
//     default: n_state = NORMAL;
//   endcase 
// end
//====================================================
//                     IF STAGE
//====================================================

assign pc_stall = load_use || cpu_stall || IO_stall & MEM_WB_inst_valid; 
// program couter
assign pc_next = IF_pc + 'd2;
assign IF_inst = IM_do;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      IF_pc <= 16'h1000;
    else if (pc_stall)
      IF_pc <= IF_pc;
    else begin
      if (pc_src == 1)
        IF_pc <= pc_branch;
      else if (pc_src == 2)
        IF_pc <= pc_jump;
      else  
        IF_pc <= pc_next;
    end
end
//====================================================
//                      IF/ID
//====================================================

always @(*) begin
  IF_ID_stall = load_use || cpu_stall || IO_stall & MEM_WB_inst_valid;
  IF_ID_flush = (branch_taken && ID_EXE_branch) || (ID_EXE_jump);
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      IF_ID_stall_ff <= 0;
      IF_ID_flush_ff <= 0;
    end
    else begin
      IF_ID_stall_ff <= IF_ID_stall;
      IF_ID_flush_ff <= IF_ID_flush;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      IF_ID_pc <= 0;
      IF_ID_inst <= 0;
    end
    else if (IF_ID_flush) begin
      IF_ID_inst <= {{4{1'b1}}, 12'b0};
      IF_ID_pc <= 0;
    end
    else if (cpu_stall & (IF_pc == 16'h1000)) begin
      IF_ID_inst <= {{4{1'b1}}, 12'b0};
      IF_ID_pc <= 0;
    end
    else if ((IF_ID_stall & IF_ID_stall_ff) || (IF_ID_flush_ff & IF_ID_stall)) begin
      IF_ID_inst <= IF_ID_inst;
      IF_ID_pc <= IF_ID_pc;
    end
    else if (IF_ID_stall) begin
      IF_ID_inst <= IF_inst;
      IF_ID_pc <= IF_ID_pc;
    end
    else begin
      IF_ID_pc <= IF_pc;
      IF_ID_inst <= IF_inst;
    end
end
//====================================================
//                     ID STAGE
//====================================================

always @(*) begin
    if (IF_ID_stall_ff || IF_ID_flush_ff)
      ID_inst = IF_ID_inst;
    else
      ID_inst = IF_inst;
end
// decoder
assign ID_opcode = ID_inst[15:13];
assign ID_rs = ID_inst[12:9];
assign ID_rt = ID_inst[8:5];
assign ID_rd = ID_inst[4:1];
assign ID_func = ID_inst[0];
assign ID_imm = {{11{ID_inst[4]}}, ID_inst[4:0]};
assign ID_addr = ID_inst[12:0];
// register file
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    for (i = 0; i < 16; i = i + 1) begin
      reg_file[i] <= 0;
    end
  end
  // else if (!IO_stall) begin
  //   for (i = 0; i < 16; i = i + 1) begin
  //     reg_file[i] <= reg_file[i];
  //   end
  // end
  else if (MEM_WB_RegWrite)
    reg_file[MEM_WB_reg_dst] <= WB_write_data;
  else begin
    for (i = 0; i < 16; i = i + 1) begin
      reg_file[i] <= reg_file[i];
    end
  end
end
// rs data, rt data
always @(*) begin
  if (MEM_WB_RegWrite && MEM_WB_reg_dst == ID_rs)
    ID_rs_data = WB_write_data;
  else
    ID_rs_data = reg_file[ID_rs];
end
always @(*) begin
  if (MEM_WB_RegWrite && MEM_WB_reg_dst == ID_rt)
    ID_rt_data = WB_write_data;
  else
    ID_rt_data = reg_file[ID_rt];
end
// controller
always @(*) begin
  if (ID_opcode == 3'b000) begin
    if (ID_func)
      ID_ALUop = 'd0; //SUB
    else
      ID_ALUop = 'd1; // ADD
  end
  else if (ID_opcode == 3'b001) begin
    if (ID_func)
      ID_ALUop = 'd3; // Set Less than
    else
      ID_ALUop = 'd2; // Mult
  end 
  else
    ID_ALUop = 'd1;
end
always @(*) begin
  if (ID_opcode == 3'b010 || ID_opcode == 3'b011)
    ID_ALUsrc = 1;
  else
    ID_ALUsrc = 0;
end
always @(*) begin
  if (!(ID_opcode[2] || (ID_opcode[1] & ID_opcode[0])))
    ID_RegWrite = 1;
  else
    ID_RegWrite = 0;
end
always @(*) begin
  if (ID_opcode  == 3'b010)
    ID_MemtoReg = 1;
  else
    ID_MemtoReg = 0;
end
always @(*) begin
  if (ID_opcode == 3'b011)
    ID_MemWrite = 1;
  else
    ID_MemWrite = 0;
end
always @(*) begin
  if (ID_opcode == 'd011)
    ID_MemRead = 1;
  else
    ID_MemRead = 0;
end
always @(*) begin
  if (ID_opcode[2] & !ID_opcode[0])
    ID_branch = 1;
  else
    ID_branch = 0;
end
always @(*) begin
  if (ID_opcode == 3'b101)
    ID_jump = 1;
  else
    ID_jump = 0;
end
always @(*) begin
  if (ID_opcode == 3'b010)
    ID_reg_dst = ID_rt;
  else
    ID_reg_dst = ID_rd;
end
always @(*) begin
  if (ID_opcode == 3'b001)
    ID_dst_src = 0;
  else
    ID_dst_src = 1;
end
always @(*) begin
  if (ID_opcode[2] && ID_opcode[0]) // only jump won't use rs
    ID_use_rs = 0;
  else
    ID_use_rs = 1;
end
always @(*) begin
  if (!(ID_opcode[2] | ID_opcode[1]) || (ID_opcode == 3'b100))
    ID_use_rt = 1;
  else
    ID_use_rt = 0;
end
//====================================================
//                      ID/EXE
//====================================================

assign ID_EXE_stall = cpu_stall || IO_stall & MEM_WB_inst_valid;
assign ID_EXE_flush = (ID_EXE_branch & branch_taken) || (ID_EXE_jump);
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    ID_EXE_RegWrite <= 0;
    ID_EXE_MemtoReg <= 0;
    ID_EXE_MemWrite <= 0;
    ID_EXE_MemRead <= 0;
    ID_EXE_ALUsrc <= 0;
    ID_EXE_jump <= 0;
    ID_EXE_branch <= 0;
    ID_EXE_dst_src <= 0;
    ID_EXE_reg_dst <= 0;
    ID_EXE_rs <= 0;
    ID_EXE_rt <= 0;
    ID_EXE_ALUop <= 0;
    ID_EXE_rs_data <= 0;
    ID_EXE_rt_data <= 0;
    ID_EXE_pc <= 0;
    ID_EXE_imm <= 0;
    ID_EXE_addr <= 0;
  end
  else if (ID_EXE_stall) begin
    ID_EXE_RegWrite <= ID_EXE_RegWrite;
    ID_EXE_MemtoReg <= ID_EXE_MemtoReg;
    ID_EXE_MemWrite <= ID_EXE_MemWrite;
    ID_EXE_MemRead <= ID_EXE_MemRead;
    ID_EXE_ALUsrc <= ID_EXE_ALUsrc;
    ID_EXE_jump <= ID_EXE_jump;
    ID_EXE_branch <= ID_EXE_branch;
    ID_EXE_dst_src <= ID_EXE_dst_src;
    ID_EXE_reg_dst <= ID_EXE_reg_dst;
    ID_EXE_rs <= ID_EXE_rs;
    ID_EXE_rt <= ID_EXE_rt;
    ID_EXE_ALUop <= ID_EXE_ALUop;
    ID_EXE_rs_data <= ID_EXE_rs_data;
    ID_EXE_rt_data <= ID_EXE_rt_data;
    ID_EXE_pc <= ID_EXE_pc;
    ID_EXE_imm <= ID_EXE_imm;
    ID_EXE_addr <= ID_EXE_addr;
  end
  else if (ID_EXE_flush || load_use) begin
    ID_EXE_RegWrite <= 0;
    ID_EXE_MemtoReg <= 0;
    ID_EXE_MemWrite <= 0;
    ID_EXE_MemRead <= 0;
    ID_EXE_ALUsrc <= 0;
    ID_EXE_jump <= 0;
    ID_EXE_branch <= 0;
    ID_EXE_dst_src <= 0;
    ID_EXE_reg_dst <= 0;
    ID_EXE_rs <= 0;
    ID_EXE_rt <= 0;
    ID_EXE_ALUop <= 0;
    ID_EXE_rs_data <= 0;
    ID_EXE_rt_data <= 0;
    ID_EXE_pc <= 0;
    ID_EXE_imm <=0;
    ID_EXE_addr <= 0;
  end
  else begin
    ID_EXE_RegWrite <= ID_RegWrite;
    ID_EXE_MemtoReg <= ID_MemtoReg;
    ID_EXE_MemWrite <= ID_MemWrite;
    ID_EXE_MemRead <= ID_MemRead;
    ID_EXE_ALUsrc <= ID_ALUsrc;
    ID_EXE_jump <= ID_jump;
    ID_EXE_branch <= ID_branch;
    ID_EXE_dst_src <= ID_dst_src;
    ID_EXE_reg_dst <= ID_reg_dst;
    ID_EXE_rs <= ID_rs;
    ID_EXE_rt <= ID_rt;
    ID_EXE_ALUop <= ID_ALUop;
    ID_EXE_rs_data <= ID_rs_data;
    ID_EXE_rt_data <= ID_rt_data;
    ID_EXE_pc <= IF_ID_pc;
    ID_EXE_imm <= ID_imm;
    ID_EXE_addr <= ID_addr;
  end
end
//====================================================
//                    EXE STAGE
//====================================================

// ALU
always @(*) begin
  if (forwarding_rs_sel == 2)
    rs_data = WB_write_data;
  else if (forwarding_rs_sel == 1)
    rs_data = EX_MEM_alu_out;
  else
    rs_data = ID_EXE_rs_data;
end
always @(*) begin
  alu_in_1 = rs_data;
end
always @(*) begin
  if (forwarding_rt_sel == 2)
    rt_data = WB_write_data;
  else if (forwarding_rt_sel == 1)
    rt_data = EX_MEM_alu_out;
  else
    rt_data = ID_EXE_rt_data;
end
always @(*) begin
  if (ID_EXE_ALUsrc)
    alu_in_2 = ID_EXE_imm;
  else
    alu_in_2 = rt_data;
end
always @(*) begin
  case(ID_EXE_ALUop)
    'd0:begin
      alu_out = alu_in_1 - alu_in_2;
    end
    'd1: begin
      alu_out = alu_in_1 + alu_in_2;
    end
    'd2: begin
      alu_out = (alu_in_1 < alu_in_2);
    end
    'd3: begin
      alu_out = alu_in_1 * alu_in_2;
    end
    default: begin
      alu_out = 0;
    end
  endcase
end
// BRANCH
assign branch_taken = (rs_data == rt_data);
always @(*) begin
  if (ID_EXE_jump)
    pc_src = 'd2;
  else if (ID_EXE_branch & branch_taken)
    pc_src = 'd1;
  else
    pc_src = 0;
end
always @(*) begin
  pc_branch = $signed(ID_EXE_pc) + ((15'd1 + $signed(ID_EXE_imm)) <<< 1);
  pc_jump = {3'b000, ID_EXE_addr};
end
always @(*) begin
  if (ID_EXE_RegWrite | ID_EXE_MemtoReg | ID_EXE_MemWrite | ID_EXE_jump | ID_EXE_branch)
    EXE_inst_valid = 1;
  else
    EXE_inst_valid = 0;
end
//====================================================
//                      EXE/MEM
//====================================================

assign EX_MEM_stall = cpu_stall || IO_stall & MEM_WB_inst_valid;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    EX_MEM_alu_out <= 0;
    EX_MEM_rt_data <= 0;
    EX_MEM_reg_dst <= 0;
    EX_MEM_RegWrite <= 0;
    EX_MEM_MemtoReg <= 0;
    EX_MEM_MemWrite <= 0;
    EX_MEM_MemRead <= 0;
    EX_MEM_dst_src <= 0;
    EX_MEM_inst_valid <= 0;
  end
  else if (EX_MEM_stall) begin
    EX_MEM_alu_out <= EX_MEM_alu_out;
    EX_MEM_rt_data <= EX_MEM_rt_data;
    EX_MEM_reg_dst <= EX_MEM_reg_dst;
    EX_MEM_RegWrite <= EX_MEM_RegWrite;
    EX_MEM_MemtoReg <= EX_MEM_MemtoReg;
    EX_MEM_MemWrite <= EX_MEM_MemWrite;
    EX_MEM_MemRead <= EX_MEM_MemRead;
    EX_MEM_dst_src <= EX_MEM_dst_src;
    EX_MEM_inst_valid <= EX_MEM_inst_valid;
  end
  else begin
    EX_MEM_alu_out <= alu_out;
    EX_MEM_rt_data <= rt_data;
    EX_MEM_reg_dst <= ID_EXE_reg_dst;
    EX_MEM_RegWrite <= ID_EXE_RegWrite;
    EX_MEM_MemtoReg <= ID_EXE_MemtoReg;
    EX_MEM_MemWrite <= ID_EXE_MemWrite;
    EX_MEM_MemRead <= ID_EXE_MemRead;
    EX_MEM_dst_src <= ID_EXE_dst_src;
    EX_MEM_inst_valid <= EXE_inst_valid;
  end
end 
//====================================================
//                    MEM STAGE
//====================================================

always @(*) begin
  fetch_addr = EX_MEM_alu_out <<< 1;
  write_data = EX_MEM_rt_data;
  load_store = {EX_MEM_MemtoReg, EX_MEM_MemWrite};
end
//====================================================
//                      MEM/WB
//====================================================

assign MEM_WB_stall = cpu_stall || IO_stall & MEM_WB_inst_valid;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    MEM_WB_stall_ff <= 0;
  else
    MEM_WB_stall_ff <= MEM_WB_stall;
end
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    MEM_WB_alu_out <= 0;
    MEM_WB_reg_dst <= 0;
    MEM_WB_MemtoReg <= 0;
    MEM_WB_RegWrite <= 0;
    MEM_WB_mem_out <= 0;
    // MEM_WB_inst_valid <= 0;
  end
  else if (MEM_WB_stall & MEM_WB_stall_ff) begin
    MEM_WB_alu_out <= MEM_WB_alu_out;
    MEM_WB_reg_dst <= MEM_WB_reg_dst;
    MEM_WB_MemtoReg <= MEM_WB_MemtoReg;
    MEM_WB_RegWrite <= MEM_WB_RegWrite;
    MEM_WB_mem_out <= MEM_WB_mem_out;
    // MEM_WB_inst_valid <= MEM_WB_inst_valid;
  end
  else if (MEM_WB_stall) begin
    MEM_WB_alu_out <= MEM_WB_alu_out;
    MEM_WB_reg_dst <= MEM_WB_reg_dst;
    MEM_WB_MemtoReg <= MEM_WB_MemtoReg;
    MEM_WB_RegWrite <= MEM_WB_RegWrite;
    MEM_WB_mem_out <= DM_do;
    // MEM_WB_inst_valid <= MEM_WB_inst_valid;
  end
  else begin
    MEM_WB_alu_out <= EX_MEM_alu_out;
    MEM_WB_reg_dst <= EX_MEM_reg_dst;
    MEM_WB_MemtoReg <= EX_MEM_MemtoReg;
    MEM_WB_RegWrite <= EX_MEM_RegWrite;
    MEM_WB_mem_out <= DM_do;
    // MEM_WB_inst_valid <= EX_MEM_inst_valid;
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    MEM_WB_inst_valid <= 0;
  else if ((IO_stall & MEM_WB_inst_valid) | cpu_stall)
    MEM_WB_inst_valid <= 0;
  else
    MEM_WB_inst_valid <= EX_MEM_inst_valid;
end
//====================================================
//                     WB STAGE
//====================================================
always @(*) begin
  if (MEM_WB_MemtoReg) begin
    if (MEM_WB_stall_ff)
      WB_write_data = MEM_WB_mem_out;
    else
      WB_write_data = DM_do;
  end
  else
    WB_write_data = MEM_WB_alu_out;
end
//====================================================
//                FORWARDING UNIT
//====================================================
assign EX_hazard_rs = (ID_EXE_rs == EX_MEM_reg_dst) && EX_MEM_RegWrite;
assign MEM_hazard_rs = (ID_EXE_rs == MEM_WB_reg_dst) && MEM_WB_RegWrite && !EX_hazard_rs;
assign EX_hazard_rt = (ID_EXE_rt == EX_MEM_reg_dst) && EX_MEM_RegWrite;
assign MEM_hazard_rt = (ID_EXE_rt == MEM_WB_reg_dst) && MEM_WB_RegWrite && !EX_hazard_rt;
always @(*) begin
  if (EX_hazard_rs)
    forwarding_rs_sel = 'd1;
  else if (MEM_hazard_rs)
    forwarding_rs_sel = 'd2;
  else
    forwarding_rs_sel = 'd0;
end
always @(*) begin
  if (EX_hazard_rt)
    forwarding_rt_sel = 'd1;
  else if (MEM_hazard_rt)
    forwarding_rt_sel = 'd2;
  else
    forwarding_rt_sel = 'd0;
end
//====================================================
//                 HAZARD DETECTION
//====================================================
assign load_use = (((ID_rs == ID_EXE_reg_dst) & ID_use_rs) || ((ID_rt == ID_EXE_reg_dst) & ID_use_rt)) && ID_EXE_MemtoReg;
//====================================================
//                   CHECK STATE
//====================================================
always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    MEM_WB_inst_valid_ff <= 0;
  else
    MEM_WB_inst_valid_ff <= MEM_WB_inst_valid;
end
always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    IO_stall <= 1;
  // else if (!IO_stall)
  //   IO_stall <= 1;
  else
    IO_stall <= !MEM_WB_inst_valid;
end 
// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n)
//     IO_stall <= 1'b1;
//   else if (MEM_WB_stall)
//     IO_stall <= 1'b1;
//   else if (MEM_WB_inst_valid)
//     IO_stall <= 1'b0;
//   else
//     IO_stall <= 1'b1;
// end
//====================================================
//                   AXI4 interface
//====================================================
I_Cache_Wrapper I_Cache_Wrapper(// clk & reset
                                .clk(clk), .rst_n(rst_n), 
                                // cpu_signal
                                .IF_pc(IF_pc), .cpu_stall(i_cpu_stall), 
                                // AXI read address channel
                                .arid_m_inf(arid_m_inf[7:4]), .arlen_m_inf(arlen_m_inf[13:7]), .arsize_m_inf(arsize_m_inf[5:3]), .arburst_m_inf(arburst_m_inf[3:2]), 
                                .araddr_m_inf(araddr_m_inf[63:32]), .arvalid_m_inf(arvalid_m_inf[1]),.arready_m_inf(arready_m_inf[1]), 
                                // AXI4 read data channel
                                .rid_m_inf(rid_m_inf[7:4]), 
                                .rdata_m_inf(rdata_m_inf[31:16]), .rresp_m_inf(rresp_m_inf[3:2]), .rlast_m_inf(rlast_m_inf[1]), .rvalid_m_inf(rvalid_m_inf[1]), .rready_m_inf(rready_m_inf[1]),
                                // sram interface
                                .IM_addr(IM_addr), .IM_di(IM_di), .IM_web(IM_web)
);
SRAM_wrapper I_Cache(.ADDR(IM_addr), .DI(IM_di), .CK(clk), .WEB(IM_web), .OE(1'b1), .CS(1'b1), .DO(IM_do));

D_Cache_Wrapper D_Cache_Wrapper(// clk & reset
                                .clk(clk), .rst_n(rst_n), 
                                // cpu signal
                                .fetch_addr({20'h00001, fetch_addr[11:0]}), .write_data(write_data), .load_store(load_store), .cpu_stall(d_cpu_stall), .IO_stall_cnt(IO_stall_cnt),
                                // AXI4 write address channel
                                .awid_m_inf(awid_m_inf), .awsize_m_inf(awsize_m_inf), .awburst_m_inf(awburst_m_inf), .awlen_m_inf(awlen_m_inf), 
                                .awaddr_m_inf(awaddr_m_inf), .awvalid_m_inf(awvalid_m_inf), .awready_m_inf(awready_m_inf),
                                // AXI4 write data channel
                                .wdata_m_inf(wdata_m_inf), .wlast_m_inf(wlast_m_inf), .wvalid_m_inf(wvalid_m_inf), .wready_m_inf(wready_m_inf),
                                // AXI write response
                                .bid_m_inf(bid_m_inf), .bresp_m_inf(bresp_m_inf), .bvalid_m_inf(bvalid_m_inf), .bready_m_inf(bready_m_inf),
                                // AXI read address channel
                                .arid_m_inf(arid_m_inf[3:0]), .araddr_m_inf(araddr_m_inf[31:0]), .arlen_m_inf(arlen_m_inf[6:0]), .arsize_m_inf(arsize_m_inf[2:0]), .arburst_m_inf(arburst_m_inf[1:0]), .arvalid_m_inf(arvalid_m_inf[0]),
                                // AXI4 read data channel
                                .arready_m_inf(arready_m_inf[0]), .rid_m_inf(rid_m_inf[3:0]), .rdata_m_inf(rdata_m_inf[15:0]), .rresp_m_inf(rresp_m_inf[1:0]), .rlast_m_inf(rlast_m_inf[0]), .rvalid_m_inf(rvalid_m_inf[0]), .rready_m_inf(rready_m_inf[0]),
                                // sram interface
                                .DM_addr(DM_addr), .DM_web(DM_web), .DM_di(DM_di), .DM_do(DM_do)
);
SRAM_wrapper D_Cache(.ADDR(DM_addr), .DI(DM_di), .CK(clk), .WEB(DM_web), .OE(1'b1), .CS(1'b1), .DO(DM_do)); 
endmodule


module I_Cache_Wrapper #(
  parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, DRAM_NUMBER=1
) (
  input   wire clk,
  input   wire rst_n,
  // read request(miss signal) & stall signal
  input [15:0] IF_pc,
  output       cpu_stall,
  // axi read address channel 
  output  wire  [ID_WIDTH-1:0]       arid_m_inf,
  output  reg  [ADDR_WIDTH-1:0]   araddr_m_inf,
  output  wire  [6:0]               arlen_m_inf,
  output  wire  [2:0]              arsize_m_inf,
  output  wire  [1:0]             arburst_m_inf,
  output  reg                    arvalid_m_inf,
  input   wire                   arready_m_inf,
  // axi read data channel 
  input   wire [ID_WIDTH-1:0]        rid_m_inf,
  input   wire [DATA_WIDTH-1:0]    rdata_m_inf,
  input   wire [1:0]               rresp_m_inf,
  input   wire                     rlast_m_inf,
  input   wire                    rvalid_m_inf,
  output  reg                     rready_m_inf,
  // sram controll
  output reg [6:0]   IM_addr,
  output reg [15:0]  IM_di,
  output reg         IM_web
);

localparam IDLE = 2'b00,
           SEND_ARADDR = 2'b01,
           READ_DATA = 2'b10,
           WAIT = 2'b11;

reg [1:0]   c_state, n_state;
reg         i_miss, i_valid;
reg [7:0]   i_tag;
reg [6:0]   i_cnt;
// //=============================================
// //              SRAM INTERFACE
// //=============================================
// SRAM_wrapper IM(.ADDR(IM_addr), .DI(IM_di), .CK(clk), .WEB(IM_web), .OE(1'b1), .CS(1'b1), .DO(IM_do));
always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    i_tag <= 9'b000100000;
  else if (c_state == SEND_ARADDR)
    i_tag <= araddr_m_inf[15:8];
  else
    i_tag <= i_tag;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    i_valid <= 0;
  else if (c_state == SEND_ARADDR)
    i_valid <= 1;
  else
    i_valid <= i_valid;
end

always @(*) begin
  i_miss = (i_tag !== IF_pc[15:8] | !i_valid) & (IF_pc[15:12] != 4'b0010);
end

always @(*) begin
  if (c_state == IDLE)
    IM_addr = IF_pc[7:1];
  else
    IM_addr = i_cnt;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    i_cnt <= 0;
  else if (c_state == READ_DATA)
    if (rvalid_m_inf)
      i_cnt <= i_cnt + 'd1;
    else
      i_cnt <= i_cnt;
  else
    i_cnt <= 'd0;
end

always @(*) begin
  if (c_state == READ_DATA && rvalid_m_inf) begin
    IM_web = 1'b0;
    IM_di = rdata_m_inf;
  end
  else begin
    IM_web = 1'b1;
    IM_di = 'd0;
  end
end
//=============================================
//               AXI INTERFACE
//=============================================
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) 
      c_state <= IDLE;
  else  
      c_state <= n_state;
end

always @(*) begin
    case(c_state)
      IDLE: begin
        if (i_miss)
          n_state = SEND_ARADDR;
        else
          n_state = IDLE;
      end
      SEND_ARADDR: begin
        if (arready_m_inf)
          n_state = READ_DATA;
        else
          n_state = SEND_ARADDR;
      end
      READ_DATA: begin
        if (rlast_m_inf)
          n_state = IDLE;
        else
          n_state = READ_DATA;
      end
      WAIT: begin
        n_state = IDLE;
      end
      default: n_state = IDLE;
    endcase
end

assign cpu_stall = ((c_state !== IDLE) || ((c_state == IDLE) & i_miss));


assign arid_m_inf = 0;
assign arlen_m_inf ='d127;
assign arsize_m_inf = 3'b001;
assign arburst_m_inf = 2'b01; 


always @(*) begin
  if (c_state == SEND_ARADDR) begin
    araddr_m_inf = {16'b0, IF_pc[15:8], 8'b0};
    arvalid_m_inf = 1'b1;
  end
  else begin
    araddr_m_inf = 32'b0;
    arvalid_m_inf = 1'b0;
  end
end

always @(*) begin
  if (c_state == READ_DATA)
    rready_m_inf = 1'b1;
  else  
    rready_m_inf = 1'b0;
end
endmodule

module D_Cache_Wrapper #(
  parameter ID_WIDTH = 4 , ADDR_WIDTH = 32, DATA_WIDTH = 16, WRIT_NUMBER = 1, DRAM_NUMBER = 1
) (
  input   wire clk,
  input   wire rst_n,
  // read request(miss signal) & stall signal
  input   wire [31:0] fetch_addr,
  input   wire [15:0] write_data,
  input   wire [1:0]  load_store,
  output  wire        cpu_stall,
  input   wire [3:0]  IO_stall_cnt,
  // axi write address channel 
  output  wire [WRIT_NUMBER * ID_WIDTH-1:0]        awid_m_inf,
  output  reg [WRIT_NUMBER * ADDR_WIDTH-1:0]    awaddr_m_inf,
  output  wire [WRIT_NUMBER * 3 -1:0]            awsize_m_inf,
  output  wire [WRIT_NUMBER * 2 -1:0]           awburst_m_inf,
  output  wire [WRIT_NUMBER * 7 -1:0]             awlen_m_inf,
  output  reg [WRIT_NUMBER-1:0]                awvalid_m_inf,
  input   wire [WRIT_NUMBER-1:0]                awready_m_inf,
  // axi write data channel 
  output  reg [WRIT_NUMBER * DATA_WIDTH-1:0]     wdata_m_inf,
  output  reg [WRIT_NUMBER-1:0]                  wlast_m_inf,
  output  reg [WRIT_NUMBER-1:0]                 wvalid_m_inf,
  input   wire [WRIT_NUMBER-1:0]                 wready_m_inf,
  // axi write response channel
  input   wire [WRIT_NUMBER * ID_WIDTH-1:0]         bid_m_inf,
  input   wire [WRIT_NUMBER * 2 -1:0]             bresp_m_inf,
  input   wire [WRIT_NUMBER-1:0]             	   bvalid_m_inf,
  output  reg [WRIT_NUMBER-1:0]                 bready_m_inf,
  // -----------------------------
  // axi read address channel 
  output  wire [DRAM_NUMBER * ID_WIDTH-1:0]       arid_m_inf,
  output  reg [DRAM_NUMBER * ADDR_WIDTH-1:0]   araddr_m_inf,
  output  wire [DRAM_NUMBER * 7 -1:0]            arlen_m_inf,
  output  wire [DRAM_NUMBER * 3 -1:0]           arsize_m_inf,
  output  wire [DRAM_NUMBER * 2 -1:0]          arburst_m_inf,
  output  reg [DRAM_NUMBER-1:0]               arvalid_m_inf,
  input   wire [DRAM_NUMBER-1:0]               arready_m_inf,
  // -----------------------------
  // axi read data channel 
  input   wire [DRAM_NUMBER * ID_WIDTH-1:0]         rid_m_inf,
  input   wire [DRAM_NUMBER * DATA_WIDTH-1:0]     rdata_m_inf,
  input   wire [DRAM_NUMBER * 2 -1:0]             rresp_m_inf,
  input   wire [DRAM_NUMBER-1:0]                  rlast_m_inf,
  input   wire [DRAM_NUMBER-1:0]                 rvalid_m_inf,
  output  reg [DRAM_NUMBER-1:0]                 rready_m_inf,
  // -----------------------------
  // SRAM controll
  output  reg [6:0]   DM_addr,
  output  reg [15:0]  DM_di,
  output  reg         DM_web,
  input   wire [15:0]  DM_do
);
// using write through(write data to cache and dram) & write no allocate(if miss only write dram)
localparam IDLE = 3'b000,
           SEND_AWADDR = 3'b001,
           WRITE_DATA = 3'b010,
           WAIT_BREP = 3'b011,
           SEND_ARADDR = 3'b100,
           READ_DATA = 3'b101,
           RESTART = 3'b110;

reg   [2:0] c_state, n_state;
reg   [6:0] d_cnt;
wire  [6:0] d_cnt_pulse;
reg   [7:0] d_tag; 
reg         d_miss, d_valid;
//================================================
//                SRAM INTERFACE
//================================================
// always @(posedge clk or negedge rst_n) begin
//   if (!rst_n)
//     d_dirty <= 0;
//   else if (c_state == IDLE && load_store[0])
//     d_dirty <= 1;
//   else if (c_state == SEND_AWADDR)
//     d_dirty <= 0;
//   else
//     d_dirty <= d_dirty;
// end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    d_valid <= 0;
  else if (c_state == SEND_ARADDR)  
    d_valid <= 1;
  else
    d_valid <= d_valid;
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    d_tag <= 32'h00001000;
  else if (c_state == SEND_ARADDR)
    d_tag <= araddr_m_inf[15:8];
  else
    d_tag <= d_tag;
end

always @(*) begin
  d_miss = (d_tag !== fetch_addr[15:8] && (load_store[0] | load_store[1])) | (!d_valid && (load_store[0] | load_store[1]));
end

always @(*) begin
  if (c_state == IDLE)
    DM_addr = fetch_addr[7:1];
  else if (c_state == WRITE_DATA && wready_m_inf)
    DM_addr = d_cnt_pulse;
  else
    DM_addr = d_cnt;
end

assign d_cnt_pulse = d_cnt + 'd1;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    d_cnt <= 0;
  else if (c_state == READ_DATA)
    if (rvalid_m_inf)
      d_cnt <= d_cnt + 'd1;
    else
      d_cnt <= d_cnt;
  else
    d_cnt <= 0;
end

always @(*) begin
  if (c_state == READ_DATA && rvalid_m_inf) begin
    DM_web = 0;
    DM_di = rdata_m_inf;
  end
  else if (c_state == IDLE && load_store[0] && !d_miss) begin
    DM_web = 0;
    DM_di = write_data;
  end
  else begin
    DM_web = 1;
    DM_di = 0;
  end
end
//================================================
//                AXI INTERFACE
//================================================
always @(posedge clk or negedge rst_n) begin
  if (!rst_n)
    c_state <= IDLE;
  else
    c_state <= n_state;
end

always @(*) begin
  case(c_state)
    IDLE: begin
      if (d_miss) begin
        if (load_store[0]) // write no allocate
          n_state = SEND_AWADDR;
        else  
          n_state = SEND_ARADDR;
      end
      else if (load_store[0]) // write through
        n_state = SEND_AWADDR;
      else
        n_state = IDLE;
    end
    SEND_AWADDR: begin
      if (awready_m_inf)
        n_state = WRITE_DATA;
      else
        n_state = SEND_AWADDR;
    end
    WRITE_DATA: begin
      if (wlast_m_inf && wready_m_inf)
        n_state = WAIT_BREP;
      else
        n_state = WRITE_DATA;
    end
    WAIT_BREP: begin
      if (bvalid_m_inf)
        n_state = RESTART;
      else
        n_state = WAIT_BREP;
    end
    RESTART: begin
      n_state = IDLE;
    end
    SEND_ARADDR: begin
      if (arready_m_inf)
        n_state = READ_DATA;
      else
        n_state = SEND_ARADDR;
    end
    READ_DATA: begin
      if (rlast_m_inf)
        n_state = IDLE;
      else
        n_state = READ_DATA;
    end
    default: n_state = IDLE;
  endcase
end

assign cpu_stall = ((((c_state !== IDLE) & (c_state !== RESTART)) || ((c_state == IDLE) & ((d_miss | load_store[0]) | (load_store[0]))))) && (load_store[1] | load_store[0]);
// assign cpu_stall = ((c_state != IDLE) & (c_state != RESTART) || ((c_state == IDLE) & (d_miss | load_store[0]))) & (load_store[0] | load_store{1});
assign awid_m_inf = 0;
assign awlen_m_inf = 0;
assign awsize_m_inf = 3'b001;
assign awburst_m_inf = 2'b01;
assign arid_m_inf = 0;
assign arlen_m_inf = 'd127;
assign arsize_m_inf = 3'b001;
assign arburst_m_inf = 2'b01;

always @(*) begin
  if (c_state == SEND_AWADDR) begin
    awaddr_m_inf = {16'h0000, fetch_addr};
    awvalid_m_inf = 1'b1;
  end 
  else begin
    awaddr_m_inf = 32'b0; 
    awvalid_m_inf = 1'b0;
  end 
end

always @(*) begin
  if (c_state == WRITE_DATA) begin
    wvalid_m_inf = 1'b1;
  end
  else begin
    wvalid_m_inf = 1'b0;
  end
end

always @(*) begin
  if (c_state == WRITE_DATA) begin
    wdata_m_inf = write_data;
  end
  else begin
    wdata_m_inf = 0;
  end
end
always @(*) begin
  if (c_state == WRITE_DATA)
    wlast_m_inf = 1;
  else
    wlast_m_inf = 0;
end

always @(*) begin
  if (c_state == WAIT_BREP)
    bready_m_inf = 1;
  else
    bready_m_inf = 0;
end
always @(*) begin
  if (c_state == SEND_ARADDR) begin
    araddr_m_inf = {fetch_addr[15:8], 8'h00};
    arvalid_m_inf = 1'b1;
  end
  else begin
    araddr_m_inf = 0;
    arvalid_m_inf = 0;
  end
end

always @(*) begin
  if (c_state == READ_DATA)
    rready_m_inf = 1'b1;
  else
    rready_m_inf = 1'b0;
end
endmodule

module SRAM_wrapper #(
  parameter ADDR_WIDTH = 7, DATA_WIDTH = 16
) (
  input [ADDR_WIDTH-1:0] ADDR,
  input [DATA_WIDTH-1:0] DI,
  input CK, 
  input WEB, 
  input OE, 
  input CS,
  output [DATA_WIDTH-1:0] DO
);

SUMA180_128X16X1BM1 i_SRAM(
  .DI0(DI[0]),
  .DI1(DI[1]),
  .DI2(DI[2]),
  .DI3(DI[3]),
  .DI4(DI[4]),
  .DI5(DI[5]),
  .DI6(DI[6]),
  .DI7(DI[7]),
  .DI8(DI[8]),
  .DI9(DI[9]),
  .DI10(DI[10]),
  .DI11(DI[11]),
  .DI12(DI[12]),
  .DI13(DI[13]),
  .DI14(DI[14]),
  .DI15(DI[15]),
  .DO0(DO[0]),
  .DO1(DO[1]),
  .DO2(DO[2]),
  .DO3(DO[3]),
  .DO4(DO[4]),
  .DO5(DO[5]),
  .DO6(DO[6]),
  .DO7(DO[7]),
  .DO8(DO[8]),
  .DO9(DO[9]),
  .DO10(DO[10]),
  .DO11(DO[11]),
  .DO12(DO[12]),
  .DO13(DO[13]),
  .DO14(DO[14]),
  .DO15(DO[15]),
  .A0(ADDR[0]),
  .A1(ADDR[1]),
  .A2(ADDR[2]),
  .A3(ADDR[3]),
  .A4(ADDR[4]),
  .A5(ADDR[5]),
  .A6(ADDR[6]),
  .CK(CK), .WEB(WEB), .OE(OE), .CS(CS)
);
endmodule












