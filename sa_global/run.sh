#!/bin/bash

# 执行命令
export design_name=sa_global #design folder name
rm -rf ./runs/RUN*

echo "++++Design folder is $design_name++++"

export PDK=sky130A

flow.tcl -design .


# 结束脚本
exit 0