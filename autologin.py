#!/usr/bin/env python3
#
# Logs in to ncore.pro so your account is kept active.
#

import random
import sys

import mechanize

sys.dont_write_bytecode = True

try:
    from ncorelogininfo.txt import USERNAME, PASSWORD
except ImportError:
    print("You need to create a ncorelogininfo.txt file with the following content:")
    print("USERNAME = 'my_username_here'")
    print("PASSWORD = 'my_password_here'")
    print("\n")
    sys.exit(-1)

SEARCH_STR = '<a href="profile.php">{0}</a>'

USER_AGENTS = [
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36'
    'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36'
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/109.0'
    'Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/109.0'
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36 Edg/109.0.1518.61'
]

if __name__ == '__main__':
    mech = mechanize.Browser()
    mech.set_handle_robots(False)
    mech.set_handle_redirect(True)
    mech.set_handle_referer(True)
    mech.addheaders = [('User-agent', random.choice(USER_AGENTS))]
    mech.open('https://ncore.pro/login.php')

    # find first form that has id starting with 'login'
    login_form = None
    for form in mech.forms():
        # If page used dynamic names for login form like 'login142', 'login189', ...
        if form.attrs['id'].startswith('login'):
            login_form = form
            break

    if not login_form:
        sys.stderr.write('Could not find login form.\n')
        sys.stderr.write('This script may need updating.\n')
        sys.exit(-1)

    # Set focus on form
    mech.form = login_form
    mech['nev'] = USERNAME
    mech['pass'] = PASSWORD
    result = mech.submit().read()
    if 'Username or password did not match'.encode('utf-8') in result:
        sys.stderr.write("Username or password incorrect.\n")
        sys.stderr.write("Please check your credentials in ncorelogininfo.txt\n")
        errorlevel = -1
    elif SEARCH_STR.format(USERNAME).encode('utf-8') not in result:
        sys.stderr.write("Didn't find welcome message in response.\n")
        sys.stderr.write("Something might be wrong. Log in manually.\n")
        errorlevel = -1
    else:
        print('Logged in successfully.') if "cron" not in sys.argv else None
        errorlevel = 0
    mech.close()
    sys.exit(errorlevel)
