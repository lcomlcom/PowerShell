<#

===== VHD Owner Finder v 1.0 ===== 

By Luiz Morais
https://github.com/lcomlcom

This script finds the Virtual Machine or host (local host or cluster members) a VHD/VHDX is attached to.

==================================

#>

Write-Host @"
╔═════════════════════════════════════════════════╗
║                                                 ║
║                 VHD Owner Finder                ║
║                                            v1.0 ║
╚═════════════════════════════════════════════════╝
"@

$validation = "invalid"
while ($validation -ne "valid")
{
    $VHD = Read-Host -prompt ">> Enter the complete path of the VHD"

    # VHD Validation #
    if (!$VHD)
    {
        write-host "Entrada inválida."
        $validation = "invalid"
    }
    elseif ($VHD -like "*.*vhd*")
    {
        $validation = "valid"
    }
    else
    {
    write-host "File is not a virtual disk file."
    $validation = "invalid"
    }
}


$server=hostname
$s = Get-WmiObject -Class Win32_SystemServices -ComputerName $server
if ($s | select PartComponent | where {$_ -like "*ClusSvc*"})
{
    $hosts = Get-ClusterNode
}
else
{
    $hosts = hostname
}


$findinclustervm = Get-VMHardDiskDrive -ComputerName $hosts -VMName * | where { $_.Path -eq $VHD}  | select VMname,ComputerName
if (!$findinclustervm.computername)
{
    $findinclusterhost = Get-VHD -Path $VHD -ComputerName $hosts -ErrorAction SilentlyContinue | select ComputerName
    $hostname = $findinclusterhost.ComputerName
    Write-Host "Your VHD is attached directly to the host $hostname."   
}
else
{
    $vmname = $findinclustervm.VmName
    $hostname = $findinclustervm.computername
    Write-Host "Your VHD is attached to the VM $vmname, hosted in host $hostname." 

}
pause