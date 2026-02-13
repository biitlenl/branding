#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob

RASTER_FORMATS=("png" "webp")
VECTOR_FORMATS=("svg" "pdf")

SIZES=(1024 512 256 128 64 32)

if [[ -f "../.branding" ]]; then
    cd ..
    pwd
elif [[ -f "./.branding" ]]; then
    pwd
else
    echo "not ok"
    exit
fi

if [[ $(pwd) == "/" ]]; then
    echo "dir is /. quitting to prevent problems."
    exit
fi

cd output
rm -rf kit

rm -rf biitle.nl\ Brand\ Kit*.zip

# create folders

mkdir kit
date -R -u > kit/build_date

cp -r ../source/* kit

cd kit

KITLOC=$(pwd)

echo

for file in ./*/* # this does not work with paths like source/abc/def/a.svg, maybe we should fxi that later?
do
    cd "$KITLOC"
    DIR=$(dirname -- "$file")

    cd "$DIR"
    echo "file: $file"

    echo

    echo -e "\e[1mRASTER\e[0m"

    for format in "${RASTER_FORMATS[@]}"
    do
        EPOCH_START=$(date +%s)

        pwd
        FORMAT_FOLDER=$(tr '[:lower:]' '[:upper:]' <<< "$format")
        mkdir -p "$FORMAT_FOLDER"

        echo "format: $format"

        for size in "${SIZES[@]}"
        do
            ext=".${file##*.}"
            output_file="./$FORMAT_FOLDER/$(basename -- "$file" "$ext")-$size.$format"

            echo "size ${size} ${output_file}"
            magick -background none "$KITLOC/$file" -resize "${size}x" "$output_file"
        done

        EPOCH_END=$(date +%s)

        echo -e "\e[1m$FORMAT_FOLDER files resized in $((EPOCH_END - EPOCH_START)) seconds \e[0m"
        echo
    done

    echo -e "\e[1mVECTOR\e[0m"

    for format in "${VECTOR_FORMATS[@]}"
    do
        EPOCH_START=$(date +%s)

        pwd

        echo "format: $format"

        ext=".${file##*.}"
        output_file="./$(basename -- "$file" "$ext").$format"

        if [[ ".$format" == "$ext" ]]; then
            echo -e "\e[1mSKIPPED vector ${output_file} \e[0m"
            echo
            continue
        fi

        echo "file vector ${output_file}"
        inkscape "$KITLOC/$file" -o "$output_file"

        EPOCH_END=$(date +%s)

        echo -e "\e[1m$(tr '[:lower:]' '[:upper:]' <<< "$format") files resized in $((EPOCH_END - EPOCH_START)) seconds \e[0m"
        echo
    done
    
    cd "$KITLOC"
done

echo -e "\e[1;92mCONVERSION DONE!\e[0m"
echo
echo "📦️ it's zip time"

cd ..
zip -r "biitle.nl Brand Kit $(date -u -I).zip" kit

echo
echo "ALL DONE! You can now push."