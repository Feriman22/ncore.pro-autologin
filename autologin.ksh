#!/bin/ksh
#
# Logs in to ncore.pro so your account is kept active.
# Originally located: https://github.com/Feriman22/ncore.pro-autologin
# Written by Feriman22
#

# Global variables
URL="https://ncore.pro/login.php"
loginlocation="./ncorelogininfo.txt"

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

# Check login form on Ncore
if [[ -z $(curl -s $URL | grep -Eo '<form[^>]+id="login[^>]+>') ]]; then
    echo "Could not find login form. This script may need updating or the website is not online."
    exit
fi

# List of agents (browsers)
user_agents=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/121.0"
    "Mozilla/5.0 (X11; Linux i686; rv:109.0) Gecko/20100101 Firefox/121.0"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15"
)

# Choose a random agent
random_user_agent=${user_agents[RANDOM % ${#user_agents[@]}]}

# Login to Ncore
curloutput="$(curl -s $URL -H "User-Agent: $random_user_agent" -c - --data-urlencode "nev=$USERNAME" --data-urlencode "pass=$PASSWORD" --location)"

# Check result
if grep -q 'Username or password did not match' <<< "$curloutput" || ! grep -q "$USERNAME" <<< "$curloutput"; then
        echo "ERROR: Username or password is incorrect. Please check your credentials in ncorelogininfo.txt"
else
        # Supress this message by putting cron as a parameter
        [[ "$1" != "cron" ]] && echo "Logged in successfully."
fi
