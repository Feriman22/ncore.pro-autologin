#!/bin/ksh
#
# Log in to ncore.pro to keep your account active.
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
    exit 2
fi

# Check the login form on Ncore
if [[ -z $(curl -s $URL | grep -Eo '<form[^>]+id="login[^>]+>') ]]; then
    echo "Could not find login form. This script may need updating or the website is not online."
    echo "You can find the latest version on GitHub: https://github.com/Feriman22/ncore.pro-autologin"
    exit 3
fi

# Get the latest user agent
UserAgent="$(curl -s "https://www.whatismybrowser.com/guides/the-latest-user-agent/chrome" | grep -Po '(?<=>)[^<]*Windows NT 10.0.*Chrome[^<]*(?=<)')"
if ! grep -q "Chrome" <<< $NewUserAgent; then
    echo "Invalid UserAgent ($UserAgent). Report on GitHub. If the bug remains: https://github.com/Feriman22/ncore.pro-autologin"
    exit 4
fi

# Login to Ncore
curloutput="$(curl -s $URL -H "User-Agent: $UserAgent" -c - --data-urlencode "nev=$USERNAME" --data-urlencode "pass=$PASSWORD" --location)"

# Check result
if grep -q 'Username or password did not match' <<< "$curloutput" || ! grep -q "$USERNAME" <<< "$curloutput"; then
        echo "ERROR: Username or password is incorrect. Please check your credentials in ncorelogininfo.txt"
        exit 5
else
        # Suppress this message by using cron as a parameter
        [[ "$1" != "cron" ]] && echo "Logged in successfully."
fi
