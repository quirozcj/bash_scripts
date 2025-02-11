```sh
#!/bin/bash
#SBATCH --partition=
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --mem 10G
#SBATCH -o /scripts/log12/kmc.%N.%j.out # STDOUT
#SBATCH -e /scripts/log12/kmc.%N.%j.err # STDERR
#SBATCH --job-name=kmc
#SBATCH --array=0-187


i=$SLURM_ARRAY_TASK_ID

in_dir=/jic/scratch/groups/Cristobal-Uauy/quirozj/26_uk_cgiar/gbs/
mapfile -t fq_paths < ${in_dir}/fq_paths.tsv
mapfile -t fq_names < ${in_dir}/fq_names.tsv
mapfile -t dir_names < ${in_dir}/dir_names.tsv

fq=${fq_paths[$i]}
name=${fq_names[$i]}
d_name=${dir_names[$i]}

cd $in_dir
mkdir -p ${d_name}

cat ${fq} | gzip > ${d_name}/${name}.fq.gz
```
