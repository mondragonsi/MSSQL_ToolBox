Read-SqlTableData -TableName rebuildDBS -SchemaName dbo -DatabaseName DBA -ServerInstance VM-DB01-PRD  | Out-GridView 

$ItemName        = "SQLDataBase;AGPRD;"
$AGNameContainer = "SQLAGWorkLoadContainer;xxxxx-1eb6-xxxxx-81b0-xxxxxxxxxxc" 

# Specify the SQL Server connection details
$serverInstance = "SRV-DB01-PRD"
$databaseName = "DBA"
$tableName = "rebuildDBS" #Table that was feed from whoisactive with only database names that are being affected by a REBUILD
$schemaName = "dbo"

# Read data from the SQL Server table
$tableData = Read-SqlTableData -TableName $tableName -SchemaName $schemaName -DatabaseName $databaseName -ServerInstance $serverInstance

# Iterate through each row and print a custom message
foreach ($row in $tableData) {


    $message = "Processing DB: " + $ItemName + $($row.db_name)
    Write-Host $message

    $dbname = $ItemName + $($row.db_name)


    az backup protection backup-now `
    --resource-group rg-myLIMS-prd `
    --item-name $dbname `
    --vault-name recover-prd `
    --container-name $AGNameContainer `
    --backup-typ Log `
    --workload-type MSSQL `
    --backup-management-type AzureWorkload `
    --output table `
    | Out-GridView

    #Start-Sleep -Seconds 120 QUANTO TEMPO DEMORA UM BACKUP DE LOG OU TODOS AO MESMO TEMPO?? 10 MINUTOS?

}
