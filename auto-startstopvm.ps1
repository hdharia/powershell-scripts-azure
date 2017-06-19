<#
    .DESCRIPTION
        An example runbook which gets all the ARM resources using the Run As Account (Service Principal)

    .NOTES
        AUTHOR: Azure Automation Team
        LASTEDIT: Mar 14, 2016
#>

$connectionName = "AzureRunAsConnection"
try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}

$startTime = Get-Date 07:00
$stopTime = Get-Date 12:00
$currentTime = Get-Date

$resourcesGroups = Find-AzureRmResourceGroup -Tag @{ Name = 'AutoShutdownSchedule' } | select name

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
            Write-Output "Stop VM, if not stopped"
            Stop-AzureRmVM -Force -Name $Resource.ResourceName -ResourceGroupName $Resource.ResourceGroupName
        }
    }
    Write-Output ("")
}
