# Caminho do script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Lê instâncias e logins
$sqlInstances = Get-Content -Path (Join-Path $ScriptDir 'instances.txt')
$loginsToRemove = Get-Content -Path (Join-Path $ScriptDir 'logins.txt')

$global:DeletedLogins = @()

function Remove-SQLLogins {
    param (
        [string]$Instance,
        [string[]]$Logins
    )

    Write-Host "Connexion à l’instance : $Instance" -ForegroundColor Cyan

    foreach ($login in $Logins) {
        $checkTsql = "SELECT 1 FROM sys.server_principals WHERE name = '$login';"
        try {
            $exists = Invoke-Sqlcmd -ServerInstance $Instance -Query $checkTsql -ErrorAction Stop
            if ($exists) {
                $dropTsql = "DROP LOGIN [$login];"
                try {
                    Invoke-Sqlcmd -ServerInstance $Instance -Query $dropTsql -ErrorAction Stop
                    Write-Host "Login '$login' supprimé de l’instance $Instance" -ForegroundColor Green

                    $rollbackCmd = "CREATE LOGIN [$login] FROM WINDOWS;"
                    $global:DeletedLogins += [PSCustomObject]@{
                        Instance = $Instance; Login = $login; Status = "Supprimé"; 'Rollback command' = $rollbackCmd
                    }
                } catch {
                    Write-Warning "Erreur lors de la suppression du login '$login' de l’instance '$Instance'"
                    $global:DeletedLogins += [PSCustomObject]@{
                        Instance = $Instance; Login = $login; Status = "Erreur"; 'Rollback command' = ""
                    }
                }
            } else {
                Write-Host "Login '$login' n'existe pas sur l’instance $Instance" -ForegroundColor Yellow
                $global:DeletedLogins += [PSCustomObject]@{
                    Instance = $Instance; Login = $login; Status = "N’existe pas"; 'Rollback command' = ""
                }
            }
        } catch {
            Write-Warning "Erreur lors de la vérification du login '$login' sur '$Instance'"
            $global:DeletedLogins += [PSCustomObject]@{
                Instance = $Instance; Login = $login; Status = "Erreur"; 'Rollback command' = ""
            }
        }
    }
}

foreach ($instance in $sqlInstances) {
    Remove-SQLLogins -Instance $instance -Logins $loginsToRemove
}

if ($DeletedLogins.Count -gt 0) {
    $DeletedLogins | Out-GridView -Title "Résumé des logins supprimés"
} else {
    Write-Host "Aucun login n’a été supprimé." -ForegroundColor Yellow
}