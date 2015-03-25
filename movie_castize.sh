#! /bin/bash

#Cron version of the batch convert script by StevenTrux. (https://github.com/steventrux/castize)
#The Purpose of this Script is to batch convert, every x time, any video file in a folder for chromecast compatibility.
#This version of castize will not check ffmpeg compatibility, so if not sure run the ffmpeg auto install script:
#https://raw.githubusercontent.com/steventrux/castize/master/compile_ffmpeg_Ubuntu.sh

# usage:
#########################
#move the script to /usr/local/bin
#edit your crontab (crontab -e), and add this line:
#* * * * * /usr/local/bin/cron_castize.sh
#########################
#the script run every minute (edit the crontab according to your needs)

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
export DISPLAY=:0.0

# Check if another istance of ffmpeg is running. if so exit the script

if pidof -x "ffmpeg" >/dev/null; then
            exit
fi

#set the path with videos to convert
cd /path/to/videos

rename "s/ /_/g" *
for filelist in `find -maxdepth 1 -type f | sed s,^./,,`
do

	if ffmpeg -i $filelist 2>&1 | grep 'Invalid data found'		#check if it's video file
	   then
	   continue
	fi

          vcodec=libx264

	if ffmpeg -i $filelist 2>&1 | grep Audio: | grep aac	        #check audio codec
	   then
	    acodec=copy
	   else
	    acodec=libfdk_aac
	fi

# remove original file extension
         destfile=${filelist%.*}

# using ffmpeg for converting
# edit the destination path for your converted videos
        ffmpeg -i $filelist -codec:v $vcodec -b 2000k -tune -film -codec:a $acodec -b:a 384k -movflags +faststart /destination/path/$destfile.CCast.mkv

# removing original file after convertion
        rm $filelist
done
exit
