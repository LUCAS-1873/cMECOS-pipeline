#!/usr/bin/env bash
#DATE:20221013
#AUTHER:LUCAS
#GOAL: MECOS双端数据整理为interleaved格式，并去掉无效barcode序列
#USSAGE: SCRIPT fq1文件 fq2文件 输出interleaved文件名 线程数
#开始将4行换1行

fq1_raw_raw=$1
fq1_raw=`basename $1`
fq2_raw=`basename $2`
out_name=$3
thread=$4

echo -e "######## 开始生成${out_name}文件,使用${thread}个线程 ########"

#RANDOM1
RAN1=`head -n 20 /dev/urandom | cksum |cut -f1 -d " "`
[ -e ${fq1_raw} ] && P=${PWD} || P=${fq1_raw_raw%/*}
cd $P

[ ! -d tmp_split_${RAN1} ] && mkdir -p tmp_split_${RAN1}/fq{1,2} || rm -fr tmp_split_${RAN1}
mkdir -p tmp_split_${RAN1}/fq{1,2} &> /dev/null

cd tmp_split_${RAN1}/fq1
ln -s ../../${fq1_raw} ${fq1_raw}_ln
split -d -l 2000 ${fq1_raw}_ln
find ./ -name 'x*'|sort|xargs -P ${thread} -i sed -i 'N;N;N ;s/\n/\t_|_/g' {}
find ./ -name 'x*'|sort|xargs cat > ../../${fq1_raw}_oneline

cd ../fq2
ln -s ../../${fq2_raw} ${fq2_raw}_ln
split -d -l 2000 ${fq2_raw}_ln
find ./ -name 'x*'|sort|xargs -P ${thread} -i sed -i 'N;N;N ;s/\n/\t_|_/g' {}
find ./ -name 'x*'|sort|xargs cat > ../../${fq2_raw}_oneline

cd ../../

rm -fr tmp_split_${RAN1}

echo ">Read文件 4行换1行完成"
#去掉第二列为0的含有无效barcode的read
#RANDOM2
RAN2=`head -n 20 /dev/urandom | cksum |cut -f1 -d " "`
[ ! -d tmp_split_${RAN2} ] && mkdir -p tmp_split_${RAN2}/fq{1,2} || rm -fr tmp_split_${RAN2}
mkdir -p tmp_split_${RAN2}/fq{1,2} &> /dev/null

cd tmp_split_${RAN2}/fq1
ln -s ../../${fq1_raw}_oneline ${fq1_raw}_oneline_ln
split -d -l 2000 ${fq1_raw}_oneline_ln
find ./ -name 'x*'|sort|xargs -P ${thread} -i sed -i -n "/\tBX:Z:0_0_0-${sample_num}/! p" {}
find ./ -name 'x*'|sort|xargs cat > ../../${fq1_raw}_oneline_filtered 

cd ../fq2
ln -s ../../${fq2_raw}_oneline ${fq2_raw}_oneline_ln
split -d -l 2000 ${fq2_raw}_oneline_ln
find ./ -name 'x*'|sort|xargs -P ${thread} -i sed -i -n "/\tBX:Z:0_0_0-${sample_num}/! p" {}
find ./ -name 'x*'|sort|xargs cat > ../../${fq2_raw}_oneline_filtered

cd ../../

rm -fr tmp_split_${RAN2}

if [ `wc -l ${fq1_raw}_oneline_filtered | cut -d' ' -f1` -eq `wc -l ${fq2_raw}_oneline_filtered | cut -d' ' -f1` ] 
then
    echo "两文件行数一致,继续"
else
    echo 'Error!两单行文件行数不一致！请检查！'
    exit 1
fi

echo ">含有无效barcode的reads已去除"
#合并
#RANDOM3
RAN3=`head -n 20 /dev/urandom | cksum |cut -f1 -d " "`
paste ${fq1_raw}_oneline_filtered  ${fq2_raw}_oneline_filtered  > ${fq1_raw}_twoline

[ ! -e tmp_split_${RAN3} ] && mkdir tmp_split_${RAN3} || rm -fr tmp_split_${RAN3}
mkdir tmp_split_${RAN3} &> /dev/null; cd tmp_split_${RAN3}

ln -s ../${fq1_raw}_twoline ${fq1_raw}_twoline_ln
split -d -l 2000 ${fq1_raw}_twoline_ln
find ./ -name 'x*'|sort|xargs -P ${thread} -i sed -i 's/\t\(@.*_|_\)/\t_|_\1/g' {}
find ./ -name 'x*'|sort|xargs cat > ../${fq1_raw}_twoline_change
cd ..
rm -fr tmp_split_${RAN3}

echo ">r1 r2文件合并完成"

sort -t "`echo -e '\t'`" -k 2 -T ./tmp_sort --parallel=${thread} ${fq1_raw}_twoline_change|sed 's/\t_|_/\n/g' > ${out_name}
rm ${fq1_raw}_oneline_filtered ${fq1_raw}_twoline_change ${fq1_raw}_twoline ${fq2_raw}_oneline_filtered ${fq1_raw}_oneline_filtered ${fq1_raw}_oneline ${fq2_raw}_oneline -fr
echo ">interleaved 文件生成完毕"
echo "##############################"
