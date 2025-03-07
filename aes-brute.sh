#!/bin/bash

# 3/6/2025 Swammers8

# Check positional arguments
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
echo "[*] Bruteforcing...."

# try each line in the wordlist as a password to decrypt the file
# How it works:
# 1. Runs the decrypt command with a password
# 2. If it failed, openssl will return an error which is then saved to a file
# 3. The 'result' variable will check the contents of the error file. If there are contents in the file, it failed
# 4. It will then delete the output_file and the err file
# 5. If the openssl did not return an error, the 'err' file will be empty, and the decryption worked
for i in $(cat $wordlist); do
	openssl enc -d -aes256 -pbkdf2 -in $input_file -iter $iter -out $output_file -pass pass:$i 2>err
	result=$(stat -c %s err | tr -d \\n)
	if [ $result -eq 0 ]; then
		test=$(file $output_file)
		# After initial testing, this script would produce false positives. 
		# After research it turns out that with aes there is about a 1/256 chance of a false password "successfully" decrypting the file. However, the output will still be nonsense stored in a 'data' file.
		# So there is a second check to make sure the output is not a plain data file.
		# If you know that the file you're trying to decrypt is a plain data file, I suggest changing this.
		# Otherwise it'll be fine
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
