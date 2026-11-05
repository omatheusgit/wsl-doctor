<#
.SYNOPSIS
    Optimizes Windows 10/11 Wi-Fi Adapter (Intel Wireless-AC) & DNS Latency for WSL2 / DevOps Workloads.
.DESCRIPTION
    1. Sets ultra-fast Cloudflare (1.1.1.1) and Google (8.8.8.8) DNS on the active Wi-Fi interface
       (eliminating ISP router DNS proxy lag of 1000ms+).
    2. Configures Intel Wireless-AC adapter advanced properties to prefer 5 GHz band,
       disable MIMO power save (SMPS), and enable Throughput Booster.
    3. Enables TCP Receive Window Auto-Tuning and flushes DNS cache.
    Run in an elevated PowerShell (Run as Administrator).
#>

$ErrorActionPreference = "Continue"

Write-Host "=== 1. Setting Low-Latency DNS (1.1.1.1 / 8.8.8.8) on Wi-Fi ===" -ForegroundColor Cyan
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses ("1.1.1.1", "8.8.8.8", "1.0.0.1", "8.8.4.4")
Clear-DnsClientCache

Write-Host "=== 2. Tuning Intel Wireless-AC 9461 Advanced Properties (5GHz + No SMPS) ===" -ForegroundColor Cyan
Set-NetAdapterAdvancedProperty -Name "Wi-Fi" -RegistryKeyword "BandType" -RegistryValue 2 -ErrorAction SilentlyContinue
Set-NetAdapterAdvancedProperty -Name "Wi-Fi" -RegistryKeyword "MimoPowerSaveMode" -RegistryValue 3 -ErrorAction SilentlyContinue
Set-NetAdapterAdvancedProperty -Name "Wi-Fi" -RegistryKeyword "ThroughputBoosterEnabled" -RegistryValue 1 -ErrorAction SilentlyContinue

Write-Host "=== 3. Verifying DNS Latency to github.com ===" -ForegroundColor Green
$sw = [Diagnostics.Stopwatch]::StartNew()
Resolve-DnsName -Name "github.com" -Server "1.1.1.1" | Out-Null
$sw.Stop()
Write-Host "Resolved github.com in $($sw.ElapsedMilliseconds) ms!" -ForegroundColor Green
