param (
    [string]$ResourceGroupName
)

Connect-AzAccount -Identity

$vms = Get-AzVM -ResourceGroupName $ResourceGroupName

foreach ($vm in $vms) {

    Write-Output "Starting VM: $($vm.Name)"

    Start-AzVM `
        -ResourceGroupName $ResourceGroupName `
        -Name $vm.Name
}