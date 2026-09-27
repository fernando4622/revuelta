[CmdletBinding()]
param(
    [string]$ComposeFile,
    [string]$CandidateImage,
    [string]$BaseUrl = "http://localhost:8080",
    [int]$HealthTimeoutSeconds = 90
)

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

if ([string]::IsNullOrWhiteSpace($ComposeFile)) {
    $ComposeFile = Join-Path $repositoryRoot "docker-compose.yml"
}
if (-not (Test-Path -LiteralPath $ComposeFile -PathType Leaf)) {
    throw "No se encontró el archivo Compose: $ComposeFile"
}

$commit = (& git -c "safe.directory=$($repositoryRoot.Replace('\', '/'))" rev-parse --short=12 HEAD).Trim()
if ($LASTEXITCODE -ne 0) {
    throw "No se pudo identificar el commit candidato."
}
if ([string]::IsNullOrWhiteSpace($CandidateImage)) {
    $CandidateImage = "revuelta-api:f9-$commit"
}
if ($CandidateImage -notmatch '^revuelta-api:f9-[a-zA-Z0-9._-]+$') {
    throw "La imagen candidata debe usar el prefijo revuelta-api:f9-."
}

function Invoke-Docker {
    param([Parameter(Mandatory)][string[]]$Arguments)

    $output = & docker @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker falló: docker $($Arguments -join ' ')`n$($output -join [Environment]::NewLine)"
    }
    return $output
}

function Wait-ApiReady {
    param([Parameter(Mandatory)][string]$Label)

    $deadline = [DateTime]::UtcNow.AddSeconds($HealthTimeoutSeconds)
    do {
        try {
            $liveness = Invoke-RestMethod -Uri "$BaseUrl/actuator/health/liveness" -TimeoutSec 3
            $readiness = Invoke-RestMethod -Uri "$BaseUrl/actuator/health/readiness" -TimeoutSec 3
            if ($liveness.status -eq "UP" -and $readiness.status -eq "UP") {
                return
            }
        } catch {}
        Start-Sleep -Seconds 2
    } while ([DateTime]::UtcNow -lt $deadline)

    throw "$Label no alcanzó liveness/readiness UP en $HealthTimeoutSeconds segundos."
}

function Test-AuthenticatedRead {
    $session = Invoke-RestMethod `
        -Method Post `
        -Uri "$BaseUrl/api/v1/auth/login" `
        -ContentType "application/json" `
        -Body (@{ username = "admin"; password = "password123" } | ConvertTo-Json)
    $headers = @{ Authorization = "Bearer $($session.token)" }
    $null = Invoke-RestMethod `
        -Method Get `
        -Uri "$BaseUrl/api/v1/containers?page=0&size=1" `
        -Headers $headers
}

function Start-ProbeContainer {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Image,
        [Parameter(Mandatory)][string]$Network
    )

    Invoke-Docker @(
        "run", "--detach", "--name", $Name,
        "--network", $Network,
        "--publish", "8080:8080",
        "--env", "SPRING_PROFILES_ACTIVE=dev",
        "--env", "SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/revuelta_db",
        "--env", "SPRING_DATASOURCE_USERNAME=revuelta_user",
        "--env", "SPRING_DATASOURCE_PASSWORD=revuelta_password",
        $Image
    ) | Out-Null
}

$apiContainer = ((Invoke-Docker @(
    "compose", "-f", $ComposeFile, "--profile", "full", "ps", "-q", "revuelta-api"
)) -join "").Trim()
$postgresContainer = ((Invoke-Docker @(
    "compose", "-f", $ComposeFile, "ps", "-q", "postgres"
)) -join "").Trim()
if ([string]::IsNullOrWhiteSpace($apiContainer) -or [string]::IsNullOrWhiteSpace($postgresContainer)) {
    throw "La API y PostgreSQL deben estar activos antes del ensayo de rollback."
}

$previousImage = ((Invoke-Docker @(
    "inspect", "--format", "{{.Image}}", $apiContainer
)) -join "").Trim()
$network = ((Invoke-Docker @(
    "inspect", "--format", '{{range $name, $settings := .NetworkSettings.Networks}}{{$name}}{{end}}',
    $postgresContainer
)) -join "").Trim()
if ([string]::IsNullOrWhiteSpace($network)) {
    throw "No se pudo resolver la red privada de PostgreSQL."
}

$candidateName = "revuelta-f9-candidate-$commit"
$rollbackName = "revuelta-f9-rollback-$commit"
$composeStopped = $false
$candidateStarted = $false
$rollbackStarted = $false

try {
    Invoke-Docker @(
        "build", "--tag", $CandidateImage,
        (Join-Path $repositoryRoot "services\revuelta-api")
    ) | Out-Null

    Invoke-Docker @(
        "compose", "-f", $ComposeFile, "--profile", "full", "stop", "revuelta-api"
    ) | Out-Null
    $composeStopped = $true

    Start-ProbeContainer -Name $candidateName -Image $CandidateImage -Network $network
    $candidateStarted = $true
    Wait-ApiReady -Label "La candidata"
    Test-AuthenticatedRead

    Invoke-Docker @("rm", "--force", $candidateName) | Out-Null
    $candidateStarted = $false

    Start-ProbeContainer -Name $rollbackName -Image $previousImage -Network $network
    $rollbackStarted = $true
    Wait-ApiReady -Label "La versión anterior"
    Test-AuthenticatedRead

    Write-Host "Rollback verificado: candidata y versión anterior arrancaron sobre el esquema actual."
    Write-Host "Candidata: $CandidateImage"
    Write-Host "Anterior: $previousImage"
} finally {
    if ($candidateStarted) {
        & docker rm --force $candidateName 2>&1 | Out-Null
    }
    if ($rollbackStarted) {
        & docker rm --force $rollbackName 2>&1 | Out-Null
    }
    if ($composeStopped) {
        & docker compose -f $ComposeFile --profile full up -d revuelta-api 2>&1 | Out-Null
    }
}
