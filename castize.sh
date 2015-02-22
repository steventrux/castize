#! /bin/bash

#Batch convert script by StevenTrux.
#The Purpose of this Script is to batch convert any video file in a folder for chromecast compatibility.
#The script only convert non compatible audio and video tracks.

# Variable used:
# sourcedir is the directory where to be converted videos are
# indir is the directory where converted video will be created

# usage:
#########################
# castize.sh /home/user/your_videos /home/user/chromecast_videos
#########################
clear
# Check FFMPEG Installation

confirm_mode=0
  while [ $confirm_mode = 0 ]
    do

if ffmpeg -formats > /dev/null 2>&1
	then
	 ffversion=`ffmpeg -version 2> /dev/null | grep ffmpeg | sed -n 's/ffmpeg\s//p'`
	 echo "Your ffmpeg verson is $ffversion"
         ffmpeg=1
	else
	 echo "ERROR: You need ffmpeg installed with x264 and libfdk_aac encoder"
         ffmpeg=0
fi

if ffmpeg -formats 2> /dev/null | grep "E mp4" > /dev/null
	then
	 echo "Check mp4 container format ... OK"
        mp4=1
	else
	 echo "Check mp4 container format ... Not OK"
        mp4=0
fi

if ffmpeg -formats 2> /dev/null | grep "E matroska" > /dev/null
        then
         echo "Check mkv container format ... OK"
        mkv=1
        else
         echo "Check mkv container format ... Not OK"
        mkv=0
fi

if ffmpeg -codecs 2> /dev/null | grep "libfdk_aac" > /dev/null
        then
         echo "Check AAC Audio Encoder ... OK"
        aac=1
        else
         echo "Check AAC Audio Encoder ... Not OK"
         echo
         echo "Requires ffmpeg to be configured with --enable-libfdk_aac"
         echo
        aac=0
fi

if ffmpeg -codecs 2> /dev/null | grep "libx264" > /dev/null
        then
         echo "Check x264 the free H.264 Video Encoder ... OK"
        x264=1
        else
         echo "Check x264 the free H.264 Video Encoder ... Not OK"
         echo
         echo "Requires ffmpeg to be configured with --enable-gpl --enable-libx264"
         echo
        x264=0
fi

      if [ $ffmpeg = 1 ] && [ $mp4 = 1 ] && [ $aac = 1 ] && [ $mkv = 1 ] && [ $x264 = 1 ];
      then
          confirm_mode=1
      else
          echo
          echo "Your FFMpeg installation is Not OK"
          echo

#castize ask for ffmpeg and encoders auto compilation

          confirm_mode=0
               while [ $confirm_mode = 0 ]
               do
                   read -p "Do you want castize compile FFmpeg and needed encoders for you?: " answer
                   compile=$answer
                        if  [ $answer = y ] || [ $answer = Y ];
                           then
                           confirm_mode=1
                           echo "Compiling ffmpeg and needed encoders"
                           wget https://raw.githubusercontent.com/steventrux/castize/master/compile_ffmpeg.sh
                           bash compile_ffmpeg.sh
                           rm compile_ffmpeg.sh
                           exec sh castize.sh
                       else
                            echo "Please compile ffmpeg and needed encoders"
                            exit
                       fi
                 done
      fi
    done


echo
echo "Your FFMpeg installation is OK Entering File Processing"
echo

# Source dir
sourcedir=$1
if [ $sourcedir ]; then
     echo "Using $sourcedir as Input Folder"
     echo
        else
         echo "Error: input folder missing (castize.sh /home/user/your_videos /home/user/chromecast_videos)"
         echo
         exit
fi

# Target dir
indir=$2
if [ $indir ]; then
if mkdir -p $indir/CCast_Videos
        then
         echo "Using $indir/CCast_Videos/ as Output Folder"
         echo
        else
         echo "Error: you can' t write in $indir"
         echo
         exit
fi
        else
         echo "Error: output folder missing (castize.sh /home/user/your_videos /home/user/chromecast_videos)"
         echo
         exit
fi

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

################################################################
cd "$sourcedir"
rename "s/ /_/g" *
for filelist in `find -maxdepth 1 -type f | sed s,^./,,`
do

	if ffmpeg -i $filelist 2>&1 | grep 'Invalid data found'		#check if it's video file
	   then
	   echo "ERROR: $filelist is NOT A VIDEO FILE"
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
	echo "ffmpeg -i $filelist -codec:v $vcode -tune -film -codec:a $acodec -b:a 384k -movflags +faststart $indir/CCast_Videos/$filelist.$outmode"
        ffmpeg -i $filelist -codec:v $vcodec -tune -film -codec:a $acodec -b:a 384k -movflags +faststart $indir/CCast_Videos/$destfile.CCast.$outmode


done
        echo
	echo ALL Processed!

###################
echo
echo "DONE, your video files are chromecast ready!"
exit
