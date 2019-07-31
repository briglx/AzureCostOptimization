#Debug
$PSVersionTable
Get-InstalledModule -Name Az -AllVersions | Select-Object Name,Version

# want >= PS v6.2.2
# want >= AZ 2.4.0

try {
    $null = Get-AzSubscription
}
catch {
    Connect-AzAccount
}

# $storage_account = Get-AzStorageAccount  -name brigdrive -ResourceGroupName brigdrive

$subscription = Get-AzSubscription

$vms = Get-AzVM -Status

# $vms[0] | Get-Member
# $vms.PowerState
Foreach ($vm in $vms)
{

    # name.value eq 'Disk Write Operations/Sec' or  name.value eq 'Percentage CPU' or  name.value eq 'Network In' or  name.value eq 'Network Out' or  name.value eq 'Disk Read Operations/Sec' or  name.value eq 'Disk Read Bytes' or  name.value eq 'Disk Write Bytes')
    # and timeGrain eq duration'PT5M'
    # and startTime eq 2017-10-26T05:28:34.919Z
    # and endTime eq 2017-10-26T05:33:34.919Z

    $time_now = Get-Date
    $metric_result = Get-AzMetric -ResourceId $vm.Id -MetricName  @("Percentage CPU", "Disk Read Operations/Sec", "Disk Write Operations/Sec", "Network In", "Network Out", "Disk Write Bytes") -TimeGrain 00:05:00 -ResultType Data

    $time_stamp = @{l="TimeStamp";e={$time_now.ToUniversalTime()}}
    $month = @{l="Month";e={Get-Date $time_now -Format "yyyy-MM"}}
    $subscription_id = @{l="Subscription";e={$subscription.Id}}
    $id = @{l="Id";e={$vm.Id}}
    $resource_group_name = @{l="ResourceGroupName";e={$vm.ResourceGroupName}}

    $resource_type = @{l="ResourceType";e={$vm.Type}}
    $power_state = @{l="PowerState";e={$vm.PowerState}}
    $local_name = @{l="Name";e={$_.Name.LocalizedValue}}
    $average = @{l="Average";e={($_.Data.Average | Measure-Object -Average).Average}}
    $data_points = @{l="DataPoints";e={$_.Data.Count}}
    
    $metric_result | Select-Object -Property $time_stamp,$month,$subscription_id,$resource_group_name,$resource_type,$power_state,$id,$local_name,Unit,$average,$data_points

}

#gps |Select -ExpandProperty Modules -ea SilentlyContinue |Group ModuleName |Sort Count |Select -Last 4
# Resources
# - https://stackoverflow.com/questions/57218402/finding-idle-virtual-machines-and-deallocating-them-using-azure-function
# - Supported Metrics https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported
# - Get VM Metrics Powershell https://docs.microsoft.com/en-us/powershell/module/az.monitor/get-azmetric?view=azps-2.5.0
# - Calucate properties https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-object?view=powershell-6