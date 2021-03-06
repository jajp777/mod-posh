﻿# Get my current profile
New-Item $profile -ItemType File -Force
$myProfile = "https://github.com/jeffpatton1971/mod-posh/blob/master/powershell/playground/Profile.ps1"
$webclient = New-Object Net.Webclient
$webClient.UseDefaultCredentials = $true
$webClient.DownloadFile($myProfile, $profile)
# Copy my profile to the console profile location
Copy-Item $profile "$($Env:USERPROFILE)\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

$Downloads = @()
$ThisFile = New-Object -TypeName PSobject -Property @{
    URL = "http://downloads.sourceforge.net/project/win32svn/1.7.5/Setup-Subversion-1.7.5.msi"
    FileName = "$($Env:USERPROFILE)\Setup-Svn.msi"
    }
$Downloads += $ThisFile
$ThisFile = New-Object -TypeName PSobject -Property @{
    Url = "http://www.opera.com/download/get.pl?id=34630&location=321&nothanks=yes&sub=marine"
    FileName = "$($Env:USERPROFILE)\Setup-Opera.exe"
    }
$Downloads += $ThisFile
$ThisFile = New-Object -TypeName PSObject -Property @{
    Url = "http://images2.store.microsoft.com/prod/clustera/framework/w7udt/1.0/en-us/Windows7-USB-DVD-tool.exe"
    FileName = "$($Env:USERPROFILE)\Setup-Win7UsbTool.exe"
    }
$Downloads += $ThisFile
$ThisFile = New-Object -TypeName PSObject -Property @{
    Url = "http://download.microsoft.com/download/5/E/4/5E456B4C-78D4-4E6C-BC84-CA7FE87BB117/WebServicesSDK.msi"
    FileName = "$($Env:USERPROFILE)\Setup-EWS.msi"
    }
$Downloads += $ThisFile

foreach ($Download in $Downloads)
{
    try
    {
        $webclient.DownloadFile($Download.Url, $Download.FileName)
        }
    catch
    {
        }
    }
