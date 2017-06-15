$startTime = Get-Date 07:00
$stopTime = Get-Date 12:00
$currentTime = Get-Date

if ($currentTime -ge $startTime -and $currentTime -le $stopTime)
{
    Write-Output "Start VM, if not started"
}
else
{
    Write-Output "Stop VM, if not stopped"
}

$resourcesGroups = Find-AzureRmResourceGroup -Tag @{AutoShutdownSchedule = '1' } | select name

Write-Output $startTime " " $stopTime " " $currentTime

foreach( $ResourceGroup in $resourcesGroups)
{
    Write-Output ("Showing resources in resource group " + $ResourceGroup.name)
    $Resources = Find-AzureRmResource -ResourceType 'Microsoft.compute/virtualMachines' |  where {$_.ResourceGroupName -like $ResourceGroup.name} | Select ResourceName, ResourceType, ResourceGroupName
    ForEach ($Resource in $Resources)
    {
        Write-Output ($Resource.ResourceName + " of type " +  $Resource.ResourceType + " in " + $Resource.ResourceGroupName)

        if ($currentTime -ge $startTime -and $currentTime -le $stopTime)
        {
           Write-Output "Start VM, if not started"
           Start-AzureRmVM -Name $Resource.ResourceName -ResourceGroupName $Resource.ResourceGroupName
        }
        else
        {
            Stop-AzureRmVM -Force -Name $Resource.ResourceName -ResourceGroupName $Resource.ResourceGroupName
            Write-Output "Stop VM, if not stopped"
        }
    }
    Write-Output ("")
}