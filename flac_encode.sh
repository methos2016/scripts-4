#! /bin/bash
# --- About: Encode input audio files with flac from current folder and delete source files
# --- Usage: script.sh <input_file_extension> <threads>
# --- Tools needed: flac, head, xxd, parallel
set -e


if [ "$#" -lt 2 ]; then
  # if user given commands is less than 1, show help message
  echo 'Usage: script <input_file_extension> <threads>'
  echo '  Example: ./script wav 2'
  exit 2
fi


ext=$1
rnd=$(head -c 4 /dev/urandom | xxd -p)
threads=$2
  let threads=threads+1


# get list of arguments
for f in ./*."$ext";
  do
    echo $f >> "$rnd.txt"
  done


parallel -j $threads 'flac {} --best -V && rm -f {}' < "$rnd.txt" && rm -f "$rnd.txt" && echo 'Done!'


exit
