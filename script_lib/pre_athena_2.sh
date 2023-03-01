#!/bin/env bash
#AUTHER:LUCAS
#DATE20221013
#GOAL:实现整理成输入athena格式的数据的下游athena组装前的处理
#USAGE:输入 整理好的interleaved文件 文件名 最大线程数
set -e -u
thread=$3
file_name=$2
input=`basename $1`
input2=$1
[ -e ${input} ] && P=${PWD} || P=${input2%/*}
cd $P
CUR_DIR=`pwd`
name=${CUR_DIR##*/}

echo ">开始Athena预处理"
echo "开始将${input}转化为fasta格式。"
fq2fa --paired --filter ${input}  ${input}.fa &> /dev/null
echo "开始idba组装。"
idba_ud --num_threads ${thread} -r ${input}.fa -o idba_${file_name} &> /dev/null

echo "开始建立bwa索引。"
bwa index idba_${file_name}/contig.fa &> /dev/null
mkdir bwa_bam_${file_name} &> /dev/null
bwa mem -t ${thread} -C -p idba_${file_name}/contig.fa ${input} 2> /dev/null | samtools sort -@ ${thread} -o bwa_bam_${file_name}/align-reads.bam - &> /dev/null

samtools index bwa_bam_${file_name}/align-reads.bam &> /dev/null

echo "开始建立输入Athena json文件。"
cat > ${input}.json << EOF
{
	"input_fqs": "${input}",
	"ctgfasta_path": "idba_${file_name}/contig.fa",
	"reads_ctg_bam_path": "bwa_bam_${file_name}/align-reads.bam"
}
EOF
   

