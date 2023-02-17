module performance_monitor (
	sa_local_vld_i,
	sa_global_inport_read_vld_i,
	vc_credit_counter_toN_i,
	vc_credit_counter_toS_i,
	vc_credit_counter_toE_i,
	vc_credit_counter_toW_i,
	node_id_x_ths_hop_i,
	node_id_y_ths_hop_i,
	clk,
	rstn
);
	parameter INPUT_PORT_NUM = 5;
	parameter OUTPUT_PORT_NUM = 5;
	parameter LOCAL_PORT_NUM = INPUT_PORT_NUM - 4;
	parameter VC_NUM_INPUT_N = 1 + LOCAL_PORT_NUM;
	parameter VC_NUM_INPUT_S = 1 + LOCAL_PORT_NUM;
	parameter VC_NUM_INPUT_E = 3 + LOCAL_PORT_NUM;
	parameter VC_NUM_INPUT_W = 3 + LOCAL_PORT_NUM;
	parameter VC_NUM_INPUT_L = 4;
	parameter VC_DEPTH_INPUT_N = 2;
	parameter VC_DEPTH_INPUT_S = 2;
	parameter VC_DEPTH_INPUT_E = 2;
	parameter VC_DEPTH_INPUT_W = 2;
	parameter VC_DEPTH_INPUT_L = 2;
	parameter VC_DEPTH_INPUT_N_COUNTER_W = $clog2(VC_DEPTH_INPUT_N + 1);
	parameter VC_DEPTH_INPUT_S_COUNTER_W = $clog2(VC_DEPTH_INPUT_S + 1);
	parameter VC_DEPTH_INPUT_E_COUNTER_W = $clog2(VC_DEPTH_INPUT_E + 1);
	parameter VC_DEPTH_INPUT_W_COUNTER_W = $clog2(VC_DEPTH_INPUT_W + 1);
	parameter VC_DEPTH_INPUT_L_COUNTER_W = $clog2(VC_DEPTH_INPUT_L + 1);
	input wire [INPUT_PORT_NUM - 1:0] sa_local_vld_i;
	input wire [INPUT_PORT_NUM - 1:0] sa_global_inport_read_vld_i;
	input wire [(VC_NUM_INPUT_N * VC_DEPTH_INPUT_N_COUNTER_W) - 1:0] vc_credit_counter_toN_i;
	input wire [(VC_NUM_INPUT_S * VC_DEPTH_INPUT_S_COUNTER_W) - 1:0] vc_credit_counter_toS_i;
	input wire [(VC_NUM_INPUT_E * VC_DEPTH_INPUT_E_COUNTER_W) - 1:0] vc_credit_counter_toE_i;
	input wire [(VC_NUM_INPUT_W * VC_DEPTH_INPUT_W_COUNTER_W) - 1:0] vc_credit_counter_toW_i;
	localparam rvh_noc_pkg_NodeID_X_Width = 2;
	input wire [1:0] node_id_x_ths_hop_i;
	localparam rvh_noc_pkg_NodeID_Y_Width = 2;
	input wire [1:0] node_id_y_ths_hop_i;
	input wire clk;
	input wire rstn;
	genvar i;
	reg [(INPUT_PORT_NUM * 64) - 1:0] sa_local_vld_counter_d;
	wire [(INPUT_PORT_NUM * 64) - 1:0] sa_local_vld_counter_q;
	reg [INPUT_PORT_NUM - 1:0] sa_local_vld_counter_ena;
	reg [(INPUT_PORT_NUM * 64) - 1:0] sa_global_inport_read_vld_counter_d;
	wire [(INPUT_PORT_NUM * 64) - 1:0] sa_global_inport_read_vld_counter_q;
	reg [INPUT_PORT_NUM - 1:0] sa_global_inport_read_vld_counter_ena;
	always @(*) begin
		sa_local_vld_counter_d = sa_local_vld_counter_q;
		sa_local_vld_counter_ena = 1'sb0;
		sa_global_inport_read_vld_counter_d = sa_global_inport_read_vld_counter_q;
		sa_global_inport_read_vld_counter_ena = 1'sb0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < INPUT_PORT_NUM; i = i + 1)
				begin
					if (sa_local_vld_i[i]) begin
						sa_local_vld_counter_d[i * 64+:64] = sa_local_vld_counter_d[i * 64+:64] + 1;
						sa_local_vld_counter_ena[i] = 1'b1;
					end
					if (sa_global_inport_read_vld_i[i]) begin
						sa_global_inport_read_vld_counter_d[i * 64+:64] = sa_global_inport_read_vld_counter_d[i * 64+:64] + 1;
						sa_global_inport_read_vld_counter_ena[i] = 1'b1;
					end
				end
		end
	end
	generate
		for (i = 0; i < INPUT_PORT_NUM; i = i + 1) begin : genblk1
			std_dffre #(.WIDTH(64)) U_DAT_SA_LOCAL_VLD_COUNTER(
				.clk(clk),
				.rstn(rstn),
				.en(sa_local_vld_counter_ena[i]),
				.d(sa_local_vld_counter_d[i * 64+:64]),
				.q(sa_local_vld_counter_q[i * 64+:64])
			);
			std_dffre #(.WIDTH(64)) U_DAT_SA_GLOBAL_INPORT_READ_VLD_COUNTER(
				.clk(clk),
				.rstn(rstn),
				.en(sa_global_inport_read_vld_counter_ena[i]),
				.d(sa_global_inport_read_vld_counter_d[i * 64+:64]),
				.q(sa_global_inport_read_vld_counter_q[i * 64+:64])
			);
		end
	endgenerate
endmodule
module std_dffre (
	clk,
	rstn,
	en,
	d,
	q
);
	parameter WIDTH = 8;
	input clk;
	input rstn;
	input en;
	input [WIDTH - 1:0] d;
	output wire [WIDTH - 1:0] q;
	reg [WIDTH - 1:0] dff_q;
	always @(posedge clk or negedge rstn)
		if (~rstn)
			dff_q <= {WIDTH {1'b0}};
		else if (en)
			dff_q <= d;
	assign q = dff_q;
endmodule
