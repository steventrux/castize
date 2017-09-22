# Castize

[![Join the chat at https://gitter.im/steventrux/castize](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/steventrux/castize?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Batch convert script for chromecast compatibility.

The Purpose of this Script is to batch convert any video file in a folder for chromecast compatibility.

The script only convert non compatible audio and video tracks.

# Prerequisites:
Castize requires **ffmpeg**, **H.264** video encoder and **AAC** audio encoder.

[FFmpeg compilation guide](https://cnhv.co/hbo)

If ffmpeg is not installed on your system, castize can compile it for you (only ubuntu is supported right now).

# Usage:
> wget https://raw.githubusercontent.com/steventrux/castize/master/castize.sh

> sh castize.sh /home/user/original_videos /home/user/chromecast_videos
