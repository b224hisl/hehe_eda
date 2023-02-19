#!/bin/bash

# 执行命令
export design_name=vnet_router_all #design folder name
rm -rf ./runs/RUN*

echo "++++Design folder is $design_name++++"

export PDK=sky130A

flow.tcl -design .


# 结束脚本
exit 0