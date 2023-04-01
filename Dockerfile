FROM jrottenberg/ffmpeg

# Usage:
#
# Convert all files in a directory:
# docker run -v $HOME/videos:/tmp/castize/input:ro -v $HOME/ccast:/tmp/castize/output:rw castize
#
# Convert a single file
# docker run -v $HOME/videos/Single.File.avi:/tmp/castize/input/Single.File.avi:ro -v $HOME/ccast:/tmp/castize/output:rw castize

ENTRYPOINT ["/usr/local/bin/castize.sh"]

ENV CASTIZE_NO_CHECK=1 \
    CASTIZE_NO_RENAME=1 \
    CASTIZE_OUTPUT_MODE=mkv \
    CASTIZE_SOURCE_DIR=/tmp/castize/input \
    CASTIZE_TARGET_DIR=/tmp/castize/output

ADD castize.sh /usr/local/bin/
