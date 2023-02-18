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
// module std_dffre (
// 	clk,
// 	rstn,
// 	en,
// 	d,
// 	q
// );
// 	parameter WIDTH = 8;
// 	input clk;
// 	input rstn;
// 	input en;
// 	input [WIDTH - 1:0] d;
// 	output wire [WIDTH - 1:0] q;
// 	reg [WIDTH - 1:0] dff_q;
// 	always @(posedge clk or negedge rstn)
// 		if (~rstn)
// 			dff_q <= {WIDTH {1'b0}};
// 		else if (en)
// 			dff_q <= d;
// 	assign q = dff_q;
// endmodule
