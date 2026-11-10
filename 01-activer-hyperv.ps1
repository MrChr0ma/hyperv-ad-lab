#Requires -RunAsAdministrator
# TP1 - Etape preliminaire : activer Hyper-V sur Windows 11 Pro.
# Lancer dans un PowerShell "Executer en tant qu'administrateur", puis redemarrer le PC.

$feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
if ($feature.State -eq 'Enabled') {
    Write-Host "Hyper-V est deja active." -ForegroundColor Green
} else {
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All -NoRestart
    Write-Host "Hyper-V active. REDEMARREZ le PC, puis lancez 02-creer-labo.ps1." -ForegroundColor Yellow
}

# Donne a l'utilisateur courant le droit de gerer Hyper-V sans elevation (prend effet apres redemarrage).
$group = (Get-LocalGroup -SID 'S-1-5-32-578').Name   # "Administrateurs Hyper-V", quel que soit la langue
$me = "$env:USERDOMAIN\$env:USERNAME"
if (-not (Get-LocalGroupMember -Group $group -ErrorAction SilentlyContinue | Where-Object Name -eq $me)) {
    Add-LocalGroupMember -Group $group -Member $me
    Write-Host "$me ajoute au groupe '$group'."
}
