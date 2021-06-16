#!/bin/bash
#SBATCH --partition=nbi-long,jic-long,RG-Cristobal-Uauy
#SBATCH -c 1
#SBATCH -N 1
#SBATCH --mem 120000
#SBATCH -o /jic/scratch/groups/Cristobal-Uauy/quirozj/09_watseq/06_scripts/slurmn/IBSpy_multy.%N.%j.out # STDOUT
#SBATCH -e /jic/scratch/groups/Cristobal-Uauy/quirozj/09_watseq/06_scripts/slurmn/IBSpy_multy.%N.%j.err # STDERR
#SBATCH --array=0-71
#SBATCH -J IBSpy_multy

# S B A T C H --localscratch=ssd:200
#i=1
i=$SLURM_ARRAY_TASK_ID

source IBSpy-0.2.0

function log_line() {
	echo $(date) "$1" >&2
}

# symlink to spelta genome
# ln -s /jic/research-groups/Cristobal-Uauy/assemblies/releasePGSBv2.0/genome/spelta.genome.fa \

declare -a references=("arinaLrFor" "chinesespring" "jagger" "julius" "lancer" "landmark" "mace" "norin61" "stanley" "symattis" "spelta.genome" "svevo")

jf_dir_1=/jic/scratch/projects/watseq/kmer_agis/jf-watseq
jf_dir_2=/jic/scratch/groups/Cristobal-Uauy/quirozj/00_jellies

declare -a databases=("$jf_dir_1/WATDE0075/WATDE0075.jf" "$jf_dir_1/WATDE0076/WATDE0076.jf" "$jf_dir_1/WATDE0096/WATDE0096.jf" "$jf_dir_2/koga1/koga1_nuq.jf" "$jf_dir_2/iena/iena_nuq.jf" "$jf_dir_2/highbury/highbury_nuq.jf")

declare -a db_names=("WATDE0075" "WATDE0076" "WATDE0096" "koga1_nuq" "iena_nuq" "highbury_nuq")

r_folder="/jic/research-groups/Cristobal-Uauy/assemblies/10wheat_annotation"
k_folder="/jic/scratch/groups/Cristobal-Uauy/quirozj/09_watseq/01_IBSpy_output"
cd $k_folder

#line=${lines[0]}
reference=$(($i%12))
reference=${references[$reference]}

db_i=$(($i/12))
db=${databases[$db_i]}
name=${db_names[$db_i]}

ref=${r_folder}/${reference}.fa
window_size=50000
log_line "Running from: $PWD"
log_line "Reference: $reference"	
log_line "db: $db"
log_line "name: $name"


out=$k_folder/running
mkdir -p $out
out=$out/${name}_${reference}_${window_size}.tsv.gz

IBSpy --window_size $window_size --kmer_size 31 -f jellyfish --database $db --reference $ref | gzip -c > $out

log_line "DONE"