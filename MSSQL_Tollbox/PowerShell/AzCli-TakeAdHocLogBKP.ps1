$dbName          = "db_name"
$ItemName        = "SQLDataBase;AGPRD;" #Name of your AG. You can find it in the azure portal JSON option
$AGNameContainer = "SQLAGWorkLoadContainer;074d1466-xxxx-xxxx-xxxx-xxxxxxxxxc" 
$finalName       = $ItemName + $dbName

Write-Host $finalName


#Starts a backup ad-hoc type LOG on Azure Service Vault
az backup protection backup-now `
--resource-group rg-myLIMS-prd `
--item-name $finalName `
--vault-name recover-prd `
--container-name $AGNameContainer `
--backup-typ Log `
--workload-type MSSQL `
--backup-management-type AzureWorkload `
--output table `
| Out-GridView

#Gets a list of backup Jobs in Progress
az backup job list `
--resource-group rg-myLIMS-prd `
--vault-name recover-prd `
--backup-management-type AzureWorkload `
--operation Backup `
--status InProgress  `
--output table  `
| Out-GridView


###############REAL EXAMPLE BELOW###############3

$dbName          = "myDB"
$ItemName        = "SQLDataBase;AGPRD;"
$AGNameContainer = "SQLAGWorkLoadContainer;XXXXXX-xxxx-xxxx-xxxx-6xxxxxxxxxc" 
$finalName       = $ItemName + $dbName

Write-Host $finalName

az backup protection backup-now `
--resource-group rg-myDB-prd `
--item-name $finalName `
--vault-name recover-prd `
--container-name $AGNameContainer `
--backup-typ Log `
--workload-type MSSQL `
--backup-management-type AzureWorkload `
--output table `
| Out-GridView


$dbName          = "myDB"
$ItemName        = "SQLDataBase;AGPRD;"
$AGNameContainer = "SQLAGWorkLoadContainer;0xxxxxx-xxx9-xxxx-xxxxx-xxxxxxxxxx" 
$finalName       = $ItemName + $dbName

Write-Host $finalName

az backup protection backup-now `
--resource-group rg-myDB-prd `
--item-name $finalName `
--vault-name recover-prd `
--container-name $AGNameContainer `
--backup-typ FULL `
--workload-type MSSQL `
--backup-management-type AzureWorkload `
--output table `
| Out-GridView         

az backup job list `
--resource-group rg-myDB-prd `
--vault-name recover-prd `
--backup-management-type AzureWorkload `
--operation Backup `
--status InProgress  `
--output table  `
| Out-GridView                                             
