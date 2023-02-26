#!/bin/bash

# 基本常量设置
# 根数据路径
sr="../source"
dp="../data"
dt="../test"
# 几何信息 (x0 x1 y0 y1 z0 z1)
ge=(0 1 0 1 0 1)

# AMCA3D标准输入
# 一级标题同时也构建了本级数据仿真结果的根样本
function PBF(){
    # $1 输出路径，$2 文件名
    if [ -f $1/$2.inp ]  # 如果文件存在则重建
    then
        rm $1/$2.inp
        echo -e "Title($1)\nOne cubic mesh\n`date`\nEnd of title" > $1/$2.inp
    else
        mkdir -p $1
        echo -e "Title($1)\nOne cubic mesh\n`date`\nEnd of title" > $1/$2.inp
    fi
}

# 二级标题
function SEC(){
    # $1 输出路径，$2 文件名（一般应继承PBF参数）
    # $3 分析步，$4 时间刻度
    # ge 全局定义几何信息
    if [ -f $1/$2.inp ]
    then
        echo -e "
Subtitle
NS. NS. Time \tTime \tx0 \tx1 \ty0 \ty1 \tz0 \tz1
$3 \t$3 \t$4 \t$4 \t${ge[0]} \t${ge[1]} \t${ge[2]} \t${ge[3]} \t${ge[4]} \t${ge[5]}
x \ty \tz \ttn" >> $1/$2.inp
    else
        mkdir -p $1
        echo -e "
Subtitle
NS. NS. Time \tTime \tx0 \tx1 \ty0 \ty1 \tz0 \tz1
$3 \t$3 \t$4 \t$4 \t${ge[0]} \t${ge[1]} \t${ge[2]} \t${ge[3]} \t${ge[4]} \t${ge[5]}
x \ty \tz \ttn" >> $1/$2.inp
    fi
}

# 数据清理
function tmp(){
    # $1 文件名，$2 原路径，$3 目标路径
    t=`awk '{if($5=="Time"){printf "%6.4f", $7}}' $2/$1`
    awk '{if($1=="PART-1-1") print $0}' $2/$1 > $3/$1
    # 作为缓存文件，数据处理完毕应当删除
}

# 节点信息提取
function DATA(){
    # $1 文件路径，$2 文件名，-N节点坐标，-T温度数据，$3 PBF文件
    awk '{if(NF==8){printf "%6d\t%6.3f\t%6.3f\t%6.3f\n", $2, $3, $4, $5}}' $1/$2 > $1/$2-N.csv
    awk '{if(NF==4){printf "%6d\t%6.2f\n", $2, $4}}' $1/$2 | awk '!a[$1]++' > $1/$2-T.csv
    python -u ./comb.py $1 $2-N $2-T $2-D  # 坐标温度场合并
    awk '{printf "%6.3f\t%6.3f\t%6.3f\t%6.2f\n", $2, $3, $4, $5}' $1/$2-D.csv >> $1/$3.inp # 节点ID去除，信息写入
    rm $1/$2 $1/$2*.csv
    # cat ../data/$var-H.txt ../data/$var-D.txt > ../data/$var.inp  # 时间帧数据合并
}

function GINP(){
    # 文件夹控制
    # if [ -d $dp ]; then rm -r $dp/*; else mkdir $dp; fi
    echo -e "<ginp.sh> processing for PBF.inp! </ginp> (`date`)\n"
    for vard in `ls $sr`  # 遍历原始数据记录文件夹
    do
        srv="$sr/$vard"  # 步进循环数据文件路径
        dpv="$dp/$vard"  # 构建对应数据存储文件路径

        if [ `ls $srv | wc -l` == 0 ]
        then
            echo -e "<ginp> processing for $srv >>> dir is empty & pass </ginp>\n"
            continue
        else
            echo -e "<ginp> processing for $srv >>>"
        fi  # 判断文件夹是否为空，没有数据记录则跳过此文件夹

        if [ -d $dpv ]; then rm -r $dpv/*; else mkdir $dpv; fi  # 构建对应数据处理文件夹，清空文件夹

        PBF $dpv PBF-$vard  # 构建输出文件根
        k=1  # 时间步计数
        for var in `ls $srv`
        do
            echo -e "\t<ginp> processing for $srv/$var >>>"
            tmp $var $srv $dpv
            SEC $dpv PBF-$vard $k $t
            DATA $dpv $var PBF-$vard

            k=$[k+1]  # 时间步顺移
            echo -e "\t<ginp> finished for $var! </ginp>"
        done
        echo -e "<ginp> finished for $srv! </ginp>\n"
    done
    echo -e "<ginp.sh> finished for PBF.inp! </ginp>"
}

if [ $# == 0 ]  # 默认执行主程序
then
    GINP
else
    if [ $1 == '-cd' ]  # 手动清除文件夹
    then
        if [ `ls $dp | wc -l` -gt 0 ]; then rm -r $dp/*; fi
    elif [ $1 == '-ct' ]  # 情况测试测试
    then
        if [ `ls $dt | wc -l` -gt 0 ]; then rm -r $dt/*; fi
    elif [ $1 == '-tp' ]
    then
        PBF ../test/pbf PBF
    elif [ $1 == '-ts' ]
    then
        SEC ../test/sec PBF 1 0
    else
        echo -e "your parameter may not have been implemented!"
    fi
fi
