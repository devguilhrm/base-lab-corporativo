$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EvidenceDir = Join-Path $ProjectRoot "docs\evidencias"
$LogFile = Join-Path $EvidenceDir "12-windows-prereqs-install.txt"

New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null

function Write-Step {
    param([string]$Message)
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Step "Reabrindo instalador com privilegios de administrador. Confirme o UAC."
    $args = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$PSCommandPath`""
    )
    Start-Process -FilePath "powershell.exe" -ArgumentList $args -Verb RunAs -Wait
    exit $LASTEXITCODE
}

Write-Step "Instalacao de prerequisitos iniciada com privilegios de administrador."

Write-Step "Habilitando Windows Subsystem for Linux."
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Tee-Object -FilePath $LogFile -Append

Write-Step "Habilitando Virtual Machine Platform."
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart | Tee-Object -FilePath $LogFile -Append

Write-Step "Configurando WSL 2 como padrao."
wsl --set-default-version 2 | Tee-Object -FilePath $LogFile -Append

Write-Step "Instalando Ubuntu no WSL sem abrir a primeira inicializacao."
wsl --install -d Ubuntu --no-launch | Tee-Object -FilePath $LogFile -Append

Write-Step "Instalando Docker Desktop via winget."
winget install -e --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements --silent | Tee-Object -FilePath $LogFile -Append

Write-Step "Instalacao concluida. Reinicie o Windows se o WSL ou Docker solicitar."
Write-Step "Apos reiniciar, abra Ubuntu pelo Menu Iniciar para criar usuario e senha Linux."
Write-Step "Depois rode: wsl -d Ubuntu -- sudo apt update && sudo apt install -y ansible"
