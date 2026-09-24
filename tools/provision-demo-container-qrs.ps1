param(
    [string]$BaseUrl = "http://localhost:8080/api/v1",
    [string]$OutputDirectory = "docs/testing/container-qrs",
    [string]$AdminUsername = "admin",
    [string]$AdminPassword = "password123"
)

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$mobileRoot = Join-Path $repositoryRoot "apps/revuelta-mobile"
$resolvedOutput = if ([System.IO.Path]::IsPathRooted($OutputDirectory)) {
    $OutputDirectory
} else {
    Join-Path $repositoryRoot $OutputDirectory
}

$loginBody = @{ username = $AdminUsername; password = $AdminPassword } | ConvertTo-Json
$session = Invoke-RestMethod `
    -Method Post `
    -Uri "$BaseUrl/auth/login" `
    -ContentType "application/json" `
    -Body $loginBody
$headers = @{ Authorization = "Bearer $($session.token)" }

$existing = @(
    Invoke-RestMethod `
        -Method Get `
        -Uri "$BaseUrl/containers?page=0&size=100" `
        -Headers $headers
)
$manifest = @()

1..5 | ForEach-Object {
    $code = "RV-DEMO-{0:D3}" -f $_
    $container = $existing | Where-Object { $_.code -eq $code } | Select-Object -First 1

    if ($null -eq $container) {
        $container = Invoke-RestMethod `
            -Method Post `
            -Uri "$BaseUrl/containers" `
            -Headers $headers `
            -ContentType "application/json" `
            -Body (@{ code = $code } | ConvertTo-Json)
    }

    if ($container.status -eq "REGISTERED") {
        $container = Invoke-RestMethod `
            -Method Post `
            -Uri "$BaseUrl/containers/$($container.id)/activate" `
            -Headers $headers `
            -ContentType "application/json" `
            -Body (@{ reason = "Activación de envase para pruebas manuales" } | ConvertTo-Json)
    }

    $qr = Invoke-RestMethod `
        -Method Get `
        -Uri "$BaseUrl/containers/$($container.id)/qr" `
        -Headers $headers

    $manifest += [ordered]@{
        code = $code
        containerRef = $qr.containerRef
        generation = $qr.generation
        payload = $qr.payload
    }
}

New-Item -ItemType Directory -Path $resolvedOutput -Force | Out-Null
$manifestPath = Join-Path $resolvedOutput "manifest.json"
$manifest | ConvertTo-Json -Depth 5 | Set-Content -Path $manifestPath -Encoding utf8

Push-Location $mobileRoot
try {
    dart run tool/render_container_qrs.dart $manifestPath $resolvedOutput
} finally {
    Pop-Location
}

Write-Host "Se generaron 5 QR estáticos válidos en $resolvedOutput"
