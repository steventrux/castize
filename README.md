# Cron Castize

[![Join the chat at https://gitter.im/steventrux/castize](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/steventrux/castize?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Cron version of the batch convert script for chromecast compatibility.

The Purpose of this Script is to batch convert, every x time, any video file in a folder for chromecast compatibility.

# Prerequisites:
Castize requires **ffmpeg**, **H.264** video encoder and **AAC** audio encoder.

[FFmpeg compilation guide](https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu)

This version of castize will not check ffmpeg compatibility, so if not sure run the ffmpeg auto install script:

> https://raw.githubusercontent.com/steventrux/castize/master/compile_ffmpeg_Ubuntu.sh

# Usage:
Move the script to /usr/local/bin and add to your crontab (crontab -e):

> * * * * * /usr/local/bin/cron_castize.sh

The script will run every minute (edit the crontab according to your needs).
