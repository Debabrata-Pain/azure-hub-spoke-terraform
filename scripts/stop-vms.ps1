param (
    [string]$ResourceGroupName,
    [string]$Environment
)

Connect-AzAccount -Identity

$vms = Get-AzVM -ResourceGroupName $ResourceGroupName -Status

foreach ($vm in $vms) {

    $vmResource = Get-AzResource -ResourceId $vm.Id

    $envTag = $vmResource.Tags["Environment"]
    $autoTag = $vmResource.Tags["AutoShutdown"]

    if ($envTag -eq $Environment -and $autoTag -eq "true") {

        Write-Output "Stopping VM: $($vm.Name)"

        Stop-AzVM `
            -ResourceGroupName $ResourceGroupName `
            -Name $vm.Name `
            -Force
    }
}