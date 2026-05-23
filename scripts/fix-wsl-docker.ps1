$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$EvidenceDir = Join-Path $ProjectRoot "docs\evidencias"
$LogFile = Join-Path $EvidenceDir "19-fix-wsl-docker.txt"

New-Item -ItemType Directory -Force -Path $EvidenceDir | Out-Null

function Write-Step {
    param([string]$Message)
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $Message"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}

function Test-Admin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Step "Reabrindo em modo administrador. Confirme o UAC."
    $args = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$PSCommandPath`""
    )
    Start-Process -FilePath "powershell.exe" -ArgumentList $args -Verb RunAs -Wait
    exit $LASTEXITCODE
}

Set-Location $ProjectRoot
Write-Step "Correcao WSL/Docker iniciada."

Write-Step "Habilitando recursos WSL, VMP e Hyper-V."
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Tee-Object -FilePath $LogFile -Append
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart | Tee-Object -FilePath $LogFile -Append
dism.exe /online /enable-feature /featurename:Microsoft-Hyper-V-All /all /norestart | Tee-Object -FilePath $LogFile -Append

Write-Step "Forcando hypervisor launch type = auto."
bcdedit /set hypervisorlaunchtype auto | Tee-Object -FilePath $LogFile -Append

Write-Step "Definindo WSL2 como padrao."
wsl --set-default-version 2 | Tee-Object -FilePath $LogFile -Append

$dockerData = "C:\ProgramData\DockerDesktop"
if (Test-Path $dockerData) {
    Write-Step "Corrigindo dono e ACL de C:\ProgramData\DockerDesktop."
    & takeown.exe /F $dockerData /A /R /D Y | Tee-Object -FilePath $LogFile -Append
    & icacls.exe $dockerData /setowner "BUILTIN\Administrators" /T /C | Tee-Object -FilePath $LogFile -Append
    & icacls.exe $dockerData /grant "BUILTIN\Administrators:(OI)(CI)F" "SYSTEM:(OI)(CI)F" /T /C | Tee-Object -FilePath $LogFile -Append
}

Write-Step "Tentando instalar Ubuntu no WSL."
wsl --install -d Ubuntu --no-launch | Tee-Object -FilePath $LogFile -Append

Write-Step "Tentando instalar Docker Desktop."
winget install -e --id Docker.DockerDesktop --accept-package-agreements --accept-source-agreements --silent | Tee-Object -FilePath $LogFile -Append

Write-Step "Listando WSL."
wsl --list --verbose | Tee-Object -FilePath $LogFile -Append

Write-Step "Verificando Docker no PATH."
if (Get-Command docker -ErrorAction SilentlyContinue) {
    docker --version | Tee-Object -FilePath $LogFile -Append
} else {
    "Docker ainda nao encontrado no PATH." | Tee-Object -FilePath $LogFile -Append
}

Write-Step "Correcao finalizada."
Write-Step "Se Ubuntu ainda nao registrar, reinicie o Windows e rode este script novamente."

