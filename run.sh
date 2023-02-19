#!/bin/bash

# 执行命令
export design_name=vnet_router_all #design folder name
export PROJ_ROOT=$(pwd)
rm -rf $PROJ_ROOT/$design_name/runs/RUN*

echo "++++Design folder is $design_name++++"

export PDK=sky130A


flow.tcl -design $design_name


# 结束脚本
exit 0