🇬🇧 [English version](README.md)

# Labo Active Directory sous Hyper-V

Deux scripts PowerShell qui préparent un labo Active Directory sous Windows 11 avec Hyper-V. Je les ai écrits pour le premier TP d'Active Directory (TP1) du Bachelor Cybersécurité de l'EPITA, en 2e année.

Ce que font les scripts :

| Script | Ce qu'il fait |
|---|---|
| `01-activer-hyperv.ps1` | Active la fonctionnalité `Microsoft-Hyper-V-All` si besoin, et ajoute l'utilisateur courant au groupe local *Administrateurs Hyper-V* (retrouvé par son SID, donc ça marche quelle que soit la langue du système). Il faut redémarrer ensuite. |
| `02-creer-labo.ps1` | Crée un commutateur virtuel interne `Labo-AD` avec la passerelle `10.10.0.1/24` sur l'hôte et un NAT `Labo-AD-NAT` pour l'accès Internet, puis crée la VM **DC01**. Il peut aussi créer une VM cliente **PC01**. |

Chaque VM est en génération 2, avec 2 vCPU, 4 Go de mémoire statique, un disque dynamique de 40 Go, le Secure Boot, sans points de contrôle automatiques, et l'ISO en premier périphérique de démarrage. PC01 reçoit en plus un TPM 2.0 virtuel, exigé par Windows 11. Chaque étape est sautée si elle existe déjà, donc on peut relancer le script sans risque.

Les scripts ne font que l'infrastructure virtuelle. L'installation de Windows Server et la promotion de DC01 en contrôleur de domaine se font ensuite à la main.

## Prérequis

- Windows 10/11 **Pro, Entreprise ou Éducation** (Hyper-V n'existe pas sur l'édition Famille)
- La virtualisation matérielle activée dans le BIOS/UEFI
- Un PowerShell lancé en administrateur (« Exécuter en tant qu'administrateur »)
- Une ISO de Windows Server (la version d'évaluation suffit) et, si tu veux PC01, une ISO de Windows 11
- Assez de ressources : 4 Go de RAM par VM, et de l'espace disque dans `C:\Hyper-V\Labo-AD` par défaut

## Utilisation

1. Activer Hyper-V, puis redémarrer :

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\01-activer-hyperv.ps1
   ```

2. Après le redémarrage, créer le réseau et DC01 :

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\02-creer-labo.ps1 -ServerIso "C:\ISO\SERVER_EVAL_x64FRE_fr-fr.iso"
   ```

   Pour créer aussi le client PC01 :

   ```powershell
   .\02-creer-labo.ps1 -ServerIso "C:\ISO\SERVER_EVAL_x64FRE_fr-fr.iso" -ClientIso "C:\ISO\Windows11.iso" -AvecPC01
   ```

   Tu peux ranger les VM ailleurs avec `-VmRoot "D:\Hyper-V\Labo-AD"`.

3. Se connecter à la VM et la démarrer. Appuie tout de suite sur une touche pour qu'elle démarre sur le DVD :

   ```powershell
   vmconnect localhost DC01
   ```

## État d'avancement

Les scripts couvrent la partie infrastructure du TP1 (réseau et VM).

### TODO
- [ ] Automatiser l'installation du rôle AD DS et la promotion de DC01 (`Install-ADDSForest`).
- [ ] Ajouter un script de nettoyage qui supprime les VM, le commutateur et le NAT.
