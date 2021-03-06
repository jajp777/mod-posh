$TargetVM = 'Windows Server Base'
$VmName = 'Scorch-DC','Scorch-SCCM','Scorch-SCDPM','Scorch-SCOM','Scorch-SCORCH','Scorch-SQL'
$ExportPath = 'C:\VirtualMachines\Exported'

foreach ($NewVMName in $VmName)
{
    try
    {
        [xml]$Config = Get-Content "$($ExportPath)\$($TargetVM)\config.xml"
        $VMDiskPath = $Config.configuration.vhd.source."#text"
        $NewDiskPath = $VMDiskPath.Split("\")          
        $NewDiskPath[$NewDiskPath.Count -1] = "$($NewVMName).vhd"
        $NewDiskPath = [string]::join("\",$NewDiskPath)
        $ExportedDisk = Get-ChildItem "$($ExportPath)\$($TargetVM)\Virtual Hard Disks"
        Copy-Item $ExportedDisk.FullName $NewDiskPath
        }
    catch
    {
        Write-Error $Error[0]
        break
        }

    try
    {
        New-VM -Name $NewVMName
        Set-VMDisk -VM $NewVMName -Path $NewDiskPath
        Set-VM -VM $NewVMName -Name $NewVMName -Notes "Imported $($TargetVM) to $($NewVMName) on $(Get-Date)"
        New-VMSnapshot -VM $NewVMName -Note "Creating initial snapshot after Import" -Force
        }
    catch
    {
        Write-Error $Error[0]
        break
        }
    }