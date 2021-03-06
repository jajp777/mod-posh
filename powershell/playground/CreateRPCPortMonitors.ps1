<#
    .SYNOPSIS
        Template script
    .DESCRIPTION
        This script sets up the basic framework that I use for all my scripts.
    .PARAMETER
    .EXAMPLE
    .NOTES
        ScriptName : CreateLicensePortMonitors.ps1
        Created By : jspatton
        Date Coded : 12/19/2011 15:30:17
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        http://scripts.patton-tech.com/wiki/PowerShell/Production/CreateLicensePortMonitors.ps1
#>
Param
    (
        $ADSPath = 'OU=1018,OU=Eaton,OU=Labs,DC=soecs,DC=ku,DC=edu'
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $LogName = "Application"
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME
 
        New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue
 
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
 
        #	Dotsource in the functions you need.
        . 'C:\scripts\powershell\production\includes\ActiveDirectoryManagement.ps1'
        $Workstations = Get-ADObjects -ADSPath $ADSPath
        }
Process
    {
        foreach ($Workstation in $Workstations)
        {
        
            C:\TEMP\CreatePortMonitoring.ps1 -serverName $Workstation.Properties.name -portNumber '135' -pollIntervalSeconds 120 -watcherNodes citadel.soecs.ku.edu -displayName "$($Workstation.Properties.name)_RPCPort" -targetMp 'Engineering_MP'
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }