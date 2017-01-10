#! /bin/bash
# --- About: Generates random passwords.
# --- Usage: script.sh <length>
# --- Tools needed: head, xxd
if [ $# -eq 0 ]; then
  echo 'Usage: script.sh <length>'
  echo '  Example: script.sh 20'
  exit 2
fi

len="$1"
# chars len must be 0..255, or 256 total count
# A-Z a-z 0-9
chars='0123456789ABCÇDEFGHIJKLMNOPQRSTUVWXYZabcçdefghijklmnopqrstuvwxyz"!@#$%&*()_-+[]{}<>:\/0123456789ABCÇDEFGHIJKLMNOPQRSTUVWXYZabcçdefghijklmnopqrstuvwxyz"!@#$%&*()_-+[]{}<>:\/0123456789ABCÇDEFGHIJKLMNOPQRSTUVWXYZabcçdefghijklmnopqrstuvwxyz"!@#$%&*()_-+[]{}<>:'

# generate password
while [ "$len" -gt 0 ];
do
  # get random index
  a=$(head -c 1 /dev/urandom | xxd -p)
  index=$(echo $((0x$a)))

  # update password
  pass="$pass"$(echo -n ${chars:$index:1});

  # update counter
  let len=len-1;
done

# show generated password
echo "$pass"
unset pass