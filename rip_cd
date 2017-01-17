#! /bin/bash
# --- About: Rip tracks from audio CD to current folder
# --- Usage: script.sh <device> <offset> <bool:whole_cd_rip> <opt_int:track>
# --- Options:
#       <device>:       the audio cd device e.g.: /dev/sr0, /dev/cdrom
#       <offset>:       the audio cd device offset e.g.: +0, +6, -10, -12
#       <whole_cd_rip>: rip audio cd tracks to a single file, possible values are: true, false
#       <track>:        (OPTIONAL) track number to be extracted from audio cd, if specified only this track will be extracted
# --- Tools needed: cdparanoia, cdrdao
set -e


# if options given is less than 1 then show help message
if [ $# -lt 3 ]; then
  echo 'Usage: script.sh <device> <offset> <bool:whole_cd_rip> <opt_int:track>'
  echo '  Example: script.sh /dev/sr0 +6 false'
  exit 2
fi


device=$1
offset=$2
whole_cd=$3
single_track=$4


# set hash tool
hash_tool=sha256sum
hash_name=SHA256
error_count=0
# try to extract cd audio device model name
dev=$(echo $device | sed 's/\//\\\//g')
device_model=$(cdrdao scanbus 2>&1 | grep -o -P '^'$device' :.*$' | tr -s ' ' | sed 's/ ,/,/g;s/ :/:/g;s/'$dev'\: //g' | tr -d ',')
log_file="rip.log"


# get count of tracks
if [ -z "$single_track" ]; then
  # no individual track specified, extract all tracks
  track_count=$(cdparanoia -Q -d "$device" 2>&1 | grep -o -P "^\s+\d+\.[0-9]*\s*" | wc -l)
  track=$track_count
else
  track_count=1
  track=$single_track
fi


# log 1
echo "Device: $device_model" > $log_file
echo "Sample offset: $offset" >> $log_file
echo "Software: cdparanoia" >> $log_file
echo >> $log_file
echo 'Started... Date format is YYYY-MM-DD HH:MM:SS (YEAR-MONTH-DAY HOUR:MINUTE:SECOND)' >> $log_file
echo -n '---------------------------------------------------------------------------------' >> $log_file


# both variables are used for same purpose, but "vcount" never changes in code
vcount=3
verr_count=3
# set whole cd tracks
whole_cd_tracks=$track_count


while [ "$track_count" -gt 0 ];
do
  verr_count="$vcount"


  # extract current track x times
  while [ "$verr_count" -gt 0 ];
  do
    if [ "$whole_cd" == "false" ]; then
      # log 2
      echo -n -e '\n'$(date '+%Y-%m-%d %H:%M:%S %Z')'\x20--\x20' >> $log_file
      echo -n "Extracting: Track $track ($((vcount-verr_count+1))) > " >> $log_file

      cdparanoia -d "$device" -w -X -z --sample-offset "$offset" -v "$track" "track-$track.wav.$verr_count"

      # log 3
      echo -n "track-$track.wav.$verr_count > " >> $log_file

      # check if files are all equal
      if [ "$verr_count" == "$vcount" ]; then
        match=$($hash_tool "./track-$track.wav.$verr_count" | grep -o -P '^[0-9a-fA-F]*')

        echo "Track $track #$((vcount-verr_count+1)): $match"

        # log 4
        echo -n "$match ($hash_name)" >> $log_file
      else
        hash=$($hash_tool "./track-$track.wav.$verr_count" | grep -o -P '^[0-9a-fA-F]*')
        echo "Track $track #$((vcount-verr_count+1)): $hash"

        # log 5
        echo -n "$hash ($hash_name)" >> $log_file

        if [ "$hash" != "$match" ]; then
          # not match, skip track
          # log 6
          echo -n -e '\n'$(date '+%Y-%m-%d %H:%M:%S %Z')'\x20--\x20' >> $log_file
          echo '*** ERROR! *** Hash not match, skipping track...' >> $log_file

          error_count=$((error_count+1))

          # delete failed files...
          verr_count=0

          while [ "$verr_count" -lt "$vcount" ];
          do
            verr_count=$((verr_count+1))

            rm -f "track-$track.wav.$verr_count"
          done

          verr_count=1
        fi
      fi
    else
      # whole_cd=true, extract all tracks to single file
      cdparanoia -d "$device" -w -X -z "1-$whole_cd_tracks" "audio_cd.wav.$verr_count"

      # check if files are all equal
      if [ "$verr_count" == "$vcount" ]; then
        match=$($hash_tool "./audio_cd.wav.$verr_count" | grep -o -P '^[0-9a-fA-F]*')
        echo "CD data #$((vcount-verr_count+1)): $match"
      else
        hash=$($hash_tool "./audio_cd.wav.$verr_count" | grep -o -P '^[0-9a-fA-F]*')
        echo "CD data #$((vcount-verr_count+1)): $hash"

        if [ "$hash" != "$match" ]; then
          # not match, abort
          verr_count=1
        fi
      fi

      track_count=1
    fi  

    verr_count=$((verr_count-1))
  done


  # rename extracted filename, and delete others if match
  if [ "$hash" == "$match" ]; then
    verr_count=$((verr_count+1))

    # rename temp file
    if [ "$whole_cd" == "false" ]; then
      # log 7
      echo -n -e '\n'$(date '+%Y-%m-%d %H:%M:%S %Z')'\x20--\x20' >> $log_file
      echo -n "Renaming file: 'track-$track.wav.$verr_count' to 'track-$track.wav'" >> $log_file

      mv "track-$track.wav.$verr_count" "track-$track.wav" && $hash_tool "track-$track.wav" >> $hash_tool
    else
      mv "audio_cd.wav.$verr_count" "audio_cd.wav" && $hash_tool "audio_cd.wav" >> $hash_tool
      cdrdao read-toc --device $device --datafile "audio_cd.wav" "audio_cd.toc"
    fi

    # delete temp files
    while [ "$verr_count" -lt "$vcount" ];
    do
      verr_count=$((verr_count+1))

      if [ "$whole_cd" == "false" ]; then
        # log 8
        echo -n -e '\n'$(date '+%Y-%m-%d %H:%M:%S %Z')'\x20--\x20' >> $log_file
        echo -n "Deleting file: 'track-$track.wav.$verr_count'" >> $log_file

        rm "track-$track.wav.$verr_count"
      else
        rm "audio_cd.wav.$verr_count"
      fi
    done


    # track finished
    #log 9
    echo >> $log_file
  fi


  track=$((track-1))
  track_count=$((track_count-1))
done

# log 10
echo -n -e '\n'$(date '+%Y-%m-%d %H:%M:%S %Z')'\x20--\x20' >> $log_file

if [ $error_count -gt 0 ]; then
  echo 'Task finished with error(s). :(' >> $log_file
else
  echo 'Task finished successfully! :)' >> $log_file
fi
