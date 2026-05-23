param(
    [Parameter(Mandatory = $true)]
    [string]$Server,

    [Parameter(Mandatory = $false)]
    [string]$Version = "7.0.0",

    [Parameter(Mandatory = $false)]
    [string]$Hostname = $env:COMPUTERNAME
)

$ErrorActionPreference = "Stop"
$Installer = "C:\zabbix_agent2.msi"
$Url = "https://cdn.zabbix.com/zabbix/binaries/stable/7.0/$Version/zabbix_agent2-$Version-windows-amd64-openssl.msi"

Invoke-WebRequest -Uri $Url -OutFile $Installer

$Arguments = @(
    "/i", $Installer,
    "/qn",
    "SERVER=$Server",
    "SERVERACTIVE=$Server",
    "HOSTNAME=$Hostname",
    "ENABLEPATH=1"
)

Start-Process -FilePath "msiexec.exe" -ArgumentList $Arguments -Wait -NoNewWindow
Start-Service -Name "Zabbix Agent 2"
Set-Service -Name "Zabbix Agent 2" -StartupType Automatic

if (-not (Get-NetFirewallRule -DisplayName "Zabbix Agent" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName "Zabbix Agent" -Direction Inbound -Protocol TCP -LocalPort 10050 -Action Allow
}

Write-Host "Zabbix Agent 2 installed and configured for server $Server."

