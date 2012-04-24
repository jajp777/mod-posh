<#
    .SYNOPSIS
        A script to inventory the local computer
    .DESCRIPTION
        This script will collect the following information: computer name, domain name, computer 
        manufacturer, computer model, number of processors, number of cores, speed of processors, 
        processor ID, MAC address of the primary network interface, operating system version 
        (including service pack level), and the amount of physical memory that is installed 
        (displayed in the most logical units).
        
        The output should be stored in an XML-formatted file in the Documents special folder.
    .PARAMETER ComputerName
        The name of the computer
    .PARAMETER FilePath
        The path to store the output xml. The default path is the Documents special folder.
    .EXAMPLE
        .\Get-SystemInfo.ps1 -ComputerName 'server01','server02'
        
        Description
        -----------
        This is the basic syntax of the command, there is no output by default.
    .NOTES
        ScriptName : Get-SystemInfo.ps1
        Created By : jspatton
        Date Coded : 04/12/2012 11:10:30
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
 
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
        
        There are some things I had to take into account when writing this, first was multi-homed
        machines. I have several machines that I manage that don't have a single primary interface
        so for the mac address, you will see more than one item if you have more than one physical 
        adapter. That's the other thing, how do you determine a physical adapter? I found a nice
        little article that talked about checking the PNPDeviceID for non ROOT values, that's the
        option I chose, the URL is in Related Links.
        
        Another item that came up in testing was single proc multi-cores versus multi-proc mult-
        cores. My desktop has one physical CPU with 4 cores, but another machine has two physical
        procs with 8 cores. If WMI returns a non-array I assume 1 proc and move on with my life,
        if WMI returns an array, I loop through the array and add up the number of cores total.
        
        To calculate RAM appropriately an if statement was the best I could come up with, I don't
        know that it's the best method of doing this, but it seems to work. I had to use some .NET
        classes since there is no power operator in PowerShell, at least that I could find. I also 
        used rounding to clean it up a little.
    .LINK
        https://code.google.com/p/mod-posh/wiki/Production/Get-SystemInfo.ps1
    .LINK
        http://weblogs.sqlteam.com/mladenp/archive/2010/11/04/find-only-physical-network-adapters-with-wmi-win32_networkadapter-class.aspx
#>
[CmdletBinding()]
Param
    (
    $ComputerName = '.',
    $FilePath = "$([environment]::getfolderpath("mydocuments"))"
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
        Foreach ($Computer in $ComputerName)
        {
            Write-Verbose "Connecting to $($Computer)"
            Write-Verbose 'Create filename'
            if ($Computer -eq '.')
            {
                $FileName = "$(& hostname).$((get-date -format "yyyMMdd")).xml"
                }
            else
            {
                $FileName = "$($Computer).$((get-date -format "yyyMMdd")).xml"
                }
            
            $Cores = $null
            $ClockSpeed = $null
            $ProcessorID = $null
            $MACAddress = $null
            $OSCaption = $null
            $PhysicalRam = $null
            
            try
            {
                Write-Verbose 'Get details about computer make, model and ram.'
                $ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $Computer -ErrorAction Stop
                
                Write-Verbose 'Get details about the processor'
                $Processor = Get-WmiObject -Class Win32_Processor -ComputerName $Computer -ErrorAction Stop
                
                Write-Verbose 'Determine the physical adapter'
                $Adapter = Get-WmiObject -Class Win32_NetworkAdapter -Filter "NetEnabled = True AND NOT PNPDeviceID LIKE 'ROOT\\%'" -ComputerName $Computer -ErrorAction Stop
                
                Write-Verbose 'Get OperatingSystem information'
                $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer -ErrorAction Stop

                Write-Verbose 'Calculating amount of ram'
                if ($ComputerSystem.TotalPhysicalMemory -gt [math]::Pow(1024,3))
                {
                    Write-Verbose 'More than 1GB of ram installed'
                    $PhysicalRam = "$([math]::round($ComputerSystem.TotalPhysicalMemory/[math]::Pow(1024,3))) GB"
                    }
                
                if ($Processor.Count -eq $null)
                {
                    if ($Processor.NumberOfCores -ne $null)
                    {
                        Write-Verbose 'One processor found'
                        $Cores = $Processor.NumberOfCores
                        $ProcessorID = $Processor.ProcessorId
                        $ClockSpeed = $Processor.CurrentClockSpeed
                        }
                    }
                else
                {
                    Write-Verbose 'More than one processor found'
                    foreach ($Core in $Processor)
                    {
                        if ($Core.NumberOfCores -ne $null)
                        {
                            Write-Verbose 'Calculate total number of cores.'
                            $Cores += $Core.NumberOfCores
                            }
                        Write-Verbose 'Calculate total clockspeed'
                        $ClockSpeed += $Core.CurrentClockSpeed
                        
                        Write-Verbose 'Get the processor id'
                        if ($Core.ProcessorId -ne $null)
                        {
                            $ProcessorID = $Core.ProcessorId
                            }
                        }
                    }
                Write-Verbose 'Pull in the MAC address, this could contain an array on multi-homed machines'
                $MacAddress = $Adapter |Select-Object -Property MACAddress -ExpandProperty MACAddress
                
                Write-Verbose 'Determine ServicePack level'
                if ($OS.ServicePackMajorVersion -gt 0)
                {
                    $OSCaption = "$($OS.Version) SP$($OS.ServicePackMajorVersion)"
                    }
                else
                {
                    $OSCaption = $OS.Version
                    }
                
                Write-Verbose 'Build the object to export out'
                $InventoryReport = New-Object -TypeName PSobject -Property @{
                    ComputerName = $ComputerSystem.Name
                    DomainName = $ComputerSystem.Domain
                    Manufacturer = $ComputerSystem.Manufacturer
                    Model = $ComputerSystem.Model
                    NumProcessors = $ComputerSystem.NumberOfProcessors
                    NumCores = $Cores
                    ClockSpeed = $ClockSpeed/$ComputerSystem.NumberOfProcessors
                    ProcessorID = $ProcessorId
                    MACAddress = $MACAddress
                    OperatingSystemVersion = $OSCaption
                    PhysicalRam = $PhysicalRam
                    }
                }
            catch
            {
                $Message = $Error[0]
                Write-Verbose $Message
                Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message
                }

            Write-Verbose "Store inventory report in $($FilePath)"
            try
            {
                $InventoryReport |Select-Object -Property ComputerName, DomainName, Manufacturer, Model, NumProcessors, NumCores, ClockSpeed, ProcessorID, MACAddress, OperatingSystemVersion, PhysicalRam `
                 |Export-Clixml -Path "$($FilePath)\$($FileName)"  -ErrorAction Stop
                }
            catch
            {
                $Message = $Error[0]
                Write-Verbose $Message
                Write-EventLog -LogName $LogName -Source $ScriptName -EventID "101" -EntryType "Error" -Message $Message	
                }

            }
        }
End
    {
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }