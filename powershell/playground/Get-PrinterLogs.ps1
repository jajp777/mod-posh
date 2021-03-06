Function Get-PrinterLogs
{
    <#
        .SYNOPSIS
            Get a log of all printing from a given server.
        .DESCRIPTION
            This function will return a log of all the printing that has occurred on
            a given print server.
        .PARAMETER LogName
            The default log for printing on Windows Server 2008 R2 is specified.
        .PARAMETER ComputerName
            The name of your print server.
        .EXAMPLE
            Get-PrinterLogs -ComputerName ps

            Size     : 96060
            Time     : 8/16/2011 5:01:09 PM
            User     : MyAccount
            Job      : 62
            Client   : \\10.133.5.143
            Port     : Desktop-PC01.company.com
            Printer  : HP-Laser
            Pages    : 1
            Document : Microsoft Office Outlook - Memo Style

            Description
            -----------
            This example shows the basic usage of the command.
        .EXAMPLE
            Get-PrinterLogs -ComputerName ps |Export-Csv -Path .\PrintLogs.csv
            
            Description
            -----------
            This is the syntax that I would see being used the most.
        .NOTES
            The following log will need to be enabled before logs can be generated by the server:
            "Microsoft-Windows-PrintService/Operational"
        .LINK
    #>
    
    Param
    (
    $LogName = "Microsoft-Windows-PrintService/Operational",
    [Parameter(Mandatory=$true)]
    $ComputerName
    )
    
    Begin
    {
        $ErrorActionPreference = "Stop"
        $PrintJobs = Get-WinEvent -ComputerName $ComputerName -LogName $LogName -Credential $Credentials |Where-Object {$_.Id -eq 307}
        $PrintLogs = @()
        }
    Process
    {
        foreach ($PrintJob in $PrintJobs)
        {
            $Client = $PrintJob.Properties[3].Value
            if($Client.IndexOf("\\") -gt -1)
            {
                $Lookup = "nslookup $($Client.Substring(2,($Client.Length)-2)) |Select-String 'Name:'"
                }
            else
            {
                $Lookup = "nslookup $($Client) |Select-String 'Name:'"
                }
            
            Try
            {
                [string]$Return = Invoke-Expression $Lookup |Out-Null
                $Client = $Return.Substring($Return.IndexOf(" "),(($Return.Length) - $Return.IndexOf(" "))).Trim()
                }
            Catch
            {
                $Client = $PrintJob.Properties[3].Value
                }
            $PrintLog = New-Object -TypeName PSObject -Property @{
                Time = $PrintJob.TimeCreated
                Job = $PrintJob.Properties[0].Value
                Document = $PrintJob.Properties[1].Value
                User = $PrintJob.Properties[2].Value
                Client = $Client
                Printer = $PrintJob.Properties[4].Value
                Port = $PrintJob.Properties[5].Value
                Size = $PrintJob.Properties[6].Value
                Pages = $PrintJob.Properties[7].Value
                }
            $PrintLogs += $PrintLog
            }
        }
    End
    {
        Return $PrintLogs
        }
}