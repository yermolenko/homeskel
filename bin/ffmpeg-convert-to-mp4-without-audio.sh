#/bin/bash

videofile=${1:?Video file name is required}

ffmpeg -i "$videofile" -an "${videofile%.*}.mp4"
