#! /bin/bash

# Batch Convertion Script by StevenTrux
# The Purpose of this Script is to batch convert any video file to mp4 or mkv format for chromecast compatibility
# this script only convert necessary tracks saving your time!

# Put all video files need to be converted in a folder!

# Variable used:
# outmode should be mp4 or mkv
# sourcedir is the directory where to be converted videos are
# indir is the directory where converted video will be created

# usage:
#########################
# castable.sh mp4 /home/user/videos /home/user/chromecastvideos/
# or
# castable.sh mkv /home/user/videos /home/user/chromecastvideos/
#########################

# working mode
outmode=$1
# check output mode
if [ $outmode ]; then
if [ $outmode = "mp4" ] || [ $outmode = "mkv" ]
	then
	echo "WORKING MODE $outmode"
	else
	echo "$outmode is NOT a Correct target format. You need to set an output format! like castable.sh mp4 xxxx or cast.sh mkv xxxx"
	exit
fi
else
echo "Working mode is missing. You should set a correct target format like mp4 or mkv"
exit
fi

# Source dir
sourcedir=$2
if [ $sourcedir ]; then
     echo "Using $sourcedir as Input Folder"
	else
	 echo "Error: Check if you have set an input folder"
	 exit
fi

# Target dir
indir=$3
if [ $indir ]; then
if mkdir -p $indir/castable
	then
	 echo "Using $indir/castable/ as Output Folder"
	else
	 echo "Error: Check if you have the rights to write in $indir/castable"
	 exit
fi
	else
	 echo "Error: Check if you have set an output folder"
	 exit
fi

# set format
if [ $outmode=mp4 ]
	then
	 outformat=mp4
	else
	 outformat=matroska
fi

# Check FFMPEG Installation
if ffmpeg -formats > /dev/null 2>&1
	then
	 ffversion=`ffmpeg -version 2> /dev/null | grep ffmpeg | sed -n 's/ffmpeg\s//p'`
	 echo "Your ffmpeg verson is $ffversion"
	else
	 echo "ERROR: You need ffmpeg installed with x264 and libfdk_aac encoder"
	 exit
fi

if ffmpeg -formats 2> /dev/null | grep "E mp4" > /dev/null
	then
	 echo "Check mp4 container format ... OK"
	else
	 echo "Check mp4 container format ... NOK"
	 exit
fi

if ffmpeg -formats 2> /dev/null | grep "E matroska" > /dev/null
        then
         echo "Check mkv container format ... OK"
        else
         echo "Check mkv container format ... NOK"
         exit
fi

if ffmpeg -codecs 2> /dev/null | grep "libfdk_aac" > /dev/null
        then
         echo "Check AAC Audio Encoder ... OK"
        else
         echo "Check AAC Audio Encoder ... Not OK"
         echo "Requires ffmpeg to be configured with --enable-libfdk_aac"
         exit
fi

if ffmpeg -codecs 2> /dev/null | grep "libx264" > /dev/null
        then
         echo "Check x264 the free H.264 Video Encoder ... OK"
        else
         echo "Check x264 the free H.264 Video Encoder ... Not OK"
         echo "Requires ffmpeg to be configured with --enable-gpl --enable-libx264"
         exit
fi

echo "Your FFMpeg is OK Entering File Processing"

################################################################
cd "$sourcedir"
rename "s/ /_/g" *
for filelist in `ls`
do

	if ffmpeg -i $filelist 2>&1 | grep 'Invalid data found'		#check if it's video file
	   then
	   echo "ERROR File $filelist is NOT A VIDEO FILE can be converted!"
	   continue
	fi

	if ffmpeg -i $filelist 2>&1 | grep Video: | grep h264		#check video codec
	   then
	    vcodec=copy
	   else
	    vcodec=libx264
	fi

	if ffmpeg -i $filelist 2>&1 | grep Audio: | grep aac	        #check audio codec
	   then
	    acodec=copy
	   else
	    acodec=libfdk_aac
	fi

        echo "Converting $filelist"
	echo "Video codec: $vcodec Audio codec: $acodec Container: $outformat"

# remove original file extension
         destfile=${filelist%.*}

# using ffmpeg for real converting
	echo "ffmpeg -i $filelist -codec:v $vcode -tune -film -codec:a $acodec -b:a 384k -movflags +faststart $indir/castable/$filelist.$outmode"
        ffmpeg -i $filelist -codec:v $vcodec -tune -film -codec:a $acodec -b:a 384k -movflags +faststart $indir/castable/$destfile.$outmode


done
	echo ALL Processed!

###################
echo "DONE, your video files are chromecast ready"
exit
