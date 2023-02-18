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
