module left_circular_rotate (
	ori_vector_i,
	req_left_rotate_num_i,
	roteted_vector_o
);
	parameter N_INPUT = 2;
	localparam [31:0] N_INPUT_WIDTH = (N_INPUT > 1 ? $clog2(N_INPUT) : 1);
	input wire [N_INPUT - 1:0] ori_vector_i;
	input wire [N_INPUT_WIDTH - 1:0] req_left_rotate_num_i;
	output wire [N_INPUT - 1:0] roteted_vector_o;
	wire [(N_INPUT * 2) - 1:0] ori_vector_mid;
	assign ori_vector_mid = {ori_vector_i, ori_vector_i} << req_left_rotate_num_i;
	assign roteted_vector_o = ori_vector_mid[(N_INPUT * 2) - 1-:N_INPUT];
endmodule
module oh2idx (
	oh_i,
	idx_o
);
	parameter [31:0] N_INPUT = 2;
	localparam [31:0] N_INPUT_WIDTH = (N_INPUT > 1 ? $clog2(N_INPUT) : 1);
	input [N_INPUT - 1:0] oh_i;
	output wire [N_INPUT_WIDTH - 1:0] idx_o;
	genvar i;
	genvar j;
	wire [(N_INPUT_WIDTH * N_INPUT) - 1:0] mask;
	generate
		for (i = 0; i < N_INPUT_WIDTH; i = i + 1) begin : gen_mask_i
			for (j = 0; j < N_INPUT; j = j + 1) begin : gen_mask_j
				assign mask[(i * N_INPUT) + j] = (j / (2 ** i)) % 2;
			end
		end
		for (i = 0; i < N_INPUT_WIDTH; i = i + 1) begin : gen_idx_o
			assign idx_o[i] = |(oh_i & mask[i * N_INPUT+:N_INPUT]);
		end
	endgenerate
endmodule
module one_hot_priority_encoder (
	sel_i,
	sel_o
);
	parameter [31:0] SEL_WIDTH = 8;
	input wire [SEL_WIDTH - 1:0] sel_i;
	output wire [SEL_WIDTH - 1:0] sel_o;
	localparam [31:0] SEL_ID_WIDHT = $clog2(SEL_WIDTH);
	wire [SEL_WIDTH - 1:0] sel_mask;
	assign sel_mask = (~sel_i + 1'b1) & sel_i;
	assign sel_o = sel_mask;
endmodule
module one_hot_rr_arb (
	req_i,
	update_i,
	grt_o,
	grt_idx_o,
	rstn,
	clk
);
	parameter N_INPUT = 2;
	localparam [31:0] N_INPUT_WIDTH = (N_INPUT > 1 ? $clog2(N_INPUT) : 1);
	localparam [31:0] IS_LOG2 = (2 ** N_INPUT_WIDTH) == N_INPUT;
	parameter TIMEOUT_UPDATE_EN = 0;
	parameter TIMEOUT_UPDATE_CYCLE = 10;
	input wire [N_INPUT - 1:0] req_i;
	input wire update_i;
	output wire [N_INPUT - 1:0] grt_o;
	output wire [N_INPUT_WIDTH - 1:0] grt_idx_o;
	input wire rstn;
	input wire clk;
	reg [$clog2(TIMEOUT_UPDATE_CYCLE) - 1:0] timeout_counter_q;
	wire [$clog2(TIMEOUT_UPDATE_CYCLE) - 1:0] timeout_counter_d;
	wire timeout_counter_add;
	wire timeout_counter_clr;
	wire timeout_counter_en;
	wire timeout_en;
	generate
		if (N_INPUT == 1) begin : gen_one_hot_rr_arb_one_input
			assign grt_o = req_i;
			assign grt_idx_o = 0;
		end
		else begin : gen_one_hot_rr_arb_common_input
			wire req_vld;
			wire [(N_INPUT * 2) - 1:0] reversed_dereordered_selected_req_pre_shift;
			wire [(N_INPUT * 2) - 1:0] reversed_dereordered_selected_req_shift;
			wire [N_INPUT - 1:0] reodered_req;
			wire [N_INPUT - 1:0] reordered_selected_req;
			wire [N_INPUT - 1:0] dereordered_selected_req;
			wire [N_INPUT - 1:0] reversed_reordered_selected_req;
			wire [N_INPUT - 1:0] reversed_dereordered_selected_req;
			reg [N_INPUT_WIDTH - 1:0] round_ptr_q;
			wire [N_INPUT_WIDTH - 1:0] round_ptr_d;
			wire [N_INPUT_WIDTH - 1:0] round_ptr_q_comp;
			wire [N_INPUT_WIDTH - 1:0] oh_to_idx;
			wire [N_INPUT_WIDTH - 1:0] selected_req_idx;
			assign req_vld = update_i | timeout_en;
			always @(posedge clk or negedge rstn)
				if (~rstn)
					round_ptr_q <= 1'sb0;
				else if (req_vld)
					round_ptr_q <= round_ptr_d;
			assign round_ptr_q_comp = N_INPUT - round_ptr_q;
			left_circular_rotate #(.N_INPUT(N_INPUT)) left_circular_rotate_reodered_req_u(
				.ori_vector_i(req_i),
				.req_left_rotate_num_i(round_ptr_q),
				.roteted_vector_o(reodered_req)
			);
			one_hot_priority_encoder #(.SEL_WIDTH(N_INPUT)) biased_one_hot_priority_encoder_u(
				.sel_i(reodered_req),
				.sel_o(reordered_selected_req)
			);
			left_circular_rotate #(.N_INPUT(N_INPUT)) left_circular_rotate_dereordered_selected_req_u(
				.ori_vector_i(reordered_selected_req),
				.req_left_rotate_num_i(round_ptr_q_comp),
				.roteted_vector_o(dereordered_selected_req)
			);
			oh2idx #(.N_INPUT(N_INPUT)) oh2idx_u(
				.oh_i(dereordered_selected_req),
				.idx_o(oh_to_idx)
			);
			assign selected_req_idx = oh_to_idx[N_INPUT_WIDTH - 1:0];
			assign round_ptr_d = (selected_req_idx == {N_INPUT_WIDTH {1'sb0}} ? N_INPUT - 1 : (selected_req_idx == (N_INPUT - 1) ? {N_INPUT_WIDTH {1'sb0}} : (N_INPUT - 1) - selected_req_idx));
			assign grt_o = dereordered_selected_req;
			assign grt_idx_o = selected_req_idx;
			if (TIMEOUT_UPDATE_EN) begin : genblk1
				assign timeout_counter_add = |req_i & ~req_vld;
				assign timeout_counter_clr = req_vld;
				assign timeout_counter_d = (timeout_counter_clr ? {$clog2(TIMEOUT_UPDATE_CYCLE) {1'sb0}} : timeout_counter_q + 1);
				assign timeout_counter_en = timeout_counter_add | (timeout_counter_clr & (timeout_counter_q != {$clog2(TIMEOUT_UPDATE_CYCLE) {1'sb0}}));
				always @(posedge clk or negedge rstn)
					if (~rstn)
						timeout_counter_q <= 1'sb0;
					else if (timeout_counter_en)
						timeout_counter_q <= timeout_counter_d;
				assign timeout_en = timeout_counter_q == TIMEOUT_UPDATE_CYCLE;
			end
			else begin : genblk1
				assign timeout_en = 1'sb0;
			end
		end
	endgenerate
endmodule
module priority_req_select (
	req_vld_i,
	req_priority_i,
	req_vld_o
);
	parameter INPUT_NUM = 4;
	parameter INPUT_NUM_IDX_W = (INPUT_NUM > 1 ? $clog2(INPUT_NUM) : 1);
	parameter INPUT_PRIORITY_W = 4;
	input wire [INPUT_NUM - 1:0] req_vld_i;
	input wire [(INPUT_NUM * INPUT_PRIORITY_W) - 1:0] req_priority_i;
	output wire [INPUT_NUM - 1:0] req_vld_o;
	genvar i;
	genvar j;
	wire [(INPUT_NUM * INPUT_NUM) - 1:0] priority_compare_vector;
	generate
		for (i = 0; i < INPUT_NUM; i = i + 1) begin : gen_priority_compare_vector_i
			for (j = 0; j < INPUT_NUM; j = j + 1) begin : gen_priority_compare_vector_j
				if (i == j) begin : gen_diagonal
					assign priority_compare_vector[(i * INPUT_NUM) + j] = req_vld_i[i];
				end
				else begin : gen_others
					assign priority_compare_vector[(i * INPUT_NUM) + j] = ~req_vld_i[j] | (req_priority_i[i * INPUT_PRIORITY_W+:INPUT_PRIORITY_W] >= req_priority_i[j * INPUT_PRIORITY_W+:INPUT_PRIORITY_W]);
				end
			end
		end
		for (i = 0; i < INPUT_NUM; i = i + 1) begin : gen_req_vld_o
			assign req_vld_o[i] = &priority_compare_vector[i * INPUT_NUM+:INPUT_NUM];
		end
	endgenerate
endmodule
module sa_global (
	sa_local_vld_i,
	sa_local_vc_id_i,
	sa_local_qos_value_i,
	sa_global_vld_o,
	sa_global_qos_value_o,
	sa_global_inport_id_oh_o,
	sa_global_inport_vc_id_o,
	vc_assignment_vld_i,
	clk,
	rstn
);
	parameter INPUT_NUM = 4;
	parameter INPUT_NUM_IDX_W = (INPUT_NUM > 1 ? $clog2(INPUT_NUM) : 1);
	input wire [INPUT_NUM - 1:0] sa_local_vld_i;
	localparam rvh_noc_pkg_CHANNEL_NUM = 4;
	localparam rvh_noc_pkg_INPUT_PORT_NUMBER = 6;
	localparam rvh_noc_pkg_ROUTER_PORT_NUMBER = 4;
	localparam rvh_noc_pkg_LOCAL_PORT_NUMBER = 2;
	localparam rvh_noc_pkg_QOS_VC_NUM_PER_INPUT = 1;
	localparam rvh_noc_pkg_VC_ID_NUM_MAX = 6;
	localparam rvh_noc_pkg_VC_ID_NUM_MAX_W = 3;
	input wire [(INPUT_NUM * 3) - 1:0] sa_local_vc_id_i;
	localparam rvh_noc_pkg_QoS_Value_Width = 4;
	input wire [(INPUT_NUM * 4) - 1:0] sa_local_qos_value_i;
	output wire sa_global_vld_o;
	output wire [3:0] sa_global_qos_value_o;
	output wire [INPUT_NUM - 1:0] sa_global_inport_id_oh_o;
	output wire [2:0] sa_global_inport_vc_id_o;
	input wire vc_assignment_vld_i;
	input wire clk;
	input wire rstn;
	wire [INPUT_NUM - 1:0] sa_global_grt_oh;
	wire [INPUT_NUM_IDX_W - 1:0] sa_global_grt_idx;
	wire [INPUT_NUM - 1:0] sa_local_vld_join_arb;
	priority_req_select #(
		.INPUT_NUM(INPUT_NUM),
		.INPUT_PRIORITY_W(rvh_noc_pkg_QoS_Value_Width)
	) sa_local_priority_req_select_u(
		.req_vld_i(sa_local_vld_i),
		.req_priority_i(sa_local_qos_value_i),
		.req_vld_o(sa_local_vld_join_arb)
	);
	one_hot_rr_arb #(
		.N_INPUT(INPUT_NUM),
		.TIMEOUT_UPDATE_EN(1),
		.TIMEOUT_UPDATE_CYCLE(10)
	) sa_global_rr_arb_u(
		.req_i(sa_local_vld_join_arb),
		.update_i(vc_assignment_vld_i),
		.grt_o(sa_global_grt_oh),
		.grt_idx_o(sa_global_grt_idx),
		.rstn(rstn),
		.clk(clk)
	);
	assign sa_global_vld_o = |sa_local_vld_join_arb;
	assign sa_global_inport_id_oh_o = sa_global_grt_oh;
	onehot_mux #(
		.SOURCE_COUNT(INPUT_NUM),
		.DATA_WIDTH(rvh_noc_pkg_VC_ID_NUM_MAX_W)
	) onehot_mux_sa_global_inport_vc_id_o_u(
		.sel_i(sa_global_grt_oh),
		.data_i(sa_local_vc_id_i),
		.data_o(sa_global_inport_vc_id_o)
	);
	onehot_mux #(
		.SOURCE_COUNT(INPUT_NUM),
		.DATA_WIDTH(rvh_noc_pkg_QoS_Value_Width)
	) onehot_mux_sa_global_qos_value_o_u(
		.sel_i(sa_global_grt_oh),
		.data_i(sa_local_qos_value_i),
		.data_o(sa_global_qos_value_o)
	);
endmodule
