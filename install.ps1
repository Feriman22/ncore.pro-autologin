#
# Installer for the Windows version of ncore.pro-autologin.
# Saves your login details and creates a weekly scheduled task (no admin rights needed).
# Run it with install.cmd. Remove the task with: install.cmd -Uninstall
# Originally located: https://github.com/Feriman22/ncore.pro-autologin
# Written by Feriman22
#

param([switch]$Uninstall)

$ErrorActionPreference = 'Stop'

$TaskName = 'ncore.pro autologin'
$ScriptLocation = Join-Path $PSScriptRoot 'autologin.ps1'
$LoginLocation = Join-Path $PSScriptRoot 'ncorelogininfo.txt'

# Uninstall
if ($Uninstall) {
	Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
	Write-Output 'The scheduled task has been removed. You can delete this folder now.'
	exit 0
}

if (-not (Test-Path $ScriptLocation)) {
	Write-Output "autologin.ps1 not found next to the installer ($ScriptLocation). Extract the whole ZIP file first."
	exit 1
}

# Ask for the login details
$User = Read-Host 'ncore.pro username'
$SecurePass = Read-Host 'ncore.pro password' -AsSecureString
$BSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePass)
try {
	$Pass = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
} finally {
	[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
}
if (-not $User -or -not $Pass) {
	Write-Output 'Username and password cannot be empty.'
	exit 1
}

# Save them in the same format as the Linux version uses (UTF-8 without BOM)
[IO.File]::WriteAllText($LoginLocation, "USERNAME='$User'`nPASSWORD='$Pass'`n", (New-Object Text.UTF8Encoding $false))

# Test the login once
Write-Output 'Testing the login...'
& $ScriptLocation
if ($LASTEXITCODE -ne 0) {
	Write-Output 'The test login failed, so the scheduled task was not created. Fix the problem above and run install.cmd again.'
	exit 1
}

# Create (or update) the weekly scheduled task. If the computer is off at that time, it runs at the next start.
$Action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptLocation`" cron" -WorkingDirectory $PSScriptRoot
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At '12:00'
$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 10)
Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Description 'Logs in to ncore.pro weekly so the account is kept active. https://github.com/Feriman22/ncore.pro-autologin' -Force | Out-Null

Write-Output "Done. The scheduled task '$TaskName' logs in every Monday at 12:00 (or at the next start if the computer was off)."
Write-Output "Results are logged to $(Join-Path $PSScriptRoot 'autologin.log')"
Write-Output 'Do not move or delete this folder, the scheduled task runs the script from here.'
