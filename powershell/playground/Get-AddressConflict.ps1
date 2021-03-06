<#
    .SYNOPSIS
        Template script
    .DESCRIPTION
        This script sets up the basic framework that I use for all my scripts.
    .PARAMETER ComputerName
    .PARAMETER Credentials
    .EXAMPLE
        Get-AddressConflict.ps1
    .NOTES
        ScriptName : Get-AddressConflict
        Created By : jspatton
        Date Coded : 01/23/2012 16:18:06
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
    .LINK
        http://scripts.patton-tech.com/wiki/PowerShell/Production/Get-AddressConflict
#>
Param
    (
        $ComputerName,
        $Credentials = (Get-Credential)
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
        }
Process
    {
        foreach ($Workstation in $ComputerName)
        {
            Write-Host $Workstation
            try
            {
                $return = Test-Connection -ComputerName $Workstation -ErrorAction Stop
                $Event = Get-WinEvent -LogName System -ComputerName $workstation -Credential $Credentials |Where-Object {$_.ID -eq 4199}
                [xml]$ThisEvent = $Event.ToXml()
                New-Object -TypeName PSObject -Property @{
                    MachineName = $Event.MachineName
                    LogTime = $Event.TimeCreated
                    ConflictIp = $ThisEvent.Event.EventData.Data[1]
                    ConflictMac = $ThisEvent.Event.EventData.Data[2]
                    }
                }
            catch
            {}
            } 
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }
