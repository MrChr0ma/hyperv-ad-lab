#Requires -RunAsAdministrator
# TP1 - Etape 0 : reseau Labo-AD (10.10.0.0/24 avec NAT) + VM DC01 (et PC01 en option).
# Usage :
#   .\02-creer-labo.ps1 -ServerIso "C:\ISO\SERVER_EVAL_x64FRE_fr-fr.iso"
#   .\02-creer-labo.ps1 -ServerIso ... -ClientIso "C:\ISO\Windows11_....iso" -AvecPC01

param(
    [Parameter(Mandatory)] [string] $ServerIso,
    [string] $ClientIso,
    [switch] $AvecPC01,
    [string] $VmRoot = "C:\Hyper-V\Labo-AD"
)

$ErrorActionPreference = 'Stop'

# --- Reseau : commutateur interne + NAT, passerelle 10.10.0.1 sur l'hote (conventions du TP) ---
$switchName = 'Labo-AD'
if (-not (Get-VMSwitch -Name $switchName -ErrorAction SilentlyContinue)) {
    New-VMSwitch -Name $switchName -SwitchType Internal | Out-Null
    Write-Host "Commutateur interne '$switchName' cree."
}
$ifIndex = (Get-NetAdapter -Name "vEthernet ($switchName)").ifIndex
if (-not (Get-NetIPAddress -InterfaceIndex $ifIndex -IPAddress 10.10.0.1 -ErrorAction SilentlyContinue)) {
    New-NetIPAddress -InterfaceIndex $ifIndex -IPAddress 10.10.0.1 -PrefixLength 24 | Out-Null
    Write-Host "Passerelle 10.10.0.1 configuree sur vEthernet ($switchName)."
}
if (-not (Get-NetNat | Where-Object InternalIPInterfaceAddressPrefix -eq '10.10.0.0/24')) {
    New-NetNat -Name 'Labo-AD-NAT' -InternalIPInterfaceAddressPrefix 10.10.0.0/24 | Out-Null
    Write-Host "NAT 10.10.0.0/24 cree (acces Internet pour les VM)."
}

function New-LabVM {
    param([string] $Name, [string] $Iso, [long] $MemoryBytes, [switch] $Tpm)

    if (Get-VM -Name $Name -ErrorAction SilentlyContinue) {
        Write-Host "La VM $Name existe deja, rien a faire." -ForegroundColor Yellow
        return
    }
    if (-not (Test-Path $Iso)) { throw "ISO introuvable : $Iso" }

    $vhd = Join-Path $VmRoot "$Name\$Name.vhdx"
    New-VM -Name $Name -Generation 2 -MemoryStartupBytes $MemoryBytes `
           -NewVHDPath $vhd -NewVHDSizeBytes 40GB -SwitchName $switchName -Path $VmRoot | Out-Null

    Set-VM -Name $Name -ProcessorCount 2 -StaticMemory -AutomaticCheckpointsEnabled $false `
           -CheckpointType Standard -AutomaticStopAction ShutDown
    $dvd = Add-VMDvdDrive -VMName $Name -Path $Iso -Passthru
    Set-VMFirmware -VMName $Name -FirstBootDevice $dvd -SecureBootTemplate MicrosoftWindows

    if ($Tpm) {
        # Windows 11 exige un TPM 2.0
        Set-VMKeyProtector -VMName $Name -NewLocalKeyProtector
        Enable-VMTPM -VMName $Name
    }
    Write-Host "VM $Name creee : 2 vCPU, $($MemoryBytes/1GB) Go statiques, disque 40 Go dynamique, reseau $switchName." -ForegroundColor Green
}

# DC01 : 4 Go (le PC a 32 Go), memoire dynamique desactivee comme demande par la fiche
New-LabVM -Name 'DC01' -Iso $ServerIso -MemoryBytes 4GB

if ($AvecPC01) {
    if (-not $ClientIso) { throw "Indiquez -ClientIso pour creer PC01." }
    New-LabVM -Name 'PC01' -Iso $ClientIso -MemoryBytes 4GB -Tpm
}

Write-Host ""
Write-Host "Etape suivante : vmconnect localhost DC01, puis Demarrer et APPUYER SUR UNE TOUCHE tout de suite." -ForegroundColor Cyan
