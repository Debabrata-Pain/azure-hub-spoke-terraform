param (
    [string]$ResourceGroupName
)

Connect-AzAccount -Identity

$vms = Get-AzVM -ResourceGroupName $ResourceGroupName

foreach ($vm in $vms) {

    Write-Output "Stopping VM: $($vm.Name)"

    Stop-AzVM `
        -ResourceGroupName $ResourceGroupName `
        -Name $vm.Name `
        -Force
}