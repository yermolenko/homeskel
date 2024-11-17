#/bin/bash

audiofile=${1:?Audio file name is required}
from_pos=${2:?From position is required}

ffmpeg -i "$audiofile" -ss "$from_pos" -c copy "${audiofile%.*}-from-${from_pos//:/_}.mp4"
