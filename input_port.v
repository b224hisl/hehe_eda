`include "para.vh"
module input_port #(
  parameter VC_NUM = 1,
  parameter VC_DEPTH  = 1,
  parameter VC_NUM_IDX_W =VC_NUM > 1 ? $clog2(VC_NUM) : 1
)
(
  // input from other router or local port
  input logic rx_flit_v_i

)


// 1 decode flit, get input vc and routing info
input_port_flit_decoder input_port_flit_decoder_u
(
  .flit_v_i     (rx_flit_v_i    ),
  .flit_i       (rx_flit_i      ),
  .flit_look_ahead_routing_i(rx_flit_look_ahead_routing_i),

  .flit_dec_o   (flit_ctrl_info )
);
