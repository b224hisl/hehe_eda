`define FLIT_PAYLOAD_T logic [256-1:0]
`define VC_ID_NUM_MAX_W 3 // ？
`define NodeID_X_Width 2
`define NodeID_Y_Width 2
`define NodeID_Device_Port_Width 2 // ??
`define TxnID_Width 12 // ??
`define QoS_Value_Width 4

typedef struct {
  logic [NodeID_X_Width-1:0]            x_position;
  logic [NodeID_Y_Width-1:0]            y_position;
  logic [NodeID_Device_Port_Width-1:0]  device_port;
  logic [1-1:0]                         device_id; //  ?
} node_id_t;

typedef struct {
    node_id_t rgt_id;
    node_id_t src_id;
    logic [TxnID_Width-1:0] txn_id; //transanction id
    logic [QoS_Value_Width-1:0] qos_value;
} flit_dec_t; 