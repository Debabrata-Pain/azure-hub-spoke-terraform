param (
    [string]$ResourceGroupName,
    [string]$Environment
)

Connect-AzAccount -Identity

$snapshots = Get-AzSnapshot -ResourceGroupName $ResourceGroupName

foreach ($snapshot in $snapshots) {

    $envTag = $snapshot.Tags["Environment"]

    if ($envTag -eq $Environment) {

        $age = (Get-Date) - $snapshot.TimeCreated

        if ($age.Days -ge 2) {

            Write-Output "Deleting old snapshot: $($snapshot.Name)"

            Remove-AzSnapshot `
                -ResourceGroupName $ResourceGroupName `
                -SnapshotName $snapshot.Name `
                -Force
        }
    }
}