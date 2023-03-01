#!/bin/env bash                                                                                                                            
#AUTHER:LUCAS
#DATE:20221018
#GOAL:Clean data的kraken物种注释和定量，基于标准库
#USAGE: script 左端fq 右端fq 输出目录 使用的线程数
set -u
set -e

DB=${KRAKEN2_DB}


f1=$1
f2=$2
out=$3
thread=$4


mkdir -p ${out}/result

#激活kraken环境
source activate  kraken2
kraken2 --db ${DB} --threads ${thread} --report-zero-counts --use-mpa-style --report ${out}/result.kreport2 --paired ${f1} ${f2} > ${out}/kraken2.log
#species
cat ${out}/result.kreport2|grep -v 'g__Homo'|grep '|s__' |sed 's/.*|s__/s_/g' > ${out}/result/species.txt
#genus
cat ${out}/result.kreport2|grep -v 'g__Homo'|grep '|g__' |grep -v 's__'|sed 's/.*|g__/g_/g' >  ${out}/result/genus.txt
#family
cat ${out}/result.kreport2|grep -v 'g__Homo'|grep '|f__' |grep -v 'g__'|grep -v 's__'|sed 's/.*|f__/f_/g'  > ${out}/result/family.txt
#Order
cat ${out}/result.kreport2|grep -v 'g__Homo'|grep '|o__' |grep -v 'f__'|grep -v 'g__'|grep -v 's__'|sed 's/.*|o__/o_/g' > ${out}/result/order.txt
#Class
cat ${out}/result.kreport2|grep -v 'g__Homo'|grep '|c__'|grep -v '|o__' |grep -v 'f__'|grep -v 'g__'|grep -v 's__'|sed 's/.*|c__/c_/g' > ${out}/result/class.txt
#Phylum
cat ${out}/result.kreport2|grep -v 'g__Homo'|grep '|p__'|grep -v '|c__'|grep -v '|o__' |grep -v 'f__'|grep -v 'g__'|grep -v 's__'|sed 's/.*|p__/p_/g' > ${out}/result/phylum.txt
#Kindom
cat ${out}/result.kreport2|grep -v 'g__Homo'|grep '|k__'|grep -v '|p__'|grep -v '|c__'|grep -v '|o__' |grep -v 'f__'|grep -v 'g__'|grep -v 's__'|sed 's/.*|k__/k_/g' >  ${out}/result/kingdom.txt
#Domain
cat ${out}/result.kreport2|grep -v 'g__Homo'|grep '|d__'|grep -v '|k__'|grep -v '|p__'|grep -v '|c__'|grep -v '|o__' |grep -v 'f__'|grep -v 'g__'|grep -v 's__'|sed 's/.*|d__/d_/g' > ${out}/result/domain.txt


