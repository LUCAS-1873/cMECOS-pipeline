#!/bin/env bash
#AUTHER:LUCAS
#DATE:20211008
#GOAL:去接头序列和宿主
#USAGE:依次输入fq1.gz;fq2.gz;样品序号;输出的目录名;最大使用线程数           #所有的参数都要按顺序输入
#要求，双端文件在同一目录下
set -u -e

F_adapter=CTGTCTCTTATACACATCTTAGGAAGACAAGCACTGACGACATGA
R_adapter=TCTGCTGAGTCGAGAACGTCTCTGTGAGCCAAGGAGTTGCTCTGG
base_dir=`dirname $0`


export SOAP_PATH=${base_dir}/script_lib/SOAPfilter_v2.2
export SH1=${base_dir}/script_lib/split_barcode.sh

host_dat="${HOST_DATABASE_PATH}"
SOAP="${SOAP_PATH}"
sh1="${SH1}"

fq1_raw_=$1
fq2_raw_=$2
sample_num=$3
name=$4
thread=$5

trap 'rm split_reads.1.fq.gz.clean.gz split_reads.2.fq.gz.clean.gz lane.lst split_reads.1.fq.gz split_reads.2.fq.gz' ERR EXIT

echo -e "###############################################################################\n开始处理${fq1_raw_}和${fq2_raw_}\n样本编号为${sample_num}\n###############################################################################"


#先运行公司给的perl脚本将read2的后末端42bp去掉并检测包含非识别barode的序列
${sh1} ${fq1_raw_} ${fq2_raw_} ${sample_num} &> cutoff_barcode.log

echo "split_reads.1.fq.gz" >lane.lst
echo "split_reads.2.fq.gz" >>lane.lst
#再运行公司给的SOAPfilter_v2.2去除低质量的read和接头read
${SOAP} -t ${thread} -q 33 -y -F $F_adapter -R $R_adapter -p -M 2 -f -1 -Q 10 lane.lst stat_SOAP.txt &> SOAP.log
echo "质控完成"

#开始去宿主
bowtie2 --very-sensitive -p ${thread} -x ${host_dat} -1 split_reads.1.fq.gz.clean.gz -2 split_reads.2.fq.gz.clean.gz --al-conc ${name}_map.fq --un-conc ${name}_unmap.fq -S ${name}_sam &> bowtie2.log
echo "已去除数据宿主序列。" 

mkdir ${name}_log &> /dev/null
mv split_read_stat.log bowtie2.log SOAP.log stat_SOAP.txt barcode_freq.txt cutoff_barcode.log ${name}_log
mv ${name}_unmap.1.fq ${name}_clean.1.fq
mv ${name}_unmap.2.fq ${name}_clean.2.fq

mkdir ${name}_other_files &> /dev/null
mv ${name}_map.1.fq ${name}_other_files
mv ${name}_map.2.fq ${name}_other_files
mv ${name}_sam ${name}_other_files

