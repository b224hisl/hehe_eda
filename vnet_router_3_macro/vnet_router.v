module input_to_output (
	sa_global_vld_i,
	sa_global_inport_id_oh_i,
	sa_global_inport_vc_id_i,
	vc_assignment_vld_i,
	vc_assignment_vc_id_i,
	look_ahead_routing_sel_i,
	inport_read_enable_o,
	inport_read_vc_id_o,
	outport_vld_o,
	outport_select_inport_id_o,
	outport_vc_id_o,
	outport_look_ahead_routing_o,
	consume_vc_credit_vld_o,
	consume_vc_credit_vc_id_o
);
	parameter INPUT_PORT_NUM = 5;
	parameter OUTPUT_PORT_NUM = 5;
	parameter LOCAL_PORT_NUM = INPUT_PORT_NUM - 4;
	parameter SA_GLOBAL_INPUT_NUM_N = 4;
	parameter SA_GLOBAL_INPUT_NUM_S = 4;
	parameter SA_GLOBAL_INPUT_NUM_E = 2;
	parameter SA_GLOBAL_INPUT_NUM_W = 2;
	parameter SA_GLOBAL_INPUT_NUM_L = 4;
	parameter SA_GLOBAL_INPUT_NUM_N_W = (SA_GLOBAL_INPUT_NUM_N > 1 ? $clog2(SA_GLOBAL_INPUT_NUM_N) : 1);
	parameter SA_GLOBAL_INPUT_NUM_S_W = (SA_GLOBAL_INPUT_NUM_S > 1 ? $clog2(SA_GLOBAL_INPUT_NUM_S) : 1);
	parameter SA_GLOBAL_INPUT_NUM_E_W = (SA_GLOBAL_INPUT_NUM_E > 1 ? $clog2(SA_GLOBAL_INPUT_NUM_E) : 1);
	parameter SA_GLOBAL_INPUT_NUM_W_W = (SA_GLOBAL_INPUT_NUM_W > 1 ? $clog2(SA_GLOBAL_INPUT_NUM_W) : 1);
	parameter SA_GLOBAL_INPUT_NUM_L_W = (SA_GLOBAL_INPUT_NUM_L > 1 ? $clog2(SA_GLOBAL_INPUT_NUM_L) : 1);
	input wire [OUTPUT_PORT_NUM - 1:0] sa_global_vld_i;
	localparam rvh_noc_pkg_CHANNEL_NUM = 4;
	localparam rvh_noc_pkg_INPUT_PORT_NUMBER = 6;
	localparam rvh_noc_pkg_ROUTER_PORT_NUMBER = 4;
	localparam rvh_noc_pkg_LOCAL_PORT_NUMBER = 2;
	localparam rvh_noc_pkg_SA_GLOBAL_INPUT_NUM_MAX = 5;
	input wire [(OUTPUT_PORT_NUM * 5) - 1:0] sa_global_inport_id_oh_i;
	localparam rvh_noc_pkg_QOS_VC_NUM_PER_INPUT = 1;
	localparam rvh_noc_pkg_VC_ID_NUM_MAX = 6;
	localparam rvh_noc_pkg_VC_ID_NUM_MAX_W = 3;
	input wire [(OUTPUT_PORT_NUM * 3) - 1:0] sa_global_inport_vc_id_i;
	input wire [OUTPUT_PORT_NUM - 1:0] vc_assignment_vld_i;
	input wire [(OUTPUT_PORT_NUM * 3) - 1:0] vc_assignment_vc_id_i;
	input wire [(OUTPUT_PORT_NUM * 3) - 1:0] look_ahead_routing_sel_i;
	output wire [INPUT_PORT_NUM - 1:0] inport_read_enable_o;
	output wire [(INPUT_PORT_NUM * 3) - 1:0] inport_read_vc_id_o;
	output wire [OUTPUT_PORT_NUM - 1:0] outport_vld_o;
	output wire [(OUTPUT_PORT_NUM * 3) - 1:0] outport_select_inport_id_o;
	output wire [(OUTPUT_PORT_NUM * 3) - 1:0] outport_vc_id_o;
	output wire [(OUTPUT_PORT_NUM * 3) - 1:0] outport_look_ahead_routing_o;
	output wire [OUTPUT_PORT_NUM - 1:0] consume_vc_credit_vld_o;
	output wire [(OUTPUT_PORT_NUM * 3) - 1:0] consume_vc_credit_vc_id_o;
	genvar i;
	genvar j;
	genvar k;
	reg [(OUTPUT_PORT_NUM * 3) - 1:0] inport_id_per_outport;
	reg [(OUTPUT_PORT_NUM * INPUT_PORT_NUM) - 1:0] inport_id_oh_per_outport;
	wire [(INPUT_PORT_NUM * OUTPUT_PORT_NUM) - 1:0] outport_id_oh_per_inport;
	generate
		for (i = 0; i < OUTPUT_PORT_NUM; i = i + 1) begin : gen_consume_vc_credit
			assign consume_vc_credit_vld_o[i] = sa_global_vld_i[i] & vc_assignment_vld_i[i];
			assign consume_vc_credit_vc_id_o[i * 3+:3] = vc_assignment_vc_id_i[i * 3+:3];
		end
	endgenerate
	assign outport_vld_o = consume_vc_credit_vld_o;
	assign outport_select_inport_id_o = inport_id_per_outport;
	assign outport_vc_id_o = vc_assignment_vc_id_i;
	assign outport_look_ahead_routing_o = look_ahead_routing_sel_i;
	generate
		for (i = 0; i < INPUT_PORT_NUM; i = i + 1) begin : genblk2
			for (j = 0; j < OUTPUT_PORT_NUM; j = j + 1) begin : genblk1
				assign outport_id_oh_per_inport[(i * OUTPUT_PORT_NUM) + j] = inport_id_oh_per_outport[(j * INPUT_PORT_NUM) + i];
			end
		end
		for (i = 0; i < INPUT_PORT_NUM; i = i + 1) begin : genblk3
			assign inport_read_enable_o[i] = |(outport_id_oh_per_inport[i * OUTPUT_PORT_NUM+:OUTPUT_PORT_NUM] & vc_assignment_vld_i);
		end
	endgenerate
	wire [((OUTPUT_PORT_NUM * INPUT_PORT_NUM) * 3) - 1:0] inport_vc_id_oh_per_outport;
	wire [((INPUT_PORT_NUM * OUTPUT_PORT_NUM) * 3) - 1:0] outport_vc_id_oh_per_inport;
	wire [((INPUT_PORT_NUM * rvh_noc_pkg_VC_ID_NUM_MAX_W) * OUTPUT_PORT_NUM) - 1:0] outport_vc_id_oh_per_inport_mid1;
	wire [(INPUT_PORT_NUM * rvh_noc_pkg_VC_ID_NUM_MAX_W) - 1:0] outport_vc_id_oh_per_inport_mid2;
	generate
		for (i = 0; i < OUTPUT_PORT_NUM; i = i + 1) begin : genblk4
			for (j = 0; j < INPUT_PORT_NUM; j = j + 1) begin : genblk1
				assign inport_vc_id_oh_per_outport[((i * INPUT_PORT_NUM) + j) * 3+:3] = {rvh_noc_pkg_VC_ID_NUM_MAX_W {inport_id_oh_per_outport[(i * INPUT_PORT_NUM) + j]}} & sa_global_inport_vc_id_i[i * 3+:3];
			end
		end
		for (i = 0; i < INPUT_PORT_NUM; i = i + 1) begin : genblk5
			for (j = 0; j < OUTPUT_PORT_NUM; j = j + 1) begin : genblk1
				assign outport_vc_id_oh_per_inport[((i * OUTPUT_PORT_NUM) + j) * 3+:3] = inport_vc_id_oh_per_outport[((j * INPUT_PORT_NUM) + i) * 3+:3];
			end
		end
		for (i = 0; i < INPUT_PORT_NUM; i = i + 1) begin : genblk6
			for (j = 0; j < OUTPUT_PORT_NUM; j = j + 1) begin : genblk1
				for (k = 0; k < rvh_noc_pkg_VC_ID_NUM_MAX_W; k = k + 1) begin : genblk1
					assign outport_vc_id_oh_per_inport_mid1[(((i * rvh_noc_pkg_VC_ID_NUM_MAX_W) + k) * OUTPUT_PORT_NUM) + j] = outport_vc_id_oh_per_inport[(((i * OUTPUT_PORT_NUM) + j) * 3) + k];
				end
			end
		end
		for (i = 0; i < (INPUT_PORT_NUM * rvh_noc_pkg_VC_ID_NUM_MAX_W); i = i + 1) begin : genblk7
			assign outport_vc_id_oh_per_inport_mid2[i] = |outport_vc_id_oh_per_inport_mid1[i * OUTPUT_PORT_NUM+:OUTPUT_PORT_NUM];
		end
		for (i = 0; i < INPUT_PORT_NUM; i = i + 1) begin : genblk8
			for (j = 0; j < rvh_noc_pkg_VC_ID_NUM_MAX_W; j = j + 1) begin : genblk1
				assign inport_read_vc_id_o[(i * 3) + j] = outport_vc_id_oh_per_inport_mid2[(i * rvh_noc_pkg_VC_ID_NUM_MAX_W) + j];
			end
		end
	endgenerate
	always @(*) begin
		inport_id_per_outport[0+:3] = 3'd1;
		inport_id_oh_per_outport[0+:INPUT_PORT_NUM] = 1'sb0;
		case (1'b1)
			sa_global_inport_id_oh_i[0]: begin
				inport_id_per_outport[0+:3] = 3'd1;
				inport_id_oh_per_outport[1] = 1'b1;
			end
			sa_global_inport_id_oh_i[1]: begin
				inport_id_per_outport[0+:3] = 3'd2;
				inport_id_oh_per_outport[2] = 1'b1;
			end
			sa_global_inport_id_oh_i[2]: begin
				inport_id_per_outport[0+:3] = 3'd3;
				inport_id_oh_per_outport[3] = 1'b1;
			end
			sa_global_inport_id_oh_i[3]: begin
				inport_id_per_outport[0+:3] = 3'd4;
				inport_id_oh_per_outport[4] = 1'b1;
			end
			default:
				;
		endcase
	end
	always @(*) begin
		inport_id_per_outport[3+:3] = 3'd0;
		inport_id_oh_per_outport[INPUT_PORT_NUM+:INPUT_PORT_NUM] = 1'sb0;
		case (1'b1)
			sa_global_inport_id_oh_i[5]: begin
				inport_id_per_outport[3+:3] = 3'd0;
				inport_id_oh_per_outport[INPUT_PORT_NUM] = 1'b1;
			end
			sa_global_inport_id_oh_i[6]: begin
				inport_id_per_outport[3+:3] = 3'd2;
				inport_id_oh_per_outport[INPUT_PORT_NUM + 2] = 1'b1;
			end
			sa_global_inport_id_oh_i[7]: begin
				inport_id_per_outport[3+:3] = 3'd3;
				inport_id_oh_per_outport[INPUT_PORT_NUM + 3] = 1'b1;
			end
			sa_global_inport_id_oh_i[8]: begin
				inport_id_per_outport[3+:3] = 3'd4;
				inport_id_oh_per_outport[INPUT_PORT_NUM + 4] = 1'b1;
			end
			default:
				;
		endcase
	end
	always @(*) begin
		inport_id_per_outport[6+:3] = 3'd3;
		inport_id_oh_per_outport[2 * INPUT_PORT_NUM+:INPUT_PORT_NUM] = 1'sb0;
		case (1'b1)
			sa_global_inport_id_oh_i[10]: begin
				inport_id_per_outport[6+:3] = 3'd3;
				inport_id_oh_per_outport[(2 * INPUT_PORT_NUM) + 3] = 1'b1;
			end
			sa_global_inport_id_oh_i[11]: begin
				inport_id_per_outport[6+:3] = 3'd4;
				inport_id_oh_per_outport[(2 * INPUT_PORT_NUM) + 4] = 1'b1;
			end
			default:
				;
		endcase
	end
	always @(*) begin
		inport_id_per_outport[9+:3] = 3'd2;
		inport_id_oh_per_outport[3 * INPUT_PORT_NUM+:INPUT_PORT_NUM] = 1'sb0;
		case (1'b1)
			sa_global_inport_id_oh_i[15]: begin
				inport_id_per_outport[9+:3] = 3'd2;
				inport_id_oh_per_outport[(3 * INPUT_PORT_NUM) + 2] = 1'b1;
			end
			sa_global_inport_id_oh_i[16]: begin
				inport_id_per_outport[9+:3] = 3'd4;
				inport_id_oh_per_outport[(3 * INPUT_PORT_NUM) + 4] = 1'b1;
			end
			default:
				;
		endcase
	end
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_have_multi_local_port
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : gen_multi_local_port
				always @(*) begin
					inport_id_per_outport[(4 + i) * 3+:3] = 3'd0;
					inport_id_oh_per_outport[(4 + i) * INPUT_PORT_NUM+:INPUT_PORT_NUM] = 1'sb0;
					case (1'b1)
						sa_global_inport_id_oh_i[(4 + i) * 5]: begin
							inport_id_per_outport[(4 + i) * 3+:3] = 3'd0;
							inport_id_oh_per_outport[(4 + i) * INPUT_PORT_NUM] = 1'b1;
						end
						sa_global_inport_id_oh_i[((4 + i) * 5) + 1]: begin
							inport_id_per_outport[(4 + i) * 3+:3] = 3'd1;
							inport_id_oh_per_outport[((4 + i) * INPUT_PORT_NUM) + 1] = 1'b1;
						end
						sa_global_inport_id_oh_i[((4 + i) * 5) + 2]: begin
							inport_id_per_outport[(4 + i) * 3+:3] = 3'd2;
							inport_id_oh_per_outport[((4 + i) * INPUT_PORT_NUM) + 2] = 1'b1;
						end
						sa_global_inport_id_oh_i[((4 + i) * 5) + 3]: begin
							inport_id_per_outport[(4 + i) * 3+:3] = 3'd3;
							inport_id_oh_per_outport[((4 + i) * INPUT_PORT_NUM) + 3] = 1'b1;
						end
						default:
							;
					endcase
				end
			end
		end
	endgenerate
endmodule
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
module look_ahead_routing (
	vc_ctrl_head_vld_i,
	vc_ctrl_head_i,
	node_id_x_ths_hop_i,
	node_id_y_ths_hop_i,
	look_ahead_routing_o
);
	input wire vc_ctrl_head_vld_i;
	localparam rvh_noc_pkg_QoS_Value_Width = 4;
	localparam rvh_noc_pkg_TxnID_Width = 12;
	localparam rvh_noc_pkg_NodeID_Device_Port_Width = 2;
	localparam rvh_noc_pkg_NodeID_X_Width = 2;
	localparam rvh_noc_pkg_NodeID_Y_Width = 2;
	input wire [32:0] vc_ctrl_head_i;
	input wire [1:0] node_id_x_ths_hop_i;
	input wire [1:0] node_id_y_ths_hop_i;
	output reg [2:0] look_ahead_routing_o;
	reg [1:0] node_id_x_nxt_hop;
	wire [1:0] node_id_x_dst_hop;
	reg [1:0] node_id_y_nxt_hop;
	wire [1:0] node_id_y_dst_hop;
	assign node_id_x_dst_hop = vc_ctrl_head_i[32-:2];
	assign node_id_y_dst_hop = vc_ctrl_head_i[30-:2];
	always @(*) begin
		node_id_x_nxt_hop = node_id_x_ths_hop_i;
		node_id_y_nxt_hop = node_id_y_ths_hop_i;
		case (vc_ctrl_head_i[6-:3])
			3'd0: node_id_y_nxt_hop = node_id_y_ths_hop_i + 1;
			3'd1: node_id_y_nxt_hop = node_id_y_ths_hop_i - 1;
			3'd2: node_id_x_nxt_hop = node_id_x_ths_hop_i + 1;
			3'd3: node_id_x_nxt_hop = node_id_x_ths_hop_i - 1;
			default:
				;
		endcase
	end
	wire x_nxt_equal_x_dst;
	wire x_nxt_less_x_dst;
	wire y_nxt_equal_y_dst;
	wire y_nxt_less_y_dst;
	assign x_nxt_equal_x_dst = node_id_x_nxt_hop == node_id_x_dst_hop;
	assign x_nxt_less_x_dst = node_id_x_nxt_hop < node_id_x_dst_hop;
	assign y_nxt_equal_y_dst = node_id_y_nxt_hop == node_id_y_dst_hop;
	assign y_nxt_less_y_dst = node_id_y_nxt_hop < node_id_y_dst_hop;
	always @(*)
		if (x_nxt_equal_x_dst) begin
			if (y_nxt_equal_y_dst)
				case (vc_ctrl_head_i[28-:2])
					0: look_ahead_routing_o = 3'd4;
					default: look_ahead_routing_o = 3'd4;
				endcase
			else if (y_nxt_less_y_dst)
				look_ahead_routing_o = 3'd0;
			else
				look_ahead_routing_o = 3'd1;
		end
		else if (x_nxt_less_x_dst)
			look_ahead_routing_o = 3'd2;
		else
			look_ahead_routing_o = 3'd3;
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
module onehot_mux (
	sel_i,
	data_i,
	data_o
);
	parameter [31:0] SOURCE_COUNT = 2;
	parameter [31:0] DATA_WIDTH = 1;
	input wire [SOURCE_COUNT - 1:0] sel_i;
	input wire [(SOURCE_COUNT * DATA_WIDTH) - 1:0] data_i;
	output wire [DATA_WIDTH - 1:0] data_o;
	wire [(DATA_WIDTH * SOURCE_COUNT) - 1:0] trans_data;
	wire [(DATA_WIDTH * SOURCE_COUNT) - 1:0] select_mat;
	genvar i;
	generate
		for (i = 0; i < DATA_WIDTH; i = i + 1) begin : genblk1
			genvar j;
			for (j = 0; j < SOURCE_COUNT; j = j + 1) begin : genblk1
				assign trans_data[(i * SOURCE_COUNT) + j] = data_i[(j * DATA_WIDTH) + i];
			end
		end
		for (i = 0; i < DATA_WIDTH; i = i + 1) begin : genblk2
			assign select_mat[i * SOURCE_COUNT+:SOURCE_COUNT] = trans_data[i * SOURCE_COUNT+:SOURCE_COUNT] & sel_i;
			assign data_o[i] = |select_mat[i * SOURCE_COUNT+:SOURCE_COUNT];
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
module output_port_vc_assignment (
	sa_global_vld_i,
	sa_global_qos_value_i,
	sa_global_inport_id_oh_i,
	look_ahead_routing_i,
	vc_select_vld_i,
	vc_select_vc_id_i,
	vc_assignment_vld_o,
	vc_assignment_vc_id_o,
	look_ahead_routing_sel_o
);
	parameter OUTPUT_VC_NUM = 4;
	parameter OUTPUT_VC_NUM_IDX_W = (OUTPUT_VC_NUM > 1 ? $clog2(OUTPUT_VC_NUM) : 1);
	parameter SA_GLOBAL_INPUT_NUM = 4;
	parameter SA_GLOBAL_INPUT_NUM_IDX_W = (SA_GLOBAL_INPUT_NUM > 1 ? $clog2(SA_GLOBAL_INPUT_NUM) : 1);
	parameter OUTPUT_TO_N = 0;
	parameter OUTPUT_TO_S = 0;
	parameter OUTPUT_TO_E = 0;
	parameter OUTPUT_TO_W = 0;
	parameter OUTPUT_TO_L = 0;
	input wire sa_global_vld_i;
	localparam rvh_noc_pkg_QoS_Value_Width = 4;
	input wire [3:0] sa_global_qos_value_i;
	input wire [SA_GLOBAL_INPUT_NUM - 1:0] sa_global_inport_id_oh_i;
	input wire [(SA_GLOBAL_INPUT_NUM * 3) - 1:0] look_ahead_routing_i;
	input wire [(OUTPUT_VC_NUM * 2) - 1:0] vc_select_vld_i;
	localparam rvh_noc_pkg_CHANNEL_NUM = 4;
	localparam rvh_noc_pkg_INPUT_PORT_NUMBER = 6;
	localparam rvh_noc_pkg_ROUTER_PORT_NUMBER = 4;
	localparam rvh_noc_pkg_LOCAL_PORT_NUMBER = 2;
	localparam rvh_noc_pkg_QOS_VC_NUM_PER_INPUT = 1;
	localparam rvh_noc_pkg_VC_ID_NUM_MAX = 6;
	localparam rvh_noc_pkg_VC_ID_NUM_MAX_W = 3;
	input wire [(OUTPUT_VC_NUM * 6) - 1:0] vc_select_vc_id_i;
	output reg vc_assignment_vld_o;
	output reg [2:0] vc_assignment_vc_id_o;
	output wire [2:0] look_ahead_routing_sel_o;
	genvar i;
	wire [2:0] look_ahead_routing_sel;
	onehot_mux #(
		.SOURCE_COUNT(SA_GLOBAL_INPUT_NUM),
		.DATA_WIDTH(3)
	) onehot_mux_look_ahead_routing_sel_u(
		.sel_i(sa_global_inport_id_oh_i),
		.data_i(look_ahead_routing_i),
		.data_o(look_ahead_routing_sel)
	);
	assign look_ahead_routing_sel_o = look_ahead_routing_sel;
	wire sa_global_sel_rt_vc_flit_en;
	wire [(OUTPUT_VC_NUM - rvh_noc_pkg_QOS_VC_NUM_PER_INPUT) - 1:0] vc_select_vld;
	wire [((OUTPUT_VC_NUM - rvh_noc_pkg_QOS_VC_NUM_PER_INPUT) * 3) - 1:0] vc_select_vc_id;
	assign sa_global_sel_rt_vc_flit_en = 1'sb0;
	generate
		for (i = 0; i < (OUTPUT_VC_NUM - rvh_noc_pkg_QOS_VC_NUM_PER_INPUT); i = i + 1) begin : gen_vc_select_vld
			assign vc_select_vld[i] = (sa_global_sel_rt_vc_flit_en ? vc_select_vld_i[0] : vc_select_vld_i[((i + rvh_noc_pkg_QOS_VC_NUM_PER_INPUT) * 2) + 1]);
		end
		for (i = 0; i < (OUTPUT_VC_NUM - rvh_noc_pkg_QOS_VC_NUM_PER_INPUT); i = i + 1) begin : gen_vc_select_vc_id
			assign vc_select_vc_id[i * 3+:3] = (sa_global_sel_rt_vc_flit_en ? vc_select_vc_id_i[2-:rvh_noc_pkg_VC_ID_NUM_MAX_W] : vc_select_vc_id_i[((i + rvh_noc_pkg_QOS_VC_NUM_PER_INPUT) * 6) + 5-:3]);
		end
		if (OUTPUT_TO_N) begin : gen_output_to_n
			always @(*) begin
				vc_assignment_vld_o = 1'b0;
				vc_assignment_vc_id_o = 1'sb0;
				case (look_ahead_routing_sel)
					3'd0: begin
						vc_assignment_vld_o = vc_select_vld[0];
						vc_assignment_vc_id_o = vc_select_vc_id[0+:3];
					end
					3'd4: begin
						vc_assignment_vld_o = vc_select_vld[1];
						vc_assignment_vc_id_o = vc_select_vc_id[3+:3];
					end
					default:
						;
				endcase
			end
		end
		if (OUTPUT_TO_S) begin : gen_output_to_s
			always @(*) begin
				vc_assignment_vld_o = 1'b0;
				vc_assignment_vc_id_o = 1'sb0;
				case (look_ahead_routing_sel)
					3'd1: begin
						vc_assignment_vld_o = vc_select_vld[0];
						vc_assignment_vc_id_o = vc_select_vc_id[0+:3];
					end
					3'd4: begin
						vc_assignment_vld_o = vc_select_vld[1];
						vc_assignment_vc_id_o = vc_select_vc_id[3+:3];
					end
					default:
						;
				endcase
			end
		end
		if (OUTPUT_TO_E) begin : gen_output_to_e
			always @(*) begin
				vc_assignment_vld_o = 1'b0;
				vc_assignment_vc_id_o = 1'sb0;
				case (look_ahead_routing_sel)
					3'd0: begin
						vc_assignment_vld_o = vc_select_vld[0];
						vc_assignment_vc_id_o = vc_select_vc_id[0+:3];
					end
					3'd1: begin
						vc_assignment_vld_o = vc_select_vld[1];
						vc_assignment_vc_id_o = vc_select_vc_id[3+:3];
					end
					3'd2: begin
						vc_assignment_vld_o = vc_select_vld[2];
						vc_assignment_vc_id_o = vc_select_vc_id[6+:3];
					end
					3'd4: begin
						vc_assignment_vld_o = vc_select_vld[3];
						vc_assignment_vc_id_o = vc_select_vc_id[9+:3];
					end
					default:
						;
				endcase
			end
		end
		if (OUTPUT_TO_W) begin : gen_output_to_w
			always @(*) begin
				vc_assignment_vld_o = 1'b0;
				vc_assignment_vc_id_o = 1'sb0;
				case (look_ahead_routing_sel)
					3'd0: begin
						vc_assignment_vld_o = vc_select_vld[0];
						vc_assignment_vc_id_o = vc_select_vc_id[0+:3];
					end
					3'd1: begin
						vc_assignment_vld_o = vc_select_vld[1];
						vc_assignment_vc_id_o = vc_select_vc_id[3+:3];
					end
					3'd3: begin
						vc_assignment_vld_o = vc_select_vld[2];
						vc_assignment_vc_id_o = vc_select_vc_id[6+:3];
					end
					3'd4: begin
						vc_assignment_vld_o = vc_select_vld[3];
						vc_assignment_vc_id_o = vc_select_vc_id[9+:3];
					end
					default:
						;
				endcase
			end
		end
		if (OUTPUT_TO_L) begin : gen_output_to_l
			always @(*) begin
				vc_assignment_vld_o = 1'b0;
				vc_assignment_vc_id_o = 1'sb0;
				case (look_ahead_routing_sel)
					default: begin
						vc_assignment_vld_o = vc_select_vld_i[1];
						vc_assignment_vc_id_o = vc_select_vc_id_i[5-:3];
					end
				endcase
			end
		end
	endgenerate
endmodule
module output_port_vc_credit_counter (
	free_vc_credit_vld_i,
	free_vc_credit_vc_id_i,
	consume_vc_credit_vld_i,
	consume_vc_credit_vc_id_i,
	vc_credit_counter_o,
	clk,
	rstn
);
	parameter VC_NUM = 4;
	parameter VC_NUM_IDX_W = (VC_NUM > 1 ? $clog2(VC_NUM) : 1);
	parameter VC_DEPTH = 1;
	parameter VC_DEPTH_COUNTER_W = $clog2(VC_DEPTH + 1);
	input wire free_vc_credit_vld_i;
	input wire [VC_NUM_IDX_W - 1:0] free_vc_credit_vc_id_i;
	input wire consume_vc_credit_vld_i;
	input wire [VC_NUM_IDX_W - 1:0] consume_vc_credit_vc_id_i;
	output wire [(VC_NUM * VC_DEPTH_COUNTER_W) - 1:0] vc_credit_counter_o;
	input wire clk;
	input wire rstn;
	genvar i;
	reg [(VC_NUM * VC_DEPTH_COUNTER_W) - 1:0] vc_credit_counter_d;
	wire [(VC_NUM * VC_DEPTH_COUNTER_W) - 1:0] vc_credit_counter_q;
	wire [(VC_NUM * VC_DEPTH_COUNTER_W) - 1:0] vc_credit_counter_q_plus1;
	wire [(VC_NUM * VC_DEPTH_COUNTER_W) - 1:0] vc_credit_counter_q_minus1;
	reg [VC_NUM - 1:0] vc_credit_counter_ena;
	wire [VC_NUM - 1:0] free_vc_credit_vc_id_hit;
	wire [VC_NUM - 1:0] consume_vc_credit_vc_id_hit;
	generate
		for (i = 0; i < VC_NUM; i = i + 1) begin : gen_vc_credit_vc_id_hit
			assign free_vc_credit_vc_id_hit[i] = free_vc_credit_vld_i & (free_vc_credit_vc_id_i == i[VC_NUM_IDX_W - 1:0]);
			assign consume_vc_credit_vc_id_hit[i] = consume_vc_credit_vld_i & (consume_vc_credit_vc_id_i == i[VC_NUM_IDX_W - 1:0]);
		end
		for (i = 0; i < VC_NUM; i = i + 1) begin : gen_vc_credit_counter_q_plus1
			assign vc_credit_counter_q_plus1[i * VC_DEPTH_COUNTER_W+:VC_DEPTH_COUNTER_W] = vc_credit_counter_q[i * VC_DEPTH_COUNTER_W+:VC_DEPTH_COUNTER_W] + 1;
		end
		for (i = 0; i < VC_NUM; i = i + 1) begin : gen_vc_credit_counter_q_minus1
			assign vc_credit_counter_q_minus1[i * VC_DEPTH_COUNTER_W+:VC_DEPTH_COUNTER_W] = vc_credit_counter_q[i * VC_DEPTH_COUNTER_W+:VC_DEPTH_COUNTER_W] - 1;
		end
		for (i = 0; i < VC_NUM; i = i + 1) begin : gen_vc_credit_counter_d
			always @(*) begin
				vc_credit_counter_d[i * VC_DEPTH_COUNTER_W+:VC_DEPTH_COUNTER_W] = vc_credit_counter_q[i * VC_DEPTH_COUNTER_W+:VC_DEPTH_COUNTER_W];
				vc_credit_counter_ena[i] = 1'b0;
				if (free_vc_credit_vc_id_hit[i] & ~consume_vc_credit_vc_id_hit[i]) begin
					vc_credit_counter_d[i * VC_DEPTH_COUNTER_W+:VC_DEPTH_COUNTER_W] = vc_credit_counter_q_plus1[i * VC_DEPTH_COUNTER_W+:VC_DEPTH_COUNTER_W];
					vc_credit_counter_ena[i] = 1'b1;
				end
				else if (~free_vc_credit_vc_id_hit[i] & consume_vc_credit_vc_id_hit[i]) begin
					vc_credit_counter_d[i * VC_DEPTH_COUNTER_W+:VC_DEPTH_COUNTER_W] = vc_credit_counter_q_minus1[i * VC_DEPTH_COUNTER_W+:VC_DEPTH_COUNTER_W];
					vc_credit_counter_ena[i] = 1'b1;
				end
			end
		end
		for (i = 0; i < VC_NUM; i = i + 1) begin : gen_vc_credit_counter_q
			std_dffrve #(.WIDTH(VC_DEPTH_COUNTER_W)) U_DAT_VC_CREDIT_CONTER_REG(
				.clk(clk),
				.rstn(rstn),
				.rst_val(VC_DEPTH[VC_DEPTH_COUNTER_W - 1:0]),
				.en(vc_credit_counter_ena[i]),
				.d(vc_credit_counter_d[i * VC_DEPTH_COUNTER_W+:VC_DEPTH_COUNTER_W]),
				.q(vc_credit_counter_q[i * VC_DEPTH_COUNTER_W+:VC_DEPTH_COUNTER_W])
			);
		end
	endgenerate
	assign vc_credit_counter_o = vc_credit_counter_q;
endmodule
module output_port_vc_selection (
	vc_credit_counter_i,
	vc_select_vld_o,
	vc_select_vc_id_o
);
	parameter OUTPUT_VC_NUM = 4;
	parameter OUTPUT_VC_NUM_IDX_W = (OUTPUT_VC_NUM > 1 ? $clog2(OUTPUT_VC_NUM) : 1);
	parameter OUTPUT_VC_DEPTH = 1;
	parameter OUTPUT_VC_DEPTH_IDX_W = $clog2(OUTPUT_VC_DEPTH + 1);
	parameter OUTPUT_TO_L = 0;
	input wire [(OUTPUT_VC_NUM * OUTPUT_VC_DEPTH_IDX_W) - 1:0] vc_credit_counter_i;
	output reg [(OUTPUT_VC_NUM * 2) - 1:0] vc_select_vld_o;
	localparam rvh_noc_pkg_CHANNEL_NUM = 4;
	localparam rvh_noc_pkg_INPUT_PORT_NUMBER = 6;
	localparam rvh_noc_pkg_ROUTER_PORT_NUMBER = 4;
	localparam rvh_noc_pkg_LOCAL_PORT_NUMBER = 2;
	localparam rvh_noc_pkg_QOS_VC_NUM_PER_INPUT = 1;
	localparam rvh_noc_pkg_VC_ID_NUM_MAX = 6;
	localparam rvh_noc_pkg_VC_ID_NUM_MAX_W = 3;
	output reg [(OUTPUT_VC_NUM * 6) - 1:0] vc_select_vc_id_o;
	genvar i;
	wire [OUTPUT_VC_NUM - 1:0] vc_credit_counter_not_empty;
	generate
		for (i = 0; i < OUTPUT_VC_NUM; i = i + 1) begin : genblk1
			assign vc_credit_counter_not_empty[i] = |vc_credit_counter_i[i * OUTPUT_VC_DEPTH_IDX_W+:OUTPUT_VC_DEPTH_IDX_W];
		end
		if (!OUTPUT_TO_L) begin : genblk2
			always @(*) begin : comb_common_vc_id
				begin : sv2v_autoblock_1
					reg signed [31:0] i;
					for (i = rvh_noc_pkg_QOS_VC_NUM_PER_INPUT; i < OUTPUT_VC_NUM; i = i + 1)
						begin
							vc_select_vld_o[(i * 2) + 1] = 1'sb0;
							vc_select_vc_id_o[(i * 6) + 5-:3] = 1'sb0;
							vc_select_vld_o[i * 2] = 1'sb0;
							vc_select_vc_id_o[(i * 6) + 2-:rvh_noc_pkg_VC_ID_NUM_MAX_W] = 1'sb0;
							if (vc_credit_counter_not_empty[i]) begin
								vc_select_vld_o[(i * 2) + 1] = 1'b1;
								vc_select_vc_id_o[(i * 6) + 5-:3] = i[2:0];
							end
							else begin : sv2v_autoblock_2
								reg signed [31:0] j;
								for (j = rvh_noc_pkg_QOS_VC_NUM_PER_INPUT; j < OUTPUT_VC_NUM; j = j + 1)
									if (j != i)
										if (vc_credit_counter_not_empty[j]) begin
											vc_select_vld_o[(i * 2) + 1] = 1'b1;
											vc_select_vc_id_o[(i * 6) + 5-:3] = j[2:0];
										end
							end
						end
				end
			end
		end
		else begin : genblk2
			always @(*) begin : sv2v_autoblock_3
				reg signed [31:0] i;
				for (i = 0; i < OUTPUT_VC_NUM; i = i + 1)
					begin
						vc_select_vld_o[(i * 2) + 1] = 1'sb0;
						vc_select_vc_id_o[(i * 6) + 5-:3] = 1'sb0;
						vc_select_vld_o[i * 2] = 1'sb0;
						vc_select_vc_id_o[(i * 6) + 2-:rvh_noc_pkg_VC_ID_NUM_MAX_W] = 1'sb0;
						if (vc_credit_counter_not_empty[i]) begin
							vc_select_vld_o[(i * 2) + 1] = 1'b1;
							vc_select_vc_id_o[(i * 6) + 5-:3] = i[2:0];
						end
						else begin : sv2v_autoblock_4
							reg signed [31:0] j;
							for (j = 0; j < OUTPUT_VC_NUM; j = j + 1)
								if (j != i)
									if (vc_credit_counter_not_empty[j]) begin
										vc_select_vld_o[(i * 2) + 1] = 1'b1;
										vc_select_vc_id_o[(i * 6) + 5-:3] = j[2:0];
									end
						end
					end
			end
		end
	endgenerate
endmodule
module performance_monitor (
	sa_local_vld_i,
	sa_global_inport_read_vld_i,
	vc_credit_counter_toN_i,
	vc_credit_counter_toS_i,
	vc_credit_counter_toE_i,
	vc_credit_counter_toW_i,
	vc_credit_counter_toL_i,
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
	input wire [((LOCAL_PORT_NUM * VC_NUM_INPUT_L) * VC_DEPTH_INPUT_L_COUNTER_W) - 1:0] vc_credit_counter_toL_i;
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
module sa_local (
	vc_ctrl_head_vld_i,
	vc_ctrl_head_i,
	sa_local_vld_to_sa_global_o,
	sa_local_vld_o,
	sa_local_vc_id_o,
	sa_local_vc_id_oh_o,
	sa_local_qos_value_o,
	inport_read_enable_sa_stage_i,
	clk,
	rstn
);
	parameter INPUT_NUM = 4;
	parameter INPUT_NUM_IDX_W = (INPUT_NUM > 1 ? $clog2(INPUT_NUM) : 1);
	input wire [INPUT_NUM - 1:0] vc_ctrl_head_vld_i;
	localparam rvh_noc_pkg_QoS_Value_Width = 4;
	localparam rvh_noc_pkg_TxnID_Width = 12;
	localparam rvh_noc_pkg_NodeID_Device_Port_Width = 2;
	localparam rvh_noc_pkg_NodeID_X_Width = 2;
	localparam rvh_noc_pkg_NodeID_Y_Width = 2;
	input wire [(INPUT_NUM * 33) - 1:0] vc_ctrl_head_i;
	localparam rvh_noc_pkg_OUTPUT_PORT_NUMBER = 6;
	output wire [5:0] sa_local_vld_to_sa_global_o;
	output wire sa_local_vld_o;
	output wire [INPUT_NUM_IDX_W - 1:0] sa_local_vc_id_o;
	output wire [INPUT_NUM - 1:0] sa_local_vc_id_oh_o;
	output wire [3:0] sa_local_qos_value_o;
	input wire inport_read_enable_sa_stage_i;
	input wire clk;
	input wire rstn;
	genvar i;
	genvar j;
	wire [INPUT_NUM - 1:0] sa_local_grt_oh;
	wire [INPUT_NUM_IDX_W - 1:0] sa_local_grt_idx;
	wire [INPUT_NUM - 1:0] vc_ctrl_head_vld_join_arb;
	wire [(INPUT_NUM * 3) - 1:0] vc_ctrl_head_i_look_ahead_routing;
	wire [(INPUT_NUM * 6) - 1:0] vc_ctrl_head_i_look_ahead_routing_match;
	wire [3:0] vc_ctrl_head_i_qos_value_sel;
	wire [32:0] vc_ctrl_head_sel;
	wire [(INPUT_NUM * 4) - 1:0] vc_ctrl_head_qos_value;
	generate
		for (i = 0; i < INPUT_NUM; i = i + 1) begin : gen_vc_ctrl_head_qos_value
			assign vc_ctrl_head_qos_value[i * 4+:4] = vc_ctrl_head_i[(i * 33) + 3-:rvh_noc_pkg_QoS_Value_Width];
		end
	endgenerate
	priority_req_select #(
		.INPUT_NUM(INPUT_NUM),
		.INPUT_PRIORITY_W(rvh_noc_pkg_QoS_Value_Width)
	) sa_local_priority_req_select_u(
		.req_vld_i(vc_ctrl_head_vld_i),
		.req_priority_i(vc_ctrl_head_qos_value),
		.req_vld_o(vc_ctrl_head_vld_join_arb)
	);
	one_hot_rr_arb #(
		.N_INPUT(INPUT_NUM),
		.TIMEOUT_UPDATE_EN(1),
		.TIMEOUT_UPDATE_CYCLE(10)
	) sa_local_rr_arb_u(
		.req_i(vc_ctrl_head_vld_join_arb),
		.update_i(inport_read_enable_sa_stage_i),
		.grt_o(sa_local_grt_oh),
		.grt_idx_o(sa_local_grt_idx),
		.rstn(rstn),
		.clk(clk)
	);
	assign sa_local_vc_id_o = sa_local_grt_idx;
	assign sa_local_vc_id_oh_o = sa_local_grt_oh;
	assign sa_local_qos_value_o = vc_ctrl_head_sel[3-:rvh_noc_pkg_QoS_Value_Width];
	assign sa_local_vld_o = |vc_ctrl_head_vld_join_arb;
	generate
		for (i = 0; i < rvh_noc_pkg_OUTPUT_PORT_NUMBER; i = i + 1) begin : genblk2
			assign sa_local_vld_to_sa_global_o[i] = vc_ctrl_head_vld_join_arb[sa_local_grt_idx] & vc_ctrl_head_i_look_ahead_routing_match[(sa_local_grt_idx * 6) + i];
		end
		for (i = 0; i < INPUT_NUM; i = i + 1) begin : genblk3
			assign vc_ctrl_head_i_look_ahead_routing[i * 3+:3] = vc_ctrl_head_i[(i * 33) + 6-:3];
		end
		for (i = 0; i < INPUT_NUM; i = i + 1) begin : gen_vc_ctrl_head_i_look_ahead_routing_match_i
			for (j = 0; j < rvh_noc_pkg_OUTPUT_PORT_NUMBER; j = j + 1) begin : gen_vc_ctrl_head_i_look_ahead_routing_match_j
				assign vc_ctrl_head_i_look_ahead_routing_match[(i * 6) + j] = vc_ctrl_head_i_look_ahead_routing[i * 3+:3] == j[2:0];
			end
		end
	endgenerate
	onehot_mux #(
		.SOURCE_COUNT(INPUT_NUM),
		.DATA_WIDTH(33)
	) onehot_mux_qos_value_sel_u(
		.sel_i(sa_local_grt_oh),
		.data_i(vc_ctrl_head_i),
		.data_o(vc_ctrl_head_sel)
	);
endmodule
module std_dffe (
	clk,
	en,
	d,
	q
);
	parameter WIDTH = 8;
	input clk;
	input en;
	input [WIDTH - 1:0] d;
	output wire [WIDTH - 1:0] q;
	reg [WIDTH - 1:0] dff_q;
	always @(posedge clk)
		if (en)
			dff_q <= d;
	assign q = dff_q;
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
module std_dffr (
	clk,
	rstn,
	d,
	q
);
	parameter WIDTH = 8;
	input clk;
	input rstn;
	input [WIDTH - 1:0] d;
	output wire [WIDTH - 1:0] q;
	reg [WIDTH - 1:0] dff_q;
	always @(posedge clk or negedge rstn)
		if (~rstn)
			dff_q <= {WIDTH {1'b0}};
		else
			dff_q <= d;
	assign q = dff_q;
endmodule
module std_dffrve (
	clk,
	rstn,
	rst_val,
	en,
	d,
	q
);
	parameter WIDTH = 8;
	input clk;
	input rstn;
	input [WIDTH - 1:0] rst_val;
	input en;
	input [WIDTH - 1:0] d;
	output wire [WIDTH - 1:0] q;
	reg [WIDTH - 1:0] dff_q;
	always @(posedge clk or negedge rstn)
		if (~rstn)
			dff_q <= rst_val;
		else if (en)
			dff_q <= d;
	assign q = dff_q;
endmodule
module switch_AC76E (
	vc_data_head_fromN_i,
	vc_data_head_fromS_i,
	vc_data_head_fromE_i,
	vc_data_head_fromW_i,
	vc_data_head_fromL_i,
	inport_read_enable_st_stage_i,
	inport_read_vc_id_st_stage_i,
	outport_vld_st_stage_i,
	outport_select_inport_id_st_stage_i,
	outport_vc_id_st_stage_i,
	outport_look_ahead_routing_st_stage_i,
	tx_flit_pend_o,
	tx_flit_v_o,
	tx_flit_o,
	tx_flit_vc_id_o,
	tx_flit_look_ahead_routing_o
);
	parameter INPUT_PORT_NUM = 5;
	parameter OUTPUT_PORT_NUM = 5;
	parameter LOCAL_PORT_NUM = INPUT_PORT_NUM - 4;
	parameter VC_NUM_INPUT_N = 2;
	parameter VC_NUM_INPUT_S = 2;
	parameter VC_NUM_INPUT_E = 4;
	parameter VC_NUM_INPUT_W = 4;
	parameter VC_NUM_INPUT_L = 4;
	parameter VC_NUM_INPUT_N_IDX_W = (VC_NUM_INPUT_N > 1 ? $clog2(VC_NUM_INPUT_N) : 1);
	parameter VC_NUM_INPUT_S_IDX_W = (VC_NUM_INPUT_S > 1 ? $clog2(VC_NUM_INPUT_S) : 1);
	parameter VC_NUM_INPUT_E_IDX_W = (VC_NUM_INPUT_E > 1 ? $clog2(VC_NUM_INPUT_E) : 1);
	parameter VC_NUM_INPUT_W_IDX_W = (VC_NUM_INPUT_W > 1 ? $clog2(VC_NUM_INPUT_W) : 1);
	parameter VC_NUM_INPUT_L_IDX_W = (VC_NUM_INPUT_L > 1 ? $clog2(VC_NUM_INPUT_L) : 1);
	input wire [(VC_NUM_INPUT_N * 256) - 1:0] vc_data_head_fromN_i;
	input wire [(VC_NUM_INPUT_S * 256) - 1:0] vc_data_head_fromS_i;
	input wire [(VC_NUM_INPUT_E * 256) - 1:0] vc_data_head_fromE_i;
	input wire [(VC_NUM_INPUT_W * 256) - 1:0] vc_data_head_fromW_i;
	input wire [((LOCAL_PORT_NUM * VC_NUM_INPUT_L) * 256) - 1:0] vc_data_head_fromL_i;
	input wire [INPUT_PORT_NUM - 1:0] inport_read_enable_st_stage_i;
	localparam rvh_noc_pkg_CHANNEL_NUM = 4;
	localparam rvh_noc_pkg_INPUT_PORT_NUMBER = 6;
	localparam rvh_noc_pkg_ROUTER_PORT_NUMBER = 4;
	localparam rvh_noc_pkg_LOCAL_PORT_NUMBER = 2;
	localparam rvh_noc_pkg_QOS_VC_NUM_PER_INPUT = 1;
	localparam rvh_noc_pkg_VC_ID_NUM_MAX = 6;
	localparam rvh_noc_pkg_VC_ID_NUM_MAX_W = 3;
	input wire [(INPUT_PORT_NUM * 3) - 1:0] inport_read_vc_id_st_stage_i;
	input wire [OUTPUT_PORT_NUM - 1:0] outport_vld_st_stage_i;
	input wire [(OUTPUT_PORT_NUM * 3) - 1:0] outport_select_inport_id_st_stage_i;
	input wire [(OUTPUT_PORT_NUM * 3) - 1:0] outport_vc_id_st_stage_i;
	input wire [(OUTPUT_PORT_NUM * 3) - 1:0] outport_look_ahead_routing_st_stage_i;
	output wire [OUTPUT_PORT_NUM - 1:0] tx_flit_pend_o;
	output wire [OUTPUT_PORT_NUM - 1:0] tx_flit_v_o;
	output reg [(OUTPUT_PORT_NUM * 256) - 1:0] tx_flit_o;
	output wire [(OUTPUT_PORT_NUM * 3) - 1:0] tx_flit_vc_id_o;
	output wire [(OUTPUT_PORT_NUM * 3) - 1:0] tx_flit_look_ahead_routing_o;
	genvar i;
	assign tx_flit_pend_o = 1'sb1;
	wire [(INPUT_PORT_NUM * 256) - 1:0] vc_head_data;
	assign vc_head_data[0+:256] = vc_data_head_fromN_i[inport_read_vc_id_st_stage_i[VC_NUM_INPUT_N_IDX_W - 1-:VC_NUM_INPUT_N_IDX_W] * 256+:256];
	assign vc_head_data[256+:256] = vc_data_head_fromS_i[inport_read_vc_id_st_stage_i[VC_NUM_INPUT_S_IDX_W + 2-:VC_NUM_INPUT_S_IDX_W] * 256+:256];
	assign vc_head_data[512+:256] = vc_data_head_fromE_i[inport_read_vc_id_st_stage_i[VC_NUM_INPUT_E_IDX_W + 5-:VC_NUM_INPUT_E_IDX_W] * 256+:256];
	assign vc_head_data[768+:256] = vc_data_head_fromW_i[inport_read_vc_id_st_stage_i[VC_NUM_INPUT_W_IDX_W + 8-:VC_NUM_INPUT_W_IDX_W] * 256+:256];
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_have_vc_data_head_fromL_i
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : gen_vc_data_head_fromL_i
				assign vc_head_data[(4 + i) * 256+:256] = vc_data_head_fromL_i[((i * VC_NUM_INPUT_L) + inport_read_vc_id_st_stage_i[((4 + i) * 3) + (VC_NUM_INPUT_L_IDX_W - 1)-:VC_NUM_INPUT_L_IDX_W]) * 256+:256];
			end
		end
	endgenerate
	assign tx_flit_v_o = outport_vld_st_stage_i;
	assign tx_flit_vc_id_o = outport_vc_id_st_stage_i;
	assign tx_flit_look_ahead_routing_o = outport_look_ahead_routing_st_stage_i;
	always @(*)
		case (outport_select_inport_id_st_stage_i[0+:3])
			3'd1: tx_flit_o[0+:256] = vc_head_data[256+:256];
			3'd2: tx_flit_o[0+:256] = vc_head_data[512+:256];
			3'd3: tx_flit_o[0+:256] = vc_head_data[768+:256];
			3'd4: tx_flit_o[0+:256] = vc_head_data[1024+:256];
			3'd5: tx_flit_o[0+:256] = vc_head_data[1280+:256];
			default: tx_flit_o[0+:256] = vc_head_data[256+:256];
		endcase
	always @(*)
		case (outport_select_inport_id_st_stage_i[3+:3])
			3'd0: tx_flit_o[256+:256] = vc_head_data[0+:256];
			3'd2: tx_flit_o[256+:256] = vc_head_data[512+:256];
			3'd3: tx_flit_o[256+:256] = vc_head_data[768+:256];
			3'd4: tx_flit_o[256+:256] = vc_head_data[1024+:256];
			3'd5: tx_flit_o[256+:256] = vc_head_data[1280+:256];
			default: tx_flit_o[256+:256] = vc_head_data[0+:256];
		endcase
	always @(*)
		case (outport_select_inport_id_st_stage_i[6+:3])
			3'd3: tx_flit_o[512+:256] = vc_head_data[768+:256];
			3'd4: tx_flit_o[512+:256] = vc_head_data[1024+:256];
			3'd5: tx_flit_o[512+:256] = vc_head_data[1280+:256];
			default: tx_flit_o[512+:256] = vc_head_data[768+:256];
		endcase
	always @(*)
		case (outport_select_inport_id_st_stage_i[9+:3])
			3'd2: tx_flit_o[768+:256] = vc_head_data[512+:256];
			3'd4: tx_flit_o[768+:256] = vc_head_data[1024+:256];
			3'd5: tx_flit_o[768+:256] = vc_head_data[1280+:256];
			default: tx_flit_o[768+:256] = vc_head_data[512+:256];
		endcase
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_have_multi_local_port_in_switch
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : gen_multi_local_port_in_switch
				always @(*)
					case (outport_select_inport_id_st_stage_i[(4 + i) * 3+:3])
						3'd0: tx_flit_o[(4 + i) * 256+:256] = vc_head_data[0+:256];
						3'd1: tx_flit_o[(4 + i) * 256+:256] = vc_head_data[256+:256];
						3'd2: tx_flit_o[(4 + i) * 256+:256] = vc_head_data[512+:256];
						3'd3: tx_flit_o[(4 + i) * 256+:256] = vc_head_data[768+:256];
						3'd4: tx_flit_o[(4 + i) * 256+:256] = vc_head_data[1024+:256];
						3'd5: tx_flit_o[(4 + i) * 256+:256] = vc_head_data[1280+:256];
						default: tx_flit_o[(4 + i) * 256+:256] = vc_head_data[0+:256];
					endcase
			end
		end
	endgenerate
endmodule
module vnet_router (
	rx_flit_pend_i,
	rx_flit_v_i,
	rx_flit_i,
	rx_flit_vc_id_i,
	rx_flit_look_ahead_routing_i,
	tx_flit_pend_o,
	tx_flit_v_o,
	tx_flit_o,
	tx_flit_vc_id_o,
	tx_flit_look_ahead_routing_o,
	rx_lcrd_v_o,
	rx_lcrd_id_o,
	tx_lcrd_v_i,
	tx_lcrd_id_i,
	node_id_x_ths_hop_i,
	node_id_y_ths_hop_i,
	clk,
	rstn
);
	parameter INPUT_PORT_NUM = 5;
	parameter OUTPUT_PORT_NUM = 5;
	parameter LOCAL_PORT_NUM = INPUT_PORT_NUM - 4;
	parameter QOS_VC_NUM_PER_INPUT = 0;
	parameter VC_NUM_INPUT_N = (1 + LOCAL_PORT_NUM) + QOS_VC_NUM_PER_INPUT;
	parameter VC_NUM_INPUT_S = (1 + LOCAL_PORT_NUM) + QOS_VC_NUM_PER_INPUT;
	parameter VC_NUM_INPUT_E = (3 + LOCAL_PORT_NUM) + QOS_VC_NUM_PER_INPUT;
	parameter VC_NUM_INPUT_W = (3 + LOCAL_PORT_NUM) + QOS_VC_NUM_PER_INPUT;
	parameter VC_NUM_INPUT_L = ((4 + LOCAL_PORT_NUM) - 1) + QOS_VC_NUM_PER_INPUT;
	parameter VC_NUM_INPUT_N_IDX_W = (VC_NUM_INPUT_N > 1 ? $clog2(VC_NUM_INPUT_N) : 1);
	parameter VC_NUM_INPUT_S_IDX_W = (VC_NUM_INPUT_S > 1 ? $clog2(VC_NUM_INPUT_S) : 1);
	parameter VC_NUM_INPUT_E_IDX_W = (VC_NUM_INPUT_E > 1 ? $clog2(VC_NUM_INPUT_E) : 1);
	parameter VC_NUM_INPUT_W_IDX_W = (VC_NUM_INPUT_W > 1 ? $clog2(VC_NUM_INPUT_W) : 1);
	parameter VC_NUM_INPUT_L_IDX_W = (VC_NUM_INPUT_L > 1 ? $clog2(VC_NUM_INPUT_L) : 1);
	parameter SA_GLOBAL_INPUT_NUM_N = 3 + LOCAL_PORT_NUM;
	parameter SA_GLOBAL_INPUT_NUM_S = 3 + LOCAL_PORT_NUM;
	parameter SA_GLOBAL_INPUT_NUM_E = 1 + LOCAL_PORT_NUM;
	parameter SA_GLOBAL_INPUT_NUM_W = 1 + LOCAL_PORT_NUM;
	parameter SA_GLOBAL_INPUT_NUM_L = (4 + LOCAL_PORT_NUM) - 1;
	parameter SA_GLOBAL_INPUT_NUM_N_IDX_W = (SA_GLOBAL_INPUT_NUM_N > 1 ? $clog2(SA_GLOBAL_INPUT_NUM_N) : 1);
	parameter SA_GLOBAL_INPUT_NUM_S_IDX_W = (SA_GLOBAL_INPUT_NUM_S > 1 ? $clog2(SA_GLOBAL_INPUT_NUM_S) : 1);
	parameter SA_GLOBAL_INPUT_NUM_E_IDX_W = (SA_GLOBAL_INPUT_NUM_E > 1 ? $clog2(SA_GLOBAL_INPUT_NUM_E) : 1);
	parameter SA_GLOBAL_INPUT_NUM_W_IDX_W = (SA_GLOBAL_INPUT_NUM_W > 1 ? $clog2(SA_GLOBAL_INPUT_NUM_W) : 1);
	parameter SA_GLOBAL_INPUT_NUM_L_IDX_W = (SA_GLOBAL_INPUT_NUM_L > 1 ? $clog2(SA_GLOBAL_INPUT_NUM_L) : 1);
	parameter VC_NUM_OUTPUT_N = (1 + LOCAL_PORT_NUM) + QOS_VC_NUM_PER_INPUT;
	parameter VC_NUM_OUTPUT_S = (1 + LOCAL_PORT_NUM) + QOS_VC_NUM_PER_INPUT;
	parameter VC_NUM_OUTPUT_E = (3 + LOCAL_PORT_NUM) + QOS_VC_NUM_PER_INPUT;
	parameter VC_NUM_OUTPUT_W = (3 + LOCAL_PORT_NUM) + QOS_VC_NUM_PER_INPUT;
	parameter VC_NUM_OUTPUT_L = 1;
	parameter VC_NUM_OUTPUT_N_IDX_W = (VC_NUM_OUTPUT_N > 1 ? $clog2(VC_NUM_OUTPUT_N) : 1);
	parameter VC_NUM_OUTPUT_S_IDX_W = (VC_NUM_OUTPUT_S > 1 ? $clog2(VC_NUM_OUTPUT_S) : 1);
	parameter VC_NUM_OUTPUT_E_IDX_W = (VC_NUM_OUTPUT_E > 1 ? $clog2(VC_NUM_OUTPUT_E) : 1);
	parameter VC_NUM_OUTPUT_W_IDX_W = (VC_NUM_OUTPUT_W > 1 ? $clog2(VC_NUM_OUTPUT_W) : 1);
	parameter VC_NUM_OUTPUT_L_IDX_W = (VC_NUM_OUTPUT_L > 1 ? $clog2(VC_NUM_OUTPUT_L) : 1);
	parameter VC_DEPTH_INPUT_N = 2;
	parameter VC_DEPTH_INPUT_S = 2;
	parameter VC_DEPTH_INPUT_E = 2;
	parameter VC_DEPTH_INPUT_W = 2;
	parameter VC_DEPTH_INPUT_L = 2;
	parameter VC_DEPTH_OUTPUT_N = VC_DEPTH_INPUT_N;
	parameter VC_DEPTH_OUTPUT_S = VC_DEPTH_INPUT_S;
	parameter VC_DEPTH_OUTPUT_E = VC_DEPTH_INPUT_E;
	parameter VC_DEPTH_OUTPUT_W = VC_DEPTH_INPUT_W;
	parameter VC_DEPTH_OUTPUT_L = VC_DEPTH_INPUT_L;
	parameter VC_DEPTH_OUTPUT_N_COUNTER_W = $clog2(VC_DEPTH_OUTPUT_N + 1);
	parameter VC_DEPTH_OUTPUT_S_COUNTER_W = $clog2(VC_DEPTH_OUTPUT_S + 1);
	parameter VC_DEPTH_OUTPUT_E_COUNTER_W = $clog2(VC_DEPTH_OUTPUT_E + 1);
	parameter VC_DEPTH_OUTPUT_W_COUNTER_W = $clog2(VC_DEPTH_OUTPUT_W + 1);
	parameter VC_DEPTH_OUTPUT_L_COUNTER_W = $clog2(VC_DEPTH_OUTPUT_L + 1);
	input wire [INPUT_PORT_NUM - 1:0] rx_flit_pend_i;
	input wire [INPUT_PORT_NUM - 1:0] rx_flit_v_i;
	input wire [(INPUT_PORT_NUM * 256) - 1:0] rx_flit_i;
	localparam rvh_noc_pkg_CHANNEL_NUM = 4;
	localparam rvh_noc_pkg_INPUT_PORT_NUMBER = 6;
	localparam rvh_noc_pkg_ROUTER_PORT_NUMBER = 4;
	localparam rvh_noc_pkg_LOCAL_PORT_NUMBER = 2;
	localparam rvh_noc_pkg_QOS_VC_NUM_PER_INPUT = 1;
	localparam rvh_noc_pkg_VC_ID_NUM_MAX = 6;
	localparam rvh_noc_pkg_VC_ID_NUM_MAX_W = 3;
	input wire [(INPUT_PORT_NUM * 3) - 1:0] rx_flit_vc_id_i;
	input wire [(INPUT_PORT_NUM * 3) - 1:0] rx_flit_look_ahead_routing_i;
	output wire [OUTPUT_PORT_NUM - 1:0] tx_flit_pend_o;
	output wire [OUTPUT_PORT_NUM - 1:0] tx_flit_v_o;
	output wire [(OUTPUT_PORT_NUM * 256) - 1:0] tx_flit_o;
	output wire [(OUTPUT_PORT_NUM * 3) - 1:0] tx_flit_vc_id_o;
	output wire [(OUTPUT_PORT_NUM * 3) - 1:0] tx_flit_look_ahead_routing_o;
	output wire [INPUT_PORT_NUM - 1:0] rx_lcrd_v_o;
	output wire [(INPUT_PORT_NUM * 3) - 1:0] rx_lcrd_id_o;
	input wire [OUTPUT_PORT_NUM - 1:0] tx_lcrd_v_i;
	input wire [(OUTPUT_PORT_NUM * 3) - 1:0] tx_lcrd_id_i;
	localparam rvh_noc_pkg_NodeID_X_Width = 2;
	input wire [1:0] node_id_x_ths_hop_i;
	localparam rvh_noc_pkg_NodeID_Y_Width = 2;
	input wire [1:0] node_id_y_ths_hop_i;
	input wire clk;
	input wire rstn;
	genvar i;
	genvar j;
	genvar k;
	wire [INPUT_PORT_NUM - 1:0] inport_read_enable_sa_stage;
	wire [(INPUT_PORT_NUM * 3) - 1:0] inport_read_vc_id_sa_stage;
	wire [OUTPUT_PORT_NUM - 1:0] outport_vld_sa_stage;
	wire [(OUTPUT_PORT_NUM * 3) - 1:0] outport_select_inport_id_sa_stage;
	wire [(OUTPUT_PORT_NUM * 3) - 1:0] outport_vc_id_sa_stage;
	wire [(OUTPUT_PORT_NUM * 3) - 1:0] outport_look_ahead_routing_sa_stage;
	wire [OUTPUT_PORT_NUM - 1:0] consume_vc_credit_vld;
	wire [(OUTPUT_PORT_NUM * 3) - 1:0] consume_vc_credit_vc_id;
	wire [INPUT_PORT_NUM - 1:0] inport_read_enable_st_stage;
	wire [(INPUT_PORT_NUM * 3) - 1:0] inport_read_vc_id_st_stage;
	wire [OUTPUT_PORT_NUM - 1:0] outport_vld_st_stage;
	wire [(OUTPUT_PORT_NUM * 3) - 1:0] outport_select_inport_id_st_stage;
	wire [(OUTPUT_PORT_NUM * 3) - 1:0] outport_vc_id_st_stage;
	wire [(OUTPUT_PORT_NUM * 3) - 1:0] outport_look_ahead_routing_st_stage;
	wire [OUTPUT_PORT_NUM - 1:0] vc_assignment_vld;
	wire [(OUTPUT_PORT_NUM * 3) - 1:0] vc_assignment_vc_id;
	wire [(OUTPUT_PORT_NUM * 3) - 1:0] look_ahead_routing_sel;
	localparam rvh_noc_pkg_OUTPUT_PORT_NUMBER = 6;
	wire [(INPUT_PORT_NUM * 6) - 1:0] sa_local_vld_to_sa_global;
	wire [INPUT_PORT_NUM - 1:0] sa_local_vld;
	wire [(INPUT_PORT_NUM * 3) - 1:0] sa_local_vc_id;
	wire [(INPUT_PORT_NUM * 6) - 1:0] sa_local_vc_id_oh;
	localparam rvh_noc_pkg_QoS_Value_Width = 4;
	wire [(INPUT_PORT_NUM * 4) - 1:0] sa_local_qos_value;
	wire [VC_NUM_INPUT_N - 1:0] vc_ctrl_head_vld_N;
	localparam rvh_noc_pkg_TxnID_Width = 12;
	localparam rvh_noc_pkg_NodeID_Device_Port_Width = 2;
	wire [(VC_NUM_INPUT_N * 33) - 1:0] vc_ctrl_head_N;
	wire [VC_NUM_INPUT_S - 1:0] vc_ctrl_head_vld_S;
	wire [(VC_NUM_INPUT_S * 33) - 1:0] vc_ctrl_head_S;
	wire [VC_NUM_INPUT_E - 1:0] vc_ctrl_head_vld_E;
	wire [(VC_NUM_INPUT_E * 33) - 1:0] vc_ctrl_head_E;
	wire [VC_NUM_INPUT_W - 1:0] vc_ctrl_head_vld_W;
	wire [(VC_NUM_INPUT_W * 33) - 1:0] vc_ctrl_head_W;
	wire [(VC_NUM_INPUT_N * 256) - 1:0] vc_data_head_N;
	wire [(VC_NUM_INPUT_S * 256) - 1:0] vc_data_head_S;
	wire [(VC_NUM_INPUT_E * 256) - 1:0] vc_data_head_E;
	wire [(VC_NUM_INPUT_W * 256) - 1:0] vc_data_head_W;
	wire [(LOCAL_PORT_NUM * VC_NUM_INPUT_L) - 1:0] vc_ctrl_head_vld_L;
	wire [((LOCAL_PORT_NUM * VC_NUM_INPUT_L) * 33) - 1:0] vc_ctrl_head_L;
	wire [((LOCAL_PORT_NUM * VC_NUM_INPUT_L) * 256) - 1:0] vc_data_head_L;
	input_port #(
		.VC_NUM(VC_NUM_INPUT_N),
		.VC_DEPTH(VC_DEPTH_INPUT_N),
		.INPUT_PORT_NO(0)
	) input_port_fromN_u(
		.rx_flit_pend_i(rx_flit_pend_i[0]),
		.rx_flit_v_i(rx_flit_v_i[0]),
		.rx_flit_i(rx_flit_i[0+:256]),
		.rx_flit_vc_id_i(rx_flit_vc_id_i[VC_NUM_INPUT_N_IDX_W - 1-:VC_NUM_INPUT_N_IDX_W]),
		.rx_flit_look_ahead_routing_i(rx_flit_look_ahead_routing_i[0+:3]),
		.rx_lcrd_v_o(rx_lcrd_v_o[0]),
		.rx_lcrd_id_o(rx_lcrd_id_o[0+:3]),
		.vc_ctrl_head_vld_o(vc_ctrl_head_vld_N),
		.vc_ctrl_head_o(vc_ctrl_head_N),
		.vc_data_head_o(vc_data_head_N),
		.inport_read_enable_sa_stage_i(inport_read_enable_sa_stage[0]),
		.inport_read_vc_id_sa_stage_i(sa_local_vc_id[VC_NUM_INPUT_N_IDX_W - 1-:VC_NUM_INPUT_N_IDX_W]),
		.inport_read_enable_st_stage_i(inport_read_enable_st_stage[0]),
		.inport_read_vc_id_st_stage_i(inport_read_vc_id_st_stage[VC_NUM_INPUT_N_IDX_W - 1-:VC_NUM_INPUT_N_IDX_W]),
		.node_id_x_ths_hop_i(node_id_x_ths_hop_i),
		.node_id_y_ths_hop_i(node_id_y_ths_hop_i),
		.clk(clk),
		.rstn(rstn)
	);
	input_port #(
		.VC_NUM(VC_NUM_INPUT_S),
		.VC_DEPTH(VC_DEPTH_INPUT_S),
		.INPUT_PORT_NO(1)
	) input_port_fromS_u(
		.rx_flit_pend_i(rx_flit_pend_i[1]),
		.rx_flit_v_i(rx_flit_v_i[1]),
		.rx_flit_i(rx_flit_i[256+:256]),
		.rx_flit_vc_id_i(rx_flit_vc_id_i[VC_NUM_INPUT_S_IDX_W + 2-:VC_NUM_INPUT_S_IDX_W]),
		.rx_flit_look_ahead_routing_i(rx_flit_look_ahead_routing_i[3+:3]),
		.rx_lcrd_v_o(rx_lcrd_v_o[1]),
		.rx_lcrd_id_o(rx_lcrd_id_o[3+:3]),
		.vc_ctrl_head_vld_o(vc_ctrl_head_vld_S),
		.vc_ctrl_head_o(vc_ctrl_head_S),
		.vc_data_head_o(vc_data_head_S),
		.inport_read_enable_sa_stage_i(inport_read_enable_sa_stage[1]),
		.inport_read_vc_id_sa_stage_i(sa_local_vc_id[VC_NUM_INPUT_S_IDX_W + 2-:VC_NUM_INPUT_S_IDX_W]),
		.inport_read_enable_st_stage_i(inport_read_enable_st_stage[1]),
		.inport_read_vc_id_st_stage_i(inport_read_vc_id_st_stage[VC_NUM_INPUT_S_IDX_W + 2-:VC_NUM_INPUT_S_IDX_W]),
		.node_id_x_ths_hop_i(node_id_x_ths_hop_i),
		.node_id_y_ths_hop_i(node_id_y_ths_hop_i),
		.clk(clk),
		.rstn(rstn)
	);
	input_port #(
		.VC_NUM(VC_NUM_INPUT_E),
		.VC_DEPTH(VC_DEPTH_INPUT_E),
		.INPUT_PORT_NO(2)
	) input_port_fromE_u(
		.rx_flit_pend_i(rx_flit_pend_i[2]),
		.rx_flit_v_i(rx_flit_v_i[2]),
		.rx_flit_i(rx_flit_i[512+:256]),
		.rx_flit_vc_id_i(rx_flit_vc_id_i[VC_NUM_INPUT_E_IDX_W + 5-:VC_NUM_INPUT_E_IDX_W]),
		.rx_flit_look_ahead_routing_i(rx_flit_look_ahead_routing_i[6+:3]),
		.rx_lcrd_v_o(rx_lcrd_v_o[2]),
		.rx_lcrd_id_o(rx_lcrd_id_o[6+:3]),
		.vc_ctrl_head_vld_o(vc_ctrl_head_vld_E),
		.vc_ctrl_head_o(vc_ctrl_head_E),
		.vc_data_head_o(vc_data_head_E),
		.inport_read_enable_sa_stage_i(inport_read_enable_sa_stage[2]),
		.inport_read_vc_id_sa_stage_i(sa_local_vc_id[VC_NUM_INPUT_E_IDX_W + 5-:VC_NUM_INPUT_E_IDX_W]),
		.inport_read_enable_st_stage_i(inport_read_enable_st_stage[2]),
		.inport_read_vc_id_st_stage_i(inport_read_vc_id_st_stage[VC_NUM_INPUT_E_IDX_W + 5-:VC_NUM_INPUT_E_IDX_W]),
		.node_id_x_ths_hop_i(node_id_x_ths_hop_i),
		.node_id_y_ths_hop_i(node_id_y_ths_hop_i),
		.clk(clk),
		.rstn(rstn)
	);
	input_port #(
		.VC_NUM(VC_NUM_INPUT_W),
		.VC_DEPTH(VC_DEPTH_INPUT_W),
		.INPUT_PORT_NO(3)
	) input_port_fromW_u(
		.rx_flit_pend_i(rx_flit_pend_i[3]),
		.rx_flit_v_i(rx_flit_v_i[3]),
		.rx_flit_i(rx_flit_i[768+:256]),
		.rx_flit_vc_id_i(rx_flit_vc_id_i[VC_NUM_INPUT_W_IDX_W + 8-:VC_NUM_INPUT_W_IDX_W]),
		.rx_flit_look_ahead_routing_i(rx_flit_look_ahead_routing_i[9+:3]),
		.rx_lcrd_v_o(rx_lcrd_v_o[3]),
		.rx_lcrd_id_o(rx_lcrd_id_o[9+:3]),
		.vc_ctrl_head_vld_o(vc_ctrl_head_vld_W),
		.vc_ctrl_head_o(vc_ctrl_head_W),
		.vc_data_head_o(vc_data_head_W),
		.inport_read_enable_sa_stage_i(inport_read_enable_sa_stage[3]),
		.inport_read_vc_id_sa_stage_i(sa_local_vc_id[VC_NUM_INPUT_W_IDX_W + 8-:VC_NUM_INPUT_W_IDX_W]),
		.inport_read_enable_st_stage_i(inport_read_enable_st_stage[3]),
		.inport_read_vc_id_st_stage_i(inport_read_vc_id_st_stage[VC_NUM_INPUT_W_IDX_W + 8-:VC_NUM_INPUT_W_IDX_W]),
		.node_id_x_ths_hop_i(node_id_x_ths_hop_i),
		.node_id_y_ths_hop_i(node_id_y_ths_hop_i),
		.clk(clk),
		.rstn(rstn)
	);
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_have_input_port_fromL
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : gen_input_port_fromL
				input_port #(
					.VC_NUM(VC_NUM_INPUT_L),
					.VC_DEPTH(VC_DEPTH_INPUT_L),
					.INPUT_PORT_NO(4 + i)
				) input_port_fromL_u(
					.rx_flit_pend_i(rx_flit_pend_i[4 + i]),
					.rx_flit_v_i(rx_flit_v_i[4 + i]),
					.rx_flit_i(rx_flit_i[(4 + i) * 256+:256]),
					.rx_flit_vc_id_i(rx_flit_vc_id_i[((4 + i) * 3) + (VC_NUM_INPUT_L_IDX_W - 1)-:VC_NUM_INPUT_L_IDX_W]),
					.rx_flit_look_ahead_routing_i(rx_flit_look_ahead_routing_i[(4 + i) * 3+:3]),
					.rx_lcrd_v_o(rx_lcrd_v_o[4 + i]),
					.rx_lcrd_id_o(rx_lcrd_id_o[(4 + i) * 3+:3]),
					.vc_ctrl_head_vld_o(vc_ctrl_head_vld_L[i * VC_NUM_INPUT_L+:VC_NUM_INPUT_L]),
					.vc_ctrl_head_o(vc_ctrl_head_L[33 * (i * VC_NUM_INPUT_L)+:33 * VC_NUM_INPUT_L]),
					.vc_data_head_o(vc_data_head_L[256 * (i * VC_NUM_INPUT_L)+:256 * VC_NUM_INPUT_L]),
					.inport_read_enable_sa_stage_i(inport_read_enable_sa_stage[4 + i]),
					.inport_read_vc_id_sa_stage_i(sa_local_vc_id[((4 + i) * 3) + (VC_NUM_INPUT_L_IDX_W - 1)-:VC_NUM_INPUT_L_IDX_W]),
					.inport_read_enable_st_stage_i(inport_read_enable_st_stage[4 + i]),
					.inport_read_vc_id_st_stage_i(inport_read_vc_id_st_stage[((4 + i) * 3) + (VC_NUM_INPUT_L_IDX_W - 1)-:VC_NUM_INPUT_L_IDX_W]),
					.node_id_x_ths_hop_i(node_id_x_ths_hop_i),
					.node_id_y_ths_hop_i(node_id_y_ths_hop_i),
					.clk(clk),
					.rstn(rstn)
				);
			end
		end
	endgenerate
	sa_local #(.INPUT_NUM(VC_NUM_INPUT_N)) sa_local_fromN_u(
		.vc_ctrl_head_vld_i(vc_ctrl_head_vld_N),
		.vc_ctrl_head_i(vc_ctrl_head_N),
		.sa_local_vld_to_sa_global_o(sa_local_vld_to_sa_global[0+:6]),
		.sa_local_vld_o(sa_local_vld[0]),
		.sa_local_vc_id_o(sa_local_vc_id[VC_NUM_INPUT_N_IDX_W - 1-:VC_NUM_INPUT_N_IDX_W]),
		.sa_local_vc_id_oh_o(sa_local_vc_id_oh[VC_NUM_INPUT_N - 1-:VC_NUM_INPUT_N]),
		.sa_local_qos_value_o(sa_local_qos_value[0+:4]),
		.inport_read_enable_sa_stage_i(inport_read_enable_sa_stage[0]),
		.clk(clk),
		.rstn(rstn)
	);
	generate
		if (rvh_noc_pkg_VC_ID_NUM_MAX_W > VC_NUM_INPUT_N_IDX_W) begin : genblk2
			assign sa_local_vc_id[0 + (2 >= VC_NUM_INPUT_N_IDX_W ? 2 : (2 + (2 >= VC_NUM_INPUT_N_IDX_W ? 3 - VC_NUM_INPUT_N_IDX_W : VC_NUM_INPUT_N_IDX_W - 1)) - 1)-:(2 >= VC_NUM_INPUT_N_IDX_W ? 3 - VC_NUM_INPUT_N_IDX_W : VC_NUM_INPUT_N_IDX_W - 1)] = 1'sb0;
		end
	endgenerate
	sa_local #(.INPUT_NUM(VC_NUM_INPUT_S)) sa_local_fromS_u(
		.vc_ctrl_head_vld_i(vc_ctrl_head_vld_S),
		.vc_ctrl_head_i(vc_ctrl_head_S),
		.sa_local_vld_to_sa_global_o(sa_local_vld_to_sa_global[6+:6]),
		.sa_local_vld_o(sa_local_vld[1]),
		.sa_local_vc_id_o(sa_local_vc_id[VC_NUM_INPUT_S_IDX_W + 2-:VC_NUM_INPUT_S_IDX_W]),
		.sa_local_vc_id_oh_o(sa_local_vc_id_oh[VC_NUM_INPUT_S + 5-:VC_NUM_INPUT_S]),
		.sa_local_qos_value_o(sa_local_qos_value[4+:4]),
		.inport_read_enable_sa_stage_i(inport_read_enable_sa_stage[1]),
		.clk(clk),
		.rstn(rstn)
	);
	generate
		if (rvh_noc_pkg_VC_ID_NUM_MAX_W > VC_NUM_INPUT_S_IDX_W) begin : genblk3
			assign sa_local_vc_id[3 + (2 >= VC_NUM_INPUT_S_IDX_W ? 2 : (2 + (2 >= VC_NUM_INPUT_S_IDX_W ? 3 - VC_NUM_INPUT_S_IDX_W : VC_NUM_INPUT_S_IDX_W - 1)) - 1)-:(2 >= VC_NUM_INPUT_S_IDX_W ? 3 - VC_NUM_INPUT_S_IDX_W : VC_NUM_INPUT_S_IDX_W - 1)] = 1'sb0;
		end
	endgenerate
	sa_local #(.INPUT_NUM(VC_NUM_INPUT_E)) sa_local_fromE_u(
		.vc_ctrl_head_vld_i(vc_ctrl_head_vld_E),
		.vc_ctrl_head_i(vc_ctrl_head_E),
		.sa_local_vld_to_sa_global_o(sa_local_vld_to_sa_global[12+:6]),
		.sa_local_vld_o(sa_local_vld[2]),
		.sa_local_vc_id_o(sa_local_vc_id[VC_NUM_INPUT_E_IDX_W + 5-:VC_NUM_INPUT_E_IDX_W]),
		.sa_local_vc_id_oh_o(sa_local_vc_id_oh[VC_NUM_INPUT_E + 11-:VC_NUM_INPUT_E]),
		.sa_local_qos_value_o(sa_local_qos_value[8+:4]),
		.inport_read_enable_sa_stage_i(inport_read_enable_sa_stage[2]),
		.clk(clk),
		.rstn(rstn)
	);
	generate
		if (rvh_noc_pkg_VC_ID_NUM_MAX_W > VC_NUM_INPUT_E_IDX_W) begin : genblk4
			assign sa_local_vc_id[6 + (2 >= VC_NUM_INPUT_E_IDX_W ? 2 : (2 + (2 >= VC_NUM_INPUT_E_IDX_W ? 3 - VC_NUM_INPUT_E_IDX_W : VC_NUM_INPUT_E_IDX_W - 1)) - 1)-:(2 >= VC_NUM_INPUT_E_IDX_W ? 3 - VC_NUM_INPUT_E_IDX_W : VC_NUM_INPUT_E_IDX_W - 1)] = 1'sb0;
		end
	endgenerate
	sa_local #(.INPUT_NUM(VC_NUM_INPUT_W)) sa_local_fromW_u(
		.vc_ctrl_head_vld_i(vc_ctrl_head_vld_W),
		.vc_ctrl_head_i(vc_ctrl_head_W),
		.sa_local_vld_to_sa_global_o(sa_local_vld_to_sa_global[18+:6]),
		.sa_local_vld_o(sa_local_vld[3]),
		.sa_local_vc_id_o(sa_local_vc_id[VC_NUM_INPUT_W_IDX_W + 8-:VC_NUM_INPUT_W_IDX_W]),
		.sa_local_vc_id_oh_o(sa_local_vc_id_oh[VC_NUM_INPUT_W + 17-:VC_NUM_INPUT_W]),
		.sa_local_qos_value_o(sa_local_qos_value[12+:4]),
		.inport_read_enable_sa_stage_i(inport_read_enable_sa_stage[3]),
		.clk(clk),
		.rstn(rstn)
	);
	generate
		if (rvh_noc_pkg_VC_ID_NUM_MAX_W > VC_NUM_INPUT_W_IDX_W) begin : genblk5
			assign sa_local_vc_id[9 + (2 >= VC_NUM_INPUT_W_IDX_W ? 2 : (2 + (2 >= VC_NUM_INPUT_W_IDX_W ? 3 - VC_NUM_INPUT_W_IDX_W : VC_NUM_INPUT_W_IDX_W - 1)) - 1)-:(2 >= VC_NUM_INPUT_W_IDX_W ? 3 - VC_NUM_INPUT_W_IDX_W : VC_NUM_INPUT_W_IDX_W - 1)] = 1'sb0;
		end
		if (LOCAL_PORT_NUM > 0) begin : gen_have_sa_local_fromL
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : gen_sa_local_fromL
				sa_local #(.INPUT_NUM(VC_NUM_INPUT_L)) sa_local_fromL_u(
					.vc_ctrl_head_vld_i(vc_ctrl_head_vld_L[i * VC_NUM_INPUT_L+:VC_NUM_INPUT_L]),
					.vc_ctrl_head_i(vc_ctrl_head_L[33 * (i * VC_NUM_INPUT_L)+:33 * VC_NUM_INPUT_L]),
					.sa_local_vld_to_sa_global_o(sa_local_vld_to_sa_global[(4 + i) * 6+:6]),
					.sa_local_vld_o(sa_local_vld[4 + i]),
					.sa_local_vc_id_o(sa_local_vc_id[((4 + i) * 3) + (VC_NUM_INPUT_L_IDX_W - 1)-:VC_NUM_INPUT_L_IDX_W]),
					.sa_local_vc_id_oh_o(sa_local_vc_id_oh[((4 + i) * 6) + (VC_NUM_INPUT_L - 1)-:VC_NUM_INPUT_L]),
					.sa_local_qos_value_o(sa_local_qos_value[(4 + i) * 4+:4]),
					.inport_read_enable_sa_stage_i(inport_read_enable_sa_stage[4 + i]),
					.clk(clk),
					.rstn(rstn)
				);
				if (rvh_noc_pkg_VC_ID_NUM_MAX_W > VC_NUM_INPUT_L_IDX_W) begin : genblk1
					assign sa_local_vc_id[((4 + i) * 3) + (2 >= VC_NUM_INPUT_L_IDX_W ? 2 : (2 + (2 >= VC_NUM_INPUT_L_IDX_W ? 3 - VC_NUM_INPUT_L_IDX_W : VC_NUM_INPUT_L_IDX_W - 1)) - 1)-:(2 >= VC_NUM_INPUT_L_IDX_W ? 3 - VC_NUM_INPUT_L_IDX_W : VC_NUM_INPUT_L_IDX_W - 1)] = 1'sb0;
				end
			end
		end
	endgenerate
	wire [OUTPUT_PORT_NUM - 1:0] sa_global_vld;
	wire [(OUTPUT_PORT_NUM * 4) - 1:0] sa_global_qos_value;
	localparam rvh_noc_pkg_SA_GLOBAL_INPUT_NUM_MAX = 5;
	wire [(OUTPUT_PORT_NUM * 5) - 1:0] sa_global_inport_id_oh;
	wire [(OUTPUT_PORT_NUM * 3) - 1:0] sa_global_inport_vc_id;
	wire [SA_GLOBAL_INPUT_NUM_N - 1:0] sa_local_vld_to_sa_global_all_inport_toN;
	wire [(SA_GLOBAL_INPUT_NUM_N * 3) - 1:0] sa_local_vc_id_all_inport_toN;
	wire [SA_GLOBAL_INPUT_NUM_S - 1:0] sa_local_vld_to_sa_global_all_inport_toS;
	wire [(SA_GLOBAL_INPUT_NUM_S * 3) - 1:0] sa_local_vc_id_all_inport_toS;
	wire [SA_GLOBAL_INPUT_NUM_E - 1:0] sa_local_vld_to_sa_global_all_inport_toE;
	wire [(SA_GLOBAL_INPUT_NUM_E * 3) - 1:0] sa_local_vc_id_all_inport_toE;
	wire [SA_GLOBAL_INPUT_NUM_W - 1:0] sa_local_vld_to_sa_global_all_inport_toW;
	wire [(SA_GLOBAL_INPUT_NUM_W * 3) - 1:0] sa_local_vc_id_all_inport_toW;
	reg [(LOCAL_PORT_NUM * SA_GLOBAL_INPUT_NUM_L) - 1:0] sa_local_vld_to_sa_global_all_inport_toL;
	reg [((LOCAL_PORT_NUM * SA_GLOBAL_INPUT_NUM_L) * 3) - 1:0] sa_local_vc_id_all_inport_toL;
	reg [((LOCAL_PORT_NUM * SA_GLOBAL_INPUT_NUM_L) * 4) - 1:0] sa_local_qos_value_all_inport_toL;
	wire [(SA_GLOBAL_INPUT_NUM_N * 4) - 1:0] sa_local_qos_value_all_inport_toN;
	wire [(SA_GLOBAL_INPUT_NUM_S * 4) - 1:0] sa_local_qos_value_all_inport_toS;
	wire [(SA_GLOBAL_INPUT_NUM_E * 4) - 1:0] sa_local_qos_value_all_inport_toE;
	wire [(SA_GLOBAL_INPUT_NUM_W * 4) - 1:0] sa_local_qos_value_all_inport_toW;
	assign sa_local_vld_to_sa_global_all_inport_toN[0] = sa_local_vld_to_sa_global[6];
	assign sa_local_vld_to_sa_global_all_inport_toN[1] = sa_local_vld_to_sa_global[12];
	assign sa_local_vld_to_sa_global_all_inport_toN[2] = sa_local_vld_to_sa_global[18];
	assign sa_local_vc_id_all_inport_toN[0+:3] = sa_local_vc_id[3+:3];
	assign sa_local_vc_id_all_inport_toN[3+:3] = sa_local_vc_id[6+:3];
	assign sa_local_vc_id_all_inport_toN[6+:3] = sa_local_vc_id[9+:3];
	assign sa_local_qos_value_all_inport_toN[0+:4] = sa_local_qos_value[4+:4];
	assign sa_local_qos_value_all_inport_toN[4+:4] = sa_local_qos_value[8+:4];
	assign sa_local_qos_value_all_inport_toN[8+:4] = sa_local_qos_value[12+:4];
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_sa_local_vld_to_sa_global_all_inport_toN_fromL_signal
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : genblk1
				assign sa_local_vld_to_sa_global_all_inport_toN[3 + i] = sa_local_vld_to_sa_global[(4 + i) * 6];
				assign sa_local_vc_id_all_inport_toN[(3 + i) * 3+:3] = sa_local_vc_id[(4 + i) * 3+:3];
				assign sa_local_qos_value_all_inport_toN[(3 + i) * 4+:4] = sa_local_qos_value[(4 + i) * 4+:4];
			end
		end
	endgenerate
	sa_global #(.INPUT_NUM(SA_GLOBAL_INPUT_NUM_N)) sa_global_toN_u(
		.sa_local_vld_i(sa_local_vld_to_sa_global_all_inport_toN),
		.sa_local_vc_id_i(sa_local_vc_id_all_inport_toN),
		.sa_local_qos_value_i(sa_local_qos_value_all_inport_toN),
		.sa_global_vld_o(sa_global_vld[0]),
		.sa_global_qos_value_o(sa_global_qos_value[0+:4]),
		.sa_global_inport_id_oh_o(sa_global_inport_id_oh[SA_GLOBAL_INPUT_NUM_N - 1-:SA_GLOBAL_INPUT_NUM_N]),
		.sa_global_inport_vc_id_o(sa_global_inport_vc_id[0+:3]),
		.vc_assignment_vld_i(vc_assignment_vld[0]),
		.clk(clk),
		.rstn(rstn)
	);
	generate
		if (rvh_noc_pkg_SA_GLOBAL_INPUT_NUM_MAX > SA_GLOBAL_INPUT_NUM_N) begin : genblk8
			assign sa_global_inport_id_oh[0 + (4 >= SA_GLOBAL_INPUT_NUM_N ? 4 : (4 + (4 >= SA_GLOBAL_INPUT_NUM_N ? 5 - SA_GLOBAL_INPUT_NUM_N : SA_GLOBAL_INPUT_NUM_N - 3)) - 1)-:(4 >= SA_GLOBAL_INPUT_NUM_N ? 5 - SA_GLOBAL_INPUT_NUM_N : SA_GLOBAL_INPUT_NUM_N - 3)] = 1'sb0;
		end
	endgenerate
	assign sa_local_vld_to_sa_global_all_inport_toS[0] = sa_local_vld_to_sa_global[1];
	assign sa_local_vld_to_sa_global_all_inport_toS[1] = sa_local_vld_to_sa_global[13];
	assign sa_local_vld_to_sa_global_all_inport_toS[2] = sa_local_vld_to_sa_global[19];
	assign sa_local_vc_id_all_inport_toS[0+:3] = sa_local_vc_id[0+:3];
	assign sa_local_vc_id_all_inport_toS[3+:3] = sa_local_vc_id[6+:3];
	assign sa_local_vc_id_all_inport_toS[6+:3] = sa_local_vc_id[9+:3];
	assign sa_local_qos_value_all_inport_toS[0+:4] = sa_local_qos_value[0+:4];
	assign sa_local_qos_value_all_inport_toS[4+:4] = sa_local_qos_value[8+:4];
	assign sa_local_qos_value_all_inport_toS[8+:4] = sa_local_qos_value[12+:4];
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_sa_local_vld_to_sa_global_all_inport_toS_fromL_signal
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : genblk1
				assign sa_local_vld_to_sa_global_all_inport_toS[3 + i] = sa_local_vld_to_sa_global[((4 + i) * 6) + 1];
				assign sa_local_vc_id_all_inport_toS[(3 + i) * 3+:3] = sa_local_vc_id[(4 + i) * 3+:3];
				assign sa_local_qos_value_all_inport_toS[(3 + i) * 4+:4] = sa_local_qos_value[(4 + i) * 4+:4];
			end
		end
	endgenerate
	sa_global #(.INPUT_NUM(SA_GLOBAL_INPUT_NUM_S)) sa_global_toS_u(
		.sa_local_vld_i(sa_local_vld_to_sa_global_all_inport_toS),
		.sa_local_vc_id_i(sa_local_vc_id_all_inport_toS),
		.sa_local_qos_value_i(sa_local_qos_value_all_inport_toS),
		.sa_global_vld_o(sa_global_vld[1]),
		.sa_global_qos_value_o(sa_global_qos_value[4+:4]),
		.sa_global_inport_id_oh_o(sa_global_inport_id_oh[SA_GLOBAL_INPUT_NUM_S + 4-:SA_GLOBAL_INPUT_NUM_S]),
		.sa_global_inport_vc_id_o(sa_global_inport_vc_id[3+:3]),
		.vc_assignment_vld_i(vc_assignment_vld[1]),
		.clk(clk),
		.rstn(rstn)
	);
	generate
		if (rvh_noc_pkg_SA_GLOBAL_INPUT_NUM_MAX > SA_GLOBAL_INPUT_NUM_S) begin : genblk10
			assign sa_global_inport_id_oh[5 + (4 >= SA_GLOBAL_INPUT_NUM_S ? 4 : (4 + (4 >= SA_GLOBAL_INPUT_NUM_S ? 5 - SA_GLOBAL_INPUT_NUM_S : SA_GLOBAL_INPUT_NUM_S - 3)) - 1)-:(4 >= SA_GLOBAL_INPUT_NUM_S ? 5 - SA_GLOBAL_INPUT_NUM_S : SA_GLOBAL_INPUT_NUM_S - 3)] = 1'sb0;
		end
	endgenerate
	assign sa_local_vld_to_sa_global_all_inport_toE[0] = sa_local_vld_to_sa_global[20];
	assign sa_local_vc_id_all_inport_toE[0+:3] = sa_local_vc_id[9+:3];
	assign sa_local_qos_value_all_inport_toE[0+:4] = sa_local_qos_value[12+:4];
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_sa_local_vld_to_sa_global_all_inport_toE_fromL_signal
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : genblk1
				assign sa_local_vld_to_sa_global_all_inport_toE[1 + i] = sa_local_vld_to_sa_global[((4 + i) * 6) + 2];
				assign sa_local_vc_id_all_inport_toE[(1 + i) * 3+:3] = sa_local_vc_id[(4 + i) * 3+:3];
				assign sa_local_qos_value_all_inport_toE[(1 + i) * 4+:4] = sa_local_qos_value[(4 + i) * 4+:4];
			end
		end
	endgenerate
	sa_global #(.INPUT_NUM(SA_GLOBAL_INPUT_NUM_E)) sa_global_toE_u(
		.sa_local_vld_i(sa_local_vld_to_sa_global_all_inport_toE),
		.sa_local_vc_id_i(sa_local_vc_id_all_inport_toE),
		.sa_local_qos_value_i(sa_local_qos_value_all_inport_toE),
		.sa_global_vld_o(sa_global_vld[2]),
		.sa_global_qos_value_o(sa_global_qos_value[8+:4]),
		.sa_global_inport_id_oh_o(sa_global_inport_id_oh[SA_GLOBAL_INPUT_NUM_E + 9-:SA_GLOBAL_INPUT_NUM_E]),
		.sa_global_inport_vc_id_o(sa_global_inport_vc_id[6+:3]),
		.vc_assignment_vld_i(vc_assignment_vld[2]),
		.clk(clk),
		.rstn(rstn)
	);
	generate
		if (rvh_noc_pkg_SA_GLOBAL_INPUT_NUM_MAX > SA_GLOBAL_INPUT_NUM_E) begin : genblk12
			assign sa_global_inport_id_oh[10 + (4 >= SA_GLOBAL_INPUT_NUM_E ? 4 : (4 + (4 >= SA_GLOBAL_INPUT_NUM_E ? 5 - SA_GLOBAL_INPUT_NUM_E : SA_GLOBAL_INPUT_NUM_E - 3)) - 1)-:(4 >= SA_GLOBAL_INPUT_NUM_E ? 5 - SA_GLOBAL_INPUT_NUM_E : SA_GLOBAL_INPUT_NUM_E - 3)] = 1'sb0;
		end
	endgenerate
	assign sa_local_vld_to_sa_global_all_inport_toW[0] = sa_local_vld_to_sa_global[15];
	assign sa_local_vc_id_all_inport_toW[0+:3] = sa_local_vc_id[6+:3];
	assign sa_local_qos_value_all_inport_toW[0+:4] = sa_local_qos_value[8+:4];
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_sa_local_vld_to_sa_global_all_inport_toW_fromL_signal
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : genblk1
				assign sa_local_vld_to_sa_global_all_inport_toW[1 + i] = sa_local_vld_to_sa_global[((4 + i) * 6) + 3];
				assign sa_local_vc_id_all_inport_toW[(1 + i) * 3+:3] = sa_local_vc_id[(4 + i) * 3+:3];
				assign sa_local_qos_value_all_inport_toW[(1 + i) * 4+:4] = sa_local_qos_value[(4 + i) * 4+:4];
			end
		end
	endgenerate
	sa_global #(.INPUT_NUM(SA_GLOBAL_INPUT_NUM_W)) sa_global_toW_u(
		.sa_local_vld_i(sa_local_vld_to_sa_global_all_inport_toW),
		.sa_local_vc_id_i(sa_local_vc_id_all_inport_toW),
		.sa_local_qos_value_i(sa_local_qos_value_all_inport_toW),
		.sa_global_vld_o(sa_global_vld[3]),
		.sa_global_qos_value_o(sa_global_qos_value[12+:4]),
		.sa_global_inport_id_oh_o(sa_global_inport_id_oh[SA_GLOBAL_INPUT_NUM_W + 14-:SA_GLOBAL_INPUT_NUM_W]),
		.sa_global_inport_vc_id_o(sa_global_inport_vc_id[9+:3]),
		.vc_assignment_vld_i(vc_assignment_vld[3]),
		.clk(clk),
		.rstn(rstn)
	);
	generate
		if (rvh_noc_pkg_SA_GLOBAL_INPUT_NUM_MAX > SA_GLOBAL_INPUT_NUM_W) begin : genblk14
			assign sa_global_inport_id_oh[15 + (4 >= SA_GLOBAL_INPUT_NUM_W ? 4 : (4 + (4 >= SA_GLOBAL_INPUT_NUM_W ? 5 - SA_GLOBAL_INPUT_NUM_W : SA_GLOBAL_INPUT_NUM_W - 3)) - 1)-:(4 >= SA_GLOBAL_INPUT_NUM_W ? 5 - SA_GLOBAL_INPUT_NUM_W : SA_GLOBAL_INPUT_NUM_W - 3)] = 1'sb0;
		end
	endgenerate
	always @(*) begin : sv2v_autoblock_1
		reg signed [31:0] k;
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1)
				begin
					begin : sv2v_autoblock_3
						reg signed [31:0] j;
						for (j = 0; j < 4; j = j + 1)
							begin
								sa_local_vld_to_sa_global_all_inport_toL[(i * SA_GLOBAL_INPUT_NUM_L) + j] = sa_local_vld_to_sa_global[(j * 6) + (4 + i)];
								sa_local_vc_id_all_inport_toL[((i * SA_GLOBAL_INPUT_NUM_L) + j) * 3+:3] = sa_local_vc_id[j * 3+:3];
								sa_local_qos_value_all_inport_toL[((i * SA_GLOBAL_INPUT_NUM_L) + j) * 4+:4] = sa_local_qos_value[j * 4+:4];
							end
					end
					k = 0;
					begin : sv2v_autoblock_4
						reg signed [31:0] j;
						for (j = 0; j < LOCAL_PORT_NUM; j = j + 1)
							if (i != j) begin
								sa_local_vld_to_sa_global_all_inport_toL[(i * SA_GLOBAL_INPUT_NUM_L) + (4 + k)] = sa_local_vld_to_sa_global[((4 + j) * 6) + (4 + i)];
								sa_local_vc_id_all_inport_toL[((i * SA_GLOBAL_INPUT_NUM_L) + (4 + k)) * 3+:3] = sa_local_vc_id[(4 + j) * 3+:3];
								sa_local_qos_value_all_inport_toL[((i * SA_GLOBAL_INPUT_NUM_L) + (4 + k)) * 4+:4] = sa_local_qos_value[(4 + j) * 4+:4];
								k = k + 1;
							end
					end
				end
		end
	end
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_have_sa_global_toL
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : gen_sa_global_toL
				sa_global #(.INPUT_NUM(SA_GLOBAL_INPUT_NUM_L)) sa_global_toL_u(
					.sa_local_vld_i(sa_local_vld_to_sa_global_all_inport_toL[i * SA_GLOBAL_INPUT_NUM_L+:SA_GLOBAL_INPUT_NUM_L]),
					.sa_local_vc_id_i(sa_local_vc_id_all_inport_toL[3 * (i * SA_GLOBAL_INPUT_NUM_L)+:3 * SA_GLOBAL_INPUT_NUM_L]),
					.sa_local_qos_value_i(sa_local_qos_value_all_inport_toL[4 * (i * SA_GLOBAL_INPUT_NUM_L)+:4 * SA_GLOBAL_INPUT_NUM_L]),
					.sa_global_vld_o(sa_global_vld[4 + i]),
					.sa_global_qos_value_o(sa_global_qos_value[(4 + i) * 4+:4]),
					.sa_global_inport_id_oh_o(sa_global_inport_id_oh[((4 + i) * 5) + (SA_GLOBAL_INPUT_NUM_L - 1)-:SA_GLOBAL_INPUT_NUM_L]),
					.sa_global_inport_vc_id_o(sa_global_inport_vc_id[(4 + i) * 3+:3]),
					.vc_assignment_vld_i(vc_assignment_vld[4 + i]),
					.clk(clk),
					.rstn(rstn)
				);
				if (rvh_noc_pkg_SA_GLOBAL_INPUT_NUM_MAX > SA_GLOBAL_INPUT_NUM_L) begin : genblk1
					assign sa_global_inport_id_oh[((4 + i) * 5) + (4 >= SA_GLOBAL_INPUT_NUM_L ? 4 : (4 + (4 >= SA_GLOBAL_INPUT_NUM_L ? 5 - SA_GLOBAL_INPUT_NUM_L : SA_GLOBAL_INPUT_NUM_L - 3)) - 1)-:(4 >= SA_GLOBAL_INPUT_NUM_L ? 5 - SA_GLOBAL_INPUT_NUM_L : SA_GLOBAL_INPUT_NUM_L - 3)] = 1'sb0;
				end
			end
		end
	endgenerate
	wire [(INPUT_PORT_NUM * 3) - 1:0] look_ahead_routing;
	wire [(INPUT_PORT_NUM * 33) - 1:0] vc_ctrl_head_sa_local_sel;
	onehot_mux #(
		.SOURCE_COUNT(VC_NUM_INPUT_N),
		.DATA_WIDTH(33)
	) onehot_mux_vc_ctrl_head_sa_local_sel_N_u(
		.sel_i(sa_local_vc_id_oh[VC_NUM_INPUT_N - 1-:VC_NUM_INPUT_N]),
		.data_i(vc_ctrl_head_N),
		.data_o(vc_ctrl_head_sa_local_sel[0+:33])
	);
	look_ahead_routing look_ahead_routing_fromN_u(
		.vc_ctrl_head_vld_i(sa_local_vld[0]),
		.vc_ctrl_head_i(vc_ctrl_head_sa_local_sel[0+:33]),
		.node_id_x_ths_hop_i(node_id_x_ths_hop_i),
		.node_id_y_ths_hop_i(node_id_y_ths_hop_i),
		.look_ahead_routing_o(look_ahead_routing[0+:3])
	);
	onehot_mux #(
		.SOURCE_COUNT(VC_NUM_INPUT_S),
		.DATA_WIDTH(33)
	) onehot_mux_vc_ctrl_head_sa_local_sel_S_u(
		.sel_i(sa_local_vc_id_oh[VC_NUM_INPUT_S + 5-:VC_NUM_INPUT_S]),
		.data_i(vc_ctrl_head_S),
		.data_o(vc_ctrl_head_sa_local_sel[33+:33])
	);
	look_ahead_routing look_ahead_routing_fromS_u(
		.vc_ctrl_head_vld_i(sa_local_vld[1]),
		.vc_ctrl_head_i(vc_ctrl_head_sa_local_sel[33+:33]),
		.node_id_x_ths_hop_i(node_id_x_ths_hop_i),
		.node_id_y_ths_hop_i(node_id_y_ths_hop_i),
		.look_ahead_routing_o(look_ahead_routing[3+:3])
	);
	onehot_mux #(
		.SOURCE_COUNT(VC_NUM_INPUT_E),
		.DATA_WIDTH(33)
	) onehot_mux_vc_ctrl_head_sa_local_sel_E_u(
		.sel_i(sa_local_vc_id_oh[VC_NUM_INPUT_E + 11-:VC_NUM_INPUT_E]),
		.data_i(vc_ctrl_head_E),
		.data_o(vc_ctrl_head_sa_local_sel[66+:33])
	);
	look_ahead_routing look_ahead_routing_fromE_u(
		.vc_ctrl_head_vld_i(sa_local_vld[2]),
		.vc_ctrl_head_i(vc_ctrl_head_sa_local_sel[66+:33]),
		.node_id_x_ths_hop_i(node_id_x_ths_hop_i),
		.node_id_y_ths_hop_i(node_id_y_ths_hop_i),
		.look_ahead_routing_o(look_ahead_routing[6+:3])
	);
	onehot_mux #(
		.SOURCE_COUNT(VC_NUM_INPUT_W),
		.DATA_WIDTH(33)
	) onehot_mux_vc_ctrl_head_sa_local_sel_W_u(
		.sel_i(sa_local_vc_id_oh[VC_NUM_INPUT_W + 17-:VC_NUM_INPUT_W]),
		.data_i(vc_ctrl_head_W),
		.data_o(vc_ctrl_head_sa_local_sel[99+:33])
	);
	look_ahead_routing look_ahead_routing_fromW_u(
		.vc_ctrl_head_vld_i(sa_local_vld[3]),
		.vc_ctrl_head_i(vc_ctrl_head_sa_local_sel[99+:33]),
		.node_id_x_ths_hop_i(node_id_x_ths_hop_i),
		.node_id_y_ths_hop_i(node_id_y_ths_hop_i),
		.look_ahead_routing_o(look_ahead_routing[9+:3])
	);
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_have_look_ahead_routing_fromL
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : gen_look_ahead_routing_fromL
				onehot_mux #(
					.SOURCE_COUNT(VC_NUM_INPUT_L),
					.DATA_WIDTH(33)
				) onehot_mux_look_ahead_routing_sel_u(
					.sel_i(sa_local_vc_id_oh[((4 + i) * 6) + (VC_NUM_INPUT_L - 1)-:VC_NUM_INPUT_L]),
					.data_i(vc_ctrl_head_L[33 * (i * VC_NUM_INPUT_L)+:33 * VC_NUM_INPUT_L]),
					.data_o(vc_ctrl_head_sa_local_sel[(4 + i) * 33+:33])
				);
				look_ahead_routing look_ahead_routing_fromL_u(
					.vc_ctrl_head_vld_i(sa_local_vld[4 + i]),
					.vc_ctrl_head_i(vc_ctrl_head_sa_local_sel[(4 + i) * 33+:33]),
					.node_id_x_ths_hop_i(node_id_x_ths_hop_i),
					.node_id_y_ths_hop_i(node_id_y_ths_hop_i),
					.look_ahead_routing_o(look_ahead_routing[(4 + i) * 3+:3])
				);
			end
		end
	endgenerate
	wire [(VC_NUM_OUTPUT_N * VC_DEPTH_OUTPUT_N_COUNTER_W) - 1:0] vc_credit_counter_toN;
	wire [(VC_NUM_OUTPUT_S * VC_DEPTH_OUTPUT_S_COUNTER_W) - 1:0] vc_credit_counter_toS;
	wire [(VC_NUM_OUTPUT_E * VC_DEPTH_OUTPUT_E_COUNTER_W) - 1:0] vc_credit_counter_toE;
	wire [(VC_NUM_OUTPUT_W * VC_DEPTH_OUTPUT_W_COUNTER_W) - 1:0] vc_credit_counter_toW;
	wire [((LOCAL_PORT_NUM * VC_NUM_OUTPUT_L) * VC_DEPTH_OUTPUT_L_COUNTER_W) - 1:0] vc_credit_counter_toL;
	output_port_vc_credit_counter #(
		.VC_NUM(VC_NUM_OUTPUT_N),
		.VC_DEPTH(VC_DEPTH_OUTPUT_N)
	) output_port_vc_credit_counter_toN_u(
		.free_vc_credit_vld_i(tx_lcrd_v_i[0]),
		.free_vc_credit_vc_id_i(tx_lcrd_id_i[VC_NUM_OUTPUT_N_IDX_W - 1-:VC_NUM_OUTPUT_N_IDX_W]),
		.consume_vc_credit_vld_i(consume_vc_credit_vld[0]),
		.consume_vc_credit_vc_id_i(consume_vc_credit_vc_id[VC_NUM_OUTPUT_N_IDX_W - 1-:VC_NUM_OUTPUT_N_IDX_W]),
		.vc_credit_counter_o(vc_credit_counter_toN),
		.clk(clk),
		.rstn(rstn)
	);
	output_port_vc_credit_counter #(
		.VC_NUM(VC_NUM_OUTPUT_S),
		.VC_DEPTH(VC_DEPTH_OUTPUT_S)
	) output_port_vc_credit_counter_toS_u(
		.free_vc_credit_vld_i(tx_lcrd_v_i[1]),
		.free_vc_credit_vc_id_i(tx_lcrd_id_i[VC_NUM_OUTPUT_S_IDX_W + 2-:VC_NUM_OUTPUT_S_IDX_W]),
		.consume_vc_credit_vld_i(consume_vc_credit_vld[1]),
		.consume_vc_credit_vc_id_i(consume_vc_credit_vc_id[VC_NUM_OUTPUT_S_IDX_W + 2-:VC_NUM_OUTPUT_S_IDX_W]),
		.vc_credit_counter_o(vc_credit_counter_toS),
		.clk(clk),
		.rstn(rstn)
	);
	output_port_vc_credit_counter #(
		.VC_NUM(VC_NUM_OUTPUT_E),
		.VC_DEPTH(VC_DEPTH_OUTPUT_E)
	) output_port_vc_credit_counter_toE_u(
		.free_vc_credit_vld_i(tx_lcrd_v_i[2]),
		.free_vc_credit_vc_id_i(tx_lcrd_id_i[VC_NUM_OUTPUT_E_IDX_W + 5-:VC_NUM_OUTPUT_E_IDX_W]),
		.consume_vc_credit_vld_i(consume_vc_credit_vld[2]),
		.consume_vc_credit_vc_id_i(consume_vc_credit_vc_id[VC_NUM_OUTPUT_E_IDX_W + 5-:VC_NUM_OUTPUT_E_IDX_W]),
		.vc_credit_counter_o(vc_credit_counter_toE),
		.clk(clk),
		.rstn(rstn)
	);
	output_port_vc_credit_counter #(
		.VC_NUM(VC_NUM_OUTPUT_W),
		.VC_DEPTH(VC_DEPTH_OUTPUT_W)
	) output_port_vc_credit_counter_toW_u(
		.free_vc_credit_vld_i(tx_lcrd_v_i[3]),
		.free_vc_credit_vc_id_i(tx_lcrd_id_i[VC_NUM_OUTPUT_W_IDX_W + 8-:VC_NUM_OUTPUT_W_IDX_W]),
		.consume_vc_credit_vld_i(consume_vc_credit_vld[3]),
		.consume_vc_credit_vc_id_i(consume_vc_credit_vc_id[VC_NUM_OUTPUT_W_IDX_W + 8-:VC_NUM_OUTPUT_W_IDX_W]),
		.vc_credit_counter_o(vc_credit_counter_toW),
		.clk(clk),
		.rstn(rstn)
	);
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_have_output_port_vc_credit_counter_toL
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : gen_output_port_vc_credit_counter_toL
				output_port_vc_credit_counter #(
					.VC_NUM(VC_NUM_OUTPUT_L),
					.VC_DEPTH(VC_DEPTH_OUTPUT_L)
				) output_port_vc_credit_counter_toL_u(
					.free_vc_credit_vld_i(tx_lcrd_v_i[4 + i]),
					.free_vc_credit_vc_id_i(tx_lcrd_id_i[((4 + i) * 3) + (VC_NUM_OUTPUT_L_IDX_W - 1)-:VC_NUM_OUTPUT_L_IDX_W]),
					.consume_vc_credit_vld_i(consume_vc_credit_vld[4 + i]),
					.consume_vc_credit_vc_id_i(consume_vc_credit_vc_id[((4 + i) * 3) + (VC_NUM_OUTPUT_L_IDX_W - 1)-:VC_NUM_OUTPUT_L_IDX_W]),
					.vc_credit_counter_o(vc_credit_counter_toL[VC_DEPTH_OUTPUT_L_COUNTER_W * (i * VC_NUM_OUTPUT_L)+:VC_DEPTH_OUTPUT_L_COUNTER_W * VC_NUM_OUTPUT_L]),
					.clk(clk),
					.rstn(rstn)
				);
			end
		end
	endgenerate
	wire [(VC_NUM_OUTPUT_N * 2) - 1:0] vc_select_vld_toN;
	wire [(VC_NUM_OUTPUT_N * 6) - 1:0] vc_select_vc_id_toN;
	wire [(VC_NUM_OUTPUT_S * 2) - 1:0] vc_select_vld_toS;
	wire [(VC_NUM_OUTPUT_S * 6) - 1:0] vc_select_vc_id_toS;
	wire [(VC_NUM_OUTPUT_E * 2) - 1:0] vc_select_vld_toE;
	wire [(VC_NUM_OUTPUT_E * 6) - 1:0] vc_select_vc_id_toE;
	wire [(VC_NUM_OUTPUT_W * 2) - 1:0] vc_select_vld_toW;
	wire [(VC_NUM_OUTPUT_W * 6) - 1:0] vc_select_vc_id_toW;
	wire [((LOCAL_PORT_NUM * VC_NUM_OUTPUT_L) * 2) - 1:0] vc_select_vld_toL;
	wire [((LOCAL_PORT_NUM * VC_NUM_OUTPUT_L) * 6) - 1:0] vc_select_vc_id_toL;
	output_port_vc_selection #(
		.OUTPUT_VC_NUM(VC_NUM_OUTPUT_N),
		.OUTPUT_VC_DEPTH(VC_DEPTH_OUTPUT_N)
	) output_port_vc_selection_toN_u(
		.vc_credit_counter_i(vc_credit_counter_toN),
		.vc_select_vld_o(vc_select_vld_toN),
		.vc_select_vc_id_o(vc_select_vc_id_toN)
	);
	output_port_vc_selection #(
		.OUTPUT_VC_NUM(VC_NUM_OUTPUT_S),
		.OUTPUT_VC_DEPTH(VC_DEPTH_OUTPUT_S)
	) output_port_vc_selection_toS_u(
		.vc_credit_counter_i(vc_credit_counter_toS),
		.vc_select_vld_o(vc_select_vld_toS),
		.vc_select_vc_id_o(vc_select_vc_id_toS)
	);
	output_port_vc_selection #(
		.OUTPUT_VC_NUM(VC_NUM_OUTPUT_E),
		.OUTPUT_VC_DEPTH(VC_DEPTH_OUTPUT_E)
	) output_port_vc_selection_toE_u(
		.vc_credit_counter_i(vc_credit_counter_toE),
		.vc_select_vld_o(vc_select_vld_toE),
		.vc_select_vc_id_o(vc_select_vc_id_toE)
	);
	output_port_vc_selection #(
		.OUTPUT_VC_NUM(VC_NUM_OUTPUT_W),
		.OUTPUT_VC_DEPTH(VC_DEPTH_OUTPUT_W)
	) output_port_vc_selection_toW_u(
		.vc_credit_counter_i(vc_credit_counter_toW),
		.vc_select_vld_o(vc_select_vld_toW),
		.vc_select_vc_id_o(vc_select_vc_id_toW)
	);
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_have_output_port_vc_selection_toL
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : gen_output_port_vc_selection_toL
				output_port_vc_selection #(
					.OUTPUT_VC_NUM(VC_NUM_OUTPUT_L),
					.OUTPUT_VC_DEPTH(VC_DEPTH_OUTPUT_L),
					.OUTPUT_TO_L(1)
				) output_port_vc_selection_toL_u(
					.vc_credit_counter_i(vc_credit_counter_toL[VC_DEPTH_OUTPUT_L_COUNTER_W * (i * VC_NUM_OUTPUT_L)+:VC_DEPTH_OUTPUT_L_COUNTER_W * VC_NUM_OUTPUT_L]),
					.vc_select_vld_o(vc_select_vld_toL[2 * (i * VC_NUM_OUTPUT_L)+:2 * VC_NUM_OUTPUT_L]),
					.vc_select_vc_id_o(vc_select_vc_id_toL[6 * (i * VC_NUM_OUTPUT_L)+:6 * VC_NUM_OUTPUT_L])
				);
			end
		end
	endgenerate
	wire [(SA_GLOBAL_INPUT_NUM_N * 3) - 1:0] look_ahead_routing_all_inport_toN;
	wire [(SA_GLOBAL_INPUT_NUM_S * 3) - 1:0] look_ahead_routing_all_inport_toS;
	wire [(SA_GLOBAL_INPUT_NUM_E * 3) - 1:0] look_ahead_routing_all_inport_toE;
	wire [(SA_GLOBAL_INPUT_NUM_W * 3) - 1:0] look_ahead_routing_all_inport_toW;
	assign look_ahead_routing_all_inport_toN[0+:3] = look_ahead_routing[3+:3];
	assign look_ahead_routing_all_inport_toN[3+:3] = look_ahead_routing[6+:3];
	assign look_ahead_routing_all_inport_toN[6+:3] = look_ahead_routing[9+:3];
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_have_look_ahead_routing_all_inport_toN
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : gen_look_ahead_routing_all_inport_toN
				assign look_ahead_routing_all_inport_toN[(3 + i) * 3+:3] = look_ahead_routing[(4 + i) * 3+:3];
			end
		end
	endgenerate
	output_port_vc_assignment #(
		.OUTPUT_VC_NUM(VC_NUM_OUTPUT_N),
		.SA_GLOBAL_INPUT_NUM(SA_GLOBAL_INPUT_NUM_N),
		.OUTPUT_TO_N(1)
	) output_port_vc_assignment_toN_u(
		.sa_global_vld_i(sa_global_vld[0]),
		.sa_global_qos_value_i(sa_global_qos_value[0+:4]),
		.sa_global_inport_id_oh_i(sa_global_inport_id_oh[SA_GLOBAL_INPUT_NUM_N - 1-:SA_GLOBAL_INPUT_NUM_N]),
		.look_ahead_routing_i(look_ahead_routing_all_inport_toN),
		.vc_select_vld_i(vc_select_vld_toN),
		.vc_select_vc_id_i(vc_select_vc_id_toN),
		.vc_assignment_vld_o(vc_assignment_vld[0]),
		.vc_assignment_vc_id_o(vc_assignment_vc_id[0+:3]),
		.look_ahead_routing_sel_o(look_ahead_routing_sel[0+:3])
	);
	assign look_ahead_routing_all_inport_toS[0+:3] = look_ahead_routing[0+:3];
	assign look_ahead_routing_all_inport_toS[3+:3] = look_ahead_routing[6+:3];
	assign look_ahead_routing_all_inport_toS[6+:3] = look_ahead_routing[9+:3];
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_have_look_ahead_routing_all_inport_toS
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : gen_look_ahead_routing_all_inport_toS
				assign look_ahead_routing_all_inport_toS[(3 + i) * 3+:3] = look_ahead_routing[(4 + i) * 3+:3];
			end
		end
	endgenerate
	output_port_vc_assignment #(
		.OUTPUT_VC_NUM(VC_NUM_OUTPUT_S),
		.SA_GLOBAL_INPUT_NUM(SA_GLOBAL_INPUT_NUM_S),
		.OUTPUT_TO_S(1)
	) output_port_vc_assignment_toS_u(
		.sa_global_vld_i(sa_global_vld[1]),
		.sa_global_qos_value_i(sa_global_qos_value[4+:4]),
		.sa_global_inport_id_oh_i(sa_global_inport_id_oh[SA_GLOBAL_INPUT_NUM_S + 4-:SA_GLOBAL_INPUT_NUM_S]),
		.look_ahead_routing_i(look_ahead_routing_all_inport_toS),
		.vc_select_vld_i(vc_select_vld_toS),
		.vc_select_vc_id_i(vc_select_vc_id_toS),
		.vc_assignment_vld_o(vc_assignment_vld[1]),
		.vc_assignment_vc_id_o(vc_assignment_vc_id[3+:3]),
		.look_ahead_routing_sel_o(look_ahead_routing_sel[3+:3])
	);
	assign look_ahead_routing_all_inport_toE[0+:3] = look_ahead_routing[9+:3];
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_have_look_ahead_routing_all_inport_toE
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : gen_look_ahead_routing_all_inport_toE
				assign look_ahead_routing_all_inport_toE[(1 + i) * 3+:3] = look_ahead_routing[(4 + i) * 3+:3];
			end
		end
	endgenerate
	output_port_vc_assignment #(
		.OUTPUT_VC_NUM(VC_NUM_OUTPUT_E),
		.SA_GLOBAL_INPUT_NUM(SA_GLOBAL_INPUT_NUM_E),
		.OUTPUT_TO_E(1)
	) output_port_vc_assignment_toE_u(
		.sa_global_vld_i(sa_global_vld[2]),
		.sa_global_qos_value_i(sa_global_qos_value[8+:4]),
		.sa_global_inport_id_oh_i(sa_global_inport_id_oh[SA_GLOBAL_INPUT_NUM_E + 9-:SA_GLOBAL_INPUT_NUM_E]),
		.look_ahead_routing_i(look_ahead_routing_all_inport_toE),
		.vc_select_vld_i(vc_select_vld_toE),
		.vc_select_vc_id_i(vc_select_vc_id_toE),
		.vc_assignment_vld_o(vc_assignment_vld[2]),
		.vc_assignment_vc_id_o(vc_assignment_vc_id[6+:3]),
		.look_ahead_routing_sel_o(look_ahead_routing_sel[6+:3])
	);
	assign look_ahead_routing_all_inport_toW[0+:3] = look_ahead_routing[6+:3];
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_have_look_ahead_routing_all_inport_toW
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : gen_look_ahead_routing_all_inport_toW
				assign look_ahead_routing_all_inport_toW[(1 + i) * 3+:3] = look_ahead_routing[(4 + i) * 3+:3];
			end
		end
	endgenerate
	output_port_vc_assignment #(
		.OUTPUT_VC_NUM(VC_NUM_OUTPUT_W),
		.SA_GLOBAL_INPUT_NUM(SA_GLOBAL_INPUT_NUM_W),
		.OUTPUT_TO_W(1)
	) output_port_vc_assignment_toW_u(
		.sa_global_vld_i(sa_global_vld[3]),
		.sa_global_qos_value_i(sa_global_qos_value[12+:4]),
		.sa_global_inport_id_oh_i(sa_global_inport_id_oh[SA_GLOBAL_INPUT_NUM_W + 14-:SA_GLOBAL_INPUT_NUM_W]),
		.look_ahead_routing_i(look_ahead_routing_all_inport_toW),
		.vc_select_vld_i(vc_select_vld_toW),
		.vc_select_vc_id_i(vc_select_vc_id_toW),
		.vc_assignment_vld_o(vc_assignment_vld[3]),
		.vc_assignment_vc_id_o(vc_assignment_vc_id[9+:3]),
		.look_ahead_routing_sel_o(look_ahead_routing_sel[9+:3])
	);
	generate
		if (LOCAL_PORT_NUM > 0) begin : gen_have_output_port_vc_assignment_toL
			for (i = 0; i < LOCAL_PORT_NUM; i = i + 1) begin : gen_output_port_vc_assignment_toL
				output_port_vc_assignment #(
					.OUTPUT_VC_NUM(VC_NUM_OUTPUT_L),
					.SA_GLOBAL_INPUT_NUM(SA_GLOBAL_INPUT_NUM_L),
					.OUTPUT_TO_L(1)
				) output_port_vc_assignment_toL_u(
					.sa_global_vld_i(sa_global_vld[4 + i]),
					.sa_global_qos_value_i(sa_global_qos_value[(4 + i) * 4+:4]),
					.sa_global_inport_id_oh_i(sa_global_inport_id_oh[((4 + i) * 5) + (SA_GLOBAL_INPUT_NUM_L - 1)-:SA_GLOBAL_INPUT_NUM_L]),
					.look_ahead_routing_i({{(SA_GLOBAL_INPUT_NUM_L - 4) * 3 {1'b0}}, look_ahead_routing[9+:3], look_ahead_routing[6+:3], look_ahead_routing[3+:3], look_ahead_routing[0+:3]}),
					.vc_select_vld_i(vc_select_vld_toL[2 * (i * VC_NUM_OUTPUT_L)+:2 * VC_NUM_OUTPUT_L]),
					.vc_select_vc_id_i(vc_select_vc_id_toL[6 * (i * VC_NUM_OUTPUT_L)+:6 * VC_NUM_OUTPUT_L]),
					.vc_assignment_vld_o(vc_assignment_vld[4 + i]),
					.vc_assignment_vc_id_o(vc_assignment_vc_id[(4 + i) * 3+:3]),
					.look_ahead_routing_sel_o(look_ahead_routing_sel[(4 + i) * 3+:3])
				);
			end
		end
	endgenerate
	input_to_output #(
		.INPUT_PORT_NUM(INPUT_PORT_NUM),
		.OUTPUT_PORT_NUM(OUTPUT_PORT_NUM),
		.SA_GLOBAL_INPUT_NUM_N(SA_GLOBAL_INPUT_NUM_N),
		.SA_GLOBAL_INPUT_NUM_S(SA_GLOBAL_INPUT_NUM_S),
		.SA_GLOBAL_INPUT_NUM_E(SA_GLOBAL_INPUT_NUM_E),
		.SA_GLOBAL_INPUT_NUM_W(SA_GLOBAL_INPUT_NUM_W),
		.SA_GLOBAL_INPUT_NUM_L(SA_GLOBAL_INPUT_NUM_L)
	) input_to_output_u(
		.sa_global_vld_i(sa_global_vld),
		.sa_global_inport_id_oh_i(sa_global_inport_id_oh),
		.sa_global_inport_vc_id_i(sa_global_inport_vc_id),
		.vc_assignment_vld_i(vc_assignment_vld),
		.vc_assignment_vc_id_i(vc_assignment_vc_id),
		.look_ahead_routing_sel_i(look_ahead_routing_sel),
		.inport_read_enable_o(inport_read_enable_sa_stage),
		.inport_read_vc_id_o(inport_read_vc_id_sa_stage),
		.outport_vld_o(outport_vld_sa_stage),
		.outport_select_inport_id_o(outport_select_inport_id_sa_stage),
		.outport_vc_id_o(outport_vc_id_sa_stage),
		.outport_look_ahead_routing_o(outport_look_ahead_routing_sa_stage),
		.consume_vc_credit_vld_o(consume_vc_credit_vld),
		.consume_vc_credit_vc_id_o(consume_vc_credit_vc_id)
	);
	generate
		for (i = 0; i < INPUT_PORT_NUM; i = i + 1) begin : gen_sa_to_st_reg_inport_angle
			std_dffr #(.WIDTH(1)) U_STA_INPORT_READ_ENABLE_ST_STAGE(
				.clk(clk),
				.rstn(rstn),
				.d(inport_read_enable_sa_stage[i]),
				.q(inport_read_enable_st_stage[i])
			);
			std_dffe #(.WIDTH(rvh_noc_pkg_VC_ID_NUM_MAX_W)) U_DAT_INPORT_READ_VC_ID_ST_STAGE(
				.clk(clk),
				.en(inport_read_enable_sa_stage[i]),
				.d(inport_read_vc_id_sa_stage[i * 3+:3]),
				.q(inport_read_vc_id_st_stage[i * 3+:3])
			);
		end
		for (i = 0; i < OUTPUT_PORT_NUM; i = i + 1) begin : gen_sa_to_st_reg_outport_angle
			std_dffr #(.WIDTH(1)) U_STA_OUTPORT_VLD_ST_STAGE(
				.clk(clk),
				.rstn(rstn),
				.d(outport_vld_sa_stage[i]),
				.q(outport_vld_st_stage[i])
			);
			std_dffe #(.WIDTH(3)) U_DAT_OUTPORT_SELECT_INPORT_ID_ST_STAGE(
				.clk(clk),
				.en(outport_vld_sa_stage[i]),
				.d(outport_select_inport_id_sa_stage[i * 3+:3]),
				.q(outport_select_inport_id_st_stage[i * 3+:3])
			);
			std_dffe #(.WIDTH(rvh_noc_pkg_VC_ID_NUM_MAX_W)) U_DAT_OUTPORT_VC_ID_ST_STAGE(
				.clk(clk),
				.en(outport_vld_sa_stage[i]),
				.d(outport_vc_id_sa_stage[i * 3+:3]),
				.q(outport_vc_id_st_stage[i * 3+:3])
			);
			std_dffe #(.WIDTH(3)) U_DAT_OUTPORT_LOOK_AHEAD_ROUTING_ST_STAGE(
				.clk(clk),
				.en(outport_vld_sa_stage[i]),
				.d(outport_look_ahead_routing_sa_stage[i * 3+:3]),
				.q(outport_look_ahead_routing_st_stage[i * 3+:3])
			);
		end
	endgenerate
	switch_AC76E #(
		.INPUT_PORT_NUM(INPUT_PORT_NUM),
		.OUTPUT_PORT_NUM(OUTPUT_PORT_NUM),
		.VC_NUM_INPUT_N(VC_NUM_INPUT_N),
		.VC_NUM_INPUT_S(VC_NUM_INPUT_S),
		.VC_NUM_INPUT_E(VC_NUM_INPUT_E),
		.VC_NUM_INPUT_W(VC_NUM_INPUT_W),
		.VC_NUM_INPUT_L(VC_NUM_INPUT_L)
	) switch_u(
		.vc_data_head_fromN_i(vc_data_head_N),
		.vc_data_head_fromS_i(vc_data_head_S),
		.vc_data_head_fromE_i(vc_data_head_E),
		.vc_data_head_fromW_i(vc_data_head_W),
		.vc_data_head_fromL_i(vc_data_head_L),
		.inport_read_enable_st_stage_i(inport_read_enable_st_stage),
		.inport_read_vc_id_st_stage_i(inport_read_vc_id_st_stage),
		.outport_vld_st_stage_i(outport_vld_st_stage),
		.outport_select_inport_id_st_stage_i(outport_select_inport_id_st_stage),
		.outport_vc_id_st_stage_i(outport_vc_id_st_stage),
		.outport_look_ahead_routing_st_stage_i(outport_look_ahead_routing_st_stage),
		.tx_flit_pend_o(tx_flit_pend_o),
		.tx_flit_v_o(tx_flit_v_o),
		.tx_flit_o(tx_flit_o),
		.tx_flit_vc_id_o(tx_flit_vc_id_o),
		.tx_flit_look_ahead_routing_o(tx_flit_look_ahead_routing_o)
	);
	performance_monitor #(
		.INPUT_PORT_NUM(INPUT_PORT_NUM),
		.OUTPUT_PORT_NUM(OUTPUT_PORT_NUM),
		.VC_NUM_INPUT_N(VC_NUM_INPUT_N),
		.VC_NUM_INPUT_S(VC_NUM_INPUT_S),
		.VC_NUM_INPUT_E(VC_NUM_INPUT_E),
		.VC_NUM_INPUT_W(VC_NUM_INPUT_W),
		.VC_NUM_INPUT_L(VC_NUM_INPUT_L),
		.VC_DEPTH_INPUT_N(VC_DEPTH_INPUT_N),
		.VC_DEPTH_INPUT_S(VC_DEPTH_INPUT_S),
		.VC_DEPTH_INPUT_E(VC_DEPTH_INPUT_E),
		.VC_DEPTH_INPUT_W(VC_DEPTH_INPUT_W),
		.VC_DEPTH_INPUT_L(VC_DEPTH_INPUT_L)
	) v_performance_monitor_u(
		.sa_local_vld_i(sa_local_vld),
		.sa_global_inport_read_vld_i(inport_read_enable_sa_stage),
		.vc_credit_counter_toN_i(vc_credit_counter_toN),
		.vc_credit_counter_toS_i(vc_credit_counter_toS),
		.vc_credit_counter_toE_i(vc_credit_counter_toE),
		.vc_credit_counter_toW_i(vc_credit_counter_toW),
		.vc_credit_counter_toL_i(vc_credit_counter_toL),
		.node_id_x_ths_hop_i(node_id_x_ths_hop_i),
		.node_id_y_ths_hop_i(node_id_y_ths_hop_i),
		.clk(clk),
		.rstn(rstn)
	);
endmodule
