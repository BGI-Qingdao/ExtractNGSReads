#!/bin/bash

INPUT=
TEMP_PREFIX='temp'
OUTPUT="output"

script_path=`dirname $0`
PAIRFQ=$script_path"/filterPairFQ"
if [[ ! -e $PAIRFQ ]] ; then 
    echo "please run 'make' command in $script_path"
    exit 1
fi

function usage(){
    echo "Usage :"
    echo "    ./mixed_2_paired.sh --input mixed.fq --out_prefix test \\ "
    echo ""
    echo "Options :"
    echo "       --input        input file that contain both read1 and read2."
    echo "       --output       output file name prefix. "
    echo "       --temp         temporary file name prefix."
    echo "       -h/--help    print this usage and exit."
}

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
        "--output")
            OUTPUT_PREFIX=$2
            shift
            ;;
        "--temp")
            TEMP_PREFIX=$2
            shift
            ;;
        "--input")
            INPUT=$2
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
check_file 'INPUT' $INPUT

###########################################################
# split into read1 & read2
###########################################################
echo "Run awk ..."
date
awk -F '/| ' '{if(FNR%4==1){if($2==1){a=1;}else if($2==2){a=2;}else{print "ERROR unknow header: "$0;}}if(a==1){print $0 >tmp".r1.fastq"}else{print $0>tmp".r2.fastq"}}' tmp=$TEMP_PREFIX $INPUT

echo "Run pairfq ..."
date
$PAIRFQ --input_r1 $TEMP_PREFIX".r1.fastq"  --input_r2 $TEMP_PREFIX".r2.fastq" \
        --output_r1 $OUTPUT_PREFIX".r1.sort.fastq"  --output_r2 $OUTPUT_PREFIX".r2.fastq" \
        --output_rs $OUTPUT_PREFIX".single.fastq"
