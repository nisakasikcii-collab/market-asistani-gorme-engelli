# Eyeshopper AI — Flutter platform klasörlerini üretir (android/ios/windows/...).
# Önkoşul: Flutter SDK kurulu ve PATH'te `flutter` görünür olmalı.
$ErrorActionPreference = "Stop"
$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutter) {
    Write-Error "Flutter bulunamadı. https://docs.flutter.dev/get-started/install"
}
$repoRoot = Split-Path $PSScriptRoot -Parent
$appDir = Join-Path $repoRoot "mobile\flutter_app"
Set-Location $appDir
flutter create . --org com.eyeshopper.ai --project-name eyeshopper_ai
flutter pub get
Write-Host "Tamam: android ve diğer platformlar güncellendi."
