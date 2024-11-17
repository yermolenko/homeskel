#/bin/bash

echo "Testing PipeWire..."
pw-play /usr/share/sounds/alsa/Rear_Center.wav

sleep 2

echo "Testing PulseAudio..."
paplay /usr/share/sounds/alsa/Rear_Center.wav

sleep 2

echo "Testing default ALSA..."
aplay /usr/share/sounds/alsa/Rear_Center.wav
# speaker-test -c2

sleep 2

echo "Testing PipeWire-ALSA..."
aplay -Dpipewire /usr/share/sounds/alsa/Rear_Center.wav
# speaker-test -Dpipewire -c2
