param (
    [string]$ResourceGroupName,
    [string]$Environment
)

Connect-AzAccount -Identity

$vms = Get-AzVM -ResourceGroupName $ResourceGroupName

foreach ($vm in $vms) {

    $vmResource = Get-AzResource -ResourceId $vm.Id

    $envTag = $vmResource.Tags["Environment"]
    $backupTag = $vmResource.Tags["Backup"]

    if ($envTag -eq $Environment -and $backupTag -eq "true") {

        Write-Output "Creating snapshot for VM: $($vm.Name)"

        $snapshotName = "$($vm.Name)-snapshot-$(Get-Date -Format 'yyyyMMddHHmm')"

        $osDisk = Get-AzDisk `
            -ResourceGroupName $ResourceGroupName `
            -DiskName $vm.StorageProfile.OsDisk.Name

        $snapshotConfig = New-AzSnapshotConfig `
            -SourceUri $osDisk.Id `
            -Location $vm.Location `
            -CreateOption Copy

        $snapshot = New-AzSnapshot `
            -Snapshot $snapshotConfig `
            -SnapshotName $snapshotName `
            -ResourceGroupName $ResourceGroupName

        Update-AzTag `
            -ResourceId $snapshot.Id `
            -Tag @{
                Environment = $Environment
                CreatedBy   = "Automation"
            } `
            -Operation Merge
    }
}