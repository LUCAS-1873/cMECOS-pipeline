#!/bin/env bash 
#AUTHER:LUCAS
#DATE 20230223
#GOAL:从输入的双端 clean reads 文件 生成 athena处理的contig文件
#USAGE:脚本名 左端fq 右端fq 输出文件名开头 线程数
set -u -e

base_dir=`dirname $0`


export PRE_ATHENA_1=${base_dir}/script_lib/pre_athena_1.sh
export PRE_ATHENA_2=${base_dir}/script_lib/pre_athena_2.sh
export RUN_ATHENA=${base_dir}/script_lib/run_athena.sh

pre_athena_1="${PRE_ATHENA_1}"
pre_athena_2="${PRE_ATHENA_2}"
athena_run="${RUN_ATHENA}"

fq1=$1
fq2=$2
name=$3
thread=$4
DIR_FQ=`dirname ${fq1}`

${pre_athena_1} ${fq1} ${fq2} ${name}_interleaved.fq ${thread}
mv ${DIR_FQ}/${name}_interleaved.fq ${base_dir}/${name}_interleaved.fq
${pre_athena_2} ${name}_interleaved.fq ${name}_pre ${thread}

${athena_run} ${name}_interleaved.fq.json ${name}_athena  ${thread}
mv bwa_bam_${name}_pre ${name}_athena/working
mv idba_${name}_pre ${name}_athena/working
mv ${name}_interleaved.fq* ${name}_athena/working/
mv ${name}_athena/results/olc/athena.asm.fa ./${name}_athena_contigs.fa

