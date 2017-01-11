#! /bin/bash
# --- About: Archive, compress, encrypt, and output file to current directory
# --- Usage: script.sh <input_file/folder> <compression> <operation>
# --- Tools needed: tar, gnupg, xz-utils, bzip2, gzip
set -e


# Available ciphers: IDEA, 3DES, CAST5, BLOWFISH, AES, AES192, AES256, TWOFISH, CAMELLIA128, CAMELLIA192, CAMELLIA256
cipher='TWOFISH'


if [ "$#" -lt 3 ]; then
  # if user given commands is less than 3, show help message
  echo 'Usage: script <input_file/folder> <compression(gzip, bzip2, xz)> <operation(archive, extract)>'
  echo '  Example: ./script folder gzip archive'
  exit 2
fi


filename=$1
suffix=$2
op=$3


# archive using specified compression
if [ "$suffix" == 'gzip' ]; then
  # check for operation...
  if [ "$op" == 'archive' ]; then
    # archive, compress, encrypt, and write to file
    tar -c -p "$filename" --to-stdout | \
    gzip --best --stdout | \
    gpg -c --compress-algo Uncompressed --cipher-algo "$cipher" > $(basename "$filename").tar.gz.gpg && echo 'Done!'
  else
    if [ "$op" == 'extract' ]; then
      # decrypt, and extract files from archive
      gpg -d "$filename" | tar -x -z && echo 'Done!'
    fi
  fi

  exit
fi


if [ "$suffix" == 'bzip2' ]; then
  # check for operation...
  if [ "$op" == 'archive' ]; then
    # archive, compress, encrypt, and write to file
    tar -c -p "$filename" --to-stdout | \
    bzip2 --compress --best --stdout | \
    gpg -c --compress-algo Uncompressed --cipher-algo "$cipher" > $(basename "$filename").tar.bz2.gpg && echo 'Done!'
  else
    if [ "$op" == 'extract' ]; then
      # decrypt, and extract files from archive
      gpg -d "$filename" | tar -x -j && echo 'Done!'
    fi
  fi

  exit
fi


if [ "$suffix" == 'xz' ]; then
  # check for operation...
  if [ "$op" == 'archive' ]; then
    # archive, compress, encrypt, and write to file
    tar -c -p "$filename" --to-stdout | \
    xz '--lzma2=dict=128MiB,lc=4,lp=0,pb=2,nice=256,mf=bt4,depth=32768' | \
    gpg -c --compress-algo Uncompressed --cipher-algo "$cipher" > $(basename "$filename").tar.xz.gpg && echo 'Done!'
  else
    if [ "$op" == 'extract' ]; then
      # decrypt, and extract files from archive
      gpg -d "$filename" | tar -x -J && echo 'Done!'
    fi
  fi

  exit
fi