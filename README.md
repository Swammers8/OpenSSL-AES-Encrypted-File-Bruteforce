# OpenSSL-AES Encrypted File Bruteforcer
I made a quick tool in bash that uses a dictionary attack against files encrypted with openssl aes. This is assuming they were encrypted with a command similar to `openssl enc -aes256 -pbkdf2 -in /etc/passwd -out passwd.enc`. If the file was encrypted with a custom iteration count such as `-iter 100000` you will need to know that or it won't work. If it wasn't specified at encryption, OpenSSL will default to `10000`. Whether the `-salt` flag was set or not it will still work.

## Usage
```
Usage: ./aes-brute.sh <input_file> <output_file> <wordlist> [iterations]
<required> [optional]
Iterations default is 10000 if not specified.
Example: ./aes-brute.sh flag.enc cracked.out rockyou.txt 100000
```
