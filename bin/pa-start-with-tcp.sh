#!/bin/bash

pulseaudio -k
pulseaudio --start && pacmd load-module module-native-protocol-tcp
