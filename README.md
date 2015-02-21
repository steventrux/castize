# Castize
Batch convert script for chromecast compatibility.

The Purpose of this Script is to batch convert any video file in a folder for chromecast compatibility.

The script only convert non compatible audio and video tracks.

# Prerequisites:
Castize requires **ffmpeg**, **H.264** video encoder and **AAC** audio encoder.

[FFmpeg compilation guide](https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu)

# Variables:
* *sourcedir* is the directory where to be converted videos are
* *destdir* is the directory where converted video will be created
 
# Usage:
> wget https://raw.githubusercontent.com/steventrux/castize/master/castize.sh

> castize.sh /home/user/videos /home/user/chromecastvideos
