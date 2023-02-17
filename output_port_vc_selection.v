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
