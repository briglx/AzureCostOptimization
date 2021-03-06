<#
.SYNOPSIS
	check-vm-utilization.ps1 - PowerShell Script to fetch utilization data from Virtural Machines.
.DESCRIPTION
      check-vm-utilization.psm1 - PowerShell Script to fetch utilization data from Virtural Machines.
.NOTES
	This script depends on Az.Accounts, Az.VirtualMachines, Az.Storage, and AzTable PowerShell modules	
#>
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Requires -modules Az, AzTable

function Add-UtilizationRecord
{
    <#
    .SYNOPSIS
        Adds a Virtual Machine Utilization record a Storage Table.
    .DESCRIPTION
        Adds a Virtual Machine Utilization record a Storage Table.
        Fetches utilization data for the previous week.
    .PARAMETER storageAccount
        Storage Account where the utilization table lives
    .PARAMETER tableName
        Name of the utilization table to save records
    .PARAMETER virtualMachineInstance
        Virtual Machine Instance of the utilization metrics to fetch
    .PARAMETER context
        The current metadata used to authenticate Azure Resource Manager request
    .EXAMPLE
        # Getting latest utilization
        $storageAccount = Get-AzStorageAccount ...
        $tableName = "table01"
        $vmInstance = (Get-AzVM -Status)[0] 
        $context = Get-AzContext ...
        Add-UtilizationRecord -StorageAccount $storageAccount -TableName $tableName -VirtualMachineInstance $vmInstance -Context $context
    #>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$true)]
		$storageAccount,
		
		[Parameter(Mandatory=$true)]
        [String]$tableName,

		[Parameter(Mandatory=$true)]
		$virtualMachineInstance,
		
		[Parameter(Mandatory=$true)]
        $context
    )

    $storageContext = $storageAccount.Context
    $storageTable  = Get-AzStorageTable –Name $tableName –Context $storageContext
    $cloudTable = $storageTable.CloudTable

    $curSubscription = $context.Subscription
    $timeNow = [DateTime]::UtcNow 

    # Build Row Object
    $row = new-object psobject
    $row | add-member NoteProperty "Month" $timeNow.ToString("yyyy-MM")
    $row | add-member NoteProperty "Subscription" $curSubscription.Id
    $row | add-member NoteProperty "ResourceGroupName" $virtualMachineInstance.ResourceGroupName
    $row | add-member NoteProperty "VmName" $virtualMachineInstance.Name
    $row | add-member NoteProperty "Id" $virtualMachineInstance.Id
    $row | add-member NoteProperty "ResourceType" $virtualMachineInstance.Type
    $row | add-member NoteProperty "PowerState" $virtualMachineInstance.PowerState

    # Metric Specific values
    $localName = @{l="Name";e={$_.Name.LocalizedValue}}
    $average = @{l="Average";e={($_.Data.Average | Measure-Object -Average).Average}}
    $dataPoints = @{l="DataPoints";e={$_.Data.Count}}
    $startTime = $timeNow.AddDays(-7) 

    $metricResult = Get-AzMetric -ResourceId $virtualMachineInstance.Id -MetricName  @("Percentage CPU", "Disk Read Operations/Sec", "Disk Write Operations/Sec", "Network In", "Network Out", "Network In Total", "Network Out Total", "Disk Write Bytes") -StartTime $startTime -EndTime $timeNow -TimeGrain 00:05:00 -ResultType Data
    $record = $metricResult | Select-Object -Property $localName,Unit,$average,$dataPoints
    
    $pivots = $record | Select-Object -unique "Name" | ForEach-Object { $_.Name } | Sort-Object 
    foreach ($pivot in $pivots)
    {
        $fieldName = $pivot -replace '\s|\/|\(|\)',''
        $row | add-member NoteProperty $fieldName ($record | Where-Object {$_.Name -eq $pivot}).Average
    }      

    # Prep data for insert
    $partitionKey = $timeNow | get-date -Format "yyyyMMddTHHmmZ"
    $rowKey =  $curSubscription.Id + ";" + $virtualMachineInstance.ResourceGroupName + ";" + $virtualMachineInstance.Name

    $hash = @{}
    $row.psobject.properties | ForEach-Object { 
        # Don't add null values
        if($null -ne $_.Value ){
            $hash[$_.Name] = $_.Value 
        }
    }

    # Publish Row to Table Storage
    Add-AzTableRow -table $cloudTable -partitionKey $partitionKey -rowKey ($rowKey) -property $hash

}