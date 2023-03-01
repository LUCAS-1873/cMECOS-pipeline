#!/bin/env bash
#AUTHER:LUCAS
#DATE:20220124
#GOAL:athena准备后的athena组装过程
#USAGE:输入 整理好的json文件 输出文件夹名 线程数
input=`basename $1`
thread=$3
input2=$1
outdir=$2
[ -e ${input} ] && P=${PWD} || P=${input2%/*}
cd $P
CUR_DIR=`pwd`
name=${CUR_DIR##*/}
echo -e "`date|cut -d ' ' -f1,2,3,4` 开始对${input%.json}执行操作。"
if [ ${thread} -gt 127 ]
then
	Th_for_athena=127
else
	Th_for_athena=${thread}
fi
athena-meta --config ${input} --threads ${Th_for_athena} &> athena.log

[ `echo $?` -eq 0 ] && echo "athena-meta运行成功。" || { echo "!WARNING!Athena 出错，请检查log日志！" ; exit 2 ; }
mkdir ${outdir}
mv logs working results athena.log ${outdir}

echo "`date|cut -d ' ' -f1,2,3,4` athena组装完成。"
