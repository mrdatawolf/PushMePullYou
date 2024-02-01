<#
.SYNOPSIS
A script to handle the common tasks with client computers

.DESCRIPTION
It will install the base applications we always want and will also uninstall the normal set as well as letting us do optional installed for Ops and Dev computers.
.EXAMPLE
coreSetup --noauto --nobase

.NOTES
Requires winget. Also you might need to run "Set-ExecutionPolicy Unrestricted" to use powershell scripts.

#>
#Patrick Moon - 2024
# Written by Patrick Moon
function Test-IP {
    param (
        [Parameter(Mandatory=$true)]
        [string]$IPAddress
    )

    $result = Test-Connection -ComputerName $IPAddress -Count 1 -Quiet

    return $result
}

function Check-LocalIP {
    param (
        [Parameter(Mandatory=$true)]
        [string]$IPAddress
    )
    $localIPs = Get-NetIPAddress | Where-Object { $_.IPAddress -eq $IPAddress }

    return ($null -ne $localIPs)
}


Write-Progress -Activity "Checking for an internet connection..." -Status "25% Complete:" -PercentComplete 25;
$eightResponds = Test-IP 8.8.8.8
Write-Progress -Activity "Checking for the server..." -Status "50% Complete:" -PercentComplete 50;
$serverResponds = Test-IP 10.42.42.2
Write-Progress -Activity "Checking on local computer ip..." -Status "75% Complete:" -PercentComplete 75;
$isPrimary = Check-LocalIP 10.42.42.3
Write-Progress -Activity "Showing results of the tests..." -Status "99% Complete:" -PercentComplete 99;
if($eightResponds) {
    Write-Host "The internet is available..." -ForegroundColor Green
    if($serverResponds) {
        Write-Host "And so is the server.  Nothing to fix!" -ForegroundColor Green
    } else {
        if ($isPrimary) {
            Write-Host "But the local server is not. You have lost the wireless bridge. Reboot it." -ForegroundColor Red
        }
        else {
            Write-Host "But the local server is not. The server seems to be off. Try turning it back on." -ForegroundColor Red
        }
    }
} else {
    if($serverResponds) {
        Write-Host "Your server is responding." -ForegroundColor Green
        if ($isPrimary) {
            Write-Host "But you have no internet. This seems to be a Optimum issue." -ForegroundColor Yellow
        } else {
            Write-Host "But not the internet. This is probably a problem with the wireless bridge.  Reset each side of the bridge." -ForegroundColor Red
        }
    } else {
        Write-Host "Your network seems to be fully down. Contact Patrick!" -ForegroundColor Red
    }
}