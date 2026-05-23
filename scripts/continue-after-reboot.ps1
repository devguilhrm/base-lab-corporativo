$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EvidenceDir = Join-Path $ProjectRoot "docs\evidencias"
$LogFile = Join-Path $EvidenceDir "18-continue-after-reboot.txt"

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
    Write-Step "Reabrindo continuacao com privilegios de administrador. Confirme o UAC."
    $args = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$PSCommandPath`""
    )
    Start-Process -FilePath "powershell.exe" -ArgumentList $args -Verb RunAs -Wait
    exit $LASTEXITCODE
}

Set-Location $ProjectRoot

Write-Step "Continuacao pos-reinicializacao iniciada."

Write-Step "Verificando WSL."
wsl --status | Tee-Object -FilePath $LogFile -Append

Write-Step "Instalando Ubuntu no WSL."
wsl --install -d Ubuntu --no-launch | Tee-Object -FilePath $LogFile -Append

Write-Step "Listando distribuicoes WSL."
wsl --list --verbose | Tee-Object -FilePath $LogFile -Append

Write-Step "Instalando Docker Desktop via winget."
winget install -e --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements --silent | Tee-Object -FilePath $LogFile -Append

Write-Step "Tentando instalar Ansible dentro do Ubuntu como root."
wsl -d Ubuntu -u root -- bash -lc "apt-get update && apt-get install -y ansible" | Tee-Object -FilePath $LogFile -Append

Write-Step "Executando readiness real."
go run ./cmd/readiness-check | Tee-Object -FilePath $LogFile -Append

Write-Step "Continuacao concluida. Se o Docker Desktop pedir login ou inicializacao, abra o Docker Desktop manualmente uma vez."
