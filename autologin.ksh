#!/bin/ksh
#
# Logs in to ncore.pro so your account is kept active.
# Originally located: https://github.com/Feriman22/ncore.pro-autologin
# Written by Feriman22
#

# Global variables
curloutput="./curl.output"
loginlocation="./ncorelogininfo.txt"
cookies="./cookies.txt"

# Check login infos
if [ -f $loginlocation ]; then
    . $loginlocation
 else
    echo "You need to create a ncorelogininfo.txt file with the following content:"
    echo "USERNAME='my_username_here'"
    echo "PASSWORD='my_password_here'"
    printf "USERNAME='my_username_here'\nPASSWORD='my_password_here'" >> $loginlocation
    echo "Don't worry, the script already made it for you with sample data. You can find it next to the script namely as $loginlocation"
    exit
fi

# Declare cleanup function
cleanup() { rm -f "$curloutput" "$cookies"; }

# Run first cleanup
cleanup

if [[ -z $(curl -s 'https://ncore.pro/login.php' | grep -Eo '<form[^>]+id="login[^>]+>') ]]; then
    echo "Could not find login form. This script may need updating or the website is not online."
    exit
fi

user_agents=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_4_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/114.0"
    "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/114.0"
)

random_user_agent=${user_agents[RANDOM % ${#user_agents[@]}]}

curl -s 'https://ncore.pro/login.php' \
    -H "User-Agent: $random_user_agent" \
    --cookie-jar $cookies \
    --data-urlencode "nev=$USERNAME" \
    --data-urlencode "pass=$PASSWORD" \
    --data-urlencode "submitted=1" \
    --data-urlencode "remember_me=1" \
    --data-urlencode "submitted=1" \
    --data-urlencode "mibiztos=1" \
    --data-urlencode "returnto=%2F" \
    --data-urlencode "submitted=1" \
    --data-urlencode "remember_me=1" \
    --location > $curloutput

if grep -q 'Username or password did not match' $curloutput || ! grep -q "$USERNAME" $curloutput; then
        echo "ERROR: Username or password is incorrect. Please check your credentials in ncorelogininfo.txt"
else
        # Supress this message by putting cron as a parameter
        [[ "$1" != "cron" ]] && echo "Logged in successfully."
fi

# Run final cleanup
cleanup
