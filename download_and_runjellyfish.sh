#!/bin/bash -e
#SBATCH --partition=nbi-medium,jic-medium,nbi-long,jic-long,RG-Cristobal-Uauy
#SBATCH --nodes=1
#SBATCH --cpus=1
#SBATCH --mem 5G
#SBATCH --array=1-4
#SBATCH --time=2-00:00:00 
#SBATCH -J extract_cov
#SBATCH --localscratch=ssd:200
#SBATCH -o /jic/scratch/groups/Cristobal-Uauy/quirozj/14_cold_storage/log/jf.%N.%j.out # STDOUT
#SBATCH -e /jic/scratch/groups/Cristobal-Uauy/quirozj/14_cold_storage/log/jf.%N.%j.err # STDERR

##   SBATCH --array=1- 8 24
source /common/software/linuxbrew/Cellar/lmod/5.9.3/lmod/5.9.3/init/bash
module use /common/modulefiles/Core
module load dtool

#this is the SSD folder. We requested 100 GB with --localscratch==ssd:100
SSD=$SLURM_LOCAL_SCRATCH
#use the ssd as dtool cache. This step is important because it avoids having the data on isilon
export DTOOL_CACHE_DIRECTORY=$SSD/dtool

mkdir -p $DTOOL_CACHE_DIRECTORY
echo $SSD
job_id=$SLURM_ARRAY_TASK_ID
#job_id=1

source jellyfish-2.1.4 
pwd
hostname
date

function log_line() {
	echo $(date) "$1" >&2
}


function download_ecs() {
  local ecs=$1
  local name=$2
  local hash=$3
  local tmp_d=$4
  log_line "Loading $name ($ecs $hash) to $tmp_d"
  FILE=`dtool item fetch $ecs $hash` 
  mv $FILE "$tmp_d/$name"
  log_line "Loaded $tmp_d/$name"
}


tmp_dir="$SSD/fastq"
mkdir -p $tmp_dir
log_line "Job: $job_id"
ls $tmp_dir
#sed "${job_id}q;d" metadata/lines_to_extract.txt

line=$(sed "${job_id}q;d" metadata/lines_to_extract.txt)

echo "Line: $line"
out_dir="jf-watseq/$line"
mkdir -p $out_dir
grep $line metadata/fastqs.txt | while read -r ecs hash name; do
  download_ecs $ecs $name $hash $tmp_dir
done

log_line "Running jellyfish"
ls -lah  $tmp_dir/*.fastq.gz

#Checking all the files in the fastq
jellyfish count <(zcat $tmp_dir/*fastq.gz) \
-t 1 \
-C \
-m 31 \
-s 16G \
-L 2 \
--disk \
--out-counter-len 1 \
-o $out_dir/$line.jf \

jellyfish histo $out_dir/${line}.jf > $out_dir/histo_${line}.txt

log_line "DONE"
