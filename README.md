# batch-cast
Batch convert script for chromecast compatibility.

The Purpose of this Script is to batch convert any video file in a folder for chromecast compatibility.
The script only convert necessary tracks, saving your time!
 
Put all video files need to be converted in a folder!
The name of files must not have space. 
 
# Variables:
outmode: mp4 or mkv

sourcedir: is the directory where to be converted videos are

destdir: is the directory where converted video will be created
 
# Usage:
# castable.sh "outmode" "sourcedir" "destdir"
castable.sh mp4 /home/user/videos /home/user/chromecastvideos

or

castable.sh mkv /home/user/videos /home/user/chromecastvideos
