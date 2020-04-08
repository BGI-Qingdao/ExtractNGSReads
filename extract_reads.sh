#!/bin/bash
###########################################################
# basic settings; change below by parameters
###########################################################
R1=""
R2=""
SAMTOOLS='samtools'
BWA='bwa'
REF='hg38.fa'
CPU=8
TEMP_PREFIX='temp'
CHR='chr19'
PAIRFQ='filterPairFQ'
###########################################################
# usage 
###########################################################
function usage(){
    echo "Usage :"
    echo "    ./extract_reads.sh --read1 r1.fq.gz --read2 r2.fq.gz --ref hg38.fa --chr chr1 [OPTIONS]"
    echo ""
    echo "Options :"
    echo "       --read1      read1 file."
    echo "       --read2      read2 file."
    echo "       --ref        reference file."
    echo "       --chr        target chromesome name."
    echo "       --temp       prefix of temporary files. default temp."
    echo "       --cpu        multi-thread used. default 8"
    echo "       --bwa        bwa file"
    echo "       --samtools   samtolls file"
    echo "       --pairfq     pairfq file"
    echo "       -h/--help    print this usage and exit."
}
###########################################################
# parsing command line parameters
###########################################################

echo "CMD :$0 $*"
while [[ $# > 0 ]] 
do
    case $1 in
        "-h")
            usage
            exit 0
            ;;
        "--help")
            usage
            exit 0
            ;;
        "--temp")
            TEMP_PREFIX=$2
            shift
            ;;
        "--cpu")
            CPU=$2
            shift
            ;;
        "--chr")
            CHR=$2
            shift
            ;;
        "--ref")
            REF=$2
            shift
            ;;
        "--bwa")
            BWA=$2
            shift
            ;;
        "--samtools")
            SAMTOOLS=$2
            shift
            ;;
        "--read2")
            R2=$2
            shift
            ;;
        "--read1")
            R1=$2
            shift
            ;;
             *)
            echo "invalid params : \"$1\" . exit ... "
            exit
        ;;
    esac
    shift
done
###########################################################
# santiy check
###########################################################
if [[ ! -e $BWA || ! -e $SAMTOOLS || ! -e $REF || \
    ! -e $READ1 || ! -e $READ2 || ! -e $PAIRFQ ]] ; then
    echo "ERROR :santity check failed !"
    usage
    exit 1
fi
###########################################################
# run ...
###########################################################
$BWA mem -@ $CPU $REF $R1 $R2                  >$TEMP_PREFIX".bwa.mem.sam"  2> $TEMP_PREFIX".bwa.mem.log"
$SAMTOOLS view -@ $CPU -o $TEMP_PREFIX".bam" -b $TEMP_PREFIX".bwa.mem.sam"  2> $TEMP_PREFIX".sam2bam.log"
# for samtools_v1.2 sort , instead of the -o parameter ,the results were pr inted into stdout;
$SAMTOOLS sort -@ $CPU $TEMP_PREFIX".bam"    -o $TEMP_PREFIX".sort.bam" \
                                              1>$TEMP_PREFIX".sort.bam"     2> $TEMP_PREFIX".bamsort.log"
$SAMTOOLS index -bc $TEMP_PREFIX".sort.bam"                                 2> $TEMP_PREFIX".bamindex.log"
$SAMTOOLS view -b $TEMP_PREFIX".sort.bam" $CHR -o $TEMP_PREFIX"."$CHR".bam" 2> $TEMP_PREFIX".bamview.log"
$SAMTOOLS bam2fq   $TEMP_PREFIX"."$CHR".bam" >$CHR.mixed.fastq              2> $TEMP_PREFIX".bam2fastq.log"
###########################################################
# split into read1 & read2
###########################################################
awk -F '/| ' '{if(FNR%4==1){if($2==1){a=1;}else if($2==2){a=2;}else{print "ERROR unknow header: "$0;}}if(a==1){print $0 >tmp".r1.fastq"}else{print $0>tmp".r2.fastq"}}' tmp=$TEMP_PREFIX $CHR.mixed.fastq

$PAIRFQ --input_r1 $TEMP_PREFIX".r1.fastq"  --input_r2 $TEMP_PREFIX".r2.fastq" \
        --output_r1 $CHR".r1.sort.fastq"  --output_r2 $CHR".r2.sort.fastq" \
        --output_rs $CHR".single.fastq"
