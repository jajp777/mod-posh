<#
    .SYNOPSIS
        Send logon, logoff times per user, per workstation to SQL
    .DESCRIPTION
        This script works in conjunction with the Set-LogonTime script. It
        reads in events logged by the Set-LogonTime provider. Event 105 is
        the logon time, and Event 106 is the username. This data is combined
        the workstation name and time, and sent to the SQL server at
        logoff.
    .PARAMETER SqlUser
        The SQL username that has insert permission on the UserTraffic Table
    .PARAMETER SqlPass
        The password for the SQL user account.
    .PARAMETER SqlServer
        The name of the SQL server, default is SQL
    .PARAMETER SqlDatabase
        The name of the SQL DB to connect to, default is UserTraffic
    .PARAMETER SqlTable
        The name of the SQL Table to insert the data to, default is AccountLogons
    .EXAMPLE
        .\Send-UserLogonTimes.ps1 -SqlUser username -SqlPass Password
    .NOTES
        ScriptName : Send-UserLogonTimes.ps1
        Created By : jspatton
        Date Coded : 12/16/2011 09:59:56
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
        
        By default this script writes data to the UserTraffic database on the SQL
        server. The data is stored in the AccountLogons table by default. There are
        five fields that need to exist:
            Name: LogonTime     Type: ntext Null: Ok
            Name: LogoffTime    Type: ntext Null: Ok
            Name: AccountName   Type: ntext Null: Ok
            Name: AccountDomain Type: ntext Null: Ok
            Name: HostName      Type: ntext Null: Ok
        These fields will store the time a user logged on, logged off, from what
        computer, their username and domain. I do a simple check to see if the
        username stored in EventID 106 equals the current username. If that test's
        false, no write ocurrs.
    .LINK
        https://trac.engr.ku.edu/powershell/browser/Public/Send-UserLogonTimes.ps1
#>
[cmdletBinding()]
Param
    (
        $SqlUser,
        $SqlPass,
        $SqlServer = 'SQL',
        $SqlDatabase = 'UserTraffic',
        $SqlTable = 'AccountLogons'
    )
Begin
    {
        $ScriptName = 'UserTraffic'
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
        try
        {
            Get-WinEvent -ListProvider UserTraffic -ErrorAction Stop |Out-Null
            Write-Verbose "Getting Event ID 105, user logon time."
            $LogonEvents = Get-WinEvent -ProviderName UserTraffic |Where-Object {$_.Id -eq 105}
            if ($LogonEvents.Count -eq $null)
            {
                $LogonTime = $LogonEvents.Message
                }
            else
            {
                $LogonTime = $LogonEvents[0].Message
                }
            $LogoffTime = Get-Date
            Write-Verbose "Getting Event ID 106, user logon name."
            $AccountEvents = Get-WinEvent -ProviderName UserTraffic |Where-Object {$_.Id -eq 106}
            if ($AccountEvents.Count -eq $null)
            {
                $AccountName = $AccountEvents.Message
                }
            else
            {
                $AccountName = $AccountEvents[0].Message
                }
            $AccountDomain = $env:USERDOMAIN
            $HostName = (&hostname)
            if ($AccountName -eq $env:USERNAME)
            {
                Write-Verbose "Account names match, sending data to SQL."
                try
                {
                    $ErrorActionPreference = 'Stop'
                    $SqlConn = New-Object System.Data.SqlClient.SqlConnection("Server=$($SqlServer);Database=$($SqlDatabase);Uid=$($SqlUser);Pwd=$($SqlPass)")
                    $SqlConn.Open()
                    $Sqlcmd = $SqlConn.CreateCommand()
                    $Sqlcmd.CommandText ="INSERT INTO [dbo].[$($SqlTable)] ([LogonTime], [LogoffTime], [AccountName], [AccountDomain], [HostName]) `
                        VALUES ('$LogonTime', '$LogoffTime', '$AccountName', '$AccountDomain', '$HostName')"
                    $Sqlcmd.ExecuteNonQuery() |Out-Null
                    $SqlConn.Close()
                    }
                catch
                {
                    Write-Verbose $Error[0].Exception.Message
                    Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Error[0].Exception.Message
                    }
                }
            else
            {
                $Message = "Account names don't match. Computer may have been powered off before logout occured."
                Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
                Write-Verbose $Message
                }
            }
        catch
        {
            Write-Verbose $Error[0].Exception.Message
            Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Error[0].Exception.Message
            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }