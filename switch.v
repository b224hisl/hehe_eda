module switch (
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
			default: tx_flit_o[0+:256] = vc_head_data[256+:256];
		endcase
	always @(*)
		case (outport_select_inport_id_st_stage_i[3+:3])
			3'd0: tx_flit_o[256+:256] = vc_head_data[0+:256];
			3'd2: tx_flit_o[256+:256] = vc_head_data[512+:256];
			3'd3: tx_flit_o[256+:256] = vc_head_data[768+:256];
			3'd4: tx_flit_o[256+:256] = vc_head_data[1024+:256];
			default: tx_flit_o[256+:256] = vc_head_data[0+:256];
		endcase
	always @(*)
		case (outport_select_inport_id_st_stage_i[6+:3])
			3'd3: tx_flit_o[512+:256] = vc_head_data[768+:256];
			3'd4: tx_flit_o[512+:256] = vc_head_data[1024+:256];
			default: tx_flit_o[512+:256] = vc_head_data[768+:256];
		endcase
	always @(*)
		case (outport_select_inport_id_st_stage_i[9+:3])
			3'd2: tx_flit_o[768+:256] = vc_head_data[512+:256];
			3'd4: tx_flit_o[768+:256] = vc_head_data[1024+:256];
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
						default: tx_flit_o[(4 + i) * 256+:256] = vc_head_data[0+:256];
					endcase
			end
		end
	endgenerate
endmodule
