#!/bin/env bash                                                                                                                            
#AUTHER:LUCAS
#DATE:20221018
#GOAL:Clean data的kraken物种注释和定量，基于标准库
#USAGE: script Dir_include_all_MAGs OUTPUT_DIR threads
set -u
set -e



IN_DIR=$1
OUT_DIR=$2
thread=$3

mkdir ${OUT_DIR} &> /dev/null

### prokka annotation
source activate prokka
ls ${IN_DIR} > ${OUT_DIR}.binning.list
for i in `cat ${OUT_DIR}.binning.list`
do
	prokka --force --cpus ${thread} --outdir ${OUT_DIR}/annotation/prokka/$i --prefix $i  --locustag $i --metagenome --kingdom Bacteria ${IN_DIR}/$i
done

### emapper annotation
source activate eggnog-mapper
for i in `cat ${OUT_DIR}.binning.list`
do
	emapper.py -i ${i} --itype metagenome -m diamond --evalue 1e-05 -o ${i} --output_dir ${OUT_DIR}/annotation/emapper
done

### gtdb annotation
source activate gtdbtk
gtdbtk classify_wf --genome_dir ${IN_DIR}   --out_dir ${OUT_DIR}/annotation/gtdb --extension fa --cpus ${thread}

### vfdb annotation
source activate abricate
for i in `cat ${OUT_DIR}.binning.list`
do
	abricate $i --db vfdb --minid=75 > ${OUT_DIR}/annotation/vfdb/${i}.vfdb.tab
done

### resfinder annotation
for i in `cat ${OUT_DIR}.binning.list`
do
	abricate $i --db resfinder --minid=75 > ${OUT_DIR}/annotation/resfinder/${i}.resfinder.tab
done

