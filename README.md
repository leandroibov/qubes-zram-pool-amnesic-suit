# 🧊 Qubes ZRAM Pool Amnesic Suit

**Live mode, 100% ZRAM (RAM) amnesic environment** for AppVMs and DVMs with primary metadata annihilated in dom0. Enables **hybrid Qubes operation**: run in persistent mode for standard workloads, and switch to amnesic mode for specific VMs requiring zero forensic traces.

---

## ⚠️ Partial Anti-Forensic Warning

This script provides **partial anti-forensic protection**. To achieve **100% anti-forensic security**, the following dom0 directories must be mounted in `tmpfs`:

| Working (tmpfs compatible) | Breaking (cannot use tmpfs) |
|----------------------------|---------------------------|
| `/var/log`                 | `/etc/libvirt/libxl`        |
| `/etc/lvm/archive`         | `/etc/qubes/backup`         |
| `/etc/lvm/backup`          | `~/.local/share`            |
|                            | `/var/lib/qubes`            |
|                            | `/etc/systemd/system`       |

The script successfully mounts the first three without bugs. However, the remaining directories store critical VM metadata (timestamps, creation/modification/access dates) that can correlate online activities even if not primary forensic data — a potential vulnerability for physical adversaries with dom0 password access.

Additional protections:
- ✅ `.bash_history` disabled (root + user)
- ✅ Swap disabled by default when creating/cloning VMs to zram_pool

---

## 📖 What This Script Does

`zram-pool-suit.sh` creates and manages a **ZRAM-based ephemeral storage pool** for Qubes VMs. All clones created here are **100% RAM-resident**, leaving **zero traces on disk** after shutdown/reboot.

Based on: [Qubes Forum - Overlay/Tmpfs/ZRAM Ephemeral VM Guide](https://web.archive.org/web/20260811182210/https://forum.qubes-os.org/t/awesome-overlay-overlayfs-on-tmpfs-zram-block-device-and-plain-dm-crypt-ephemerality-for-vms-and-directories/42662)

---

## 📦 Installation

1. Download the script to an AppVM (e.g., `vault`):
   ```bash
   /home/your_user/zram-pool-suit.sh
   ```

2. Transfer to dom0:
   ```bash
   qvm-run --pass-io vault cat '"/home/your_user/zram-pool-suit.sh"' > /home/your_user/zram-pool-suit.sh
   ```

3. Make executable and run:
   ```bash
   chmod +x /home/your_user/zram-pool-suit.sh
   sudo ./zram-pool-suit.sh
   ```

---

## ⚙️ Recommended Setup Order

| Step | Option | Action |
|------|--------|--------|
| 1️⃣ | **13** | Enable `tmpfs` mounts for `/var/log`, `/etc/lvm/archive`, `/etc/lvm/backup`. **Reboot required.** |
| 2 | **11** | Anti Cold Boot — in the keyboard settings, create a shortcut such as `Control + Alt + Space` for `halt -p` to trigger a rapid shutdown in the event of a physical attack or imminent threat. **Reboot required.** |
| 3 | **1** | Create `zram_pool` (ZRAM amnesic pool for VMs) |
| 4 | **3** | Register VMs in clone registry (or clone manually) |
| 5 | **4** | Create all registered clones. Auto-disables swap + `.bash_history` per session |
| 6 | **17** | After use, randomize timestamps on unprotected directories (Ideal is 5-10 iteration) |

---

## 🎛️ Menu Options Summary

| # | Function | Description |
|---|----------|-------------|
| **1** | Create ZRAM Pool | Initialize amnesic storage pool + log metadata protection |
| **2** | Remove ZRAM Pool | Destroy pool and all associated artifacts |
| **3** | Add VM to Registry | Register source VM for cloning |
| **4** | Create All Clones | Clone all registered VMs to zram_pool (auto-disable swap/history) |
| **5** | Create Single Clone | Clone one registered VM to zram_pool |
| **6** | Remove Entry | Delete one entry from registry |
| **7** | Clear Registry | Wipe entire clone registry |
| **8** | Delete Specific DVM | Remove one VM from zram_pool |
| **9** | Delete All DVMs | Remove all VMs from zram_pool |
| **10** | Check Status | View registry, pool, LVM, and service status |
| **11** | Enable Cold Boot Protection | Install DRACUT RAM-wipe module |
| **12** | Disable Cold Boot Protection | Remove DRACUT RAM-wipe module |
| **13** | Tmpfs Metadata Protection | Mount critical dirs in tmpfs |
| **14** | Revert Tmpfs Optimization | Restore default tmpfs configuration |
| **15** | Disable .bash_history | Clear bash history for root + user |
| **16** | Enable .bash_history | Restore bash history functionality |
| **17** | Metadata Randomizer | Randomize timestamps on non-tmpfs directories |
| **18** | Activate Swap | Enable swap partition/file |
| **19** | Deactivate Swap | Disable swap partition/file |
| **20** | Increase dom0 Memory | Modify GRUB memory limits |
| **21** | Restore GRUB Defaults | Revert GRUB to defaults RAM memory |
| **22** | Check Tmpfs Status | Verify active tmpfs mounts |

---



## Usability and Advantages of Using zram_pool Despite Not Being 100% Anti-Forensic!

**Hybrid operation**: You can use persistent mode alongside some RAM-resident VMs simultaneously without needing to reboot or reconfigure dom0 for persistent VM settings.

You can update dom0, VMs, templates, create additional templates, AppVMs, DVMs, StandaloneVMs, Named DisposableVMs, etc., even while `/var/log`, `/etc/lvm/archive`, and `/etc/lvm/backup` are mounted in tmpfs (RAM), with `.bash_history` disabled and swap off. This already represents a significant gain in metadata annihilation against forensic adversaries!

### Ideal 100% RAM Anti-Forensic Setup (Tails OS & kicksecure Failsafe Mode)

1. Configure anti-cold-boot attack modules in dom0 via DRACUT
2. Boot dom0 100% in RAM
3. Place AppVMs inside `varlibqubes` pool in dom0 — they'll reside 100% in RAM

All logs, metadata, and timestamps are annihilated at shutdown with anti-cold-boot protection configured!

Therefore, the ideal anti-forensic method equivalent to Tails is:
- https://github.com/leandroibov/qubes-os-live-in-ram-tmpfs-anti-forensic

And overlayfs is even more secure:
- https://web.archive.org/web/20260713201009/https://forum.qubes-os.org/t/qubes-os-live-mode-dom0-in-ram-non-persistent-boot-ram-wipe-protection-against-forensics-tails-mode-hardening-dom0-root-read-only-paranoid-security-ephemeral-encryption/38868

### Usability Problems with This Mode

To update dom0, configure VMs, or create new VMs is impossible — you must reboot, reconfigure to return to persistent mode, update/create new VMs/configure, then reboot again to resume 100% RAM usage!

In these situations, dom0 must remain persistent, requiring constant reboots, making usability horrible.

---

## 🔒 Anti-Forensic Limitations (TODO Section)

### Forensic Scan Analysis

Using `qubes-forensic-hunter.sh` to check where AppVM/DVM/Standalone registered in zram_pool or normally gets recorded in dom0.

**Test Subject**: `whonix-tails-failsafe`

Scan checked:
- VM name (partial or full filename matches)
- VM UUID (`a3f2c891-4e6b-4d29-b7a1-9cd5f3e28476`)
- `backup_timestamp` (obtained via `qvm-prefs whonix-tails-failsafe`: `998992877738`)
- Files sent between VMs

---

### `/var/log`
```
/var/log/libvirt/libxl/whonix-tails-failsafe.log         5 occurrences
```

### `/etc/lvm/archive` **(MORE THAN 500 FILES!)**
```
/etc/lvm/archive/qubes_dom0_27752-238367017.vg          2 occurrences
/etc/lvm/archive/qubes_dom0_27604-523883419.vg          2 occurrences
/etc/lvm/archive/qubes_dom0_27668-1628118992.vg         2 occurrences
... (~350+ .vg files continue) ...
/etc/lvm/archive/qubes_dom0_27929-8066256.vg          8 occurrences
/etc/lvm/archive/qubes_dom0_27858-276893239.vg        2 occurrences
/etc/lvm/archive/qubes_dom0_27977-362421532.vg       13 occurrences
```
**(Estimated Total: 350+ files, ~600+ occurrences)**

### `/etc/lvm/backup`
```
/etc/lvm/backup/qubes_dom0                              7 occurrences
```

### `/var/lib/qubes/backup`
```
/var/lib/qubes/backup                                  (referenced)
```

---

## 🔴 OTHER CRITICAL FOLDERS - **NOT HANDLED**

### 📁 `/etc/systemd/system/`
```
/etc/systemd/system/rw.service                         1 occurrence
```

### 📁 `/etc/ephemeral-antiforensic.state`
```
/etc/ephemeral-antiforensic.state                      1 occurrence
```

### 📁 `/etc/libvirt/libxl/`
```
/etc/libvirt/libxl/whonix-tails-failsafe.xml           2 occurrences
```

### 📁 `/etc/qubes/backup/`
```
/etc/qubes/backup/qubes-manager-backup.conf            1 occurrence
```

### 📁 `/home/your_user/`
```
/home/your_user/.xsession-errors                           35 occurrences
/home/your_user/.local/state/wireplumber/stream-properties   1 occurrence
```

### 📁 `/home/your_user/.local/share/applications/` **(38 .desktop FILES)**
```
org.qubes-os.vm._whonix_dtails_dfailsafe.pidgin.desktop                 6
org.qubes-os.vm._whonix_dtails_dfailsafe_dbk.org.kde.kleopatra.desktop  6
org.qubes-os.vm._whonix_dtails_dfailsafe_dbk.org.onionshare.desktop     6
... (35 more desktop entries) ...
```
**(Total: ~240 occurrences)**

### 📁 `/home/your_user/.local/share/desktop-directories/`
```
qubes-vm-directory_whonix_dtails_dfailsafe_dbk.directory   1
qules-vm-directory_whonix_dtails_dfailsafe.directory       1
```

### 📁 `/home/your_user/.local/share/qubes-appmenus/` **(52 FILES)**
```
whonix-tails-failsafe-bk/apps/*.desktop                   (28 files)
whonix-tails-failsafe/apps/*.desktop                      (24 files)
```

### 📁 `/run/udev/data/`
```
/run/udev/data/b252:395                                    2
/run/udev/data/b252:419                                    2
/run/udev/data/b252:418                                    2
/run/udev/data/b252:411                                    2
/run/udev/data/b252:409                                    2
```

### 📁 `/tmp/`
```
/tmp/dom0-content-MIThGW.tmp                              51
```

### 📁 `/var/lib/qubes/`
```
/var/lib/qubes/qubes.xml                                   8
```

### 📁 `/var/log/libvirt/libxl/`
```
/var/log/libvirt/libxl/whonix-tails-failsafe.log           5
```

---

## 📋 SUMMARY BY CATEGORY

| Category | Files | Occurrences | Status |
|----------|-------|-------------|--------|
| **`/etc/lvm/archive/`** | ~350+ | ~600+ | ✅ tmpfs covers |
| **`/etc/lvm/backup/`** | 1 | 7 | ✅ tmpfs covers |
| **`/var/log/`** | 1 | 5 | ✅ tmpfs covers |
| **`/var/lib/qubes/`** | 1 | 8 | ⚠️ Partial |
| **`/etc/libvirt/libxl/`** | 1 | 2 | ⚠️ **Not handled** |
| **`/etc/qubes/backup/`** | 1 | 1 | ⚠️ **Not handled** |
| **`/home/your_user/.local/share/applications/`** | 38 | ~240 | ⚠️ **Not handled** |
| **`/home/your_user/.local/share/qubes-appmenus/`** | 52 | ~300 | ⚠️ **Not handled** |
| **`/home/your_user/.local/share/desktop-directories/`** | 2 | 2 | ⚠️ **Not handled** |
| **`/etc/systemd/`** | 1 | 1 | ⚠️ **Not handled** |
| **`/etc/ephemeral-`** | 1 | 1 | ⚠️ **Not handled** |
| **`/run/udev/data/`** | 5 | 10 | ⚠️ **Not handled** |
| **`/tmp/`** | 1 | 51 | ⚠️ Volatile (RAM) |
| **`/home/your_user/.xsession-errors`** | 1 | 35 | ⚠️ **Not handled** |
| **TOTAL** | **~455+** | **~1270+** | |

---

### UUID & Backup Timestamp Traces

**UUID**: `a3f2c891-4e6b-4d29-b7a1-9cd5f3e28476`

Found in:
```
/etc/libvirt/libxl/whonix-tails-failsafe.xml                                    1 occurrence
/var/log/libvirt/libxl/whonix-tails-failsafe.log                                191 occurrences
/var/lib/qubes/qubes.xml                                                      1 occurrence
/var/lib/qubes/backup/qubes-*.xml                                             100+ occurrences
/tmp/dom0-content-MIThGW.tmp                                                  1 occurrence
```

**Backup Timestamp**: `998992877738`

Found in:
```
/var/lib/qubes/qubes.xml                                                      2 occurrences
/var/lib/qubes/backup/qubes-*.xml                                             100+ occurrences
/home/your_user/998992877738-rastros.txt                                           2 occurrences
/tmp/dom0-content-24P0OU.tmp                                                  1 occurrence
```

*Research ongoing. Contributions and improvements welcome.*

# Doe monero para nos ajudar: (donate XMR)
```bash
87JGuuwXzoMGwQAcSD7cvS7D7iacPpN2f5bVqETbUvCgdEmrPZa12gh5DSiKKRgdU7c5n5x1UvZLj8PQ7AAJSso5CQxgjak
```

**Página oficial de segurança digital:**

https://traderprofissional.com.br/seguranca-digital.aspx


