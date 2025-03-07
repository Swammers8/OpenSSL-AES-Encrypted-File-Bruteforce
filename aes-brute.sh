#!/bin/bash

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
    echo "[i] Usage: $0 <input_file> <output_file> <wordlist> [iterations]"
    echo "[i] <required> [optional]"
    echo "[i] Iterations default is 10000 if not specified."
    echo "[i] Example: $0 flag.enc cracked.out rockyou.txt 100000"
    exit 1
fi

input_file="$1"
output_file="$2"
wordlist="$3"
iter="${4:-10000}"

if [ ! -f "$input_file" ]; then
    echo "[!] Error: Input file '$input_file' not found!"
    exit 1
fi

if [ ! -f "$wordlist" ]; then
    echo "[!] Error: Wordlist '$wordlist' not found!"
    exit 1
fi

echo "[i] Processing input file: $input_file"
echo "[i] Using wordlist: $wordlist"
echo "[*] Bruteforcing...."

for i in $(cat $wordlist); do
	openssl enc -d -aes256 -pbkdf2 -in $input_file -iter $iter -out $output_file -pass pass:$i 2>err
	result=$(stat -c %s err | tr -d \\n)
	if [ $result -eq 0 ]; then
		test=$(file $output_file)
		if [ "$(echo $test | awk -F: '{print $2}' | tr -d ' ')" != "data" ]; then

			echo "[*] Cracked: $i"
			echo "[i] Saved to: $output_file"
			rm err
			exit
		fi
	else
		rm $output_file
		rm err
	fi
done
echo "[!] Failed! Password was not in provided wordlist"
exit 1
