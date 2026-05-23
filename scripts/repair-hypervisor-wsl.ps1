$ErrorActionPreference = "Continue"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EvidenceDir = Join-Path $ProjectRoot "docs\evidencias"
$LogFile = Join-Path $EvidenceDir "24-repair-hypervisor-wsl.txt"

New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null

function Write-Log {
    param([string]$Message)
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

function Add-CommandOutput {
    param(
        [string]$Title,
        [scriptblock]$Command
    )
    Write-Log "=== $Title ==="
    try {
        & $Command 2>&1 | Out-String | Add-Content -Path $LogFile -Encoding UTF8
    } catch {
        Add-Content -Path $LogFile -Value $_.Exception.Message -Encoding UTF8
    }
}

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Log "Reabrindo em modo administrador. Confirme o UAC."
    $args = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$PSCommandPath`""
    )
    Start-Process -FilePath "powershell.exe" -ArgumentList $args -Verb RunAs -Wait
    exit $LASTEXITCODE
}

Set-Content -Path $LogFile -Value "=== $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') repair-hypervisor-wsl ===" -Encoding UTF8
Write-Log "Executando elevado: $(Test-Admin)"

Add-CommandOutput "computer info" {
    Get-ComputerInfo -Property WindowsProductName,WindowsVersion,OsBuildNumber,HyperVRequirement* | Format-List
}

Add-CommandOutput "systeminfo hyper-v" {
    systeminfo | Select-String -Pattern "Hyper-V|Virtualization|Virtualiza|hypervisor|hipervisor"
}

Add-CommandOutput "feature state before" {
    foreach ($feature in @(
        "Microsoft-Windows-Subsystem-Linux",
        "VirtualMachinePlatform",
        "Microsoft-Hyper-V-All",
        "HypervisorPlatform"
    )) {
        Get-WindowsOptionalFeature -Online -FeatureName $feature | Select-Object FeatureName,State | Format-List
    }
}

Write-Log "Habilitando recursos de virtualizacao usados por WSL2/Docker."
foreach ($feature in @(
    "Microsoft-Windows-Subsystem-Linux",
    "VirtualMachinePlatform",
    "Microsoft-Hyper-V-All",
    "HypervisorPlatform"
)) {
    Add-CommandOutput "enable $feature" {
        dism.exe /online /enable-feature /featurename:$feature /all /norestart
    }
}

Write-Log "Forcando hypervisorlaunchtype Auto."
Add-CommandOutput "bcdedit set hypervisorlaunchtype auto" {
    bcdedit /set hypervisorlaunchtype auto
}

Add-CommandOutput "bcdedit current after" {
    bcdedit /enum "{current}"
}

Add-CommandOutput "feature state after" {
    foreach ($feature in @(
        "Microsoft-Windows-Subsystem-Linux",
        "VirtualMachinePlatform",
        "Microsoft-Hyper-V-All",
        "HypervisorPlatform"
    )) {
        Get-WindowsOptionalFeature -Online -FeatureName $feature | Select-Object FeatureName,State | Format-List
    }
}

Add-CommandOutput "wsl status" {
    wsl --status
    wsl --version
}

Write-Log "Finalizado. Se algum recurso mudou ou bcdedit confirmou Auto, reinicie o Windows antes de tentar instalar Ubuntu novamente."
