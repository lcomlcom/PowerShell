## Pega quantidade de Memória total das VMs
$TotalVmMem = 0

$vms = get-vm -ComputerName (get-clusternode) | Where-Object {$_.state -like "Running"} |Get-VMMemory
Foreach ( $VmMem in $vms )
{
$TotalVmMem += $VmMem.Startup
}
$TotalVmMem = $TotalVmMem / 1073741824

# Pega quantidade total de memória do cluster e # Pega Host com maior quantidade de memória
$TotalClusterMem = 0
$TopHostMem = 0

$cNodes = Get-ClusterNode | Where-Object {$_.State -like "Up"}
$cNodesMem = Get-WmiObject -Class win32_OperatingSystem -ComputerName $cNodes.Name |Select FreePhysicalMemory, TotalVisibleMemorySize
foreach ( $clusterNode in $cNodesMem)
    {
    $TotalClusterMem += $clusterNode.TotalVisibleMemorySize
    if ($clusterNode.TotalVisibleMemorySize -gt $TopHostMem)
        {
        $TopHostMem = $clusterNode.TotalVisibleMemorySize / 1048576
        }
    }
    $TotalClusterMem = $TotalClusterMem / 1048576

# subtrai Memoria do maior nó pela quantidade total de memória do cluster
$MemClusterFalut = $TotalClusterMem - $TopHostMem

#Verifica se A memória total do CLuster menos o maior host suporta a memória total das VMs
$HAStatus = [math]::Round($MemClusterFalut / $TotalVmMem, 2)
Write-Host $HAStatus