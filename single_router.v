`include "para.vh"
typedef logic[256 - 1:0] flit_payload_t
module single_router #(
  parameter INPUT_PORT_NUM = 5,
  parameter OUTPUT_PORT_NUM = 5,
  parameter LOCAL_PORT_NUM  = INPUT_PORT_NUM-4,
  parameter VC_NUM_INPUT_N = 1 + LOCAL_PORT_NUM
)

(
// input from other router or local port
  input logic [INPUT_PORT_NUM-1: 0] rx_flit_pend_i,
  input logic [INPUT_PORT_NUM-1: 0] rx_flit_v_i,
  input `FLIT_PAYLOAD_T [INPUT_PORT_NUM-1: 0] rx_flit_i,
  input logic [INPUT_PORT_NUM-1:0][VC_ID_NUM_MAX_W-1:0]  rx_flit_vc_id_i,

// output to other router or local port // N,S,E,W,L
  output logic [OUTPUT_PORT_NUM-1:0] tx_flit_pend_o,
  output logic [OUTPUT_PORT_NUM-1:0] tx_flit_v_o,
  output  `FLIT_PAYLOAD_T [OUTPUT_PORT_NUM-1: 0] tx_flit_o,
  output logic  [OUTPUT_PORT_NUM-1:0][VC_ID_NUM_MAX_W-1:0]  tx_flit_vc_id_o,

// tell the sender I have received 
  output logic [INPUT_PORT_NUM-1:0] rx_lcrd_v_o,
  output logic [INPUT_PORT_NUM-1:0][VC_ID_NUM_MAX_W-1:0] rx_lcrd_id_o,

// ack from the receiver
  input logic [OUTPUT_PORT_NUM-1:0] tx_lcrd_v_i,
  input logic [OUTPUT_PORT_NUM-1:0][VC_ID_NUM_MAX_W-1:0] tx_lcrd_id_i,

// router addr 3*3 ， 所以每个维度的坐标为2维
  input logic [NodeID_X_Width-1:0] node_id_x_this_hop_i,
  input logic [NodeID_Y_Width-1:0] node_id_y_this_hop_i,

  input  logic clk,
  input  logic rstn

);

  logic [INPUT_PORT_NUM-1:0] inport_read_enable_sa_stage;
  logic [INPUT_PORT_NUM-1:0][VC_ID_NUM_MAX_W-1:0]  inport_read_vc_id_sa_stage;


endmodule