# ExtractNGSReads
extract subset of  NGS PE reads 

## DOWNLOAD

```
git clone https://github.com/BGI-Qingdao/ExtractNGSReads.git
```
## COMPILE

compile the code only when you use ```mixed_2_paired.sh```


```
cd ExtractNGSReads
make

```

## Usage

* To extract reads that mapped a certain chromesome

```
./extract_reads.sh -h
Usage :
    ./extract_reads.sh --read1 r1.fq.gz --read2 r2.fq.gz \
                       --ref hg38.fa --chr chr1 \
            --bwa /home/sw/bwa --samtools /home/sw/samtools

Options :
       --read1      read1 file.
       --read2      read2 file.
       --ref        reference file.
       --chr        target chromesome name.
       --temp       prefix of temporary files. default temp.
       --cpu        multi-thread used. default 8
       --bwa        bwa file
       --samtools   samtolls file
       -h/--help    print this usage and exit.
```

* To separate r1 and r2 from one unsort and mixed fastq

```
Usage :
    ./mixed_2_paired.sh --input mixed.fq --out_prefix test \

Options :
       --input        input file that contain both read1 and read2.
       --output       output file name prefix.
       --temp         temporary file name prefix.
       -h/--help    print this usage and exit.
```

Enjoy !
