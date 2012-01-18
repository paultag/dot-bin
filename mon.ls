#!/bin/bash
xrandr -q | grep "^[^\ ].*" | grep -v Screen
