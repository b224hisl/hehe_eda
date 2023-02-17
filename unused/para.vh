`define FLIT_LEN 256
`define VC_ID_NUM_MAX_W 3 // 4+3=7
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


//二维数组打包为一维数组
`define PACK_ARRAY(PK_WIDTH,PK_LEN,PK_SRC,PK_DEST) \
                generate \
                genvar pk_idx; \
                for (pk_idx=0; pk_idx<(PK_LEN); pk_idx=pk_idx+1) \
                begin \
                        assign PK_DEST[((PK_WIDTH)*pk_idx+((PK_WIDTH)-1)):((PK_WIDTH)*pk_idx)] = PK_SRC[pk_idx][((PK_WIDTH)-1):0]; \
                end \
                endgenerate

//一维数组展开为二维数组
`define UNPACK_ARRAY(PK_WIDTH,PK_LEN,PK_DEST,PK_SRC) \
                generate \
                genvar unpk_idx; \
                for (unpk_idx=0; unpk_idx<(PK_LEN); unpk_idx=unpk_idx+1) \
                begin \
                        assign PK_DEST[unpk_idx][((PK_WIDTH)-1):0] = PK_SRC[((PK_WIDTH)*unpk_idx+(PK_WIDTH-1)):((PK_WIDTH)*unpk_idx)]; \
                end \
                endgenerate