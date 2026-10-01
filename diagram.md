# Qubes ZRAM DVM Clone Manager - Function Diagram

## Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                   SECURITY & AMNESIC VM MANAGEMENT SYSTEM                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Main Entry Point

```
┌────────────────────────┐
│   show_menu_main()     │
│      (Main Entry)      │
└────────────────────────┘
             │
             ▼
```

---

## Core Function Sections

### Section 1: ZRAM Pool Functions

```
┌────────────────────────┐
│     zram_pool()        │──► Creates amnesic storage pool
│                        │
│  ┌──────────────────┐  │
│  │zram-pool-create.sh│  │
│  └──────────────────┘  │
└────────────────────────┘
             │
             ▼
┌────────────────────────┐
│amnesic_logs_metadata_  │──► Volatile journald config
│dom0()                  │
│                        │
│  ┌──────────────────┐  │
│  │clean.sh          │  │
│  └──────────────────┘  │
└────────────────────────┘
             │
             ▼
┌────────────────────────┐
│  remove_zram_pool()    │──► Destroy pool & artifacts
└────────────────────────┘
```

---

### Section 2: DVM Clone Manager (Registry)

```
┌────────────────────────────────────────────┐
│              REGISTRY FUNCTIONS            │
├────────────────────────────────────────────┤
│  add_entry()         ► Register VM         │
│  create_all_clones() ► Clone all registered│
│  create_single_clone()► Clone one VM       │
│  remove_entry()      ► Delete entry        │
│  clear_registry()    ► Wipe all entries    │
│  add_more_entries()  ► Wrapper function    │
└────────────────────────────────────────────┘
```

---

### Section 3: Deletion Functions

```
┌────────────────────────┐
│ delete_specific_dvm()  │──► Remove single DVM
└────────────────────────┘

┌────────────────────────┐
│  delete_all_dvms()     │──► Batch remove all
└────────────────────────┘
```

---

### Section 4: Anti-Forensic Tools

```
┌─────────────────────────────────────────┐
│   system_wide_metadata_randomizer()     │
│   (Randomizes timestamps 1-5 years ago) │
├─────────────────────────────────────────┤
│   Sub-functions:                        │
│   ├── randomize_file()                  │
│   ├── randomize_dir()                   │
│   └── is_protected()                    │
└─────────────────────────────────────────┘
             │
             ▼
┌────────────────────────┐
│   anti_cold_boot()     │──► RAM wipe at shutdown
│                        │
│  Embedded Scripts:     │
│  ├── module-setup.sh   │
│  ├── wipe-ram.sh       │
│  ├── ram-wipe-lib.sh   │
│  └── 30-ram-wipe.conf  │
└────────────────────────┘
             │
             ▼
┌────────────────────────┐
│remove_anti_cold_boot() │──► Remove DRACUT module
└────────────────────────┘
```

---

### Section 5: Check & Status Functions

```
┌────────────────────────────────────────────┐
│           STATUS FUNCTIONS                 │
├────────────────────────────────────────────┤
│  check_root()         ► Root validation    │
│  check_status()       ► Registry & stats   │
│  check_zram_amnesic_  ► 9-point security   │
│  status()             │ verification       │
│  check_tmpfs_simple() ► Quick mount status │
└────────────────────────────────────────────┘
```

---

### Section 6: Helper Functions (VM Detection)

```
┌────────────────────────────────────────────┐
│          HELPER FUNCTIONS                  │
├────────────────────────────────────────────┤
│  get_vms_in_zram_pool()                   │
│  └─► Lists VMs in pool (4 methods):       │
│      ├── Method 1: qvm-volume list        │
│      ├── Method 2: /dev/zram_vg devices   │
│      ├── Method 3: findmnt (placeholder)  │
│      └── Method 4: qvm-pool info          │
│                                           │
│  is_vm_in_zram_pool()                     │
│  └─► Boolean check for single VM          │
│                                           │
│  list_all_vms()                           │
│  └─► List all AppVMs/DVMs                 │
└────────────────────────────────────────────┘
```

---

### Section 7: Memory Management

```
┌────────────────────────────────────────────┐
│          MEMORY MANAGEMENT                 │
├────────────────────────────────────────────┤
│  dom0-ram-manager()    ► Set GRUB limits  │
│  restore_grub_default_4g()► Restore config│
│  swap_on()             ► Enable swap      │
│  swap_off()            ► Disable swap     │
└────────────────────────────────────────────┘
```

---

### Section 8: DOM0 Metadata Protection

```
┌────────────────────────────────────────────┐
│        DOM0 METADATA PROTECTION            │
├────────────────────────────────────────────┤
│  dom0_tmpfs_metadata()                    │
│  └─► Add tmpfs mounts to fstab:           │
│      ├── /var/log (50M)                   │
│      ├── /etc/lvm/archive (250M)          │
│      ├── /etc/lvm/backup (250M)           │
│      └── /var/lib/qubes/backup (20M)      │
│                                           │
│  revert_tmpfs_optimization()              │
│  └─► Remove all tmpfs entries             │
│                                           │
│  get_user_dom0()                          │
│  └─► Validate dom0 username               │
│                                           │
│  disable_bash_history()                   │
│  └─► Clear & disable bash history         │
│                                           │
│  enable_bash_history()                    │
│  └─► Restore bash history                 │
└────────────────────────────────────────────┘
```

---

## Embedded Scripts Created by Functions

| Function | Script Created | Purpose |
|----------|----------------|---------|
| `zram_pool()` | `zram-pool.service` | systemd unit for ZRAM pool |
| | `zram-pool-create.sh` | ZRAM device & LVM creation |
| `amnesic_logs_metadata_dom0()` | `journald.conf` | volatile storage mode |
| | `clean.service` | cleanup scheduler |
| | `clean.sh` | log removal script |
| `anti_cold_boot()` | `module-setup.sh` | DRACUT installer |
| | `wipe-ram.sh` | shutdown RAM wipe |
| | `ram-wipe-lib.sh` | utility library |
| | `30-ram-wipe.conf` | DRACUT config |
| `dom0_tmpfs_metadata()` | `tmpfs.conf` | tmpfiles.d directory setup |

---

## Execution Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         WHILE TRUE LOOP                             │
│                                                                     │
│  User Input (0-22) ───► Route to Function Section                   │
│  Option 0 (Exit) ─────► Terminate Program                          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Notes

> ⚠️ **Important**  
> 1. All boxes represent bash functions in this script  
> 2. Nested boxes represent embedded scripts or sub-functions  
> 3. Arrows indicate main flow direction  
> 4. Functions can be called independently or via main menu  
> 5. No hard-coded dependencies - all callable standalone  

---

## Bug Report

```bash
# BUG: remove_zram_pool() does not detect if zram_pool is already removed
#      Still executes removal commands regardless of pool status,
#      but the program continues working normally despite the errors
```

---

*Diagram generated for developer reference and GitHub documentation*
