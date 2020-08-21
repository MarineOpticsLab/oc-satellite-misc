#!/bin/bash

# This script is for MODIS files and:
# 1) downloads a L1A file for an input download url,
# 2) creates the GEO file
# 3) extracts the ROI from the L1A file
# 4) process the subcened L1A to L2
# 5) removes the L1A, GEO, GEO.SUB and L1B.SUB
#
# inputs: $1 = url to download

#-----------------------------------
# Downloading file
#-----------------------------------

#string manipulation to set savedir
filename=${1##*/}

echo "working on :" $filename

sat=${filename:0:1}
year=${filename:1:4}
doy=${filename:5:3}

#sorting file names
base=${filename%%.*}
L1Afile=${filename%.*}
L1Asubfile=$L1Afile.SUB
geofile=$base.GEO
geosubfile=$geofile.SUB
L1Bfile=$base.L1B_LAC
L2file=$base.L2
outputlog=$base.log
parfile=$base.par
tprfile=$base.tpr
defaultpar=/mnt/storage/labs/mitchell/nasacms2018/analysis/scripts/pardefaults.par

if [[ $sat = A ]]
then
	satellite=aqua
elif [[ $sat = T ]]
then
	satellite=terra
else
	echo "ERROR: unrecognized satellite sensor. Aborting..."
	exit 1
fi

savedir=/mnt/storage/labs/mitchell/nasacms2018/analysis/data/satellite/$satellite/$year/$doy/
mkdir -p $savedir
cd $savedir

#download L1A file if it doesn't already exist
#NB: user credentials in ~/.urs_cookies
if [[ ! -f $savedir$filename ]]; then
	#echo "***** Downloading " $filename " *****"
	wget --load-cookies=~/.urs_cookies --auth-no-challenge=on \
	--directory-prefix=$savedir --content-disposition -o $outputlog $1

	wgetL1AStatus=$?
fi

if [[ wgetL1AStatus -eq 0 ]]; then
	#-----------------------------------
	# Process file to level 2
	#-----------------------------------
	#echo "***** Processing " $base " *****"

	#unzip
	bunzip2 $filename

	modis_GEO.py $L1Afile -o $geofile --refreshDB --verbose >> $outputlog
	geoStatus=$?

	if [[ geoStatus -eq 0 ]]; then
		modis_L1A_extract.py --verbose $L1Afile --geofile=$geofile \
		-w -71 -s 42 -e -66 -n 45 \
		-o $L1Asubfile --extract_geo=$geosubfile >> $outputlog
		extractStatus=$?

		if [[ $extractStatus -eq 0 ]]; then
			#echo "successful extraction of " $L1Afile	
			
			#L1A to L1B
			modis_L1B.py $L1Asubfile $geosubfile --del-hkm --del-qkm --okm=$L1Bfile >> $outputlog

			#getting ancillary data
			getanc.py $L1Bfile > $outputlog
			
			#making par file by combining anc with the defaults and filenames
			cat <<-EOF >$tprfile
				ifile=$L1Bfile
				geofile=$geosubfile
				ofile1=$L2file
			EOF
			
			cat $tprfile $defaultpar ${L1Bfile}.anc > $parfile
			
			#L1B to L2
			l2gen par=$parfile >> $outputlog
			l2Status=$?

			#removing unneeded files
			rm $tprfile
			rm $L1Bfile.anc
			rm $L1Afile
			rm $geofile
			rm $L1Bfile
			rm $geosubfile
			rm $L1Asubfile
			rm $outputlog
			rm $parfile
			
			if [[ l2Status -eq 0 ]]; then
				echo "L2 file " $L2file " produced"
			else
				echo "ERROR: Failed processing L1A to L2 for " $base
			fi
		else
			rm $L1Afile
			rm $geofile
			echo "ERROR: Extraction failed for " $L1Afile
		fi
	else
		rm $L1Afile
		echo "ERROR: GEO errors for " $L1Afile
	fi
else
	echo "ERROR: wget fail for " $filename
fi
