#requires -Version 5.1
<#
.SYNOPSIS
  Traffic Ledger 开发版 Windows debug 构建入口（隔离正式版数据）。

.DESCRIPTION
  本脚本仅用于 Traffic Ledger 开发构建，会设置 FLCLASH_DEV_IDENTITY=1
  环境变量，使 windows/runner/Runner.rc 的 VERSIONINFO 切换为：
      CompanyName = com.follow.trafficledger
      ProductName = clash-traffic-ledger-dev
  这样 path_provider_windows 会推导出独立 support 目录
  (com.follow.trafficledger\clash-traffic-ledger-dev)，避免 dev build
  读取、写入或锁定正式版 FlClash 的用户数据 (com.follow\clash)。

  构建完成后脚本会读取生成 FlClash.exe 的 VERSIONINFO 并校验上述两个字段，
  仅当字段正确时才报告开发构建成功，防止漏设环境变量导致共用正式版数据目录。

  本脚本不影响官方正式构建命令 (flutter build windows / setup.dart)，
  不启动 TUN、不修改系统代理、不读取正式版配置。

.PARAMETER SkipBuild
  跳过 flutter build 步骤，仅校验已存在的产物（用于调试）。

.EXAMPLE
  .\tool\dev_build_windows.ps1
  .\tool\dev_build_windows.ps1 -SkipBuild
#>
[CmdletBinding()]
param(
  [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$exeRel = 'build\windows\x64\runner\Debug\FlClash.exe'
$exePath = Join-Path $repoRoot $exeRel

if (-not $SkipBuild) {
  Write-Host '== Traffic Ledger dev build (Windows debug) ==' -ForegroundColor Cyan
  Write-Host "repo: $repoRoot"
  Write-Host 'setting FLCLASH_DEV_IDENTITY=1 for this build' -ForegroundColor Yellow
  $env:FLCLASH_DEV_IDENTITY = '1'

  Write-Host 'running: flutter build windows --debug' -ForegroundColor Cyan
  & flutter.bat build windows --debug
  if ($LASTEXITCODE -ne 0) {
    Write-Error "flutter build failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
  }
}

if (-not (Test-Path $exePath)) {
  Write-Error "build output not found: $exePath"
  exit 1
}

Write-Host '== verifying dev identity in VERSIONINFO ==' -ForegroundColor Cyan
$vi = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($exePath)
Write-Host "CompanyName     : $($vi.CompanyName)"
Write-Host "ProductName     : $($vi.ProductName)"
Write-Host "FileDescription : $($vi.FileDescription)"

$expectedCompany = 'com.follow.trafficledger'
$expectedProduct = 'clash-traffic-ledger-dev'
$ok = $true
if ($vi.CompanyName -ne $expectedCompany) {
  Write-Host "FAIL: CompanyName expected '$expectedProduct', got '$($vi.CompanyName)'" -ForegroundColor Red
  $ok = $false
}
if ($vi.ProductName -ne $expectedProduct) {
  Write-Host "FAIL: ProductName expected '$expectedProduct', got '$($vi.ProductName)'" -ForegroundColor Red
  $ok = $false
}

if (-not $ok) {
  Write-Host ''
  Write-Host 'DEV BUILD REJECTED: identity not isolated.' -ForegroundColor Red
  Write-Host 'If FLCLASH_DEV_IDENTITY was not set, the build would share the production' -ForegroundColor Red
  Write-Host 'support directory (com.follow\clash) and could read/write production data.' -ForegroundColor Red
  Write-Host 'Re-run this script without -SkipBuild, or ensure FLCLASH_DEV_IDENTITY=1 is set.' -ForegroundColor Red
  exit 2
}

Write-Host ''
Write-Host 'DEV BUILD OK: identity isolated from production FlClash.' -ForegroundColor Green
Write-Host "  exe: $exePath"
Write-Host '  dev support dir will be: %APPDATA%\com.follow.trafficledger\clash-traffic-ledger-dev'
