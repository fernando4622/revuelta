[CmdletBinding()]
param(
    [string]$ComposeFile,
    [string]$BackupDirectory,
    [string]$SourceDatabase = "revuelta_db",
    [string]$DatabaseUser = "revuelta_user",
    [string]$RestoreDatabase
)

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

if ([string]::IsNullOrWhiteSpace($ComposeFile)) {
    $ComposeFile = Join-Path $repositoryRoot "docker-compose.yml"
}
if ([string]::IsNullOrWhiteSpace($BackupDirectory)) {
    $BackupDirectory = Join-Path ([System.IO.Path]::GetTempPath()) "revuelta-f9\backups"
}

$runId = [DateTime]::UtcNow.ToString("yyyyMMddTHHmmssZ")
if ([string]::IsNullOrWhiteSpace($RestoreDatabase)) {
    $RestoreDatabase = "revuelta_f9_restore_$($runId.ToLowerInvariant())"
}

if ($SourceDatabase -eq $RestoreDatabase) {
    throw "La base restaurada debe ser distinta de la base fuente."
}
if ($RestoreDatabase -notmatch '^revuelta_f9_restore_[a-z0-9_]+$') {
    throw "El nombre de restauración debe iniciar con revuelta_f9_restore_ y usar solo minúsculas, números o guion bajo."
}
if (-not (Test-Path -LiteralPath $ComposeFile -PathType Leaf)) {
    throw "No se encontró el archivo Compose: $ComposeFile"
}

function Invoke-Docker {
    param([Parameter(Mandatory)][string[]]$Arguments)

    $output = & docker @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker falló: docker $($Arguments -join ' ')`n$($output -join [Environment]::NewLine)"
    }
    return $output
}

function Get-DatabaseCounts {
    param(
        [Parameter(Mandatory)][string]$ContainerId,
        [Parameter(Mandatory)][string]$DatabaseName
    )

    $query = @"
SELECT concat_ws('|',
    (SELECT COUNT(*) FROM users),
    (SELECT COUNT(*) FROM containers),
    (SELECT COUNT(*) FROM circulations),
    (SELECT COUNT(*) FROM container_events),
    (SELECT COUNT(*) FROM flyway_schema_history WHERE success = TRUE)
);
"@
    $raw = Invoke-Docker @(
        "exec", $ContainerId,
        "psql", "--username=$DatabaseUser", "--dbname=$DatabaseName",
        "--tuples-only", "--no-align", "--command=$query"
    )
    $values = (($raw -join "").Trim() -split '\|')
    if ($values.Count -ne 5) {
        throw "No se pudieron interpretar los conteos de $DatabaseName."
    }

    return [ordered]@{
        users = [long]$values[0]
        containers = [long]$values[1]
        circulations = [long]$values[2]
        containerEvents = [long]$values[3]
        successfulMigrations = [long]$values[4]
    }
}

New-Item -ItemType Directory -Path $BackupDirectory -Force | Out-Null
$backupPath = Join-Path $BackupDirectory "revuelta-$runId.dump"
$manifestPath = Join-Path $BackupDirectory "revuelta-$runId.restore.json"
$remoteBackup = "/tmp/revuelta-f9-$runId.dump"
$remoteRestore = "/tmp/revuelta-f9-restore-$runId.dump"

$containerId = ((Invoke-Docker @(
    "compose", "-f", $ComposeFile, "ps", "-q", "postgres"
)) -join "").Trim()
if ([string]::IsNullOrWhiteSpace($containerId)) {
    throw "PostgreSQL no está activo en el Compose indicado."
}

$running = ((Invoke-Docker @(
    "inspect", "--format", "{{.State.Running}}", $containerId
)) -join "").Trim()
if ($running -ne "true") {
    throw "El contenedor PostgreSQL no está ejecutándose."
}

$alreadyExists = ((Invoke-Docker @(
    "exec", $containerId,
    "psql", "--username=$DatabaseUser", "--dbname=postgres",
    "--tuples-only", "--no-align",
    "--command=SELECT 1 FROM pg_database WHERE datname = '$RestoreDatabase';"
)) -join "").Trim()
if ($alreadyExists -eq "1") {
    throw "La base aislada $RestoreDatabase ya existe; no se sobrescribirá."
}

$sourceCounts = Get-DatabaseCounts -ContainerId $containerId -DatabaseName $SourceDatabase

Invoke-Docker @(
    "exec", $containerId,
    "pg_dump", "--username=$DatabaseUser", "--dbname=$SourceDatabase",
    "--format=custom", "--no-owner", "--no-acl", "--file=$remoteBackup"
) | Out-Null
Invoke-Docker @("cp", "${containerId}:$remoteBackup", $backupPath) | Out-Null

$checksum = (Get-FileHash -LiteralPath $backupPath -Algorithm SHA256).Hash.ToLowerInvariant()

Invoke-Docker @(
    "exec", $containerId,
    "createdb", "--username=$DatabaseUser", $RestoreDatabase
) | Out-Null
Invoke-Docker @("cp", $backupPath, "${containerId}:$remoteRestore") | Out-Null
Invoke-Docker @(
    "exec", $containerId,
    "pg_restore", "--username=$DatabaseUser", "--dbname=$RestoreDatabase",
    "--no-owner", "--no-acl", "--exit-on-error", $remoteRestore
) | Out-Null

$restoredCounts = Get-DatabaseCounts -ContainerId $containerId -DatabaseName $RestoreDatabase
$countsMatch = (($sourceCounts | ConvertTo-Json -Compress) -eq ($restoredCounts | ConvertTo-Json -Compress))
if (-not $countsMatch) {
    throw "La restauración terminó, pero los conteos fuente/restauración no coinciden. La base aislada se conserva para diagnóstico."
}

$manifest = [ordered]@{
    runId = $runId
    verifiedAtUtc = [DateTime]::UtcNow.ToString("o")
    sourceDatabase = $SourceDatabase
    restoredDatabase = $RestoreDatabase
    sourceContainer = $containerId
    backupPath = $backupPath
    sha256 = $checksum
    counts = $sourceCounts
    sourceUnchangedByProcedure = $true
    restoredDatabasePreservedForInspection = $true
}
$manifest | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $manifestPath -Encoding utf8

Write-Host "Respaldo y restauración verificados sin sobrescribir la fuente."
Write-Host "Respaldo: $backupPath"
Write-Host "SHA-256: $checksum"
Write-Host "Base restaurada: $RestoreDatabase"
Write-Host "Evidencia: $manifestPath"
