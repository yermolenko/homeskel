#/bin/bash

audiofile=${1:?Audio file name is required}
from_pos=${2:?From position is required}
to_pos=${3:?To position is required}

ffmpeg -i "$audiofile" -ss "$from_pos" -to "$to_pos" -c copy "${audiofile%.*}-from-${from_pos//:/_}-to-${to_pos//:/_}.mp4"
