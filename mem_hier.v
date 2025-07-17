//******************************************************************************
// Copyright (c) 2014 - 2018, 2019 - 2021, Indian Institute of Science, Bangalore.
// All Rights Reserved. See LICENSE for license details.
//------------------------------------------------------------------------------

// Contributors
// Naveen Chander V (naveenv@alum.iisc.ac.in)
// Akshay Birari (akshay@alum.iisc.ac.in), Piyush Birla (piyush@alum.iisc.ac.in)
// Suseela Budi (suseela@alum.iisc.ac.in), Pradeep Gupta (gupta@alum.iisc.ac.in)
// Kavya Sharat (kavyasharat@alum.iisc.ac.in), Sumeet Bandishte (sumeet.bandishte30@gmail.com)
// Kuruvilla Varghese (kuru@iisc.ac.in)
`timescale 1ns / 1ps

module mem_hier(
    clk, clk_x2, rst_n, freeze_in,
    i_addr, instr_out, stall_out, eret_ack, stall_load,
    wb_clk_i, wb_rst_i, wb_ack_i, wb_err_i,
    wb_rty_i, wb_dat_i, wb_cyc_o, wb_stb_o,
    wb_we_o, wb_adr_o, wb_bte_o, wb_cti_o,
    wb_sel_o, wb_dat_o    
`ifdef itlb_def
    ,vpn_to_ppn_req_in
`endif
);

//----------------Parameters-----------------
parameter offset_start_bit = 0;
parameter page_offset_start = 0;
parameter page_offset_last = 11;
parameter offset_last_bit = 4;
parameter index_start_bit = 5;
parameter index_last_bit = 11;
parameter tag_start_bit = 12;
parameter tag_last_bit = 31;
parameter tag_tlb_start_bit = 4;
parameter tag_tlb_last_bit = 23;
parameter tag_phy_start_bit = 0;
parameter tag_phy_last_bit = 19;

input clk, clk_x2, rst_n;
input [31:0] i_addr;
input freeze_in;
input eret_ack;
input stall_load;
input wb_clk_i;
input wb_rst_i;
input wb_ack_i;
input wb_err_i;
input wb_rty_i;
input [31:0] wb_dat_i;
output wb_cyc_o;
output wb_stb_o;
output wb_we_o;
output [31:0] wb_adr_o;
output [1:0] wb_bte_o;
output [2:0] wb_cti_o;
output [3:0] wb_sel_o;
output [31:0] wb_dat_o;
output [31:0] instr_out;
output stall_out;

`ifdef itlb_def
input vpn_to_ppn_req_in;
`endif 

// ---------Wire & Reg
wire biu_we_i;
wire i_hit;
wire [255:0] bus_line;
wire bus_rdy;

wire [1:0] state;
wire [31:0] i_addr_cache;

reg [31:0] virtual_addr;
wire stall;

wire [3:0] burst_len;
wire i_we;
wire d_we, rdy;
wire [255:0] m_data;
wire [255:0] set_0, set_1;
wire [18:0] tag_0, tag_1;
wire i_acc_int;
wire i_acc;
wire [31:0] biu_dat_o;
wire [31:0] instr;
reg [31:0] instr_reg;
wire [3:0] biu_sel_i;

wire [2:0] wb_cti_o;
wire [1:0] wb_fsm_state_cur;
wire rd, wr, m_rdy_n;
wire [31:0] addr;
wire biu_cyc_i, biu_stb_i, biu_cab_i;

wire [255:0] bus_data;          
wire [255:0] i_data;
wire [31:0] addr_latch;
wire freeze;
wire x_freeze;
reg freeze_int;
reg stall_int;
reg stall_load_int;
wire vpn_to_ppn_req_in1;
wire vpn_to_ppn_req7;
reg freeze_hit_status;
wire [tag_phy_last_bit : tag_phy_start_bit] physical_tag;

wire wb_cyc_o_int;
wire wb_stb_o_int;
wire wb_we_o_int;
wire [31:0] wb_adr_o_int;
wire [1:0] wb_bte_o_int;
wire [2:0] wb_cti_o_int;
wire [3:0] wb_sel_o_int;
wire [31:0] wb_dat_o_int;

// Declare tag_hit unconditionally
wire tag_hit;

`ifdef itlb_def
wire wb_cyc_tlb_o;          
wire wb_stb_tlb_o;
wire wb_we_tlb_o;
wire [31:0] wb_adr_tlb_o;
wire [1:0] wb_bte_tlb_o;
wire [2:0] wb_cti_tlb_o;
wire [3:0] wb_sel_tlb_o;
wire [31:0] wb_dat_tlb_o;

reg [31:0] physical_adr;
reg [31:0] i_addr_int;
wire [tag_phy_last_bit:tag_phy_start_bit] tag_o_tlb;

assign wb_cyc_o = wb_cyc_o_int | wb_cyc_tlb_o;
assign wb_adr_o = wb_stb_tlb_o ? wb_adr_tlb_o : wb_adr_o_int;
assign wb_stb_o = wb_stb_o_int | wb_stb_tlb_o;
assign wb_we_o = wb_we_o_int | wb_we_tlb_o;
assign wb_sel_o = wb_stb_tlb_o ? wb_sel_tlb_o : wb_sel_o_int;
assign wb_dat_o = wb_stb_tlb_o ? wb_dat_tlb_o : wb_dat_o_int;
assign wb_cti_o = wb_stb_tlb_o ? wb_cti_tlb_o : wb_cti_o_int;
assign wb_bte_o = wb_stb_tlb_o ? wb_bte_tlb_o : wb_bte_o_int;

assign freeze = freeze_tlb_out | freeze_in;
assign i_acc = i_acc_int;

`else
assign tag_hit = 1'b0;  // Default assignment when itlb_def not defined

assign wb_cyc_o = wb_cyc_o_int;
assign wb_adr_o = wb_adr_o_int;
assign wb_stb_o = wb_stb_o_int;
assign wb_we_o = wb_we_o_int;
assign wb_sel_o = wb_sel_o_int;
assign wb_dat_o = wb_dat_o_int;
assign wb_cti_o = wb_cti_o_int;
assign wb_bte_o = wb_bte_o_int;

assign freeze = freeze_in;
assign i_acc = i_acc_int;

`endif 

`ifdef itlb_def
assign vpn_to_ppn_req_in1 = vpn_to_ppn_req_in;
`else
assign vpn_to_ppn_req_in1 = 1'b0;
`endif

assign stall_out = stall;
assign i_acc_int = 1'b1;
assign instr_out = (vpn_to_ppn_req7 ? instr_reg : instr);
assign biu_we_i = 1'b0;

reg dat;

always @(posedge clk) begin
    if(rst_n) begin
        dat <= 1'b0;
    end
    else if ((i_addr == 32'h3e78)) begin
        dat <= 1'b1;
    end
    else
        dat <= 1'b0;
end

always @(posedge clk) begin
    if(rst_n)
        virtual_addr <= 0;
    else if(~(stall_out || freeze_in))
        virtual_addr <= stall_load ? (i_addr - 32'd4) : i_addr;
end

always @(posedge clk) begin
    if(rst_n)
        freeze_hit_status <= 1'b0;
    else if(x_freeze && freeze_in)
        freeze_hit_status <= i_hit;
end

always @(posedge clk) begin
    if(rst_n)
        instr_reg <= 32'b0;
    else if(x_freeze && freeze_in)
        instr_reg <= instr;
    `ifdef itlb_def
    else if(tag_hit && i_hit && freeze_in && stall_int)
        instr_reg <= instr;
    `endif
end

always @(posedge clk) begin
    if(rst_n) begin
        freeze_int <= 0;
        stall_int <= 0;
        stall_load_int <= 0;
    end
    else begin
        freeze_int <= freeze_in;
        stall_int <= stall;
        stall_load_int <= stall_load;
    end
end

assign x_freeze = (freeze_int ^ freeze_in);
assign vpn_to_ppn_req7 = (freeze_int && x_freeze && ~eret_ack);

or1200_wb_biu1 a1(
    .clk(clk),
    .rst(rst_n),
    .clmode(2'b00),
    .wb_clk_i(wb_clk_i), .wb_rst_i(wb_rst_i),
    .wb_ack_i(wb_ack_i), .wb_err_i(wb_err_i),
    .wb_rty_i(wb_rty_i), .wb_dat_i(wb_dat_i),
    .wb_cyc_o(wb_cyc_o_int), .wb_adr_o(wb_adr_o_int),
    .wb_stb_o(wb_stb_o_int), .wb_we_o(wb_we_o_int),
    .wb_sel_o(wb_sel_o_int), .wb_dat_o(wb_dat_o_int),
    .wb_cti_o(wb_cti_o_int), .wb_bte_o(wb_bte_o_int),
    .biu_adr_i({physical_tag, virtual_addr[page_offset_last:page_offset_start]} & 32'hffffffe0),
    .biu_cyc_i(biu_cyc_i),
    .biu_stb_i(biu_stb_i),
    .biu_we_i(biu_we_i),
    .biu_sel_i(biu_sel_i),
    .biu_cab_i(biu_cab_i),
    .biu_dat_o(biu_dat_o),
    .bus_data(bus_data),
    .bus_rdy(bus_rdy),
    .burst_len(burst_len),
    .wb_fsm_state_cur(wb_fsm_state_cur),
    .bus_line(bus_line)
);

icache icache1(
    .clk(clk),
    .clk_x2(clk_x2),
    .rst_n(rst_n),
    .freeze(freeze && ~stall_out),
    .freeze_in(freeze_in && ~stall_out),
    .stall_load(stall_load),
    .wr_data(i_data),
    .we(i_we),
    .re(i_acc_int),
    .hit_out(i_hit),
    .i_addr(i_addr),
    .virtual_addr(virtual_addr),
    .state_fsm(state),
    .physical_tag(physical_tag),
    .vpn_to_ppn_req3(vpn_to_ppn_req3),
    .vpn_to_ppn_req7(vpn_to_ppn_req7),
    .eret_ack(eret_ack),
    .freeze_hit_status(freeze_hit_status),
    .stall(stall),
    .re_int(i_acc_int),
    .instr(instr),
    .vpn_to_ppn_req(vpn_to_ppn_req_in1 || vpn_to_ppn_req_in2)
    `ifdef itlb_def
    ,.tag_o_tlb(tag_o_tlb), .freeze_tlb_out(freeze_tlb_out), .tag_hit(tag_hit),
    .wb_ack_i(wb_ack_i), .wb_err_i(wb_err_i), .wb_rty_i(wb_rty_i),
    .wb_dat_i(wb_dat_i), .wb_cyc_o(wb_cyc_tlb_o), .wb_stb_o(wb_stb_tlb_o),
    .wb_we_o(wb_we_tlb_o), .wb_adr_o(wb_adr_tlb_o), .wb_bte_o(wb_bte_tlb_o),
    .wb_cti_o(wb_cti_tlb_o), .wb_sel_o(wb_sel_tlb_o), .wb_dat_o(wb_dat_tlb_o)
    `endif
);

cachefsm a3(
    .clk(clk),
    .rst_n(rst_n),
    .freeze((freeze && ~stall_out)),
    .freeze_in(freeze_in),
    .i_hit(i_hit),
    .m_line_full(bus_line),
    .tag_hit(tag_hit),  // Always connected now
    .i_acc(i_acc),
    .i_we(i_we),
    .i_data(i_data),
    .vpn_to_ppn_req_out(vpn_to_ppn_req_in2),
    .vpn_to_ppn_req3(vpn_to_ppn_req3),
    .state(state),
    .stall(stall),
    .biu_cyc_i(biu_cyc_i),
    .biu_stb_i(biu_stb_i),
    .biu_cab_i(biu_cab_i),
    .biu_sel_i(biu_sel_i),
    .wb_ack_i(wb_ack_i && wb_stb_o_int)
);

endmodule