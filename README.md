🇫🇷 [Version française](README.fr.md)

# Hyper-V Active Directory Lab

Two PowerShell scripts that prepare an Active Directory lab on Windows 11 with Hyper-V. They were written for the first Active Directory practical (TP1) of the EPITA Cybersecurity Bachelor, year 2.

What the scripts do:

| Script | What it does |
|---|---|
| `01-activer-hyperv.ps1` | Enables the `Microsoft-Hyper-V-All` feature if needed, and adds the current user to the local *Hyper-V Administrators* group (found by its SID, so it works whatever the system language). A reboot is required afterwards. |
| `02-creer-labo.ps1` | Creates an internal virtual switch `Labo-AD` with gateway `10.10.0.1/24` on the host and a NAT `Labo-AD-NAT` for Internet access, then creates the **DC01** VM. It can also create a **PC01** client VM. |

Each VM is Generation 2, with 2 vCPUs, 4 GB of static memory, a 40 GB dynamic disk, Secure Boot, no automatic checkpoints, and the ISO set as the first boot device. PC01 also gets a virtual TPM 2.0, which Windows 11 requires. Every step is skipped if it already exists, so the script can be re-run safely.

The scripts only build the virtual infrastructure. Installing Windows Server and promoting DC01 to a domain controller are done by hand afterwards.

## Requirements

- Windows 10/11 **Pro, Enterprise or Education** (Hyper-V is not available on Home)
- Hardware virtualisation enabled in the BIOS/UEFI
- An elevated PowerShell session ("Run as administrator")
- A Windows Server ISO (an evaluation version works) and, optionally, a Windows 11 ISO for PC01
- Enough resources: 4 GB of RAM per VM, and disk space under `C:\Hyper-V\Labo-AD` by default

## Usage

1. Enable Hyper-V, then reboot:

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\01-activer-hyperv.ps1
   ```

2. After the reboot, create the network and DC01:

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\02-creer-labo.ps1 -ServerIso "C:\ISO\SERVER_EVAL_x64FRE_fr-fr.iso"
   ```

   To also create the PC01 client:

   ```powershell
   .\02-creer-labo.ps1 -ServerIso "C:\ISO\SERVER_EVAL_x64FRE_fr-fr.iso" -ClientIso "C:\ISO\Windows11.iso" -AvecPC01
   ```

   You can store the VMs elsewhere with `-VmRoot "D:\Hyper-V\Labo-AD"`.

3. Connect to the VM and boot it. Press a key straight away so it starts from the DVD:

   ```powershell
   vmconnect localhost DC01
   ```

## Status

The scripts cover the infrastructure part of TP1 (network and VMs). Script messages and comments are in French.

### TODO
- [ ] Automate the AD DS role installation and the promotion of DC01 (`Install-ADDSForest`).
- [ ] Add a cleanup script that removes the VMs, the switch and the NAT.
