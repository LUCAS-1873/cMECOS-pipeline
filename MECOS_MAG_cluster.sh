#!/bin/env bash 
#AUTHER:LUCAS
#DATE 20230223
#GOAL:输入contig文件 和 双端的clean read 文件 进行分箱
#USAGE:SCRIPT reads.fq1 reads.fq2 input_contig.fa  output_file_prefix threads

set -u -e

base_dir=`dirname $0`

pre_athena_1="${PRE_ATHENA_1}"
pre_athena_2="${PRE_ATHENA_2}"
athena_run="${RUN_ATHENA}"

fq1=$1
fq2=$2
contig_=$3
name=$4
thread=$5
DIR_FQ=`dirname ${fq1}`


bowtie2-build -f ${contig_} ${contig_}_index
bowtie2 -x $${contig_}_index -1 ${fq1} -2 ${fq2} -p ${thread} -S $name.sam 2> bowtie2.log
samtools view -F 4 -Sb ${name}.sam  > ${name}.bam
samtools sort ${name}.bam -o ${name}.sort.bam
samtools index ${name}.sort.bam
jgi_summarize_bam_contig_depths  --outputDepth ${name}.depth.txt ${name}.sort.bam
metabat2 -i ${contig_} -a ${name}.depth.txt -o ${name}_metabat2 --sensitive -t ${thread} -v > ${name}.log.txt

#整理中间文件
mkdir tmp_med &> /dev/null
mv ${name}.sort.bam ${name}.depth.txt ${name}.bam ${name}.sam ${contig_}_index* tmp_med
#CHECKM
source activate checkM

checkm lineage_wf -t ${thread} --pplacer_threads 1 -x fa ${name}_metabat2 ${name}_metabat2_checkM -f checkm.log

checkm qa -t ${thread} --tab_table -f allbin.checkm ${name}_metabat2_checkM/lineage.ms ${name}_metabat2_checkM/
