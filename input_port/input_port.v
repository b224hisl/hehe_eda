module input_port_flit_decoder_4FC44 (
	flit_v_i,
	flit_i,
	flit_look_ahead_routing_i,
	flit_dec_o
);
	input wire flit_v_i;
	input wire [255:0] flit_i;
	input wire [2:0] flit_look_ahead_routing_i;
	localparam rvh_noc_pkg_QoS_Value_Width = 4;
	localparam rvh_noc_pkg_TxnID_Width = 12;
	localparam rvh_noc_pkg_NodeID_Device_Port_Width = 2;
	localparam rvh_noc_pkg_NodeID_X_Width = 2;
	localparam rvh_noc_pkg_NodeID_Y_Width = 2;
	output wire [32:0] flit_dec_o;
	localparam rvh_noc_pkg_NodeID_Device_Id_Width = 1;
	localparam rvh_noc_pkg_NodeID_Width = 7;
	assign flit_dec_o[32-:7] = flit_i[10:rvh_noc_pkg_QoS_Value_Width];
	assign flit_dec_o[25-:7] = flit_i[17:11];
	assign flit_dec_o[18-:12] = flit_i[29:18];
	assign flit_dec_o[6-:3] = flit_look_ahead_routing_i;
endmodule
module input_port (
	rx_flit_pend_i,
	rx_flit_v_i,
	rx_flit_i,
	rx_flit_vc_id_i,
	rx_flit_look_ahead_routing_i,
	rx_lcrd_v_o,
	rx_lcrd_id_o,
	vc_ctrl_head_vld_o,
	vc_ctrl_head_o,
	vc_data_head_o,
	inport_read_enable_sa_stage_i,
	inport_read_vc_id_sa_stage_i,
	inport_read_enable_st_stage_i,
	inport_read_vc_id_st_stage_i,
	node_id_x_ths_hop_i,
	node_id_y_ths_hop_i,
	clk,
	rstn
);
	parameter VC_NUM = 1;
	parameter VC_DEPTH = 1;
	parameter VC_NUM_IDX_W = (VC_NUM > 1 ? $clog2(VC_NUM) : 1);
	parameter INPUT_PORT_NO = 0;
	input wire rx_flit_pend_i;
	input wire rx_flit_v_i;
	input wire [255:0] rx_flit_i;
	input wire [VC_NUM_IDX_W - 1:0] rx_flit_vc_id_i;
	input wire [2:0] rx_flit_look_ahead_routing_i;
	output wire rx_lcrd_v_o;
	localparam rvh_noc_pkg_CHANNEL_NUM = 4;
	localparam rvh_noc_pkg_INPUT_PORT_NUMBER = 6;
	localparam rvh_noc_pkg_ROUTER_PORT_NUMBER = 4;
	localparam rvh_noc_pkg_LOCAL_PORT_NUMBER = 2;
	localparam rvh_noc_pkg_QOS_VC_NUM_PER_INPUT = 1;
	localparam rvh_noc_pkg_VC_ID_NUM_MAX = 6;
	localparam rvh_noc_pkg_VC_ID_NUM_MAX_W = 3;
	output wire [2:0] rx_lcrd_id_o;
	output wire [VC_NUM - 1:0] vc_ctrl_head_vld_o;
	localparam rvh_noc_pkg_QoS_Value_Width = 4;
	localparam rvh_noc_pkg_TxnID_Width = 12;
	localparam rvh_noc_pkg_NodeID_Device_Port_Width = 2;
	localparam rvh_noc_pkg_NodeID_X_Width = 2;
	localparam rvh_noc_pkg_NodeID_Y_Width = 2;
	output wire [(VC_NUM * 33) - 1:0] vc_ctrl_head_o;
	output wire [(VC_NUM * 256) - 1:0] vc_data_head_o;
	input wire inport_read_enable_sa_stage_i;
	input wire [VC_NUM_IDX_W - 1:0] inport_read_vc_id_sa_stage_i;
	input wire inport_read_enable_st_stage_i;
	input wire [VC_NUM_IDX_W - 1:0] inport_read_vc_id_st_stage_i;
	input wire [1:0] node_id_x_ths_hop_i;
	input wire [1:0] node_id_y_ths_hop_i;
	input wire clk;
	input wire rstn;
	wire [32:0] flit_ctrl_info;
	input_port_flit_decoder_4FC44 input_port_flit_decoder_u(
		.flit_v_i(rx_flit_v_i),
		.flit_i(rx_flit_i),
		.flit_look_ahead_routing_i(rx_flit_look_ahead_routing_i),
		.flit_dec_o(flit_ctrl_info)
	);
	input_port_vc_E2879 #(
		.VC_NUM(VC_NUM),
		.VC_DEPTH(VC_DEPTH)
	) input_port_vc_u(
		.flit_v_i(rx_flit_v_i),
		.flit_i(rx_flit_i),
		.flit_dec_i(flit_ctrl_info),
		.flit_vc_id_i(rx_flit_vc_id_i),
		.lcrd_v_o(rx_lcrd_v_o),
		.lcrd_id_o(rx_lcrd_id_o),
		.vc_ctrl_head_vld_o(vc_ctrl_head_vld_o),
		.vc_ctrl_head_o(vc_ctrl_head_o),
		.vc_data_head_o(vc_data_head_o),
		.inport_read_enable_sa_stage_i(inport_read_enable_sa_stage_i),
		.inport_read_vc_id_sa_stage_i(inport_read_vc_id_sa_stage_i),
		.inport_read_enable_st_stage_i(inport_read_enable_st_stage_i),
		.inport_read_vc_id_st_stage_i(inport_read_vc_id_st_stage_i),
		.clk(clk),
		.rstn(rstn)
	);
endmodule
module input_port_vc_E2879 (
	flit_v_i,
	flit_i,
	flit_dec_i,
	flit_vc_id_i,
	lcrd_v_o,
	lcrd_id_o,
	vc_ctrl_head_vld_o,
	vc_ctrl_head_o,
	vc_data_head_o,
	inport_read_enable_sa_stage_i,
	inport_read_vc_id_sa_stage_i,
	inport_read_enable_st_stage_i,
	inport_read_vc_id_st_stage_i,
	clk,
	rstn
);
	parameter VC_NUM = 1;
	parameter VC_NUM_IDX_W = (VC_NUM > 1 ? $clog2(VC_NUM) : 1);
	parameter VC_DEPTH = 1;
	parameter VC_BUFFER_DEPTH = VC_DEPTH;
	parameter VC_BUFFER_DEPTH_IDX_W = (VC_BUFFER_DEPTH > 1 ? $clog2(VC_BUFFER_DEPTH) : 1);
	input wire flit_v_i;
	input wire [255:0] flit_i;
	localparam rvh_noc_pkg_QoS_Value_Width = 4;
	localparam rvh_noc_pkg_TxnID_Width = 12;
	localparam rvh_noc_pkg_NodeID_Device_Port_Width = 2;
	localparam rvh_noc_pkg_NodeID_X_Width = 2;
	localparam rvh_noc_pkg_NodeID_Y_Width = 2;
	input wire [32:0] flit_dec_i;
	input wire [VC_NUM_IDX_W - 1:0] flit_vc_id_i;
	output wire lcrd_v_o;
	localparam rvh_noc_pkg_CHANNEL_NUM = 4;
	localparam rvh_noc_pkg_INPUT_PORT_NUMBER = 6;
	localparam rvh_noc_pkg_ROUTER_PORT_NUMBER = 4;
	localparam rvh_noc_pkg_LOCAL_PORT_NUMBER = 2;
	localparam rvh_noc_pkg_QOS_VC_NUM_PER_INPUT = 1;
	localparam rvh_noc_pkg_VC_ID_NUM_MAX = 6;
	localparam rvh_noc_pkg_VC_ID_NUM_MAX_W = 3;
	output wire [2:0] lcrd_id_o;
	output wire [VC_NUM - 1:0] vc_ctrl_head_vld_o;
	output wire [(VC_NUM * 33) - 1:0] vc_ctrl_head_o;
	output wire [(VC_NUM * 256) - 1:0] vc_data_head_o;
	input wire inport_read_enable_sa_stage_i;
	input wire [VC_NUM_IDX_W - 1:0] inport_read_vc_id_sa_stage_i;
	input wire inport_read_enable_st_stage_i;
	input wire [VC_NUM_IDX_W - 1:0] inport_read_vc_id_st_stage_i;
	input wire clk;
	input wire rstn;
	genvar i;
	reg [VC_NUM - 1:0] vc_data_tail_we;
	wire [255:0] vc_data_din;
	wire [VC_NUM - 1:0] vc_data_enqueue_rdy;
	reg [VC_NUM - 1:0] vc_ctrl_tail_we;
	wire [32:0] vc_ctrl_din;
	wire [VC_NUM - 1:0] vc_ctrl_enqueue_rdy;
	wire [VC_NUM - 1:0] vc_data_head_vld;
	wire [(VC_NUM * 256) - 1:0] vc_data_head;
	reg [VC_NUM - 1:0] vc_data_head_dequeue_vld;
	wire [VC_NUM - 1:0] vc_ctrl_head_vld;
	wire [(VC_NUM * 33) - 1:0] vc_ctrl_head;
	reg [VC_NUM - 1:0] vc_ctrl_head_dequeue_vld;
	always @(*) begin
		vc_data_tail_we = 1'sb0;
		vc_ctrl_tail_we = 1'sb0;
		if (flit_v_i) begin
			vc_data_tail_we[flit_vc_id_i] = 1'b1;
			vc_ctrl_tail_we[flit_vc_id_i] = 1'b1;
		end
	end
	assign vc_data_din = flit_i;
	assign vc_ctrl_din[32-:7] = flit_dec_i[32-:7];
	assign vc_ctrl_din[25-:7] = flit_dec_i[25-:7];
	assign vc_ctrl_din[18-:12] = flit_dec_i[18-:12];
	assign vc_ctrl_din[6-:3] = flit_dec_i[6-:3];
	always @(*) begin
		vc_ctrl_head_dequeue_vld = 1'sb0;
		vc_ctrl_head_dequeue_vld[inport_read_vc_id_sa_stage_i] = inport_read_enable_sa_stage_i;
	end
	always @(*) begin
		vc_data_head_dequeue_vld = 1'sb0;
		vc_data_head_dequeue_vld[inport_read_vc_id_st_stage_i] = inport_read_enable_st_stage_i;
	end
	generate
		for (i = 0; i < VC_NUM; i = i + 1) begin : gen_vc_data_fifo
			mp_fifo_8192C #(
				.ENQUEUE_WIDTH(1),
				.DEQUEUE_WIDTH(1),
				.DEPTH(VC_BUFFER_DEPTH),
				.MUST_TAKEN_ALL(1)
			) VC_DATA_U(
				.enqueue_vld_i(vc_data_tail_we[i]),
				.enqueue_payload_i(vc_data_din),
				.enqueue_rdy_o(vc_data_enqueue_rdy[i]),
				.dequeue_vld_o(vc_data_head_vld[i]),
				.dequeue_payload_o(vc_data_head[i * 256+:256]),
				.dequeue_rdy_i(vc_data_head_dequeue_vld[i]),
				.flush_i(1'b0),
				.clk(clk),
				.rst(~rstn)
			);
			assign vc_data_head_o[i * 256+:256] = vc_data_head[i * 256+:256];
		end
		for (i = 0; i < VC_NUM; i = i + 1) begin : gen_vc_ctrl_fifo
			mp_fifo_0F478_46EF5 #(
				.payload_t_rvh_noc_pkg_NodeID_Device_Port_Width(rvh_noc_pkg_NodeID_Device_Port_Width),
				.payload_t_rvh_noc_pkg_NodeID_X_Width(rvh_noc_pkg_NodeID_X_Width),
				.payload_t_rvh_noc_pkg_NodeID_Y_Width(rvh_noc_pkg_NodeID_Y_Width),
				.payload_t_rvh_noc_pkg_QoS_Value_Width(rvh_noc_pkg_QoS_Value_Width),
				.payload_t_rvh_noc_pkg_TxnID_Width(rvh_noc_pkg_TxnID_Width),
				.ENQUEUE_WIDTH(1),
				.DEQUEUE_WIDTH(1),
				.DEPTH(VC_DEPTH),
				.MUST_TAKEN_ALL(1)
			) VC_CTRL_U(
				.enqueue_vld_i(vc_ctrl_tail_we[i]),
				.enqueue_payload_i(vc_ctrl_din),
				.enqueue_rdy_o(vc_ctrl_enqueue_rdy[i]),
				.dequeue_vld_o(vc_ctrl_head_vld[i]),
				.dequeue_payload_o(vc_ctrl_head[i * 33+:33]),
				.dequeue_rdy_i(vc_ctrl_head_dequeue_vld[i]),
				.flush_i(1'b0),
				.clk(clk),
				.rst(~rstn)
			);
			assign vc_ctrl_head_vld_o[i] = vc_ctrl_head_vld[i];
			assign vc_ctrl_head_o[i * 33+:33] = vc_ctrl_head[i * 33+:33];
		end
	endgenerate
	assign lcrd_v_o = inport_read_enable_st_stage_i;
	assign lcrd_id_o = {{rvh_noc_pkg_VC_ID_NUM_MAX_W - VC_NUM_IDX_W {1'b0}}, inport_read_vc_id_st_stage_i};
endmodule
module mp_fifo_0F478_46EF5 (
	enqueue_vld_i,
	enqueue_payload_i,
	enqueue_rdy_o,
	dequeue_vld_o,
	dequeue_payload_o,
	dequeue_rdy_i,
	flush_i,
	clk,
	rst
);
	parameter signed [31:0] payload_t_rvh_noc_pkg_NodeID_Device_Port_Width = 0;
	parameter signed [31:0] payload_t_rvh_noc_pkg_NodeID_X_Width = 0;
	parameter signed [31:0] payload_t_rvh_noc_pkg_NodeID_Y_Width = 0;
	parameter signed [31:0] payload_t_rvh_noc_pkg_QoS_Value_Width = 0;
	parameter signed [31:0] payload_t_rvh_noc_pkg_TxnID_Width = 0;
	parameter [31:0] ENQUEUE_WIDTH = 4;
	parameter [31:0] DEQUEUE_WIDTH = 4;
	parameter [31:0] DEPTH = 16;
	parameter [31:0] MUST_TAKEN_ALL = 1;
	input wire [ENQUEUE_WIDTH - 1:0] enqueue_vld_i;
	input wire [(ENQUEUE_WIDTH * ((((((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0)) + ((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0))) + payload_t_rvh_noc_pkg_TxnID_Width) + 3) + payload_t_rvh_noc_pkg_QoS_Value_Width)) - 1:0] enqueue_payload_i;
	output wire [ENQUEUE_WIDTH - 1:0] enqueue_rdy_o;
	output wire [DEQUEUE_WIDTH - 1:0] dequeue_vld_o;
	output wire [(DEQUEUE_WIDTH * ((((((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0)) + ((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0))) + payload_t_rvh_noc_pkg_TxnID_Width) + 3) + payload_t_rvh_noc_pkg_QoS_Value_Width)) - 1:0] dequeue_payload_o;
	input wire [DEQUEUE_WIDTH - 1:0] dequeue_rdy_i;
	input wire flush_i;
	input clk;
	input rst;
	localparam [31:0] ENTRY_PTR_WIDTH = $clog2(DEPTH);
	localparam [31:0] ENTRY_CNT_WIDTH = $clog2(DEPTH + 1);
	wire [(ENQUEUE_WIDTH * ENTRY_PTR_WIDTH) - 1:0] enq_ptr;
	wire [(DEQUEUE_WIDTH * ENTRY_PTR_WIDTH) - 1:0] deq_ptr;
	wire [ENTRY_CNT_WIDTH - 1:0] avail_cnt;
	reg [(DEPTH * ((((((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0)) + ((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0))) + payload_t_rvh_noc_pkg_TxnID_Width) + 3) + payload_t_rvh_noc_pkg_QoS_Value_Width)) - 1:0] payload_dff;
	wire [ENQUEUE_WIDTH - 1:0] enq_fire;
	wire [DEQUEUE_WIDTH - 1:0] deq_fire;
	assign enq_fire = enqueue_vld_i & enqueue_rdy_o;
	assign deq_fire = dequeue_vld_o & dequeue_rdy_i;
	genvar i;
	generate
		for (i = 0; i < DEQUEUE_WIDTH; i = i + 1) begin : genblk1
			assign dequeue_payload_o[i * ((((((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0)) + ((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0))) + payload_t_rvh_noc_pkg_TxnID_Width) + 3) + payload_t_rvh_noc_pkg_QoS_Value_Width)+:(((((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0)) + ((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0))) + payload_t_rvh_noc_pkg_TxnID_Width) + 3) + payload_t_rvh_noc_pkg_QoS_Value_Width] = payload_dff[deq_ptr[i * ENTRY_PTR_WIDTH+:ENTRY_PTR_WIDTH] * ((((((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0)) + ((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0))) + payload_t_rvh_noc_pkg_TxnID_Width) + 3) + payload_t_rvh_noc_pkg_QoS_Value_Width)+:(((((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0)) + ((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0))) + payload_t_rvh_noc_pkg_TxnID_Width) + 3) + payload_t_rvh_noc_pkg_QoS_Value_Width];
			assign dequeue_vld_o[i] = (DEPTH - avail_cnt) > i;
		end
		if (MUST_TAKEN_ALL) begin : genblk2
			assign enqueue_rdy_o = {ENQUEUE_WIDTH {avail_cnt >= ENQUEUE_WIDTH}};
		end
		else begin : genblk2
			genvar i;
			for (i = 0; i < ENQUEUE_WIDTH; i = i + 1) begin : genblk1
				assign enqueue_rdy_o[i] = avail_cnt > i;
			end
		end
	endgenerate
	always @(posedge clk) begin : payload_dff_update
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < ENQUEUE_WIDTH; i = i + 1)
				if (enq_fire[i])
					payload_dff[enq_ptr[i * ENTRY_PTR_WIDTH+:ENTRY_PTR_WIDTH] * ((((((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0)) + ((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0))) + payload_t_rvh_noc_pkg_TxnID_Width) + 3) + payload_t_rvh_noc_pkg_QoS_Value_Width)+:(((((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0)) + ((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0))) + payload_t_rvh_noc_pkg_TxnID_Width) + 3) + payload_t_rvh_noc_pkg_QoS_Value_Width] <= enqueue_payload_i[i * ((((((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0)) + ((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0))) + payload_t_rvh_noc_pkg_TxnID_Width) + 3) + payload_t_rvh_noc_pkg_QoS_Value_Width)+:(((((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0)) + ((((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0) >= 0 ? ((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 1 : 1 - (((payload_t_rvh_noc_pkg_NodeID_X_Width + payload_t_rvh_noc_pkg_NodeID_Y_Width) + payload_t_rvh_noc_pkg_NodeID_Device_Port_Width) + 0))) + payload_t_rvh_noc_pkg_TxnID_Width) + 3) + payload_t_rvh_noc_pkg_QoS_Value_Width];
		end
	end
	usage_manager #(
		.ENTRY_COUNT(DEPTH),
		.ENQ_WIDTH(ENQUEUE_WIDTH),
		.DEQ_WIDTH(DEQUEUE_WIDTH),
		.FLAG_EN(0),
		.INIT_IS_FULL(0),
		.COMB_DEQ_EN(0),
		.COMB_ENQ_EN(1)
	) u_usage_manager(
		.enq_fire_i(enq_fire),
		.deq_fire_i(deq_fire),
		.head_o(deq_ptr),
		.tail_o(enq_ptr),
		.avail_cnt_o(avail_cnt),
		.flush_i(flush_i),
		.clk(clk),
		.rst(rst)
	);
endmodule
module mp_fifo_8192C (
	enqueue_vld_i,
	enqueue_payload_i,
	enqueue_rdy_o,
	dequeue_vld_o,
	dequeue_payload_o,
	dequeue_rdy_i,
	flush_i,
	clk,
	rst
);
	parameter [31:0] ENQUEUE_WIDTH = 4;
	parameter [31:0] DEQUEUE_WIDTH = 4;
	parameter [31:0] DEPTH = 16;
	parameter [31:0] MUST_TAKEN_ALL = 1;
	input wire [ENQUEUE_WIDTH - 1:0] enqueue_vld_i;
	input wire [(ENQUEUE_WIDTH * 256) - 1:0] enqueue_payload_i;
	output wire [ENQUEUE_WIDTH - 1:0] enqueue_rdy_o;
	output wire [DEQUEUE_WIDTH - 1:0] dequeue_vld_o;
	output wire [(DEQUEUE_WIDTH * 256) - 1:0] dequeue_payload_o;
	input wire [DEQUEUE_WIDTH - 1:0] dequeue_rdy_i;
	input wire flush_i;
	input clk;
	input rst;
	localparam [31:0] ENTRY_PTR_WIDTH = $clog2(DEPTH);
	localparam [31:0] ENTRY_CNT_WIDTH = $clog2(DEPTH + 1);
	wire [(ENQUEUE_WIDTH * ENTRY_PTR_WIDTH) - 1:0] enq_ptr;
	wire [(DEQUEUE_WIDTH * ENTRY_PTR_WIDTH) - 1:0] deq_ptr;
	wire [ENTRY_CNT_WIDTH - 1:0] avail_cnt;
	reg [(DEPTH * 256) - 1:0] payload_dff;
	wire [ENQUEUE_WIDTH - 1:0] enq_fire;
	wire [DEQUEUE_WIDTH - 1:0] deq_fire;
	assign enq_fire = enqueue_vld_i & enqueue_rdy_o;
	assign deq_fire = dequeue_vld_o & dequeue_rdy_i;
	genvar i;
	generate
		for (i = 0; i < DEQUEUE_WIDTH; i = i + 1) begin : genblk1
			assign dequeue_payload_o[i * 256+:256] = payload_dff[deq_ptr[i * ENTRY_PTR_WIDTH+:ENTRY_PTR_WIDTH] * 256+:256];
			assign dequeue_vld_o[i] = (DEPTH - avail_cnt) > i;
		end
		if (MUST_TAKEN_ALL) begin : genblk2
			assign enqueue_rdy_o = {ENQUEUE_WIDTH {avail_cnt >= ENQUEUE_WIDTH}};
		end
		else begin : genblk2
			genvar i;
			for (i = 0; i < ENQUEUE_WIDTH; i = i + 1) begin : genblk1
				assign enqueue_rdy_o[i] = avail_cnt > i;
			end
		end
	endgenerate
	always @(posedge clk) begin : payload_dff_update
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < ENQUEUE_WIDTH; i = i + 1)
				if (enq_fire[i])
					payload_dff[enq_ptr[i * ENTRY_PTR_WIDTH+:ENTRY_PTR_WIDTH] * 256+:256] <= enqueue_payload_i[i * 256+:256];
		end
	end
	usage_manager #(
		.ENTRY_COUNT(DEPTH),
		.ENQ_WIDTH(ENQUEUE_WIDTH),
		.DEQ_WIDTH(DEQUEUE_WIDTH),
		.FLAG_EN(0),
		.INIT_IS_FULL(0),
		.COMB_DEQ_EN(0),
		.COMB_ENQ_EN(1)
	) u_usage_manager(
		.enq_fire_i(enq_fire),
		.deq_fire_i(deq_fire),
		.head_o(deq_ptr),
		.tail_o(enq_ptr),
		.avail_cnt_o(avail_cnt),
		.flush_i(flush_i),
		.clk(clk),
		.rst(rst)
	);
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
module usage_manager (
	enq_fire_i,
	deq_fire_i,
	head_o,
	tail_o,
	avail_cnt_o,
	flush_i,
	clk,
	rst
);
	parameter [31:0] ENTRY_COUNT = 8;
	parameter [31:0] ENQ_WIDTH = 2;
	parameter [31:0] DEQ_WIDTH = 2;
	parameter [31:0] FLAG_EN = 0;
	parameter [31:0] INIT_IS_FULL = 0;
	parameter [31:0] COMB_ENQ_EN = 0;
	parameter [31:0] COMB_DEQ_EN = 0;
	localparam [31:0] ENTRY_PTR_WIDTH = $clog2(ENTRY_COUNT);
	localparam [31:0] ENTRY_TAG_WIDTH = ENTRY_PTR_WIDTH + FLAG_EN;
	localparam [31:0] USAGE_CNT_WIDTH = $clog2(ENTRY_COUNT + 1);
	input wire [ENQ_WIDTH - 1:0] enq_fire_i;
	input wire [DEQ_WIDTH - 1:0] deq_fire_i;
	output reg [(DEQ_WIDTH * ENTRY_TAG_WIDTH) - 1:0] head_o;
	output reg [(ENQ_WIDTH * ENTRY_TAG_WIDTH) - 1:0] tail_o;
	output wire [USAGE_CNT_WIDTH - 1:0] avail_cnt_o;
	input wire flush_i;
	input clk;
	input rst;
	localparam [31:0] ENQ_CNT_WIDTH = $clog2(ENQ_WIDTH + 1);
	localparam [31:0] DEQ_CNT_WIDTH = $clog2(DEQ_WIDTH + 1);
	localparam [31:0] IS_2N = (2 ** ENTRY_PTR_WIDTH) == ENTRY_COUNT;
	function automatic [ENTRY_TAG_WIDTH - 1:0] head_ptr_plus;
		input reg [ENTRY_TAG_WIDTH - 1:0] head_ptr_i;
		input reg [DEQ_CNT_WIDTH - 1:0] plus_cnt_i;
		reg flag;
		reg [ENTRY_PTR_WIDTH - 1:0] index;
		reg [ENTRY_PTR_WIDTH:0] sum;
		reg [ENTRY_PTR_WIDTH:0] reverse_sum;
		if (IS_2N)
			head_ptr_plus = head_ptr_i + plus_cnt_i;
		else begin
			index = head_ptr_i[ENTRY_PTR_WIDTH - 1:0];
			flag = head_ptr_i[ENTRY_TAG_WIDTH - 1];
			sum = index + plus_cnt_i;
			reverse_sum = sum - ENTRY_COUNT;
			if (FLAG_EN) begin
				if (~reverse_sum[ENTRY_PTR_WIDTH])
					head_ptr_plus = {~flag, reverse_sum[ENTRY_PTR_WIDTH - 1:0]};
				else
					head_ptr_plus = {flag, sum[ENTRY_PTR_WIDTH - 1:0]};
			end
			else if (~reverse_sum[ENTRY_PTR_WIDTH])
				head_ptr_plus = reverse_sum[ENTRY_PTR_WIDTH - 1:0];
			else
				head_ptr_plus = sum[ENTRY_PTR_WIDTH - 1:0];
		end
	endfunction
	function automatic [ENTRY_TAG_WIDTH - 1:0] ptr_plus_one;
		input reg [ENTRY_TAG_WIDTH - 1:0] ptr_i;
		reg flag;
		reg [ENTRY_PTR_WIDTH - 1:0] index;
		reg reverse_flag;
		if (IS_2N)
			ptr_plus_one = ptr_i + 1'b1;
		else begin
			index = ptr_i[ENTRY_PTR_WIDTH - 1:0];
			flag = ptr_i[ENTRY_TAG_WIDTH - 1];
			if (index == (ENTRY_COUNT - 1)) begin
				index = {ENTRY_PTR_WIDTH {1'b0}};
				reverse_flag = ~flag;
			end
			else begin
				index = ptr_i + 1'b1;
				reverse_flag = flag;
			end
			if (FLAG_EN)
				ptr_plus_one = {reverse_flag, index};
			else
				ptr_plus_one = index;
		end
	endfunction
	function automatic [ENTRY_TAG_WIDTH - 1:0] tail_ptr_plus;
		input reg [ENTRY_TAG_WIDTH - 1:0] tail_ptr_i;
		input reg [ENQ_CNT_WIDTH - 1:0] plus_cnt_i;
		reg flag;
		reg [ENTRY_PTR_WIDTH - 1:0] index;
		reg [ENTRY_PTR_WIDTH:0] sum;
		reg [ENTRY_PTR_WIDTH:0] reverse_sum;
		if (IS_2N)
			tail_ptr_plus = tail_ptr_i + plus_cnt_i;
		else begin
			index = tail_ptr_i[ENTRY_PTR_WIDTH - 1:0];
			flag = tail_ptr_i[ENTRY_TAG_WIDTH - 1];
			sum = index + plus_cnt_i;
			reverse_sum = sum - ENTRY_COUNT;
			if (FLAG_EN) begin
				if (~reverse_sum[ENTRY_PTR_WIDTH])
					tail_ptr_plus = {~flag, reverse_sum[ENTRY_PTR_WIDTH - 1:0]};
				else
					tail_ptr_plus = {flag, sum[ENTRY_PTR_WIDTH - 1:0]};
			end
			else if (~reverse_sum[ENTRY_PTR_WIDTH])
				tail_ptr_plus = reverse_sum[ENTRY_PTR_WIDTH - 1:0];
			else
				tail_ptr_plus = sum[ENTRY_PTR_WIDTH - 1:0];
		end
	endfunction
	wire enq_clk_en;
	wire deq_clk_en;
	wire [ENQ_CNT_WIDTH - 1:0] enq_cnt;
	wire [DEQ_CNT_WIDTH - 1:0] deq_cnt;
	reg [ENTRY_TAG_WIDTH - 1:0] head_ptr_d;
	reg [ENTRY_TAG_WIDTH - 1:0] head_ptr_q;
	reg [ENTRY_TAG_WIDTH - 1:0] tail_ptr_d;
	reg [ENTRY_TAG_WIDTH - 1:0] tail_ptr_q;
	reg [USAGE_CNT_WIDTH - 1:0] avail_cnt_d;
	reg [USAGE_CNT_WIDTH - 1:0] avail_cnt_q;
	assign enq_clk_en = |enq_fire_i;
	assign deq_clk_en = |deq_fire_i;
	always @(*) begin : gen_head
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < DEQ_WIDTH; i = i + 1)
				if (i == 0)
					head_o[i * ENTRY_TAG_WIDTH+:ENTRY_TAG_WIDTH] = head_ptr_q;
				else if (COMB_DEQ_EN)
					head_o[i * ENTRY_TAG_WIDTH+:ENTRY_TAG_WIDTH] = (deq_fire_i[i - 1] ? ptr_plus_one(head_o[(i - 1) * ENTRY_TAG_WIDTH+:ENTRY_TAG_WIDTH]) : head_o[(i - 1) * ENTRY_TAG_WIDTH+:ENTRY_TAG_WIDTH]);
				else
					head_o[i * ENTRY_TAG_WIDTH+:ENTRY_TAG_WIDTH] = ptr_plus_one(head_o[(i - 1) * ENTRY_TAG_WIDTH+:ENTRY_TAG_WIDTH]);
		end
	end
	always @(*) begin : gen_tail
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < ENQ_WIDTH; i = i + 1)
				if (i == 0)
					tail_o[i * ENTRY_TAG_WIDTH+:ENTRY_TAG_WIDTH] = tail_ptr_q;
				else if (COMB_ENQ_EN)
					tail_o[i * ENTRY_TAG_WIDTH+:ENTRY_TAG_WIDTH] = (enq_fire_i[i - 1] ? ptr_plus_one(tail_o[(i - 1) * ENTRY_TAG_WIDTH+:ENTRY_TAG_WIDTH]) : tail_o[(i - 1) * ENTRY_TAG_WIDTH+:ENTRY_TAG_WIDTH]);
				else
					tail_o[i * ENTRY_TAG_WIDTH+:ENTRY_TAG_WIDTH] = ptr_plus_one(tail_o[(i - 1) * ENTRY_TAG_WIDTH+:ENTRY_TAG_WIDTH]);
		end
	end
	assign avail_cnt_o = avail_cnt_q;
	always @(*) begin : head_ptr_update
		head_ptr_d = head_ptr_q;
		if (deq_clk_en)
			head_ptr_d = head_ptr_plus(head_ptr_q, deq_cnt);
		if (flush_i)
			head_ptr_d = head_ptr_q;
	end
	always @(*) begin : tail_ptr_update
		tail_ptr_d = tail_ptr_q;
		if (enq_clk_en)
			tail_ptr_d = tail_ptr_plus(tail_ptr_q, enq_cnt);
		if (flush_i)
			if ((INIT_IS_FULL == 1) && (FLAG_EN == 1))
				tail_ptr_d = {~head_ptr_q[ENTRY_TAG_WIDTH - 1], head_ptr_q[ENTRY_PTR_WIDTH - 1:0]};
			else
				tail_ptr_d = head_ptr_q;
	end
	always @(*) begin : avail_cnt_update
		avail_cnt_d = avail_cnt_q;
		if (enq_clk_en)
			avail_cnt_d = avail_cnt_q - enq_cnt;
		if (deq_clk_en)
			avail_cnt_d = avail_cnt_q + deq_cnt;
		if (enq_clk_en & deq_clk_en)
			avail_cnt_d = (avail_cnt_q + deq_cnt) - enq_cnt;
		if (flush_i)
			if (INIT_IS_FULL)
				avail_cnt_d = {USAGE_CNT_WIDTH {1'b0}};
			else
				avail_cnt_d = ENTRY_COUNT[USAGE_CNT_WIDTH - 1:0];
	end
	always @(posedge clk) begin : head_ptr_dff
		if (rst)
			head_ptr_q <= {ENTRY_TAG_WIDTH {1'b0}};
		else if (deq_clk_en | flush_i)
			head_ptr_q <= head_ptr_d;
	end
	always @(posedge clk) begin : tail_ptr_dff
		if (rst) begin
			if (INIT_IS_FULL & FLAG_EN)
				tail_ptr_q <= {1'b1, {ENTRY_PTR_WIDTH {1'b0}}};
			else
				tail_ptr_q <= {ENTRY_TAG_WIDTH {1'b0}};
		end
		else if (enq_clk_en | flush_i)
			tail_ptr_q <= tail_ptr_d;
	end
	always @(posedge clk) begin : avail_cnt_dff
		if (rst) begin
			if (INIT_IS_FULL)
				avail_cnt_q <= {USAGE_CNT_WIDTH {1'b0}};
			else
				avail_cnt_q <= ENTRY_COUNT[USAGE_CNT_WIDTH - 1:0];
		end
		else if ((enq_clk_en | deq_clk_en) | flush_i)
			avail_cnt_q <= avail_cnt_d;
	end
	one_counter #(.DATA_WIDTH(ENQ_WIDTH)) u_enq_one_counter(
		.data_i(enq_fire_i),
		.cnt_o(enq_cnt)
	);
	one_counter #(.DATA_WIDTH(DEQ_WIDTH)) u_deq_one_counter(
		.data_i(deq_fire_i),
		.cnt_o(deq_cnt)
	);
endmodule
