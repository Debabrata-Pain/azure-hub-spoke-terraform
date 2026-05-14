Connect-AzAccount -Identity

$resourceGroup = "dev-hub-spoke-rg"

$vms = Get-AzVM -ResourceGroupName $resourceGroup

foreach ($vm in $vms) {

    Write-Output "Stopping VM: $($vm.Name)"

    Stop-AzVM `
        -ResourceGroupName $resourceGroup `
        -Name $vm.Name `
        -Force
}