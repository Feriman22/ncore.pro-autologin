#
# Log in to ncore.pro to keep your account active (Windows / PowerShell version).
# Originally located: https://github.com/Feriman22/ncore.pro-autologin
# Written by Feriman22
#

param([string]$Mode)

$ErrorActionPreference = 'Stop'

# Hide the download progress bar (it also makes Invoke-WebRequest slow on PowerShell 5.1)
$ProgressPreference = 'SilentlyContinue'

# Windows PowerShell 5.1 may not enable TLS 1.2 by default
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

# Global variables
$URL = 'https://ncore.pro/login.php'
$LoginLocation = Join-Path $PSScriptRoot 'ncorelogininfo.txt'
$LogLocation = Join-Path $PSScriptRoot 'autologin.log'

# Log the result, print it (success is silent with the "cron" parameter) and exit
function Finish([int]$Code, [string]$Message) {
	Add-Content -Path $LogLocation -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
	if ($Code -ne 0 -or $Mode -ne 'cron') { Write-Output $Message }
	exit $Code
}

# Check login infos
if (-not (Test-Path $LoginLocation)) {
	[IO.File]::WriteAllText($LoginLocation, "USERNAME='my_username_here'`nPASSWORD='my_password_here'`n")
	Finish 2 "You need to fill in $LoginLocation with your login details. The script already created it with sample data."
}
$USERNAME = ''
$PASSWORD = ''
foreach ($line in Get-Content -Path $LoginLocation -Encoding UTF8) {
	if ($line -match "^\s*(USERNAME|PASSWORD)\s*=\s*['`"](.*)['`"]\s*$") {
		Set-Variable -Name $Matches[1] -Value $Matches[2]
	}
}
if (-not $USERNAME -or -not $PASSWORD) {
	Finish 2 "USERNAME or PASSWORD is missing in $LoginLocation"
}

# Check the login form on Ncore
try {
	$LoginPage = (Invoke-WebRequest -Uri $URL -UseBasicParsing -TimeoutSec 30).Content
} catch {
	$LoginPage = ''
}
if ($LoginPage -notmatch '<form[^>]+id="login[^>]+>') {
	Finish 3 'Could not find login form. This script may need updating or the website is not online. You can find the latest version on GitHub: https://github.com/Feriman22/ncore.pro-autologin'
}

# Get the latest user agent
try {
	$UAPage = (Invoke-WebRequest -Uri 'https://www.whatismybrowser.com/guides/the-latest-user-agent/chrome' -UseBasicParsing -TimeoutSec 30).Content
} catch {
	$UAPage = ''
}
$UserAgent = [regex]::Match($UAPage, '(?<=>)[^<]*Windows NT 10\.0[^<]*Chrome[^<]*(?=<)').Value
if ($UserAgent -notmatch 'Chrome') {
	Finish 4 "Invalid UserAgent ($UserAgent). Report on GitHub. If the bug remains: https://github.com/Feriman22/ncore.pro-autologin"
}

# Login to Ncore
try {
	$Output = (Invoke-WebRequest -Uri $URL -Method Post -Body @{ nev = $USERNAME; pass = $PASSWORD } -UserAgent $UserAgent -SessionVariable Session -UseBasicParsing -TimeoutSec 45).Content
} catch {
	Finish 5 "ERROR: Login request failed: $($_.Exception.Message)"
}

# Check result
if ($Output.Contains('Username or password did not match') -or -not $Output.Contains($USERNAME)) {
	Finish 5 "ERROR: Username or password is incorrect. Please check your credentials in $LoginLocation"
}
Finish 0 'Logged in successfully.'
