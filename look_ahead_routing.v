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
