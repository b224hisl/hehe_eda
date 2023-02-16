`include "para.vh"
module input_port_flit_decoder(
    input logic flit_v_i,
    input `FLIT_PAYLOAD_T flit_i,
    output flit_dec_t flit_dec_o
);

assign flit_dec_o.qos_value = flit[QoS_Value_Width-1:0];
assign flit_dec_o.tgt_id = flit[QoS_Value_Width+NodeID_Width-1:QoS_Value_Width];
assign flit_dec_o.src_id = flit_i[QoS_Value_Width+NodeID_Width+NodeID_Width-1:QoS_Value_Width+NodeID_Width];
assign flit_dec_o.txn_id = flit_i[QoS_Value_Width+NodeID_Width+NodeID_Width+TxnID_Width-1:QoS_Value_Width+NodeID_Width+NodeID_Width];
endmodule