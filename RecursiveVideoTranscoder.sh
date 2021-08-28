#!/bin/bash

# https://unix.stackexchange.com/questions/230421/unable-to-stop-a-bash-script-with-ctrlc
(
    trap "printout" "$old" SIGINT
    printout() {
        echo "Exiting..."
        echo "$1"
        exit
    }
echo "This script will recursively search for any videos and transcode them in place to make'em smaller"
# echo "do you wish to append _f to transcoded videos?, videos that end with _f won't be transcoded"
# echo "Do you wish to change frame rate?"
find . \( -iname '*.kvm' -o -iname '*avi' -o -iname '*mp4' -o -iname '*flv' -o -iname '*ogg' -o -iname '*mov' -o -iname '*asf' -o -iname '*mkv' \) -print |
    while IFS= read file    # IFS= prevents "read" stripping whitespace
        do
            if [[ "$file" != *"_f."* ]]
            then
                old="${file%.*}_old_f.${file##*.}"
                mv "$file" "$old"
                # < /dev/null to prevent from reading standard input (Strange errors when using ffmpeg in a loop)
                # -max_muxing_queue_size 1024 needed for certain situations (FFMPEG: Too many packets buffered)
                < /dev/null ffmpeg -i "$old" -vcodec libx265 -crf 28 -max_muxing_queue_size 1024 "${file%.*}_f.mp4" || exit

                 rm "$old"
                echo "file $file transcoded..."
            fi
        done
)
