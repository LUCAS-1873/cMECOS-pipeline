# cMECOS-pipline
cMECOS analysis pipeline

# conda environment preparation

##Configure athena and other software environment
```
conda create -n athena2
conda activate athena2
conda install -c bioconda athena_meta=1.2
conda install -c bioconda bowtie2==2.2.5
conda install -c bioconda metabat2==2.12.1
```

##Configure kraken2 environment
```
conda create -n kraken2 -c bioconda kraken2 
```
## download kraken2 database
```
conda activate kraken2 
kraken2-build --standard --threads 24 --db kraken2_std
conda deactivate
```
##Configure prokka environment
```
conda create -n prokka -c bioconda prokka==1.14.6
```

##Configure gtdbtk environment
```
conda create -n gtdbtk
conda activate gtdbtk
conda install -c bioconda gtdbtk==1.7.0
```
### follow the gtdbtk instruction to prepare the Database(https://github.com/Ecogenomics/GTDBTk)
```
###eg:
sh download-db.sh
export GTDBTK_DATA_PATH=/gtdbtk-1.7.0/db/release202/
```
## Configure eggnog-mapper enviroment
```
conda install -c bioconda eggnog-mapper

#emapper-2.1.6 / Expected eggNOG DB version: 5.0.2 / Installed eggNOG DB version: 5.0.2 / Diamond version found: diamond version 2.0.11 / MMseqs2 version found: 113e3212c137d026e297c7540e1fcd039f6812b1
```
## Configure CheckM enviroment
```
conda create -n checkM python=3.9
conda activate checkM
conda install numpy matplotlib pysam
conda install hmmer prodigal pplacer
pip3 install checkm-genome

### Download the CheckM database
https://data.ace.uq.edu.au/public/CheckM_databases/

###unpack
tar zxvf checkm_data_2015_01_16.tar.gz 
#### set the PATH for it
checkm data setRoot {PATH of unpacked}

conda deactivate 
```
## Configure abricate enviroment
```
conda create -c bioconda -n abricate abricate==0.5
```
## preparation of host database: 
### Download human database or mice database or others(According to your data)

* human (hg39)
```
wget -c --timestamping 'ftp://hgdownload.cse.ucsc.edu/goldenPath/hg38/chromosomes/*'
gunzip * 
cat *.fa > hg38.fa
conda activate athena2
bowtie2-build hg38.fa hg38
```
* mice (mm39)
```
wget -c --timestamping 'ftp://hgdownload.cse.ucsc.edu/goldenPath/mm39/chromosomes/*'
cat *.fa > mm39.fa
bowtie2-build mm39.fa mm39
```
# Raw Reads to MAGs

## Set the environment variable
##set the PATH variable in the PATH_pre_configure.sh
```
source PATH_pre_configure.sh
```
1. QC and filter low-quanlity reads
```
###eg: Add the sample ID 1 to the paired sequence (1.fq 2.fq) and output it to the A1 directory, using 100 threads.

MECOS_reads_process.sh 1.fq.gz 2.fq.gz 1 A1 100
```
2. Assemble clean reads to contigs
```
###eg:input 1.fq 2.fq and output to Athena directory, using 100 threads.
MECOS_contig_assemble.sh 1.fq 2.fq Athena 100
```
3. cluster contigs to MAGs
```
###eg: Input Read sequence (1.fq 2.fq) in double-ended fastq format. And the conitg file (athena_contig.fa), the output prefix name (metabat2), using 100 threads.
MECOS_MAG_cluster.sh 1.fq 2.fq athena_contig.fa metabat2 100

###The output includes the quality of each MAG detected by CheckM and the MAG file formed by clustering.
```
# Processed annotation and analysis

1. Annotation reads with kraken2
```
###eg: Input Read sequence (1.fq 2.fq) and then used kraken2 to get taxonomic profiling in Kraken_res directory with 100 threads
Read_anno_kraken.sh 1.fq 2.fq Kraken_res 100
```
2. Annotation MAGs
```
###eg: Input the directory HMQ_MAGs which included MAGs obtained from step.3 above ; and annotated them with 100 threads,output to Res_MAGs_analysis directory
MAG_processed.sh HMQ_MAGs Res_MAGs_analysis 100
```
