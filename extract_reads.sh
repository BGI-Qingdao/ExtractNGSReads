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
###########################################################
# usage 
###########################################################
function usage(){
    echo "Usage :"
    echo "    ./extract_reads.sh --read1 r1.fq.gz --read2 r2.fq.gz \\ "
    echo "                       --ref hg38.fa --chr chr1 \\ "
    echo "            --bwa /home/sw/bwa --samtools /home/sw/samtools"
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
function check_file(){
    decr=$1
    file=$2
    if [[ ! -e $file ]] ; then 
        echo "\$$decr in : \"$file\" is not exist!!"
        echo "ERROR :santity check failed !"
        usage
        exit 1
    fi
}
check_file 'BWA' $BWA
check_file 'SAMTOOLS' $SAMTOOLS
check_file 'REF' $REF
check_file 'R1' $R1
check_file 'R2' $R2
## check_file 'PAIRFQ' $PAIRFQ
echo "Start ..."
###########################################################
# run ...
###########################################################

if [[ ! -e $REF".pac" ]] ; then
    echo "Index ref"
    $BWA index $REF 2>$TEMP_PREFIX".bwa.index.log"
else
    echo "Use old ref index..."
fi
echo "Run bwa mem ..."
date
$BWA mem -t $CPU $REF $R1 $R2                  >$TEMP_PREFIX".bwa.mem.sam"  2> $TEMP_PREFIX".bwa.mem.log"
echo "Run samtools sam2bam ..."
date
$SAMTOOLS view -@ $CPU -o $TEMP_PREFIX".bam" -b $TEMP_PREFIX".bwa.mem.sam"  2> $TEMP_PREFIX".sam2bam.log"
echo "Run samtools sort ..."
date
# for samtools_v1.2 sort , instead of the -o parameter ,the results were printed into stdout;
$SAMTOOLS sort -@ $CPU $TEMP_PREFIX".bam"    -o $TEMP_PREFIX".sort.bam" \
                                              1>$TEMP_PREFIX".sort.bam"     2> $TEMP_PREFIX".bamsort.log"
echo "Run samtools index ..."
date
$SAMTOOLS index -bc $TEMP_PREFIX".sort.bam"                                 2> $TEMP_PREFIX".bamindex.log"
echo "Run samtools view ..."
date
$SAMTOOLS view -F 2304 -b $TEMP_PREFIX".sort.bam" $CHR -o $TEMP_PREFIX"."$CHR".bam" 2> $TEMP_PREFIX".bamview.log"
echo "Run samtools sort ..."
# for samtools_v1.2 sort , instead of the -o parameter ,the results were printed into stdout;
$SAMTOOLS sort -@ $CPU $TEMP_PREFIX"."$CHR".bam" -n -o $TEMP_PREFIX"."$CHR".sort.bam" \
                                              1>$TEMP_PREFIX"."$CHR".sort.bam"\
                                                                            2> $TEMP_PREFIX".bamsort1.log"
echo "Run samtools bam2fq ..."
date
$SAMTOOLS bam2fq   $TEMP_PREFIX"."$CHR".sort.bam" -1 $CHR".r1.fastq" \
     -2 $CHR".r2.fastq" -s $CHR".single.fastq"  -0 /dev/null -N             2> $TEMP_PREFIX".bam2fastq.log"
echo "All done."
date
