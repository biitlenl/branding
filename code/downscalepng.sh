#!/bin/bash

# downscalepng.sh size density input output

convert -antialias -background transparent -density $1 -resize $2 $3 $4