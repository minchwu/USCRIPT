#!/bin/bash
# 缓存信息处理，提取数据行
awk '{if($1=="PART-1-1") print $0}' ../source/abaqus.rpt > ../data/tmp.txt
# 空间节点输出
# if test $# -eq 2 # 两个脚本参数，同时处理节点与温度
if (( $# == 2 )) # 两个脚本参数，同时处理节点与温度
then
    echo 2
    if [ -f "../data/$1" ]; then rm "../data/$1"; fi
    if [ -f "../data/$2" ]; then rm "../data/$2"; fi
    # awk '{if(NF==4 && NR%8==1){printf "%6.2f\n", $4}}' ../data/tmp.txt > ../data/$1
    awk '{if(NF==4){printf "%6d\t%6.2f\n", $2, $4}}' ../data/tmp.txt | awk '!a[$1]++' | awk '{print $2}'> ../data/$1
    awk '{if(NF==8){printf "%6.3f\t%6.3f\t%6.3f\n", $4, $5, $6}}' ../data/tmp.txt > ../data/$2
elif (( $# == 1 ))
then
    echo 1
    if [ -f "../data/$1" ]; then rm "../data/$1"; fi
    awk '{if(NF==4 && NR%8==1){printf "%6.2f\n", $4}}' ../data/tmp.txt > ../data/$1
fi
rm ../data/tmp.txt

#TODO: 改进脚本，去除awk脚本，以shell脚本为主进行实现