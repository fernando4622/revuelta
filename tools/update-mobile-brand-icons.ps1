param(
    [string]$Source = "apps/revuelta-mobile/resources/logo.jpeg"
)

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$sourcePath = if ([System.IO.Path]::IsPathRooted($Source)) {
    $Source
} else {
    Join-Path $repositoryRoot $Source
}

Add-Type -AssemblyName System.Drawing
$sourceImage = [System.Drawing.Image]::FromFile($sourcePath)

function Write-SquarePng {
    param([string]$Path, [int]$Size)

    $directory = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $bitmap = New-Object System.Drawing.Bitmap($Size, $Size)
    try {
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.Clear([System.Drawing.Color]::FromArgb(247, 243, 233))
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
            $graphics.DrawImage($sourceImage, 0, 0, $Size, $Size)
            $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
        } finally {
            $graphics.Dispose()
        }
    } finally {
        $bitmap.Dispose()
    }
}

try {
    $androidRoot = Join-Path $repositoryRoot "apps/revuelta-mobile/android/app/src/main/res"
    @{
        "mipmap-mdpi/ic_launcher.png" = 48
        "mipmap-hdpi/ic_launcher.png" = 72
        "mipmap-xhdpi/ic_launcher.png" = 96
        "mipmap-xxhdpi/ic_launcher.png" = 144
        "mipmap-xxxhdpi/ic_launcher.png" = 192
    }.GetEnumerator() | ForEach-Object {
        Write-SquarePng (Join-Path $androidRoot $_.Key) $_.Value
    }

    $iosRoot = Join-Path $repositoryRoot "apps/revuelta-mobile/ios/Runner/Assets.xcassets/AppIcon.appiconset"
    @{
        "Icon-App-20x20@1x.png" = 20
        "Icon-App-20x20@2x.png" = 40
        "Icon-App-20x20@3x.png" = 60
        "Icon-App-29x29@1x.png" = 29
        "Icon-App-29x29@2x.png" = 58
        "Icon-App-29x29@3x.png" = 87
        "Icon-App-40x40@1x.png" = 40
        "Icon-App-40x40@2x.png" = 80
        "Icon-App-40x40@3x.png" = 120
        "Icon-App-60x60@2x.png" = 120
        "Icon-App-60x60@3x.png" = 180
        "Icon-App-76x76@1x.png" = 76
        "Icon-App-76x76@2x.png" = 152
        "Icon-App-83.5x83.5@2x.png" = 167
        "Icon-App-1024x1024@1x.png" = 1024
    }.GetEnumerator() | ForEach-Object {
        Write-SquarePng (Join-Path $iosRoot $_.Key) $_.Value
    }
} finally {
    $sourceImage.Dispose()
}

Write-Host "Iconos Android/iOS actualizados desde $sourcePath"
