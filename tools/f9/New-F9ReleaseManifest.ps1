[CmdletBinding()]
param(
    [string]$EvidenceDirectory,
    [string]$ApkPath,
    [string]$ComposeFile
)

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

if ([string]::IsNullOrWhiteSpace($EvidenceDirectory)) {
    $EvidenceDirectory = Join-Path ([System.IO.Path]::GetTempPath()) "revuelta-f9\release"
}
if ([string]::IsNullOrWhiteSpace($ApkPath)) {
    $ApkPath = Join-Path $repositoryRoot "apps\revuelta-mobile\build\app\outputs\flutter-apk\app-debug.apk"
}
if ([string]::IsNullOrWhiteSpace($ComposeFile)) {
    $ComposeFile = Join-Path $repositoryRoot "docker-compose.yml"
}

function Invoke-Git {
    param([Parameter(Mandatory)][string[]]$Arguments)

    $output = & git -c "safe.directory=$($repositoryRoot.Replace('\', '/'))" @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Git falló: git $($Arguments -join ' ')`n$($output -join [Environment]::NewLine)"
    }
    return (($output -join [Environment]::NewLine).Trim())
}

$trackedChanges = Invoke-Git @("status", "--porcelain", "--untracked-files=no")
if (-not [string]::IsNullOrWhiteSpace($trackedChanges)) {
    throw "Hay cambios rastreados sin commit; no se puede identificar un candidato inmutable."
}

$commit = Invoke-Git @("rev-parse", "HEAD")
$branch = Invoke-Git @("branch", "--show-current")
$remote = Invoke-Git @("remote", "get-url", "origin")

$apk = $null
if (Test-Path -LiteralPath $ApkPath -PathType Leaf) {
    $apk = [ordered]@{
        path = (Resolve-Path -LiteralPath $ApkPath).Path
        sha256 = (Get-FileHash -LiteralPath $ApkPath -Algorithm SHA256).Hash.ToLowerInvariant()
        bytes = (Get-Item -LiteralPath $ApkPath).Length
    }
}

$apiImage = $null
try {
    $apiContainer = (& docker compose -f $ComposeFile --profile full ps -q revuelta-api 2>$null)
    if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace(($apiContainer -join "").Trim())) {
        $apiImage = ((& docker inspect --format "{{.Image}}" (($apiContainer -join "").Trim()) 2>$null) -join "").Trim()
    }
} catch {
    $apiImage = $null
}

$manifest = [ordered]@{
    generatedAtUtc = [DateTime]::UtcNow.ToString("o")
    target = "pilot-like local staging on laptop and hotspot"
    readiness = "NO-GO"
    reason = "Field acceptance, D-004 active-circulation outcome and D-007 real-pilot provisioning remain open."
    source = [ordered]@{
        commit = $commit
        branch = $branch
        remote = $remote
        trackedWorkingTreeClean = $true
    }
    artifacts = [ordered]@{
        apk = $apk
        apiImageId = $apiImage
    }
    approvedConfiguration = [ordered]@{
        returnWindowHours = 48
        deliveryTransition = "AVAILABLE_TO_IN_USE"
        assignedUsed = $false
        environment = "local laptop and hotspot"
    }
    remainingBlockers = @(
        "D-004 active-circulation exceptional outcome",
        "D-007 real-pilot account provisioning and revocation",
        "named field owners and signatures",
        "physical field checklist"
    )
}

New-Item -ItemType Directory -Path $EvidenceDirectory -Force | Out-Null
$manifestPath = Join-Path $EvidenceDirectory "release-manifest-$($commit.Substring(0, 12)).json"
$manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $manifestPath -Encoding utf8

Write-Host "Manifiesto F9 generado en $manifestPath"
Write-Host "El estado permanece NO-GO hasta cerrar los bloqueos de campo."
