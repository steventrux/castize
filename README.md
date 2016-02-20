# Castize

[![Join the chat at https://gitter.im/steventrux/castize](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/steventrux/castize?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Batch convert script for chromecast compatibility.

The Purpose of this Script is to batch convert any video file in a folder for chromecast compatibility.

The script only convert non compatible audio and video tracks.

# Prerequisites:
Castize requires **ffmpeg**, **H.264** video encoder and **AAC** audio encoder.

[FFmpeg compilation guide](https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu)

If ffmpeg is not installed on your system, castize can compile it for you (only ubuntu is supported right now).

# Usage:
> wget https://raw.githubusercontent.com/steventrux/castize/master/castize.sh

> sh castize.sh /home/user/original_videos /home/user/chromecast_videos

# Convert files inside docker:

Build the castize docker image:

    docker build -t castize .

Convert all files in a directory:

    docker run -v $HOME/videos:/tmp/castize/input:ro -v $HOME/ccast:/tmp/castize/output:rw castize

Convert a single file

    docker run -v $HOME/videos/Single.File.avi:/tmp/castize/input/Single.File.avi:ro -v $HOME/ccast:/tmp/castize/output:rw castize