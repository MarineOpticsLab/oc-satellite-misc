#!/bin/bash

# This script:
# 1) reads a text file with seawifs, modis and viirs download urls
# 2) calls the appropriate workflow for a given satellite
# 3) forks the while loop, so multiple instances run at once
#
# inputs: $1 = full path of file containing download urls


# function to loop over for every download url
satproc_init()
{
sat=${2:0:1}
year=${2:1:4}
doy=${2:5:3}
L2file=$2.L2
savedir=/mnt/storage/labs/mitchell/nasacms2018/analysis/data/satellite/

if [[ $sat = A ]]
then
	satellite="aqua"
	if [[ ! -f $savedir$satellite/$year/$doy/$L2file ]]; then
		modis_workflow.sh $1
	else
		echo $L2file" already exists"
	fi
elif [[ $sat = T ]]
then
	satellite="terra"
	if [[ ! -f $savedir$satellite/$year/$doy/$L2file ]]; then
		modis_workflow.sh $1
	else
		echo $L2file" already exists"
	fi
elif [[ $sat = S ]]
then
	satellite="seawifs"
	if [[ ! -f $savedir$satellite/$year/$doy/$L2file ]]; then
		seawifs_workflow.sh $1
	else
		echo $L2file" already exists"
	fi
elif [[ $sat = V ]]
then
	satellite="viirs"
	if [[ ! -f $savedir$satellite/$year/$doy/$L2file ]]; then
		viirs_workflow.sh $1
	else
		echo $L2file" already exists"
	fi
else
	echo "ERROR: unrecognized satellite sensor. Aborting..."
fi
}

while IFS=, read -r cruise granid granlink || [ -n "$cruise" ]; do
	while [ $(jobs | wc -l) -ge 8 ] ; do
		sleep 1s
	done
	satproc_init $granlink $granid &
done < $1