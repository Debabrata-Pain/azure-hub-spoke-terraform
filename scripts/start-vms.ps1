Connect-AzAccount -Identity

$resourceGroup = "dev-hub-spoke-rg"

$vms = Get-AzVM -ResourceGroupName $resourceGroup

foreach ($vm in $vms) {

    Write-Output "Starting VM: $($vm.Name)"

    Start-AzVM `
        -ResourceGroupName $resourceGroup `
        -Name $vm.Name
}