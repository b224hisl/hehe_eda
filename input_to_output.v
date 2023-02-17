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
