# Azure Cost Optimization

The `azure cost optimization` is an unofficial collection of scripts used to find useful information about an azure subscription.

Azure provides metrics usage for their customers. The `azure cost optimzation` uses a script to fetch the data and use PowerBI M queries to parse the data info useful fields.

# Requirements

This works with
- `>= PS v6.2.2`
- `>= AZ 2.4.0`
- `>= AzTable 2.0.2`


# Resources
- [https://stackoverflow.com/questions/57218402/finding-idle-virtual-machines-and-deallocating-them-using-azure-function]
- [Supported Metrics](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported)
- [Get VM Metrics Powershell](https://docs.microsoft.com/en-us/powershell/module/az.monitor/get-azmetric?view=azps-2.5.0)
- [Calucate properties](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-object?view=powershell-6)
- [Storage Metrics example](https://docs.microsoft.com/en-us/rest/api/storageservices/storage-analytics-metrics-table-schema)
- [Old Documentation to insert into tables with powershell](https://docs.microsoft.com/en-us/azure/storage/tables/table-storage-how-to-use-powershell#reference-cloudtable-property-of-a-specific-table)
    - this indicates that PS AZ module doesn't have cloudtable features
- [Blog post on tables and PS AZ module](https://paulomarquesc.github.io/working-with-azure-storage-tables-from-powershell/)
- [Powershell example of tables ps2 az module](https://docs.microsoft.com/en-us/azure/storage/tables/table-storage-how-to-use-powershell)
- [Power BI Integraton with Tables](https://blogs.endjin.com/2015/04/visualise-your-azure-table-storage-data-with-power-bi/)
- [Example ps1 file for Add-AzTableRow](https://github.com/paulomarquesc/AzureRmStorageTable/blob/master/AzureRmStorageTableCoreHelper.psm1)
- [Debugging Powershell in VSCode](https://code.visualstudio.com/docs/languages/powershell)