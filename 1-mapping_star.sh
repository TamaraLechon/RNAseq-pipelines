#!/bin/bash
#SBATCH --partition=QUEUE_NAME       # the requested queue
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=8      #   
#SBATCH --mem-per-cpu=4G     # in megabytes, unless unit explicitly stated
#SBATCH --time=48:00:00
#SBATCH --error=logs/%J.err         # redirect stderr to this file
#SBATCH --output=logs/%J.out        # redirect stdout to this file
#SBATCH --mail-user=USERNAME@INSTITUTIONAL_ADDRESS  # email
#SBATCH --mail-type=BEGIN,END,FAIL      # email on job start, end, and/or failure


## Load some modules
module load  STAR/2.7.3a


## Point to directory containing the reference genome where your sequences will map
export refdir=/your/reference/directory

## Declare your working directory
export workingdir=/your/working/directory


## The commands you want to run

# Index your reference genome so that it can be quickly accessed by STAR
STAR    --runThreadN ${SLURM_CPUS_PER_TASK} \
        --limitGenomeGenerateRAM 31000000000 \
        --runMode genomeGenerate \
        --genomeDir  $refdir/ \
        --genomeFastaFiles $refdir/YOUR_REFERENCE_GENOME.dna.toplevel.fa \
        --sjdbGTFfile $refdir/YOUR_REFERENCE_ANNOTATION.gtf \
        --sjdbOverhang 75

# Note: Change --sjdbOverhang to length of your sequence data /2 minus 1

# List of sequences to align
list=("sample1" "sample2" "samplen")

# Create a new directory to store alignment files
mkdir star

# Map forward and reverse reads to indexed genome

for i in ${list[@]}

do
        echo ${i}

        STAR   --outMultimapperOrder Random \
       --outSAMmultNmax 1 \
       --runThreadN ${SLURM_CPUS_PER_TASK}  \
       --runMode alignReads \
       --outSAMtype BAM Unsorted \
       --quantMode GeneCounts \
       --outFileNamePrefix $workingdir/star/${i}_unsort. \
       --genomeDir $refdir \
       --readFilesIn $workingdir/trimmed/${i}_fp1.fastq.gz $workingdir/trimmed/${i}_fp2.fastq.gz \
       --readFilesCommand zcat
      
done
