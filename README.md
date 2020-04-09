# ExtractNGSReads
extract subset of  NGS PE reads 

## INSTALl

```
git clone https://github.com/BGI-Qingdao/ExtractNGSReads.git
cd ExtractNGSReads
make
```

## Usage

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

Enjoy !
