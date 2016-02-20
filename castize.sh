#! /bin/bash

set -e

# Batch convert script by StevenTrux.
# The Purpose of this Script is to batch convert any video file in a folder for chromecast compatibility.
# The script only convert non compatible audio and video tracks.

# Variable used:
# sourcedir is the directory where to be converted videos are
# indir is the directory where converted video will be created

# usage:
#########################
# castize.sh /home/user/your_videos /home/user/chromecast_videos
#
# choose source/target directory via environment
# CASTIZE_SOURCE_DIR=/home/user/your_videos
# CASTIZE_TARGET_DIR=/home/user/chromecast_videos
#
# choose output mode via environment
# CASTIZE_OUTPUT_MODE=mp4
# CASTIZE_OUTPUT_MODE=mkv
#
# set your email for notifications:
# CASTIZE_EMAIL=user@email.com
#
# skip ffmpeg check:
# CASTIZE_NO_CHECK=1

# skip renaming files:
# CASTIZE_NO_RENAME=1
#
#########################

clear

# Check FFMPEG Installation
function check_ffmpeg() {

    confirm_mode=${CASTIZE_NO_CHECK:-0}
    while [ ${confirm_mode} = 0 ]
    do

        if (ffmpeg -formats > /dev/null 2>&1)
        then
            ffversion=`ffmpeg -version 2> /dev/null | grep ffmpeg | sed -n 's/ffmpeg\s//p'`
            echo "Your ffmpeg verson is $ffversion"
            ffmpeg=1
        else
            echo "ERROR: You need ffmpeg installed with x264 and libfdk_aac encoder"
            ffmpeg=0
        fi

        if (ffmpeg -formats 2> /dev/null | grep "E mp4" > /dev/null)
        then
            echo "Check mp4 container format ... OK"
            mp4=1
        else
            echo "Check mp4 container format ... Not OK"
            mp4=0
        fi

        if (ffmpeg -formats 2> /dev/null | grep "E matroska" > /dev/null)
        then
            echo "Check mkv container format ... OK"
            mkv=1
        else
            echo "Check mkv container format ... Not OK"
            mkv=0
        fi

        if (ffmpeg -codecs 2> /dev/null | grep "libfdk_aac" > /dev/null)
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

        if (ffmpeg -codecs 2> /dev/null | grep "libx264" > /dev/null)
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

        if [ ${ffmpeg} = 1 ] && [ ${mp4} = 1 ] && [ ${aac} = 1 ] && [ ${mkv} = 1 ] && [ ${x264} = 1 ];
        then
            confirm_mode=1
        else
            echo
            echo "Your FFMpeg installation is Not OK"
            echo

            #check running distro
            distro=`lsb_release -si`

            if [ $distro = Ubuntu ];
            then
                #castize ask for ffmpeg and encoders auto compilation

                confirm_mode=0
                while [ ${confirm_mode} = 0 ]
                do
                    read -p "Do you want castize compile FFmpeg and needed encoders for you?: " compile
                    if  [ ${answer} = y ] || [ ${answer} = Y ];
                    then
                        confirm_mode=1
                        echo "Compiling ffmpeg and needed encoders"
                        wget https://raw.githubusercontent.com/steventrux/castize/master/compile_ffmpeg_${distro}.sh
                        bash compile_ffmpeg_${distro}.sh
                        rm compile_ffmpeg_${distro}.sh
                    else
                        echo "Please compile ffmpeg and needed encoders"
                        exit 1
                    fi
                done
            else
                echo "Sorry but actually your distro is not supported"
                echo "Right now only Ubuntu is supported"
                exit 1
            fi
        fi
    done

    echo
    echo "Your FFMpeg installation is OK Entering File Processing"
}

function check_targetdir() {
    if mkdir -p "${indir}/CCast_Videos"
    then
        echo "Using ${indir}/CCast_Videos/ as Output Folder"
        echo
    else
         echo "Error: you can' t write in ${indir}"
         exit 1
    fi
}

function choose_outmode() {
    outmode="${CASTIZE_OUTPUT_MODE}"
    while [ "${outmode}" != 'mp4' ] && [ "${outmode}" != 'mkv' ]
    do
        if [ -n "${outmode}" ]
        then
            echo "${outmode} is NOT a Correct file extension. It should be mkv or mp4."
        fi

        read -p "Enter file extension (mkv or mp4): " outmode
    done
}

# Notify, that destfile ${1} is complete
function notify_complete() {
    if [ -n "${CASTIZE_EMAIL}" ]
    then
        echo "${1} convertion has completed" | /usr/sbin/sendmail -F ffmpeg@castize "${CASTIZE_EMAIL}"
    fi
}

# convert a file ${1}
function convert_file() {
    file="${1}"
	if (ffmpeg -i "${file}" 2>&1 | grep -q 'Invalid data found')  #check if it's video file
    then
	    echo "ERROR: ${file} is NOT A VIDEO FILE"
	    continue
	fi

	if (ffmpeg -i "${file}" 2>&1 | grep Video: | grep -q h264)      #check video codec
    then
        vcodec=copy
    else
        vcodec=libx264
	fi

	if (ffmpeg -i "${file}" 2>&1 | grep Audio: | grep -q aac)       #check audio codec
    then
        acodec=copy
    else
        acodec=libfdk_aac
	fi

    echo "Converting ${file}"
	echo "Video codec: ${vcodec} Audio codec: ${acodec} Container: ${outformat}"

    # remove original file extension
    destfile="${file%.*}"

    # using ffmpeg for real converting
	echo "ffmpeg -i ${file} -codec:v ${vcode} -tune -film -codec:a ${acodec} -b:a 384k -movflags +faststart ${indir}/CCast_Videos/${file}.${outmode}"
        ffmpeg -i "${file}" -codec:v ${vcode} -tune -film -codec:a ${acodec} -b:a 384k -movflags +faststart "${indir}/CCast_Videos/${file}.${outmode}"

    notify_complete ${destfile}
}

function convert_all() {
    for file in $(find -maxdepth 1 -type f | sed s,^./,,)
    do
        convert_file "${file}"
    done
}

function remove_spaces() {
    if [ -z "${CASTIZE_NO_RENAME}" ]
    then
        rename "s/ /_/g" *
    fi
}

function check_dir() {
    if [ -z "${2}" ]
    then
        echo "${1} is unspecified"
        echo "usage: ${0} source-dir target-dir"
        exit 1
    fi

    if [ ! -e "${2}" ]
    then
        echo "${2} does not exist"
        echo "usage: ${0} source-dir target-dir"
        exit 1
    fi
}

if [ $# -eq 2 ]
then
    # pick directories from command line arguments
    sourcedir="${1}"
    indir="${2}"
else
    # pick directories from enviroment
    sourcedir="${CASTIZE_SOURCE_DIR}"
    indir="${CASTIZE_TARGET_DIR}"
fi

check_dir "source directory" "${sourcedir}"
check_dir "target directory" "${indir}"

cd "${sourcedir}"

check_ffmpeg
check_targetdir
choose_outmode
remove_spaces
convert_all

echo
echo "DONE, your video files are chromecast ready!"
