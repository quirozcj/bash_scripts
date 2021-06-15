#!/bin/bash
# /jic/scratch/groups/Cristobal-Uauy/quirozj/14_cold_storage/scripts
source package /nbi/software/testing/bin/python-3.7.2
source package /nbi/software/production/bin/dtool-3.12.0
source /common/software/linuxbrew/Cellar/lmod/5.9.3/lmod/5.9.3/init/bash
module use /common/modulefiles/Core
module load dtool

echo "" > metadata/fastqs.txt
for path_ecs in `dtool ls ecs://pr-raw-watseq/ | grep ecs `; do
	echo $path_ecs >> metadata/fastqs.txt
	dtool ls $path_ecs  | grep "fastq" | sed -e 's,^,'"$path_ecs"'	,' >> metadata/fastqs.txt 
done