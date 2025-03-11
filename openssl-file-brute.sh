#!/bin/bash

# Initial: 3/6/2025 Swammers8

# Check Positional Arguments
if [ "$#" -lt 3 ] || [ "$#" -gt 5 ]; then
	openssl enc -list
    	echo "[i] Usage: $0 <input_file> <output_file> <wordlist> -[cipher] [iterations]"
    	echo "[i] <required> [optional]"
    	echo "[i] Iterations default is 10000 if not specified. The higher the number, the slower it'll take"
    	echo "[i] Cipher default is AES-256"
    	echo "[i] Example: $0 flag.enc cracked.out rockyou.txt -aes128 100000"
    	exit 1
fi

input_file="$1"
output_file="$2"
wordlist="$3"
iter="${5:-10000}"
alg="${4:--aes256}"

# Check files
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
echo "[i] Cipher : $alg"
echo "[*] Bruteforcing...."

# Get number of entries in wordlist
total=$(wc -l < "$wordlist")
# Count for progess bar
count=0

# Read each line in wordlist
while IFS= read -r i; do
	count=$((count + 1)) # add to progess bar
	# test password  decryption
	result=$(openssl enc -d $alg -pbkdf2 -in "$input_file" -iter "$iter" -pass pass:"$i" 2>&1 | tr -d '\0')
	# check for error
	if [[ "$result" =~ "bad decrypt" || "$result" =~ "error" ]]; then
		: # continue to next password
	else
		# check that the decryption was successful and not gibberish
		# Note: for aes256 encryption, there's a 1/256 chance of an incorrect password successfully "decrypting" a file with openssl, however it outputs gibberish data files
		echo $result > test_file
		test=$(file test_file)
		if [ "$(echo $test | awk -F: '{print $2}' | tr -d ' ')" != "data" ]; then
			echo -e "\n[*] Password found: $i"
			# if it's not gibberish, decrypt and save output
			openssl enc -d $alg -pbkdf2 -in "$input_file" -iter "$iter" -pass pass:"$i" -out "$output_file"
			echo "[*] Decrypted successfully!"
			echo "[i] Saved to $output_file"
			rm test_file
			exit 0
		fi
		rm test_file
	fi
	# update progress bar
	progress=$((count * 100 / total))
	bar_length=$((progress / 2))
	printf "\r[i] Wordlist Progress : [%d / %d] %d%%" "$count" "$total" "$progress"
done < "$wordlist"

echo
echo '[!] Failed! Password was not in provided wordlist'
exit 1
