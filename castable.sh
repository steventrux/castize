#! /bin/bash

#Batch convert script by StevenTrux.
#The Purpose of this Script is to batch convert any video file in a folder for chromecast compatibility.
#The script only convert non compatible audio and video tracks.

# Variable used:
# sourcedir is the directory where to be converted videos are
# indir is the directory where converted video will be created

# usage:
#########################
# castable.sh /home/user/videos /home/user/chromecastvideos
#########################
clear
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

echo
echo "Your FFMpeg installation is OK Entering File Processing"
echo

confirm_mode=0
  while [ $confirm_mode = 0 ]
    do
      read -p "Enter file extension (mkv or mp4): " answer
      outmode=$answer
      if [ $outmode = "mp4" ] || [ $outmode = "mkv" ]
      then
        confirm_mode=1
      else
      echo "$outmode is NOT a Correct file extension. It should be mkv or mp4."
      fi
    done

# Source dir
sourcedir=$1
if [ $sourcedir ]; then
     echo "Using $sourcedir as Input Folder"
	else
	 echo "Error: Check if you have set an input folder"
	 exit
fi

# Target dir
indir=$2
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
        echo
	echo ALL Processed!

###################
echo
echo "DONE, your video files are chromecast ready"
exit
