`include "para.vh"
module input_port #(
  parameter VC_NUM = 1,
  parameter VC_DEPTH  = 1,
  parameter VC_NUM_IDX_W =VC_NUM > 1 ? $clog2(VC_NUM) : 1
  parameter INPUT_PORT_NO = 0
)
(
  // input from other router or local port
  input rx_flit_v_i,
  input rx_flit_v_i,
  input [FLIT_LEN-1:0] rx_flit_i,
  input [VC_NUM_IDX_W-1:0] rx_flit_vc_id_i, //不一定每次都用上所有channel
  input [VC_ID_NUM_MAX_W-1:0] rx_flit_look_ahead_routing_i,

  //free cv credit sent to sender
  output rx_lcrd_v_o,
  output [VC_ID_NUM_MAX_W-1:0] rx_lcrd_id_o,

  // output head flit ctrl info to SA & RC unit
  output [VC_NUM-1:0]  vc_ctrl_head_vld_o,
  output [VC_NUM-1:0]  vc_ctrl_head_rgt_id_o,
  output [VC_NUM-1:0]  vc_ctrl_head_src_id_o,
  output [VC_NUM-1:0]  vc_ctrl_head_txn_id_o,

);
  wire [VC_NUM-1:0] 


// 1 decode flit, get input vc and routing info
input_port_flit_decoder input_port_flit_decoder_u
(
  .flit_v_i     (rx_flit_v_i    ),
  .flit_i       (rx_flit_i      ),
  .flit_look_ahead_routing_i(rx_flit_look_ahead_routing_i),

  .flit_dec_o   (flit_ctrl_info )
);
