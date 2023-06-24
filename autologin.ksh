#!/bin/ksh
#
# Logs in to ncore.pro so your account is kept active.
# BETA!!! DO NOT USE!!!
#

USERNAME='my_username_here'
PASSWORD='my_password_here'
SEARCH_STR='<a href="profile.php">${USERNAME}</a>'

mech_login() {
    login_form=$(curl -s 'https://ncore.pro/login.php' | grep -Eo '<form[^>]+id="login[^>]+>')
    if [[ -z $login_form ]]; then
        echo "Could not find login form." >&2
        echo "This script may need updating." >&2
        return 1
    fi

user_agents=(
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"
    "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:90.0) Gecko/20100101 Firefox/90.0"
    # Add more user agents as needed
)

random_user_agent=${user_agents[RANDOM % ${#user_agents[@]}]}

result=$(curl -s 'https://ncore.pro/login.php' \
    -H "User-Agent: $random_user_agent" \
    --cookie-jar cookies.txt \
    --data-urlencode "nev=$USERNAME" \
    --data-urlencode "pass=$PASSWORD" \
    --data-urlencode "submitted=1" \
    --data-urlencode "login=Belépés" \
    --data-urlencode "remember_me=1" \
    --data-urlencode "submitted=1" \
    --data-urlencode "mibiztos=1" \
    --data-urlencode "returnto=%2F" \
    --data-urlencode "submitted=1" \
    --data-urlencode "remember_me=1" \
    --location)

    if [[ $result == *'Username or password did not match'* ]]; then
        echo "Username or password incorrect." >&2
        echo "Please check your credentials in ncorelogininfo.txt" >&2
        errorlevel=-1
    elif [[ $result != *"${SEARCH_STR//\$\{USERNAME\}/$USERNAME}"* ]]; then
        echo "Didn't find welcome message in response." >&2
        echo "Something might be wrong. Log in manually." >&2
        errorlevel=-1
    else
        [[ "cron" != *$@* ]] && echo "Logged in successfully."
        errorlevel=0
    fi

    return $errorlevel
}

main() {
    if [[ -f ncorelogininfo.txt ]]; then
        . ncorelogininfo.txt
    else
        echo "You need to create a ncorelogininfo.txt file with the following content:" >&2
        echo "USERNAME='my_username_here'" >&2
        echo "PASSWORD='my_password_here'" >&2
        echo >&2
        return 1
    fi

    mech_login "$@"
    return $?
}

main "$@"
exit $?
