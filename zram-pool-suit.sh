#!/bin/bash

#zram pool in 100% zram for amnesic VMs in qubes OS!
#zram-pool-suit.sh

#Functions and order 
# control + f #begin funcion_name() and #end funcion_name()

#BUGS AND TREATMENT
#to repair or improve
#repeated functions, look for #2 repeated
# BUG: remove_zram_pool() does not detect if zram_pool is already removed
#      Still executes removal commands regardless of pool status,
#      but the program continues working normally despite the errors

# Global variables block

# check_root()

#----------------------------------------------------------------
# BEGIN SECTION
# Qubes DVM Clone Manager Functions : Separared by category for organization

# get_vms_in_zram_pool()

# is_vm_in_zram_pool()

# list_all_vms()

# add_entry()

# create_all_clones()

# create_single_clone()

# add_more_entries()

# remove_entry()

# clear_registry()

# delete_specific_dvm()

# delete_all_dvms()

# check_status()

# END SECTION
# Qubes DVM Clone Manager Functions : Separared by category for organization
#----------------------------------------------------------------

#****************************************************************
# BEGIN
# Zram Pool Creator, Removal, and Dom0 Anti-Forensic Metadata Defense

# zram_pool()
#   # zram-pool.service (embedded systemd unit)
#   # zram-pool-create.sh (embedded script)

# amnesic_logs_metadata_dom0()
#   # journald.conf (embedded config)
#   # clean.service (embedded systemd unit)
#   # clean.sh (embedded script)

# remove_zram_pool()

# check_zram_amnesic_status()

# create_all_clones()

# create_single_clone() #2 repeated

# remove_entry() #2 repeated

# clear_registry() #2 repeated

# delete_specific_dvm() #2 repeated

# delete_all_dvms() #2 repeated

# check_status() #2 repeated

# END SECTION
# Zram Pool Creator, Removal, and Dom0 Anti-Forensic Metadata Defense
#****************************************************************

#----------------------------------------------------------------
# BEGIN SECTION
# Dom0 Amnesic and anti-forensic metadata defense

# revert_tmpfs_optimization()

# dom0_tmpfs_metadata()
#   # tmpfs.conf (embedded tmpfiles config)
#   # clean.service (embedded systemd unit)
#   # clean.sh (embedded script)

# get_user_dom0()

# clean_bashrc_blocks()

# disable_bash_history()

# enable_bash_history()

# check_tmpfs_simple()

# dom0-ram-manager()

# restore_grub_default_4g()

# swap_on()

# swap_off()

# system_wide_metadata_randomizer()
#   # randomize_file()
#   # randomize_dir()
#   # is_protected()

# END SECTION
# Dom0 Amnesic and anti-forensic metadata defense
#----------------------------------------------------------------

#****************************************************************
# BEGIN SECTION
# Qubes Anti Cold Boot Attack

# anti_cold_boot()
#   # module-setup.sh (embedded dracut module)
#   # wipe-ram-needshutdown.sh (embedded dracut module)
#   # wipe-ram.sh (embedded dracut module)
#   # ram-wipe-lib.sh (embedded library)
#   # 30-ram-wipe.conf (embedded dracut config)

# remove_anti_cold_boot()

# END SECTION
# Qubes Anti Cold Boot Attack
#****************************************************************

# show_menu_main()

# Main while loop block


# Global Variables
REGISTRY_FILE="/etc/qubes/zram-dvm-registry.conf"
ZRAM_POOL="zram_pool"
ZRAM_VG="zram_vg"
QUBES_APPVM_DIR="/var/lib/qubes/appvms"


#begin check_root()
check_root()
{
# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or use sudo."
    sleep 4
    exit 1
fi
}
#end check_root()
check_root

# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# BEGIN
# Qubes DVM Clone Manager Functions : Separared by category for organization
# BEGIN
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================

# =============================================================================
# QUBES DVM CLONE MANAGER - COMPLETELY REWRITTEN WITH POOL DETECTION FIX
# =============================================================================

REGISTRY_FILE="/etc/qubes/zram-dvm-registry.conf"
ZRAM_POOL="zram_pool"
ZRAM_VG="zram_vg"
QUBES_APPVM_DIR="/var/lib/qubes/appvms"

# =============================================================================
# Helper Functions for Pool Detection
# =============================================================================

# Get list of all VMs that are currently in zram_pool by checking LVM devices
#begin get_vms_in_zram_pool()
get_vms_in_zram_pool() {
    local vms=""
    
    # Method 1: Check qvm-volume list for all VMs
    for vm in $(ls "$QUBES_APPVM_DIR" 2>/dev/null); do
        if qvm-volume list "$vm" 2>/dev/null | grep -q "$ZRAM_POOL"; then
            vms="$vms $vm"
        fi
    done
    
    # Method 2: Check LVM devices in /dev/zram_vg (after VM started at least once)
    if [[ -d "/dev/$ZRAM_VG" ]]; then
        for dev in /dev/$ZRAM_VG/*; do
            [[ -b "$dev" ]] || continue
            # Extract VM name from device name like: vm-xxx-private, vm-yyy-volatile
            local dev_name=$(basename "$dev")
            if [[ "$dev_name" =~ ^vm-(.+)-private ]] || [[ "$dev_name" =~ ^vm-(.+)-volatile ]]; then
                local vm_name="${BASH_REMATCH[1]}"
                if ! echo "$vms" | grep -qw "$vm_name"; then
                    vms="$vms $vm_name"
                fi
            fi
        done
    fi
    
    # Method 3: Check with findmnt for mounted pools
    local mounts=$(findmnt -t lvm -n -o TARGET 2>/dev/null | grep "$ZRAM_VG" || true)
    for mount in $mounts; do
        # Extract VM path from mount point like: /var/lib/qubes/dom0/...
        :  # placeholder
    done
    
    # Method 4: Query qvm-pool info directly
    local pool_vms=$(qvm-pool info "$ZRAM_POOL" 2>/dev/null | grep -E "^\s+[a-zA-Z0-9_-]+" | awk '{print $1}' || true)
    for vm in $pool_vms; do
        if ! echo "$vms" | grep -qw "$vm"; then
            vms="$vms $vm"
        fi
    done
    
    echo "$vms" | tr ' ' '\n' | sort -u | grep -v '^$'
}
#end get_vms_in_zram_pool()

# Check if a specific VM is in zram_pool
#begin is_vm_in_zram_pool()
is_vm_in_zram_pool() {
    local vm_name="$1"
    local vms=$(get_vms_in_zram_pool)
    echo "$vms" | grep -qx "$vm_name"
}
#end is_vm_in_zram_pool()

# =============================================================================
# List VMs
# =============================================================================

#begin list_all_vms()
list_all_vms() {
    echo "All AppVMs/DVMs available:"
    echo "--------------------------"
    ls "$QUBES_APPVM_DIR" 2>/dev/null | sort || echo "(none found)"
    echo "--------------------------"
}
#end list_all_vms()

# =============================================================================
# Option 1: Add to Registry
# =============================================================================

#begin add_entry()
add_entry() {
    echo ""
    echo "===== ADD VM TO CLONE REGISTRY ====="
    
    mkdir -p "$(dirname "$REGISTRY_FILE")"
    touch "$REGISTRY_FILE"
    chmod 600 "$REGISTRY_FILE"
    
    list_all_vms
    
    read -p "Source VM name to clone: " SOURCE_VM
    
    if [[ -z "$SOURCE_VM" ]]; then
        echo "[!] ERROR: Source VM name cannot be empty!"
        return 1
    fi
    
    if [[ ! -d "$QUBES_APPVM_DIR/$SOURCE_VM" ]]; then
        echo "[!] ERROR: VM '$SOURCE_VM' not found!"
        return 1
    fi
    
    read -p "Target clone name: " TARGET_NAME
    
    if [[ -z "$TARGET_NAME" ]]; then
        echo "[!] ERROR: Target name cannot be empty!"
        return 1
    fi
    
    if grep -q "^${TARGET_NAME}:" "$REGISTRY_FILE" 2>/dev/null; then
        echo "[!] ERROR: '$TARGET_NAME' already in registry!"
        return 1
    fi
    
    echo "Available VMs for NetVM selection:"
    echo "-----------------------------------"
    ls "$QUBES_APPVM_DIR" 2>/dev/null | sort
    echo "-----------------------------------"
    echo "Press ENTER for NO network access"
    echo "-----------------------------------"
    
    read -p "Select NetVM: " NET_VM
    
    if [[ -z "$NET_VM" ]]; then
        NET_VM="none"
        echo "[i] No NetVM selected — clone will have no network."
    else
        if [[ ! -d "$QUBES_APPVM_DIR/$NET_VM" ]]; then
            echo "[!] ERROR: NetVM '$NET_VM' not found!"
            return 1
        fi
    fi
    
    echo "${TARGET_NAME}:${SOURCE_VM}:${NET_VM}" >> "$REGISTRY_FILE"
    echo "[+] Added: $TARGET_NAME <- $SOURCE_VM (NetVM: $NET_VM)"
}
#end add_entry()

# =============================================================================
# Option 2: Create All Clones (WITH START/SHUTDOWN FOR REGISTRATION)
# =============================================================================

create_all_clones() {
    echo ""
    echo "===== CREATE ALL REGISTERED CLONES ====="
    
    if [[ ! -s "$REGISTRY_FILE" ]]; then
        echo "[!] Registry is empty. Nothing to clone!"
        return 1
    fi
    
    echo "Entries in registry:"
    cat "$REGISTRY_FILE" | nl
    echo ""
    
    local success=0
    local fail=0
    local skipped=0
    local start_fail=0
    
    while IFS=: read -r TARGET SOURCE NET; do
        if [[ -z "$TARGET" ]]; then continue; fi
        
        if qvm-check "$TARGET" >/dev/null 2>&1; then
            echo "[SKIP] '$TARGET' already exists! (will not clone again)"
            ((skipped++)) || true
            continue
        fi
        
        echo "[*] Cloning: $SOURCE -> $TARGET (pool: $ZRAM_POOL, NetVM: $NET)"
        
        if qvm-clone -P="$ZRAM_POOL" "$SOURCE" "$TARGET" 2>/dev/null; then
            if [[ "$NET" == "none" ]]; then
                qvm-prefs "$TARGET" netvm ""
                echo "[i] NetVM set to: NONE (no network)"
            else
                qvm-prefs "$TARGET" netvm "$NET"
                echo "[i] NetVM set to: $NET"
            fi
            
            qvm-prefs "$TARGET" template_for_dispvms True
            
            # Start and shutdown to register volumes in LVM
            echo "[*] Starting VM to register volumes in zram_pool..."
            if qvm-start "$TARGET" 2>/dev/null; then
                echo "[i] VM started successfully"
                sleep 5
                
                echo "[*] Shutting down VM..."
                if qvm-shutdown --wait "$TARGET" 2>/dev/null; then
                    echo "[OK] VM shut down - volumes registered in /dev/$ZRAM_VG"
                    ((success++)) || true
                else
                    echo "[WARN] Shutdown failed! Trying force kill..."
                    qvm-kill "$TARGET" 2>/dev/null || true
                    sleep 2
                    echo "[WARN] Volume registration may be incomplete!"
                    ((success++)) || true
                    ((start_fail++)) || true
                fi
            else
                echo "[WARN] Failed to start VM! Volume registration may be incomplete!"
                echo "[i] Run 'qvm-start $TARGET' manually later to register volumes"
                ((success++)) || true
                ((start_fail++)) || true
            fi
        else
            echo "[FAIL] Clone command failed!"
            ((fail++)) || true
        fi
    done < "$REGISTRY_FILE"
    
    echo ""
    echo "========================================"
    echo "Results:"
    echo "  Created:         $success"
    echo "  Skipped:         $skipped (already existed)"
    echo "  Failed:          $fail"
    echo "  Start issues:    $start_fail (check volume registration)"
    echo "========================================"
}


# =============================================================================
# Option 2.1: Create Single Registered Clone
# =============================================================================
# begin create_single_clone() #repeated function #need to be treated...
create_single_clone() {
    echo ""
    echo "===== CREATE SINGLE REGISTERED CLONE ====="
    
    if [[ ! -s "$REGISTRY_FILE" ]]; then
        echo "[!] Registry is empty. Nothing to clone!"
        return 1
    fi
    
    echo "Registered entries:"
    echo "--------------------"
    cat "$REGISTRY_FILE" | nl
    echo "--------------------"
    echo ""
    
    read -p "Enter entry number to clone: " ENTRY_NUM
    
    if ! [[ "$ENTRY_NUM" =~ ^[0-9]+$ ]]; then
        echo "[!] ERROR: Invalid number!"
        return 1
    fi
    
    # Extract specific line from registry
    SELECTED_LINE=$(sed -n "${ENTRY_NUM}p" "$REGISTRY_FILE")
    
    if [[ -z "$SELECTED_LINE" ]]; then
        echo "[!] ERROR: Entry $ENTRY_NUM does not exist!"
        return 1
    fi
    
    # Parse the selected entry
    IFS=: read -r TARGET SOURCE NET <<< "$SELECTED_LINE"
    
    if [[ -z "$TARGET" || -z "$SOURCE" ]]; then
        echo "[!] ERROR: Invalid entry format!"
        return 1
    fi
    
    # Check if already exists
    if qvm-check "$TARGET" >/dev/null 2>&1; then
        echo "[!] ERROR: '$TARGET' already exists! Cannot clone again."
        echo "[i] Remove it first or choose a different entry."
        return 1
    fi
    
    echo ""
    echo "[*] Cloning: $SOURCE -> $TARGET (pool: $ZRAM_POOL)"
    echo "[*] NetVM: $NET"
    echo "------------------------------------------------------"
    
    # Step 1: Clone with pool
    if qvm-clone -P="$ZRAM_POOL" "$SOURCE" "$TARGET" 2>/dev/null; then
        echo "[OK] VM cloned successfully"
        
        # Step 2: Set NetVM
        if [[ "$NET" == "none" ]]; then
            qvm-prefs "$TARGET" netvm ""
            echo "[i] NetVM set to: NONE (no network)"
        else
            qvm-prefs "$TARGET" netvm "$NET"
            echo "[i] NetVM set to: $NET"
        fi
        
        # Step 3: Mark as DVM Template
        qvm-prefs "$TARGET" template_for_dispvms True
        echo "[i] Marked as DVM Template for Disposable VMs"
        
        # Step 4: Start and shutdown to register volumes in LVM
        echo ""
        echo "[*] Starting VM to register volumes in zram_pool..."
        if qvm-start "$TARGET" 2>/dev/null; then
            echo "[i] VM started successfully"
            sleep 5
            
            echo "[*] Shutting down VM..."
            if qvm-shutdown --wait "$TARGET" 2>/dev/null; then
                echo "[OK] VM shut down - volumes registered in /dev/$ZRAM_VG"
                echo ""
                echo "========================================"
                echo "[SUCCESS] Clone created successfully!"
                echo "========================================"
            else
                echo "[WARN] Shutdown failed! Trying force kill..."
                qvm-kill "$TARGET" 2>/dev/null || true
                sleep 2
                echo "[WARN] Volume registration may be incomplete!"
                echo ""
                echo "========================================"
                echo "[SUCCESS] Clone created (partial registration)"
                echo "========================================"
            fi
        else
            echo "[WARN] Failed to start VM! Volume registration may be incomplete!"
            echo "[i] Run 'qvm-start $TARGET' manually later to register volumes"
            echo ""
            echo "========================================"
            echo "[SUCCESS] Clone created (manual start needed)"
            echo "========================================"
        fi
    else
        echo "[FAIL] Clone command failed!"
        echo ""
        echo "========================================"
        echo "[FAILED] Could not create clone"
        echo "========================================"
        return 1
    fi
}
#end create_single_clone()

# =============================================================================
# Option 3: Add More Entries
# =============================================================================

add_more_entries() {
    add_entry
}

# =============================================================================
# Option 4: Remove Entry
# =============================================================================
#begin remove_entry() #repeated function
remove_entry() {
    echo ""
    echo "===== REMOVE ENTRY FROM REGISTRY ====="
    
    if [[ ! -s "$REGISTRY_FILE" ]]; then
        echo "[!] Registry is empty!"
        return 1
    fi
    
    echo "Current entries:"
    cat "$REGISTRY_FILE" | nl
    echo ""
    
    read -p "Enter entry number to remove: " NUM
    
    if ! [[ "$NUM" =~ ^[0-9]+$ ]]; then
        echo "[!] Invalid number!"
        return 1
    fi
    
    sed -i "${NUM}d" "$REGISTRY_FILE"
    echo "[+] Entry removed!"
}
#end remove_entry()

# =============================================================================
# Option 5: Clear Registry
# =============================================================================
#begin clear_registry() # function repeated
clear_registry() {
    echo ""
    echo "===== CLEAR ENTIRE REGISTRY ====="
    
    if [[ ! -s "$REGISTRY_FILE" ]]; then
        echo "[!] Registry is already empty!"
        return 1
    fi
    
    read -p "Are you sure? (yes/no): " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "[!] Cancelled!"
        return 1
    fi
    
    : > "$REGISTRY_FILE"
    echo "[+] Registry cleared!"
}
#end clear_registry()

# =============================================================================
# Option 6: Delete Specific DVM from zram_pool (DETECTION FIXED)
# =============================================================================

#begin delete_specific_dvm() #funcion repeated
delete_specific_dvm() {
    echo ""
    echo "===== DELETE SPECIFIC DVM FROM zram_pool ====="
    
    echo "Detecting VMs in zram_pool using multiple methods..."
    echo "------------------------------------------------------"
    
    local vms=$(get_vms_in_zram_pool)
    
    if [[ -z "$vms" ]]; then
        echo "[!] No VMs detected in zram_pool!"
        echo "[i] Make sure at least one VM was started after cloning"
        echo "[i] Try running 'qvm-start <vm-name>' first, then try again"
        return 1
    fi
    
    echo "VMs found in zram_pool:"
    echo "$vms" | nl
    echo ""
    echo "Note: If a VM doesn't appear here but exists,"
    echo "it hasn't been started since being added to the pool."
    echo "Try starting it: qvm-start <vm-name>"
    echo "------------------------------------------------------"
    echo ""
    
    read -p "Enter DVM name to delete: " VM_NAME
    
    if [[ -z "$VM_NAME" ]]; then
        echo "[!] ERROR: VM name cannot be empty!"
        return 1
    fi
    
    if ! qvm-check "$VM_NAME" >/dev/null 2>&1; then
        echo "[!] ERROR: VM '$VM_NAME' not found in Qubes!"
        return 1
    fi
    
    if ! echo "$vms" | grep -qx "$VM_NAME"; then
        echo "[WARN] '$VM_NAME' was not detected in zram_pool by this script,"
        echo "but will still try to delete it. It may not be in the correct pool."
        read -p "Continue anyway? (yes/no): " CONFIRM
        if [[ "$CONFIRM" != "yes" ]]; then
            echo "[!] Cancelled!"
            return 1
        fi
    fi
    
    read -p "Delete '$VM_NAME'? (yes/no): " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "[!] Cancelled!"
        return 1
    fi
    
    # Shutdown if running
    if qvm-check --running "$VM_NAME" >/dev/null 2>&1; then
        echo "[*] Shutting down $VM_NAME..."
        qvm-shutdown --wait "$VM_NAME" 2>/dev/null || qvm-kill "$VM_NAME" 2>/dev/null
        sleep 2
    fi
    
    qvm-remove --force "$VM_NAME"
    echo "[+] '$VM_NAME' deleted!"
}
#end delete_specific_dvm()

# =============================================================================
# Option 7: Delete ALL DVMs from zram_pool (DETECTION FIXED)
# =============================================================================

#begin delete_all_dvms() #funcion repeated
delete_all_dvms() {
    echo ""
    echo "===== DELETE ALL DVMS FROM zram_pool ====="
    
    echo "Detecting VMs in zram_pool using multiple methods..."
    echo "------------------------------------------------------"
    
    local vms=$(get_vms_in_zram_pool)
    
    if [[ -z "$vms" ]]; then
        echo "[!] No VMs detected in zram_pool!"
        echo "[i] Make sure at least one VM was started after cloning"
        echo "[i] Try running 'qvm-start <vm-name>' first, then try again"
        return 1
    fi
    
    echo "VMs found in zram_pool that will be DELETED:"
    echo "$vms" | nl
    echo "------------------------------------------------------"
    echo ""
    
    read -p "DELETE ALL THESE DVMS? (yes/no): " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "[!] Cancelled!"
        return 1
    fi
    
    local count=0
    
    for vm in $vms; do
        echo "Processing: $vm"
        
        # Shutdown if running
        if qvm-check --running "$vm" >/dev/null 2>&1; then
            echo "  [*] Shutting down..."
            qvm-shutdown --wait "$vm" 2>/dev/null || qvm-kill "$vm" 2>/dev/null
            sleep 2
        fi
        
        qvm-remove --force "$vm"
        ((count++)) || true
    done
    
    if [[ $count -eq 0 ]]; then
        echo "[i] No VMs were deleted (none found or all already gone)"
    else
        echo "[+] Deleted $count VM(s) from zram_pool!"
    fi
}
#end delete_all_dvms()

# =============================================================================
# Option 8: Check Status
# =============================================================================

#begin check_status() # funcion repeated
check_status() {
    echo ""
    echo "===== REGISTRY & zram_pool STATUS ====="
    
    echo "Registry entries:"
    echo "------------------"
    if [[ -s "$REGISTRY_FILE" ]]; then
        cat "$REGISTRY_FILE" | nl
    else
        echo "  [Empty]"
    fi
    echo ""
    
    echo "VMs detected in zram_pool:"
    echo "--------------------------"
    local pool_count=0
    
    local vms=$(get_vms_in_zram_pool)
    
    if [[ -z "$vms" ]]; then
        echo "  [None detected]"
        echo "  Note: VMs must be started at least once to be visible in /dev/$ZRAM_VG"
    else
        for vm in $vms; do
            local netvm=$(qvm-prefs "$vm" netvm 2>/dev/null || echo "None")
            local disp=$(qvm-prefs "$vm" template_for_dispvms 2>/dev/null || echo "False")
            local pool=$(qvm-prefs "$vm" default_volume_pool 2>/dev/null || echo "Unknown")
            
            echo "  $vm"
            echo "    ├─ Pool: $pool"
            echo "    ├─ NetVM: $netvm"
            echo "    └─ DispTemplate: $disp"
            ((pool_count++)) || true
        done
    fi
    echo "--------------------------"
    echo ""
    
    echo "LVM Devices in /dev/$ZRAM_VG:"
    echo "------------------------------"
    if [[ -d "/dev/$ZRAM_VG" ]]; then
        ls /dev/$ZRAM_VG/ 2>/dev/null | head -20 || echo "  [Cannot read]"
    else
        echo "  [Directory does not exist]"
    fi
    echo "------------------------------"
    echo ""

echo "ZRAM pool size and DVM usage"
zramctl
    echo

    echo "Summary:"
    echo "  Registry entries: $(wc -l < "$REGISTRY_FILE" 2>/dev/null | tr -d ' ' || echo 0)"
    echo "  Active clones detected: $pool_count"
    echo "  ZRAM pool: $ZRAM_POOL"
}
#end check_status()


# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# FINISHED
# Qubes DVM Clone Manager Functions : Separared by category for organization
# FINISHED
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================




# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# BEGIN
# Zram Pool Creator, Removal, and Dom0 Anti-Forensic Metadata Defense
# BEGIN
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************

zram_pool()
{
echo ""
echo "==========================================================="
echo "  [!] ZRAM AMNESIC POOL - WARNING"
echo "==========================================================="
echo "[i] Recommendation: reserve 50-60% of your total RAM"
echo "    Example: if you have 16GB -> use 8G or 10G"
echo ""
echo "Expected format: 4G, 6G, 8G, 10G, 12G, etc."
echo ""
read -p "Enter ZRAM pool size (e.g. 4G): " zram_pool_size

if [ -z "$zram_pool_size" ]; then
    echo "[!] No size entered. Aborting."
    exit 1
fi

echo ""
echo "[*] ZRAM_SIZE set to: ${zram_pool_size}"
echo ""

sudo tee /etc/systemd/system/zram-pool.service << 'EOF'
[Unit]
Description=ZRAM Ephemeral Pool
After=qubesd.service
Before=qubes-vm@sys-net.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/zram-pool-create.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF


sudo tee /usr/local/bin/zram-pool-create.sh << 'EOF'
#!/bin/bash
set -euo pipefail

POOL_NAME="zram_pool"
ZRAM_SIZE="$zram_pool_size"
VG_NAME="zram_vg"

EXTRA_VMS=(
    #"whonix"
    #"sys-whonix"
)

ROOT_DEV=$(findmnt -n -o SOURCE / 2>/dev/null || echo "")

if echo "$ROOT_DEV" | grep -qE "(overlay|/dev/zram0)"; then
    echo "[*] Detected amnesiac mode: $ROOT_DEV"
    echo "    Cleaning up old VMs..."

    for vm in $(qvm-ls --raw-list --running 2>/dev/null); do
        if qvm-volume list "$vm" 2>/dev/null | grep -q "${POOL_NAME}"; then
            echo "    -> Stopping: $vm"
            qvm-shutdown --wait --timeout 10 "$vm" 2>/dev/null || \
                qvm-kill "$vm" 2>/dev/null || true
        fi
    done

    for vm in $(qvm-ls --raw-list 2>/dev/null); do
        if qvm-volume list "$vm" 2>/dev/null | grep -q "${POOL_NAME}"; then
            echo "    -> Removing: $vm"
            qvm-remove --force "$vm" 2>/dev/null || true
        fi
    done

    qvm-pool remove "${POOL_NAME}" 2>/dev/null || true
    vgchange -an "${VG_NAME}" 2>/dev/null || true
    vgremove -f "${VG_NAME}" 2>/dev/null || true

    for dev in /dev/zram*; do
        [ -b "$dev" ] || continue
        zramctl --reset "$dev" 2>/dev/null || true
    done

    echo "[+] Cleanup completed."
    exit 0
fi

if [ "$EUID" -ne 0 ]; then
    echo "[!] Root privileges required"
    exit 1
fi

echo "[*] Creating zram device (${ZRAM_SIZE})..."
modprobe zram 2>/dev/null || true

ZRAM_DEV=""
for dev in /dev/zram*; do
    [ -b "$dev" ] || continue
    if ! zramctl "$dev" 2>/dev/null | grep -q "mounted\|active"; then
        ZRAM_DEV="$dev"
        break
    fi
done

if [ -z "$ZRAM_DEV" ]; then
    ZRAM_DEV=$(zramctl --find --size "$ZRAM_SIZE" --algorithm lz4)
else
    zramctl --reset "$ZRAM_DEV" 2>/dev/null || true
    ZRAM_DEV=$(zramctl --find --size "$ZRAM_SIZE" --algorithm lz4)
fi

echo "    Device: $ZRAM_DEV"

echo "[*] Removing VMs from pool ${POOL_NAME}..."
for vm in $(qvm-ls --raw-list --running 2>/dev/null); do
    if qvm-volume list "$vm" 2>/dev/null | grep -q "${POOL_NAME}"; then
        echo "    -> Stopping: $vm"
        qvm-shutdown --wait --timeout 30 "$vm" 2>/dev/null || {
            echo "    -> Force killing: $vm"
            qvm-kill "$vm" 2>/dev/null || true
        }
    fi
done

for vm in $(qvm-ls --raw-list 2>/dev/null); do
    if qvm-volume list "$vm" 2>/dev/null | grep -q "${POOL_NAME}"; then
        echo "    -> Removing: $vm"
        qvm-remove --force "$vm" 2>/dev/null || true
    fi
done

echo "[*] Cleaning up old infrastructure..."
qvm-pool remove "${POOL_NAME}" 2>/dev/null || true
vgchange -an "${VG_NAME}" 2>/dev/null || true
vgremove -f "${VG_NAME}" 2>/dev/null || true

# Detach old loops on zram
for loopdev in $(losetup -a 2>/dev/null | grep "$ZRAM_DEV" | cut -d: -f1); do
    echo "    -> Detaching loop: $loopdev"
    losetup -d "$loopdev" 2>/dev/null || true
done

echo "[*] Creating loop on ${ZRAM_DEV}..."
LOOP_DEV=$(losetup -f --show "$ZRAM_DEV")
echo "    Loop: $LOOP_DEV"

echo "[*] Creating LVM on ${LOOP_DEV}..."
pvcreate -q "$LOOP_DEV"
vgcreate -q "${VG_NAME}" "$LOOP_DEV"
lvcreate -q -T -n "thin_pool" -l +100%FREE "${VG_NAME}"

echo "[*] Registering pool ${POOL_NAME}..."
if qvm-pool list 2>/dev/null | grep -q "^${POOL_NAME}"; then
    qvm-pool remove "${POOL_NAME}" 2>/dev/null || true
    sleep 1
fi

qvm-pool add "${POOL_NAME}" lvm_thin --option volume_group="${VG_NAME}" --option thin_pool=thin_pool 2>/dev/null || \
qvm-pool add "${POOL_NAME}" lvm_thin -o volume_group="${VG_NAME}",thin_pool=thin_pool

echo "    Pool created:"
qvm-pool info "${POOL_NAME}"
EOF

# [!] Modifying /usr/local/bin/zram-pool-create.sh: replacing $zram_pool_size with real size
sed -i 's/ZRAM_SIZE="\$zram_pool_size"/ZRAM_SIZE="'$zram_pool_size'"/' /usr/local/bin/zram-pool-create.sh

sudo chmod +x /usr/local/bin/zram-pool-create.sh
echo "ZRAM pool activated"
echo "Add only DVMs to it for amnesic anti-forensic mode"
echo "AppVMs do not work — never create an AppVM inside zram_pool"
sudo systemctl daemon-reload
sudo systemctl enable --now zram-pool.service
}

amnesic_logs_metadata_dom0()
{
sudo tee /etc/systemd/journald.conf << EOF
[Journal]
Storage=volatile
EOF
sudo systemctl restart systemd-journald

mkdir -p /etc/systemd/system/
sudo tee /etc/systemd/system/clean.service << 'EOF'
[Unit]
Description=Clean logs of removed Qubes VMs
After=qubesd.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/clean.sh
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF

sudo tee /usr/local/bin/clean.sh << 'EOF'
#!/bin/bash

set -euo pipefail

readonly LOGDIR='/var/log'
readonly TEMPDIR_ROOT='/home/user/tmp'
readonly MENUDIR='/home/user/.config/menus/applications-merged'


existing_qubes=$(qvm-ls --fields=name --raw-data | sort)


all_qube_names=''


all_qube_names+=$(find "${LOGDIR}/libvirt/libxl/" \
    -type f \
    -regextype posix-egrep \
    -regex '.*\.log((\.old)|(-[0-9]{8}))?(\.gz)?$' \
    -exec basename "{}" \; \
    | sed -r 's/\.log((\.old)|(-[0-9]{8}))?(\.gz)?$//g' \
    | sed -r 's/^(guid|qrexec|qubesdb)\.//g' \
    | sort | uniq)$'\n'


all_qube_names+=$(find "${LOGDIR}/qubes/" \
    -type f \
    -regextype posix-egrep \
    -regex '.*\.log((\.old)|(-[0-9]{8}))?(\.gz)?$' \
    -exec basename "{}" \; \
    | sed -r 's/\.log((\.old)|(-[0-9]{8}))?(\.gz)?$//g' \
    | sed -r 's/^(guid|qrexec|qubesdb)\.//g' \
    | sort | uniq)$'\n'


all_qube_names+=$(find "${LOGDIR}/xen/console/" \
    -type f \
    -regextype posix-egrep \
    -regex '.*\/guest-.*\.log((\.old)|(-[0-9]{8}))?(\.gz)?$' \
    -exec basename "{}" \; \
    | sed -r 's/\.log((\.old)|(-[0-9]{8}))?(\.gz)?$//g' \
    | sed -r 's/^guest-//g' \
    | sort | uniq)$'\n'


set +e
ram_pools=$(qvm-pool list | grep -Eio '^ram_pool_[^ ]+' | sort | uniq)
set -e
all_qube_names+=$(echo "${ram_pools}" | sed -r 's/^ram_pool_//g')$'\n'


if [ -d "${TEMPDIR_ROOT}" ]; then
    all_qube_names+=$(find "${TEMPDIR_ROOT}" \
        -mindepth 1 -maxdepth 1 -type d \
        -exec basename "{}" \; \
        | sort | uniq)$'\n'
fi


all_qube_names+=$(find "${MENUDIR}" \
    -regextype posix-egrep \
    -regex '.*\/user-qubes-.*\.menu$' \
    -exec basename "{}" \; \
    | sed -r 's/\.menu$//g' \
    | sed -r 's/^user-qubes-(disp)?vm-directory(_|-)//g' \
    | sort | uniq)$'\n'


all_qube_names=$(echo "${all_qube_names}" \
    | sed -r 's/^(Domain-0|libxl-driver)$//g' \
    | sed -r '/^\s*$/d' \
    | sort | uniq)


set +e
qubes_to_remove=$(diff --new-line-format='' --unchanged-line-format='' \
    <(echo "${all_qube_names}") <(echo "${existing_qubes}") \
    | sed -r '/^\s*$/d')
set -e


for qube_name in ${qubes_to_remove}; do
    decoded_qube_name=$(echo "${qube_name}" \
        | sed -r 's/_d/-/g' \
        | sed -r 's/_u/_/g')

    log_pattern="${qube_name}\.log((\.old)|(-[0-9]{8}))?(\.gz)?"
    menu_pattern="user-qubes-(disp)?vm-directory(_|-)${qube_name}\.menu"

    declare -A targets
    targets=(["${LOGDIR}/libvirt/libxl"]="${log_pattern}"
             ["${LOGDIR}/qubes"]="((guid|qrexec|qubesdb)\.)?${log_pattern}"
             ["${LOGDIR}/xen/console"]="guest-${log_pattern}"
             ["${MENUDIR}"]="${menu_pattern}")

    if [ -d "${TEMPDIR_ROOT}" ]; then
        targets+=("${TEMPDIR_ROOT}"="${qube_name}")
    fi

    for search_dir in "${!targets[@]}"; do
        mapfile -d $'\0' found_files < <(find "${search_dir}" \
            -regextype posix-egrep \
            -regex ".*\/${targets[${search_dir}]}$" \
            -print0)
        for file in "${found_files[@]}"; do
            [ -z "${file}" ] && continue
            rm -rf "${file}"
        done
    done
done


for pool_name in ${ram_pools}; do
    qube_name=$(echo "${pool_name}" | sed -r 's/^ram_pool_//')
    if ! echo "${existing_qubes}" | grep -qx "${qube_name}"; then
        pool_mountpoint=$(qvm-pool info "${pool_name}" \
            | grep -E '^dir_path' \
            | sed -r 's/^dir_path\s+//g')
        qvm-pool remove "${pool_name}" 2>/dev/null || true
        umount "${pool_mountpoint}" 2>/dev/null || true
        rm -rf "${pool_mountpoint}" 2>/dev/null || true
    fi
done

find "${LOGDIR}/qubes/" -maxdepth 1 -type f -name '*.log.old' -delete
EOF

sudo chmod +x /usr/local/bin/clean.sh
echo "Turn on amnesic logs and metadata in dom0 for zram-pool DVMs"
sudo systemctl daemon-reload
sudo systemctl enable clean.service
}


remove_zram_pool()
{
    echo "==========================================================="
    echo "  WARNING: ZRAM POOL DELETION"
    echo "==========================================================="
    echo ""
    echo "This will DELETE:"
    echo "  - The entire zram_pool volume group"
    echo "  - ALL DVMs and AppVMs stored in zram_pool"
    echo "  - Associated volumes and configurations"
    echo ""
    echo "[!] THIS ACTION IS IRREVERSIBLE!"
    echo ""
    
    read -p "Are you sure you want to continue? (yes/no): " CONFIRM
    
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "[!] Operation cancelled. Returning to menu..."
        return 1
    fi
    
    echo "[*] Proceeding with zram_pool deletion..."
    echo ""
# Step 1: Stop and disable the systemd service
sudo systemctl stop zram-pool.service
sudo systemctl disable zram-pool.service

# Step 2: Remove all VMs from zram_pool
echo "[*] Removing VMs from zram_pool..."
for vm in $(qvm-ls --raw-list 2>/dev/null); do
    if qvm-volume list "$vm" 2>/dev/null | grep -q "zram_pool"; then
        echo "    -> Removing: $vm"
        qvm-kill "$vm" 2>/dev/null || true
        sleep 1
        qvm-remove --force "$vm" 2>/dev/null || true
        sleep 1
    fi
done

# Step 3: Remove the Qubes storage pool
echo "[*] Removing zram_pool..."
qvm-pool remove zram_pool 2>/dev/null || true

# Step 4: Deactivate and remove LVM volume group
echo "[*] Cleaning up LVM..."
vgchange -an zram_vg 2>/dev/null || true
vgremove -f zram_vg 2>/dev/null || true

# Step 5: Detach loop device from zram
echo "[*] Detaching loop devices..."
for loopdev in $(losetup -a 2>/dev/null | grep "/dev/zram" | cut -d: -f1); do
    echo "    -> Detaching: $loopdev"
    losetup -d "$loopdev" 2>/dev/null || true
done

# Step 6: Reset zram device
echo "[*] Resetting zram device..."
for dev in /dev/zram*; do
    [ -b "$dev" ] || continue
    zramctl --reset "$dev" 2>/dev/null || true
done

echo "[+] zram pool completely removed. Reboot to clear all traces from memory."
}

# Function: Check ZRAM Pool and DVM Memory Status
check_zram_amnesic_status()
{
echo "=========================================="
echo "ZRAM AMNESIC POOL STATUS CHECK"
echo "=========================================="
echo ""

# 1. ZRAM DEVICE CHECK
echo "========== 1. ZRAM DEVICE CHECK =========="
echo "ZRAM devices present:"
zramctl 2>/dev/null || echo "  [!] No ZRAM devices found!"
echo ""

echo "ZRAM compression algorithm:"
cat /sys/block/zram0/comp_algorithm 2>/dev/null || echo "  [!] Cannot read zram0 algorithm"
echo ""

# 2. ZRAM POOL REGISTRY CHECK
echo "========== 2. QUBES STORAGE POOL CHECK =========="
echo "Available pools in Qubes:"
qvm-pool list 2>/dev/null || echo "  [!] qvm-pool command failed"
echo ""

echo "zram_pool details:"
qvm-pool info zram_pool 2>/dev/null || echo "  [!] zram_pool not found or not accessible"
echo ""

# 3. DVM VOLUME LOCATION CHECK
echo "========== 3. DVM VOLUME LOCATION CHECK =========="
echo "All DVMs and their volume locations:"
for vm in $(qvm-ls --raw-list 2>/dev/null); do
    volumes=$(qvm-volume list "$vm" 2>/dev/null | grep "root\|private" | awk '{print $2}' | tr '\n' ' ')
    echo "  $vm: $volumes"
done
echo ""

echo "Checking which VMs use zram_pool:"
for vm in $(qvm-ls --raw-list 2>/dev/null); do
    if qvm-volume list "$vm" 2>/dev/null | grep -q "zram_pool"; then
        echo "  [OK] $vm uses zram_pool"
    fi
done
echo ""

# 4. TMPFS MOUNTS CHECK (for ZRAM-backed pools)
echo "========== 4. TMPFS/ZRAM MOUNT CHECK =========="
echo "All tmpfs filesystems (includes ZRAM):"
mount | grep tmpfs | grep -v "snapshots" || echo "  [!] No tmpfs mounts found"
echo ""

echo "Detailed findmnt for tmpfs:"
findmnt -t tmpfs -o TARGET,SOURCE,FSTYPE,SIZE 2>/dev/null || echo "  [!] findmnt failed"
echo ""

# 5. LVM THIN POOL CHECK
echo "========== 5. LVM THIN POOL CHECK =========="
echo "Volume groups:"
vgdisplay 2>/dev/null | grep -E "VG Name|VG Size|Free" || echo "  [!] Cannot read VG info"
echo ""

echo "Logical volumes:"
lvdisplay 2>/dev/null | grep -E "LV Name|LV Path|LV Size" | head -20 || echo "  [!] Cannot read LV info"
echo ""

# 6. SERVICE STATUS CHECK
echo "========== 6. SYSTEMD SERVICE STATUS =========="
echo "ZRAM pool service:"
systemctl is-active zram-pool.service 2>/dev/null || echo "  [!] Service not active or not found"
echo ""

echo "Clean service (log cleaning):"
systemctl is-active clean.service 2>/dev/null || echo "  [!] Service not active or not found"
echo ""

# 7. JOURNALD CONFIGURATION CHECK
echo "========== 7. JOURNALD VOLATILE CHECK =========="
echo "Current journald storage setting:"
grep -E "^Storage=" /etc/systemd/journald.conf 2>/dev/null || echo "  [!] journald.conf not modified or missing"
echo ""

echo "Journald actual storage (runtime):"
journalctl -b | head -5 2>/dev/null && echo "  [INFO] Journal is running (storage may be volatile)" || echo "  [!] Cannot read journal"
echo ""

# 8. MEMORY USAGE SUMMARY
echo "========== 8. MEMORY USAGE SUMMARY =========="
echo "Total RAM and swap:"
free -h 2>/dev/null || echo "  [!] free command failed"
echo ""

# 9. VERIFICATION SUMMARY
echo "========== 9. VERIFICATION SUMMARY =========="
errors=0

if ! zramctl &>/dev/null; then
    echo "[FAIL] ZRAM device not found"
    errors=$((errors+1))
else
    echo "[PASS] ZRAM device detected"
fi

if ! qvm-pool list 2>/dev/null | grep -q "zram_pool"; then
    echo "[FAIL] zram_pool not registered in Qubes"
    errors=$((errors+1))
else
    echo "[PASS] zram_pool registered"
fi

if [ "$(systemctl is-active zram-pool.service 2>/dev/null)" != "active" ]; then
    echo "[WARN] zram-pool.service not active (may need manual start)"
else
    echo "[PASS] zram-pool.service active"
fi

if ! grep -q "Storage=volatile" /etc/systemd/journald.conf 2>/dev/null; then
    echo "[WARN] journald may not be set to volatile"
else
    echo "[PASS] journald configured for volatile storage"
fi

echo ""
echo "Total issues found: $errors"
echo ""

if [ "$errors" -eq 0 ]; then
    echo "[SUCCESS] All checks passed! Your DVMs should be fully amnesic."
else
    echo "[WARNING] Some checks failed. Review the output above."
fi

echo ""
echo "=========================================="
echo "END OF ZRAM AMNESIC CHECK"
echo "=========================================="
}



# =============================================================================
# CREATE ALL REGISTERED CLONES
# =============================================================================

#begin create_all_clones()
create_all_clones() {
    echo ""
    echo "===== CREATE ALL REGISTERED CLONES ====="
    
    if [[ ! -s "$REGISTRY_FILE" ]]; then
        echo "[!] Registry is empty. Nothing to clone!"
        return 1
    fi
    
    echo "Entries in registry:"
    cat "$REGISTRY_FILE" | nl
    echo ""
    
    local success=0
    local fail=0
    local skipped=0
    local start_fail=0
    
    while IFS=: read -r TARGET SOURCE NET; do
        if [[ -z "$TARGET" ]]; then continue; fi
        
        if qvm-check "$TARGET" >/dev/null 2>&1; then
            echo "[SKIP] '$TARGET' already exists! (will not clone again)"
            ((skipped++)) || true
            continue
        fi
        
        echo "[*] Cloning: $SOURCE -> $TARGET (pool: $ZRAM_POOL, NetVM: $NET)"
        
        if qvm-clone -P="$ZRAM_POOL" "$SOURCE" "$TARGET" 2>/dev/null; then
            if [[ "$NET" == "none" ]]; then
                qvm-prefs "$TARGET" netvm ""
                echo "[i] NetVM set to: NONE (no network)"
            else
                qvm-prefs "$TARGET" netvm "$NET"
                echo "[i] NetVM set to: $NET"
            fi
            
            qvm-prefs "$TARGET" template_for_dispvms True
            
            echo "[*] Starting VM to register volumes in zram_pool..."
            if qvm-start "$TARGET" 2>/dev/null; then
                echo "[i] VM started successfully"
                sleep 5
                
                echo "[*] Shutting down VM..."
                if qvm-shutdown --wait "$TARGET" 2>/dev/null; then
                    echo "[OK] VM shut down - volumes registered in /dev/$ZRAM_VG"
                    ((success++)) || true
                else
                    echo "[WARN] Shutdown failed! Trying force kill..."
                    qvm-kill "$TARGET" 2>/dev/null || true
                    sleep 2
                    echo "[WARN] Volume registration may be incomplete!"
                    ((success++)) || true
                    ((start_fail++)) || true
                fi
            else
                echo "[WARN] Failed to start VM! Volume registration may be incomplete!"
                echo "[i] Run 'qvm-start $TARGET' manually later to register volumes"
                ((success++)) || true
                ((start_fail++)) || true
            fi
        else
            echo "[FAIL] Clone command failed!"
            ((fail++)) || true
        fi
    done < "$REGISTRY_FILE"

echo
    disable_bash_history
echo
echo "Disabling swap"
    swap_off
echo
    
    echo ""
    echo "========================================"
    echo "Results:"
    echo "  Created:         $success"
    echo "  Skipped:         $skipped (already existed)"
    echo "  Failed:          $fail"
    echo "  Start issues:    $start_fail (check volume registration)"
    echo "========================================"
}
#end create_all_clones()

# =============================================================================
# CREATE SINGLE REGISTERED CLONE
# =============================================================================

#begin create_single_clone()
create_single_clone() {
    echo ""
    echo "===== CREATE SINGLE REGISTERED CLONE ====="
    
    if [[ ! -s "$REGISTRY_FILE" ]]; then
        echo "[!] Registry is empty. Nothing to clone!"
        return 1
    fi
    
    echo "Registered entries:"
    echo "--------------------"
    cat "$REGISTRY_FILE" | nl
    echo "--------------------"
    echo ""
    
    read -p "Enter entry number to clone: " ENTRY_NUM
    
    if ! [[ "$ENTRY_NUM" =~ ^[0-9]+$ ]]; then
        echo "[!] ERROR: Invalid number!"
        return 1
    fi
    
    SELECTED_LINE=$(sed -n "${ENTRY_NUM}p" "$REGISTRY_FILE")
    
    if [[ -z "$SELECTED_LINE" ]]; then
        echo "[!] ERROR: Entry $ENTRY_NUM does not exist!"
        return 1
    fi
    
    IFS=: read -r TARGET SOURCE NET <<< "$SELECTED_LINE"
    
    if [[ -z "$TARGET" || -z "$SOURCE" ]]; then
        echo "[!] ERROR: Invalid entry format!"
        return 1
    fi
    
    if qvm-check "$TARGET" >/dev/null 2>&1; then
        echo "[!] ERROR: '$TARGET' already exists! Cannot clone again."
        echo "[i] Remove it first or choose a different entry."
        return 1
    fi
    
    echo ""
    echo "[*] Cloning: $SOURCE -> $TARGET (pool: $ZRAM_POOL)"
    echo "[*] NetVM: $NET"
    echo "------------------------------------------------------"
    
    if qvm-clone -P="$ZRAM_POOL" "$SOURCE" "$TARGET" 2>/dev/null; then
        echo "[OK] VM cloned successfully"
        
        if [[ "$NET" == "none" ]]; then
            qvm-prefs "$TARGET" netvm ""
            echo "[i] NetVM set to: NONE (no network)"
        else
            qvm-prefs "$TARGET" netvm "$NET"
            echo "[i] NetVM set to: $NET"
        fi
        
        qvm-prefs "$TARGET" template_for_dispvms True
        echo "[i] Marked as DVM Template for Disposable VMs"
        
        echo ""
        echo "[*] Starting VM to register volumes in zram_pool..."
        if qvm-start "$TARGET" 2>/dev/null; then
            echo "[i] VM started successfully"
            sleep 5
            
            echo "[*] Shutting down VM..."
            if qvm-shutdown --wait "$TARGET" 2>/dev/null; then
                echo "[OK] VM shut down - volumes registered in /dev/$ZRAM_VG"
                echo ""
                echo "========================================"
                echo "[SUCCESS] Clone created successfully!"
                echo "========================================"
            else
                echo "[WARN] Shutdown failed! Trying force kill..."
                qvm-kill "$TARGET" 2>/dev/null || true
                sleep 2
                echo "[WARN] Volume registration may be incomplete!"
                echo ""
                echo "========================================"
                echo "[SUCCESS] Clone created (partial registration)"
                echo "========================================"
            fi
        else
            echo "[WARN] Failed to start VM! Volume registration may be incomplete!"
            echo "[i] Run 'qvm-start $TARGET' manually later to register volumes"
            echo ""
            echo "========================================"
            echo "[SUCCESS] Clone created (manual start needed)"
            echo "========================================"
        fi
    else
        echo "[FAIL] Clone command failed!"
        echo ""
        echo "========================================"
        echo "[FAILED] Could not create clone"
        echo "========================================"
        return 1
    fi

echo
    disable_bash_history
echo "Disabling swap"
    swap_off
echo

}
#end create_single_clone()

# =============================================================================
# REMOVE ENTRY FROM REGISTRY
# =============================================================================

#begin remove_entry()
remove_entry() {
    echo ""
    echo "===== REMOVE ENTRY FROM REGISTRY ====="
    
    if [[ ! -s "$REGISTRY_FILE" ]]; then
        echo "[!] Registry is empty!"
        return 1
    fi
    
    echo "Current entries:"
    cat "$REGISTRY_FILE" | nl
    echo ""
    
    read -p "Enter entry number to remove: " NUM
    
    if ! [[ "$NUM" =~ ^[0-9]+$ ]]; then
        echo "[!] Invalid number!"
        return 1
    fi
    
    sed -i "${NUM}d" "$REGISTRY_FILE"
    echo "[+] Entry removed!"
}
#end remove_entry()

# =============================================================================
# CLEAR ENTIRE REGISTRY
# =============================================================================

#begin clear_registry()
clear_registry() {
    echo ""
    echo "===== CLEAR ENTIRE REGISTRY ====="
    
    if [[ ! -s "$REGISTRY_FILE" ]]; then
        echo "[!] Registry is already empty!"
        return 1
    fi
    
    read -p "Are you sure? (yes/no): " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "[!] Cancelled!"
        return 1
    fi
    
    : > "$REGISTRY_FILE"
    echo "[+] Registry cleared!"
}
#end clear_registry()

# =============================================================================
# DELETE SPECIFIC DVM FROM ZRAM_POOL
# =============================================================================

#begin delete_specific_dvm()
delete_specific_dvm() {
    echo ""
    echo "===== DELETE SPECIFIC DVM FROM zram_pool ====="
    
    echo "Detecting VMs in zram_pool using multiple methods..."
    echo "------------------------------------------------------"
    
    local vms=$(get_vms_in_zram_pool)
    
    if [[ -z "$vms" ]]; then
        echo "[!] No VMs detected in zram_pool!"
        echo "[i] Make sure at least one VM was started after cloning"
        echo "[i] Try running 'qvm-start <vm-name>' first, then try again"
        return 1
    fi
    
    echo "VMs found in zram_pool:"
    echo "$vms" | nl
    echo ""
    echo "Note: If a VM doesn't appear here but exists,"
    echo "it hasn't been started since being added to the pool."
    echo "Try starting it: qvm-start <vm-name>"
    echo "------------------------------------------------------"
    echo ""
    
    read -p "Enter DVM name to delete: " VM_NAME
    
    if [[ -z "$VM_NAME" ]]; then
        echo "[!] ERROR: VM name cannot be empty!"
        return 1
    fi
    
    if ! qvm-check "$VM_NAME" >/dev/null 2>&1; then
        echo "[!] ERROR: VM '$VM_NAME' not found in Qubes!"
        return 1
    fi
    
    if ! echo "$vms" | grep -qx "$VM_NAME"; then
        echo "[WARN] '$VM_NAME' was not detected in zram_pool by this script,"
        echo "but will still try to delete it. It may not be in the correct pool."
        read -p "Continue anyway? (yes/no): " CONFIRM
        if [[ "$CONFIRM" != "yes" ]]; then
            echo "[!] Cancelled!"
            return 1
        fi
    fi
    
    read -p "Delete '$VM_NAME'? (yes/no): " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "[!] Cancelled!"
        return 1
    fi
    
    if qvm-check --running "$VM_NAME" >/dev/null 2>&1; then
        echo "[*] Shutting down $VM_NAME..."
        qvm-shutdown --wait "$VM_NAME" 2>/dev/null || qvm-kill "$VM_NAME" 2>/dev/null
        sleep 2
    fi
    
    qvm-remove --force "$VM_NAME"
    echo "[+] '$VM_NAME' deleted!"
}
#end delete_specific_dvm()

# =============================================================================
# DELETE ALL DVMS FROM ZRAM_POOL
# =============================================================================

#begin delete_all_dvms()
delete_all_dvms() {
    echo ""
    echo "===== DELETE ALL DVMS FROM zram_pool ====="
    
    echo "Detecting VMs in zram_pool using multiple methods..."
    echo "------------------------------------------------------"
    
    local vms=$(get_vms_in_zram_pool)
    
    if [[ -z "$vms" ]]; then
        echo "[!] No VMs detected in zram_pool!"
        echo "[i] Make sure at least one VM was started after cloning"
        echo "[i] Try running 'qvm-start <vm-name>' first, then try again"
        return 1
    fi
    
    echo "VMs found in zram_pool that will be DELETED:"
    echo "$vms" | nl
    echo "------------------------------------------------------"
    echo ""
    
    read -p "DELETE ALL THESE DVMS? (yes/no): " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "[!] Cancelled!"
        return 1
    fi
    
    local count=0
    
    for vm in $vms; do
        echo "Processing: $vm"
        
        if qvm-check --running "$vm" >/dev/null 2>&1; then
            echo "  [*] Shutting down..."
            qvm-shutdown --wait "$vm" 2>/dev/null || qvm-kill "$vm" 2>/dev/null
            sleep 2
        fi
        
        qvm-remove --force "$vm"
        ((count++)) || true
    done
    
    if [[ $count -eq 0 ]]; then
        echo "[i] No VMs were deleted (none found or all already gone)"
    else
        echo "[+] Deleted $count VM(s) from zram_pool!"
    fi
}
#end delete_all_dvms()

# =============================================================================
# CHECK STATUS
# =============================================================================

#begin check_status()
check_status() {
    echo ""
    echo "===== REGISTRY & zram_pool STATUS ====="
    
    echo "Registry entries:"
    echo "------------------"
    if [[ -s "$REGISTRY_FILE" ]]; then
        cat "$REGISTRY_FILE" | nl
    else
        echo "  [Empty]"
    fi
    echo ""
    
    echo "VMs detected in zram_pool:"
    echo "--------------------------"
    local pool_count=0
    
    local vms=$(get_vms_in_zram_pool)
    
    if [[ -z "$vms" ]]; then
        echo "  [None detected]"
        echo "  Note: VMs must be started at least once to be visible in /dev/$ZRAM_VG"
    else
        for vm in $vms; do
            local netvm=$(qvm-prefs "$vm" netvm 2>/dev/null || echo "None")
            local disp=$(qvm-prefs "$vm" template_for_dispvms 2>/dev/null || echo "False")
            local pool=$(qvm-prefs "$vm" default_volume_pool 2>/dev/null || echo "Unknown")
            
            echo "  $vm"
            echo "    ├─ Pool: $pool"
            echo "    ├─ NetVM: $netvm"
            echo "    └─ DispTemplate: $disp"
            ((pool_count++)) || true
        done
    fi
    echo "--------------------------"
    echo ""
    
    echo "LVM Devices in /dev/$ZRAM_VG:"
    echo "------------------------------"
    if [[ -d "/dev/$ZRAM_VG" ]]; then
        ls /dev/$ZRAM_VG/ 2>/dev/null | head -20 || echo "  [Cannot read]"
    else
        echo "  [Directory does not exist]"
    fi
    echo "------------------------------"
    echo ""
    
    echo "ZRAM pool size and DVM usage:"
    zramctl
    echo
    
    echo "Summary:"
    echo "  Registry entries: $(wc -l < "$REGISTRY_FILE" 2>/dev/null | tr -d ' ' || echo 0)"
    echo "  Active clones detected: $pool_count"
    echo "  ZRAM pool: $ZRAM_POOL"
}
#end check_status()

# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# FINISHED
# Zram Pool Creator, Removal, and Dom0 Anti-Forensic Metadata Defense
# FINISHED
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************
# *****************************************************************************


# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# BEGIN
# Dom0 Amnesic and anti-forensic metadata defense
# BEGIN
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# =============================================================================
# REVERT TMPFS OPTIMIZATION (UNINSTALL MODE)
# Removes all tmpfs entries and cleanup services to restore default state
# =============================================================================

#begin revert_tmpfs_optimization()
revert_tmpfs_optimization() {
    echo ""
    echo "==========================================================="
    echo "  REVERT TMPFS OPTIMIZATION - RESTORE DEFAULT STATE"
    echo "==========================================================="
    echo ""
    
    read -p "Are you sure you want to revert all tmpfs optimizations? (yes/no): " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "[!] Operation cancelled!"
        return 1
    fi
    
    echo "[*] Starting system restoration..."
    echo ""
    
    local errors=0
    
    # ------------------------------------------------------------------------
    # Step 1: Remove tmpfs entries from /etc/fstab
    # ------------------------------------------------------------------------
    
    if [[ ! -f "/etc/fstab" ]]; then
        echo "[ERROR] /etc/fstab not found!"
        ((errors++)) || true
    else
        # Backup fstab before modification
        sudo cp /etc/fstab /etc/fstab.tmpfs.backup.$(date +%Y%m%d_%H%M%S)
        echo "[BACKUP] Created /etc/fstab backup"
        
        # Remove specific tmpfs lines
        local fstab_modifications=0
        
        if grep -q "^tmpfs /var/log tmpfs" /etc/fstab; then
            sudo sed -i '/^tmpfs \/var\/log tmpfs/d' /etc/fstab
            ((fstab_modifications++)) || true
            echo "[REMOVED] tmpfs entry for /var/log"
        fi
        
        if grep -q "^tmpfs /etc/lvm/archive tmpfs" /etc/fstab; then
            sudo sed -i '/^tmpfs \/etc\/lvm\/archive tmpfs/d' /etc/fstab
            ((fstab_modifications++)) || true
            echo "[REMOVED] tmpfs entry for /etc/lvm/archive"
        fi
        
        if grep -q "^tmpfs /etc/lvm/backup tmpfs" /etc/fstab; then
            sudo sed -i '/^tmpfs \/etc\/lvm\/backup tmpfs/d' /etc/fstab
            ((fstab_modifications++)) || true
            echo "[REMOVED] tmpfs entry for /etc/lvm/backup"
        fi
        
        if grep -q "^tmpfs /var/lib/qubes/backup tmpfs" /etc/fstab; then
            sudo sed -i '/^tmpfs \/var\/lib\/qubes\/backup tmpfs/d' /etc/fstab
            ((fstab_modifications++)) || true
            echo "[REMOVED] tmpfs entry for /var/lib/qubes/backup"
        fi
        
        if [[ $fstab_modifications -eq 0 ]]; then
            echo "[SKIP] No tmpfs entries found in /etc/fstab"
        else
            echo "[OK] Removed $fstab_modifications tmpfs entry/entries"
        fi
    fi

#restore .bak of swap-zram service
sudo cp -ra /usr/lib/systemd/system/systemd-zram-setup@.service.bak /usr/lib/systemd/system/systemd-zram-setup@.service;
echo;

    
    echo ""
    # ------------------------------------------------------------------------
    # Step 2: Remove /etc/tmpfiles.d/tmpfs.conf
    # ------------------------------------------------------------------------
    echo "--- Step 2: Cleaning tmpfiles.d configuration ---"
    
    if [[ -f "/etc/tmpfiles.d/tmpfs.conf" ]]; then
        sudo rm -f /etc/tmpfiles.d/tmpfs.conf
        echo "[REMOVED] /etc/tmpfiles.d/tmpfs.conf"
    else
        echo "[SKIP] /etc/tmpfiles.d/tmpfs.conf does not exist"
    fi
    
    echo ""
    
    # ------------------------------------------------------------------------
    # Step 3: Disable and remove systemd clean service
    # ------------------------------------------------------------------------
    echo "--- Step 3: Cleaning systemd services ---"
    
    # Stop service if running
    if systemctl is-active --quiet clean.service 2>/dev/null; then
        echo "[*] Stopping clean.service..."
        sudo systemctl stop clean.service 2>/dev/null || true
    else
        echo "[SKIP] clean.service is not active"
    fi
    
    # Disable service
    if systemctl is-enabled clean.service 2>/dev/null; then
        echo "[*] Disabling clean.service..."
        sudo systemctl disable clean.service 2>/dev/null || true
    else
        echo "[SKIP] clean.service is not enabled"
    fi
    
    # Remove service file
    if [[ -f "/etc/systemd/system/clean.service" ]]; then
        sudo rm -f /etc/systemd/system/clean.service
        echo "[REMOVED] /etc/systemd/system/clean.service"
    else
        echo "[SKIP] /etc/systemd/system/clean.service does not exist"
    fi
    
    # Remove cleanup script
    if [[ -f "/usr/local/bin/clean.sh" ]]; then
        sudo rm -f /usr/local/bin/clean.sh
        echo "[REMOVED] /usr/local/bin/clean.sh"
    else
        echo "[SKIP] /usr/local/bin/clean.sh does not exist"
    fi
    
    # Reload systemd daemon
    echo "[*] Reloading systemd daemon..."
    sudo systemctl daemon-reload
    echo "[OK] Systemd daemon reloaded"
    
    echo ""
    
    # ------------------------------------------------------------------------
    # Step 4: Restore journald.conf
    # ------------------------------------------------------------------------
    echo "--- Step 4: Restoring journald configuration ---"
    
    if [[ -f "/etc/systemd/journald.conf" ]]; then
        # Check if we modified it (contains Storage=volatile)
        if grep -q "Storage=volatile" /etc/systemd/journald.conf; then
            # Try to restore from default
            if [[ -f "/usr/lib/systemd/journald.conf" ]]; then
                sudo cp /usr/lib/systemd/journald.conf /etc/systemd/journald.conf.bak
                sudo rm -f /etc/systemd/journald.conf
                echo "[RESTORED] journald.conf from default"
            else
                # Just comment out the volatile line
                sudo sed -i 's/^Storage=volatile/#Storage=volatile/' /etc/systemd/journald.conf
                echo "[MODIFIED] Commented out Storage=volatile in journald.conf"
            fi
            
            echo "[*] Restarting systemd-journald..."
            sudo systemctl restart systemd-journald 2>/dev/null || true
        else
            echo "[SKIP] journald.conf was not modified"
        fi
    else
        echo "[SKIP] /etc/systemd/journald.conf does not exist"
    fi
    
    echo ""
    
    # ------------------------------------------------------------------------
    # Summary
    # ------------------------------------------------------------------------
    echo "==========================================================="
    echo "  REVERSION COMPLETE"
    echo "==========================================================="
    echo ""
    
    if [[ $errors -gt 0 ]]; then
        echo "[!] Errors occurred during reversion: $errors"
    else
        echo "[SUCCESS] All tmpfs optimizations removed successfully!"
    fi
    
    echo ""
    echo "=========================================="
    echo "  IMPORTANT REQUIREMENTS"
    echo "=========================================="
    echo ""
    echo "  [!] REBOOT REQUIRED"
    echo ""
    echo "  The following changes require a system reboot to take effect:"
    echo "    • /etc/fstab modifications (tmpfs mounts)"
    echo "    • systemd service configuration"
    echo ""
    echo "  To apply changes, run:"
    echo "    sudo reboot"
    echo ""
    echo "  Or to continue without rebooting (changes won't apply until next boot):"
    echo "    Press Enter to return to main menu"
    echo ""
    echo "=========================================="
    
    return 0
}
#end revert_tmpfs_optimization()

#begin dom0_tmpfs_metadata()
dom0_tmpfs_metadata()
{
set -euo pipefail

# ============================================================================
# Step 1: Add tmpfs entries to /etc/fstab
# ============================================================================

FSTAB_ENTRIES=(
    "tmpfs /var/log tmpfs defaults,noatime,size=50M 0 0"
    "tmpfs /etc/lvm/archive tmpfs defaults,size=250M,noatime 0 0"
    "tmpfs /etc/lvm/backup tmpfs defaults,size=250M,noatime 0 0"
    "tmpfs /var/lib/qubes/backup tmpfs defaults,size=20M,noatime 0 0"

#need be tested until...
#    "tmpfs /etc/libvirt/libxl tmpfs defaults,size=50M,noatime 0 0"
#    "tmpfs /etc/qubes/backup tmpfs defaults,size=20M,noatime 0 0"
#    "tmpfs /home/user/.local/share tmpfs defaults,size=100M,noatime 0 0"
#    "tmpfs /var/lib/qubes tmpfs defaults,size=100M,noatime 0 0"
#    "tmpfs /run/udev/data tmpfs defaults,size=10M,noatime 0 0"
#    "tmpfs /etc/systemd/system tmpfs defaults,size=20M,noatime 0 0"
)


#backup fstab
sudo cp -ra /etc/fstab /etc/fstab.backup.$(date +%Y%m%d_%H%M%S)

for entry in "${FSTAB_ENTRIES[@]}"; do
    mount_point=$(echo "$entry" | awk '{print $2}')
    if grep -q "^[[:space:]]*tmpfs[[:space:]]\+${mount_point}[[:space:]]" /etc/fstab; then
        echo "[SKIP] tmpfs mount for $mount_point already exists in /etc/fstab"
    else
printf '\n%s\n' "$entry" >> /etc/fstab
        echo "[ADDED] $entry"
    fi
done

# ============================================================================
# Step 2: Create /etc/tmpfiles.d/tmpfs.conf
# ============================================================================

TMPFILES_CONF="/etc/tmpfiles.d/tmpfs.conf"

cat > "$TMPFILES_CONF" << 'EOF'
# /etc/tmpfiles.d/tmpfs.conf
# Ensures directories exist on boot for tmpfs-backed mounts.

# /var/log subdirectories
d /var/log/qubes           2770 root qubes          -
d /var/log/audit           700  root root            -
d /var/log/xen             770  root qubes          -
d /var/log/xen/console     2750 root qubes          -
d /var/log/anaconda        755  root root            -
d /var/log/samba           700  root root            -
d /var/log/samba/old       700  root root            -
d /var/log/blivet-gui      755  root root            -
d /var/log/usbguard        755  root root            -
d /var/log/lightdm         755  lightdm lightdm     -
d /var/log/journal         2755 root systemd-journal -
d /var/log/private         700  root root            -
d /var/log/libvirt         700  root root            -
d /var/log/libvirt/libxl   700  root root            -
d /var/log/salt            755  root root            -

# LVM metadata directories
d /etc/lvm/archive         755  root root -
d /etc/lvm/backup          755  root root -

# Qubes backup directory
d /var/lib/qubes/backup    755  root root -
EOF

# ============================================================================
# Step 3: Create systemd cleanup service
# ============================================================================

# backup journld.conf
sudo cp /etc/systemd/journald.conf /etc/systemd/journald.conf.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true

sudo tee /etc/systemd/journald.conf << EOF
[Journal]
Storage=volatile
EOF
sudo systemctl restart systemd-journald

sudo tee /etc/systemd/system/clean.service << 'EOF'
[Unit]
Description=Clean logs of removed Qubes VMs
After=qubesd.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/clean.sh
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF

sudo tee /usr/local/bin/clean.sh << 'EOF'
#!/bin/bash

set -euo pipefail


readonly TEMPDIR_ROOT='/home/user/tmp'
readonly MENUDIR='/home/user/.config/menus/applications-merged'


existing_qubes=$(qvm-ls --fields=name --raw-data | sort)


all_qube_names=''


if [ -d "${TEMPDIR_ROOT}" ]; then
    all_qube_names+=$(find "${TEMPDIR_ROOT}" \
        -mindepth 1 -maxdepth 1 -type d \
        -exec basename "{}" \; \
        | sort | uniq)$'\n'
fi


all_qube_names+=$(find "${MENUDIR}" \
    -regextype posix-egrep \
    -regex '.*\/user-qubes-.*\.menu$' \
    -exec basename "{}" \; \
    | sed -r 's/\.menu$//g' \
    | sed -r 's/^user-qubes-(disp)?vm-directory(_|-)//g' \
    | sort | uniq)$'\n'


all_qube_names=$(echo "${all_qube_names}" \
    | sed -r 's/^(Domain-0|libxl-driver)$//g' \
    | sed -r '/^\s*$/d' \
    | sort | uniq)


set +e
qubes_to_remove=$(diff --new-line-format='' --unchanged-line-format='' \
    <(echo "${all_qube_names}") <(echo "${existing_qubes}") \
    | sed -r '/^\s*$/d')
set -e


for qube_name in ${qubes_to_remove}; do
    decoded_qube_name=$(echo "${qube_name}" \
        | sed -r 's/_d/-/g' \
        | sed -r 's/_u/_/g')

    log_pattern="${qube_name}\.log((\.old)|(-[0-9]{8}))?(\.gz)?"
    menu_pattern="user-qubes-(disp)?vm-directory(_|-)${qube_name}\.menu"

    declare -A targets
    targets=(["${MENUDIR}"]="${menu_pattern}")

    if [ -d "${TEMPDIR_ROOT}" ]; then
        targets+=("${TEMPDIR_ROOT}"="${qube_name}")
    fi

    for search_dir in "${!targets[@]}"; do
        mapfile -d $'\0' found_files < <(find "${search_dir}" \
            -regextype posix-egrep \
            -regex ".*\/${targets[${search_dir}]}$" \
            -print0)
        for file in "${found_files[@]}"; do
            [ -z "${file}" ] && continue
            rm -rf "${file}"
        done
    done
done
EOF

sudo chmod +x /usr/local/bin/clean.sh
sudo systemctl daemon-reload
sudo systemctl enable clean.service

echo ""
echo "Done. Reboot to apply tmpfs mounts"


}
#end dom0_tmpfs_metadata()

#begin get_user_dom0()
get_user_dom0() {
    local valid_user=false
    
    echo ""
    echo "==========================================================="
    echo "  USER DOM0 VALIDATION"
    echo "==========================================================="
    echo ""
    
    while [[ "$valid_user" != "true" ]]; do
        echo "Available users in /home:"
        echo "-------------------------"
        ls /home 2>/dev/null | sort || echo "[!] Unable to list /home directory"
        echo "-------------------------"
        echo ""
        
        read -p "Enter the dom0 username: " user_dom0
        
        # Check if input is empty
        if [[ -z "$user_dom0" ]]; then
            echo "[!] ERROR: Username cannot be empty!"
            echo "[i] Please try again."
            echo ""
            continue
        fi
        
        # Check if user directory exists in /home
        if [[ -d "/home/$user_dom0" ]]; then
            echo "[OK] User '$user_dom0' found in /home"
            echo "[i] User path: /home/$user_dom0"
            valid_user=true
        else
            echo "[!] ERROR: User '$user_dom0' not found in /home!"
            echo "[i] Please check the username and try again."
            echo ""
            user_dom0=""
        fi
    done
    
    echo ""
    echo "==========================================================="
    echo "  USER VALIDATED SUCCESSFULLY"
    echo "==========================================================="
    echo "[i] Selected user: $user_dom0"
    echo "[i] Home directory: /home/$user_dom0"
    echo ""
}
#end get_user_dom0()

#begin clean_bashrc_blocks()
clean_bashrc_blocks() {
    echo "==========================================================="
    echo "  CLEANING OLD BASH HISTORY BLOCKS"
    echo "==========================================================="
    echo ""
    
    # Clean root .bashrc
    echo "[*] Cleaning /root/.bashrc..."
    if grep -q "# DISABLE BASH HISTORY - PERMANENT\|# ENABLE BASH HISTORY - PERMANENT" /root/.bashrc 2>/dev/null; then
        sed -i '/# DISABLE BASH HISTORY - PERMANENT/,/shopt -u histappend/d' /root/.bashrc
        sed -i '/# ENABLE BASH HISTORY - PERMANENT/,/shopt -s histappend/d' /root/.bashrc
        echo "[+] Old blocks removed from root .bashrc"
    else
        echo "[SKIP] No blocks found in root .bashrc"
    fi
    
    # Clean user .bashrc
    echo "[*] Cleaning /home/$user_dom0/.bashrc..."
    if grep -q "# DISABLE BASH HISTORY - PERMANENT\|# ENABLE BASH HISTORY - PERMANENT" "/home/$user_dom0/.bashrc" 2>/dev/null; then
        sed -i '/# DISABLE BASH HISTORY - PERMANENT/,/shopt -u histappend/d' "/home/$user_dom0/.bashrc"
        sed -i '/# ENABLE BASH HISTORY - PERMANENT/,/shopt -s histappend/d' "/home/$user_dom0/.bashrc"
        echo "[+] Old blocks removed from user .bashrc"
    else
        echo "[SKIP] No blocks found in user .bashrc"
    fi
    
    echo "[OK] Cleanup complete!"
    echo ""
}
#end clean_bashrc_blocks()

#begin disable_bash_history()
disable_bash_history()
{
    echo "Disable .bash_history"
    get_user_dom0
    clean_bashrc_blocks
    
    unset HISTFILE
    HISTSIZE=0
    echo "" > /root/.bash_history 2>/dev/null
    echo "" > "/home/$user_dom0/.bash_history" 2>/dev/null

# Root .bashrc handling
echo "[*] Processing /root/.bashrc..."

# Check if DISABLE or ENABLE block exists in root .bashrc
if grep -q "# DISABLE BASH HISTORY - PERMANENT\|# ENABLE BASH HISTORY - PERMANENT" /root/.bashrc; then
    echo "[*] Found existing block in root .bashrc, removing..."
    # Remove any existing DISABLE or ENABLE block (from start marker to end marker)
sed -i '/# DISABLE BASH HISTORY - PERMANENT/,/shopt -u histappend/d' /root/.bashrc
sed -i '/# ENABLE BASH HISTORY - PERMANENT/,/shopt -s histappend/d' "/home/$user_dom0/.bashrc"
fi

# Add blank line separator, then add DISABLE block
echo "" >> /root/.bashrc
cat >> /root/.bashrc << 'EOF'

# DISABLE BASH HISTORY - PERMANENT
# Prevent bash history from being written to disk
# This overrides any previous HISTFILE settings
export HISTFILE=/dev/null
export HISTSIZE=0
export HISTFILESIZE=0
shopt -u histappend
EOF
echo "[+] Root .bashrc updated"


# User .bashrc handling
echo "[*] Processing /home/$user_dom0/.bashrc..."

if grep -q "# DISABLE BASH HISTORY - PERMANENT\|# ENABLE BASH HISTORY - PERMANENT" "/home/$user_dom0/.bashrc"; then
    echo "[*] Found existing block in user .bashrc, removing..."
    sed -i '/# DISABLE BASH HISTORY - PERMANENT/,/shopt -u histappend/d' "/home/$user_dom0/.bashrc"
    sed -i '/# ENABLE BASH HISTORY - PERMANENT/,/shopt -s histappend/d' "/home/$user_dom0/.bashrc"
fi

# Add blank line separator, then add DISABLE block
echo "" >> "/home/$user_dom0/.bashrc"
cat >> "/home/$user_dom0/.bashrc" << 'EOF'

# DISABLE BASH HISTORY - PERMANENT
# Prevent bash history from being written to disk
# This overrides any previous HISTFILE settings
export HISTFILE=/dev/null
export HISTSIZE=0
export HISTFILESIZE=0
shopt -u histappend
EOF

echo "[+] User '$user_dom0' .bashrc updated"


# Clear current session history
unset HISTFILE
export HISTSIZE=0
export HISTFILESIZE=0
history -c
echo "" > /root/.bash_history 2>/dev/null
echo "" > "/home/$user_dom0/.bash_history" 2>/dev/null

source ~/.bashrc
source /root/.bashrc

echo "[OK] Bash history disabled for new sessions"
echo "     Current session cleared."

echo "cat /home/$user_dom0/.bash_history"
cat /home/$user_dom0/.bash_history
echo
echo "cat /root/.bash_history"
cat /root/.bash_history
}
#end disable_bash_history()

#begin enable_bash_history()
enable_bash_history()
{
    echo "Enable .bash_history"
    get_user_dom0
    clean_bashrc_blocks
    
    export HISTFILE=/root/.bash_history
    export HISTSIZE=1000
    export HISTFILESIZE=2000

# Root .bashrc handling
echo "[*] Processing /root/.bashrc..."

# Check if DISABLE or ENABLE block exists in root .bashrc
if grep -q "# DISABLE BASH HISTORY - PERMANENT\|# ENABLE BASH HISTORY - PERMANENT" /root/.bashrc; then
    echo "[*] Found existing block in root .bashrc, removing..."
    # Remove any existing DISABLE or ENABLE block (from start marker to end marker)
sed -i '/# DISABLE BASH HISTORY - PERMANENT/,/shopt -u histappend/d' /root/.bashrc
sed -i '/# ENABLE BASH HISTORY - PERMANENT/,/shopt -s histappend/d' "/home/$user_dom0/.bashrc"
fi

# Add blank line separator, then add ENABLE block
echo "" >> /root/.bashrc
cat >> /root/.bashrc << 'EOF'

# ENABLE BASH HISTORY - PERMANENT
# Restore default bash history settings
export HISTFILE=~/.bash_history
export HISTSIZE=1000
export HISTFILESIZE=2000
shopt -s histappend
EOF

echo "[+] Root .bashrc updated with ENABLE block"


# User .bashrc handling
echo "[*] Processing /home/$user_dom0/.bashrc..."

if grep -q "# DISABLE BASH HISTORY - PERMANENT\|# ENABLE BASH HISTORY - PERMANENT" "/home/$user_dom0/.bashrc"; then
    echo "[*] Found existing block in user .bashrc, removing..."
    sed -i '/# DISABLE BASH HISTORY - PERMANENT/,/shopt -u histappend/d' "/home/$user_dom0/.bashrc"  
    sed -i '/# ENABLE BASH HISTORY - PERMANENT/,/shopt -s histappend/d' "/home/$user_dom0/.bashrc"
fi

# Add blank line separator, then add ENABLE block
echo "" >> "/home/$user_dom0/.bashrc"
cat >> "/home/$user_dom0/.bashrc" << 'EOF'

# ENABLE BASH HISTORY - PERMANENT
# Restore default bash history settings
export HISTFILE=~/.bash_history
export HISTSIZE=1000
export HISTFILESIZE=2000
shopt -s histappend
EOF

source ~/.bashrc
source /root/.bashrc

echo "[+] User '$user_dom0' .bashrc updated."

echo "[OK] Bash history re-enabled for new sessions"
echo "     Logout and login again to apply changes."

echo "cat /home/$user_dom0/.bash_history"
cat /home/$user_dom0/.bash_history
echo
echo "cat /root/.bash_history"
cat /root/.bash_history
}
#end enable_bash_history()


#begin check_tmpfs_simple()
check_tmpfs_simple() {
    echo "--- TMPFS MOUNT STATUS ---"
    echo ""
    #update after test all directories
    #for mp in /var/log /etc/lvm/archive /etc/lvm/backup /var/lib/qubes/backup /etc/libvirt/libxl /etc/qubes/backup /home/user/.local/share /var/lib/qubes /etc/systemd/system; do
    echo "Expected mounts:"
    for mp in /var/log /etc/lvm/archive /etc/lvm/backup /var/lib/qubes/backup; do
        if mountpoint -q "$mp" 2>/dev/null; then
            echo "  [MOUNTED] $mp"
        else
            echo "  [NOT MOUNTED] $mp"
        fi
    done
    
    echo ""
    echo "All current tmpfs mounts:"
    mount -t tmpfs | awk '{print $3}'
echo 
echo "Swap Status"
sudo swapon --show
echo

echo "All Mounts"
df -h
echo
}
#end check_tmpfs_simple()

#begin dom0-ram-manager()
dom0-ram-manager()
{
# Calculating the total RAM in Qubes OS from hardware memory using dmidecode
total_ram=$(sudo dmidecode -t memory \
    | awk '/Size:/ && $2 != "No" {
            gsub(/GB|MB/, "", $2);
            sum += ($2 ~ /MB/ ? $2/1024 : $2)
        }
        END { printf "%.2f", sum }')

total_ram_mb=$(awk "BEGIN { printf \"%d\", $total_ram * 1024 }")

# Calculate the total size of the dom0 file and ensure the used space does not exceed the RAM value chosen by the user
mount_point=$(df --output=target /var/lib/qubes | tail -n1)
used_human=$(df -h "$mount_point" | awk 'NR==2 {print $3}')
size_gb=${used_human%G}
size_gb=${size_gb/,/.}

if ! [[ "$size_gb" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "“Could not interpret the size.”: '$used_human'"
sleep 3
    exit 1
fi

size_mb=$(awk "BEGIN { printf \"%d\", $size_gb * 1024 }")


echo;
echo "Total RAM available is $total_ram GB or $total_ram_mb megabytes"
echo "Dom0 total size used: $size_gb GB ($size_mb MB)"
echo "Enter the amount of RAM for dom0 in megabytes to support tmpfs metadata anti-forensic in new directories"
echo "It must be no larger than the total available RAM"
echo "Recommended but optional if you have low RAM: 5 GB = 5000 megabytes"
echo "You do not want it? So set 4000 GB = 4000 megabytes"
echo

while true; do
        # Ask the user
        read -p "Enter the RAM amount (megabytes): " ram_input

        # Strip any whitespace the user might have typed
        ram_input=$(echo "$ram_input" | tr -d '[:space:]')

        # ----- Validate that the input is a positive integer -----
        if ! [[ $ram_input =~ ^[0-9]+$ ]]; then
            echo "Please enter a positive integer number."
            continue
        fi

        # If we reach this point the value is acceptable
        ram=$ram_input
        break
    done
echo
# Backup the grub file
echo "Backup the grub file";
sudo cp /etc/default/grub /etc/default/grub.bak


maxram=$ram_input
# New line to be inserted in /etc/default/grub
new_line="GRUB_CMDLINE_XEN_DEFAULT=\"console=none dom0_mem=min:1096M dom0_mem=max:${maxram}M ucode=scan smt=off gnttab_max_frames=2048 gnttab_max_maptrack_frames=4096\""

# Remove the existing line in the grub file
sudo sed -i "/^GRUB_CMDLINE_XEN_DEFAULT=/d" /etc/default/grub
echo "$new_line" >> /etc/default/grub
echo "GRUB configuration updated successfully."
echo;

            echo "Generating grub configuration files with grub2-mkconfig..."
            sudo grub2-mkconfig -o /boot/grub2/grub.cfg
            sudo grub2-mkconfig -o /boot/efi/EFI/grub.cfg
            echo "GRUB configuration for Qubes 4.3 completed."
echo;

# Regenerate Dracut
echo "Regenerating Dracut..."
sudo dracut --verbose --force

echo "Dracut regenerated."

}
#end dom0-ram-manager()

#begin restore_grub_default_4g()
restore_grub_default_4g()
{
echo
echo "Restoring grub default configuration and reactivate swap..."
echo "Regenerating Dracut..."
sudo dracut --verbose --force
echo;

echo "Restore original grub configuration..."
GRUB_BAK="/etc/default/grub.bak"


if [[ ! -e "$GRUB_BAK" ]]; then
    echo "⚠️  Warning: $GRUB_BAK does not exist."
    echo "The script cannot continue without this backup file."
    sleep 2;
    exit 1   # non‑zero exit code signals failure
fi

# If we reach this point the file exists
echo "  $GRUB_BAK found. Continuing with the program..."
#restore .bak of grub
sudo cp -ra /etc/default/grub.bak /etc/default/grub;

            echo "Generating grub configuration files with grub2-mkconfig..."
            sudo grub2-mkconfig -o /boot/grub2/grub.cfg
            echo "GRUB configuration for Qubes 4.3 completed."

echo "Restore original zram-service..."
swap_ram_bak="/usr/lib/systemd/system/systemd-zram-setup@.service.bak"
if [[ -e "$swap_ram_bak" ]]; then
    sudo cp -r "$swap_ram_bak" /usr/lib/systemd/system/systemd-zram-setup@.service;
    echo "[OK] zram-service restored"
else
    echo "[SKIP] zram-service backup not found"
fi
  
}
#end restore_grub_default_4g()


#begin swap_on()

swap_on()
{
echo "Turn on Swap"
sudo swapon -a
echo "Status"
sudo swapon --show
echo
}
#end swap_on()


#begin swap_off()
swap_off()
{
echo "Turn off Swap"
sudo swapoff -a
echo "Status"
sudo swapon --show
echo
}
#end swap_off()

# =============================================================================
# SYSTEM-WIDE METADATA RANDOMIZER (ANTI-FORENSIC MODE)
# =============================================================================

#begin system_wide_metadata_randomizer()
system_wide_metadata_randomizer() {
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        echo "[!] ERROR: This function requires root privileges (dom0)."
        echo "[i] Please run as root or with sudo."
        return 1
    fi

    # Display brief warning
    echo ""
    echo "==========================================================="
    echo "  SYSTEM-WIDE METADATA RANDOMIZER"
    echo "==========================================================="
    echo ""
    echo "[!] WARNING: This will randomize timestamps on files/directories"
    echo "    except protected system directories."
    echo ""
    echo "[i] EXCLUDED DIRECTORIES (won't be touched):"
    echo "    • /var/log"
    echo "    • /etc/lvm/archive"
    echo "    • /etc/lvm/backup"
    echo ""
    echo "[i] USE CASE: Anti-forensic timestamp falsification"
    echo "    Timestamps set between 365-1825 days ago (1-5 years)"
    echo ""
    echo "==========================================================="
    echo ""

    # Function definitions for metadata randomization
#begin randomize_file()
    randomize_file() {
        local FILE="$1"
        local RAND_DAYS_M=$((RANDOM % 1460 + 365))
        local RAND_DAYS_A=$((RANDOM % 1460 + 365))
        local DATE_M=$(date -d "-${RAND_DAYS_M} days" +"%Y-%m-%d %H:%M:%S")
        local DATE_A=$(date -d "-${RAND_DAYS_A} days" +"%Y-%m-%d %H:%M:%S")
        touch -d "$DATE_M" "$FILE" 2>/dev/null
        touch -d "$DATE_A" "$FILE" 2>/dev/null
    }
#end randomize_file()

#begin randomize_dir()
    randomize_dir() {
        local DIR="$1"
        local RAND_DAYS_M=$((RANDOM % 1460 + 365))
        local RAND_DAYS_A=$((RANDOM % 1460 + 365))
        local DATE_M=$(date -d "-${RAND_DAYS_M} days" +"%Y-%m-%d %H:%M:%S")
        local DATE_A=$(date -d "-${RAND_DAYS_A} days" +"%Y-%m-%d %H:%M:%S")
        touch -d "$DATE_M" "$DIR" 2>/dev/null
        touch -d "$DATE_A" "$DIR" 2>/dev/null
    }
#end randomize_dir()

    # Ask user for target type
    echo "Select Target Type:"
    echo "  1) Specific File"
    echo "  2) Specific Directory"
    echo "  3) Critical Qubes Metadata (Standard 5 Directories)"
    echo ""
    read -p "Choose option [1-3]: " TARGET_TYPE

    # Initialize variables
    MODE=""
    TARGET_PATH=""
    TARGET_PATHS=()

    case "$TARGET_TYPE" in
        1)
            # SPECIFIC FILE MODE
            read -p "Enter the absolute path to the file: " TARGET_PATH
            if [ ! -f "$TARGET_PATH" ]; then
                echo "[!] ERROR: File '$TARGET_PATH' does not exist!"
                return 1
            fi
            MODE="FILE"
            echo "[OK] Selected: FILE ($TARGET_PATH)"
            ;;
        2)
            # SPECIFIC DIRECTORY MODE
            read -p "Enter the absolute path to the directory: " TARGET_PATH
            if [ ! -d "$TARGET_PATH" ]; then
                echo "[!] ERROR: Directory '$TARGET_PATH' does not exist!"
                return 1
            fi
            MODE="DIR"
            echo "[OK] Selected: DIR ($TARGET_PATH)"
            ;;
        3)
            # CRITICAL METADATA DIRECTORIES MODE (DEFAULT STANDARD)
            echo "[*] Loading standard critical Qubes metadata directories..."
            TARGET_PATHS=(
                "/etc/libvirt/libxl"
                "/etc/qubes/backup"
                "/home"
                "/var/lib/qubes"
                "/etc/systemd/system"
            )
            MODE="MULTIPLE"
            echo "[OK] Selected: MULTIPLE (5 Standard Critical Directories)"
            echo "[i] These are STANDARD QUBES CRITICAL METADATA DIRECTORIES:"
            for target in "${TARGET_PATHS[@]}"; do
                if [[ -d "$target" ]]; then
                    echo "    ✓ $target (exists)"
                else
                    echo "    ✗ $target (does not exist - will be skipped)"
                fi
            done
            ;;
        *)
            echo "[!] Invalid option! Defaulting to standard critical directories."
            TARGET_PATHS=(
                "/etc/libvirt/libxl"
                "/etc/qubes/backup"
                "/home"
                "/var/lib/qubes"
                "/etc/systemd/system"
            )
            MODE="MULTIPLE"
            ;;
    esac

    echo ""
    echo "==========================================================="
    echo "  SELECTION CONFIRMED"
    echo "==========================================================="
    echo "Mode:               $MODE"
    if [[ "$MODE" = "MULTIPLE" ]]; then
        echo "Targets:            ${#TARGET_PATHS[@]} directories"
    else
        echo "Target Path:        $TARGET_PATH"
    fi
    echo "==========================================================="
    echo ""

    # Ask for number of modifications per item
    read -p "How many randomizations per file/directory? [Default: 1]: " NUM_ITERATIONS

    if [ -z "$NUM_ITERATIONS" ]; then
        NUM_ITERATIONS=1
    fi

    if ! [[ "$NUM_ITERATIONS" =~ ^[0-9]+$ ]] || [ "$NUM_ITERATIONS" -le 0 ]; then
        echo "[!] Using default: 1 iteration"
        NUM_ITERATIONS=1
    fi

    if [ "$NUM_ITERATIONS" -gt 1 ]; then
        echo "[i] NOTE: Only the LAST randomization counts. Multiple iterations are redundant."
        echo "[i] Recommended: 1 (faster processing)."
        echo ""
        read -p "Continue with $NUM_ITERATIONS iterations? (y/n): " CONFIRM_ITER
        if [[ ! "$CONFIRM_ITER" =~ ^[yY]$ ]]; then
            echo "[!] Cancelled!"
            return 1
        fi
    fi

    # Ask if user wants report generation
    echo ""
    read -p "Generate modification report to /dev/shm? (y/n): " GENERATE_REPORT

    REPORT_ENABLED=false
    if [[ "$GENERATE_REPORT" =~ ^[yY]$ ]]; then
        REPORT_ENABLED=true
        REPORT_FILE="/dev/shm/metadata_randomizer_report_$(date +%Y%m%d_%H%M%S).txt"
        echo "[i] Report will be saved to: $REPORT_FILE"
        echo "[i] /dev/shm is RAM-based - report will be lost on reboot."
    fi

    # Define protected directories (excluded from randomization)
    PROTECTED_DIRS=(
        "/var/log"
        "/etc/lvm/archive"
        "/etc/lvm/backup"
    )

    # Confirmation before proceeding
    echo ""
    echo "==========================================================="
    echo "  FINAL CONFIRMATION"
    echo "==========================================================="
    echo "Target Mode:        $MODE"
    if [[ "$MODE" = "MULTIPLE" ]]; then
        echo "Critical Directories: ${#TARGET_PATHS[@]}"
        for target in "${TARGET_PATHS[@]}"; do
            echo "                     $target"
        done
    else
        echo "Target Path:        $TARGET_PATH"
    fi
    echo "Iterations:         $NUM_ITERATIONS"
    echo "Report Enabled:     $REPORT_ENABLED"
    echo ""
    echo "[!] WARNING: THIS CANNOT BE UNDONE!"
    echo "[!] Original timestamps will be PERMANENTLY LOST!"
    echo ""
    read -p "Proceed? (yes/no): " CONFIRM_FINAL

    if [[ "$CONFIRM_FINAL" != "yes" ]]; then
        echo "[!] Operation cancelled!"
        return 1
    fi

    echo ""
    echo "==========================================================="
    echo "  STARTING METADATA RANDOMIZATION"
    echo "==========================================================="
    echo ""

    # Initialize counters
    FILES_PROCESSED=0
    DIRS_PROCESSED=0
    SKIPPED=0

    # Initialize report header if enabled
    if [ "$REPORT_ENABLED" = true ]; then
        cat > "$REPORT_FILE" << REPORT_HEADER
===============================================================================
METADATA RANDOMIZATION REPORT
Generated: $(date)
===============================================================================
Target Mode:        $MODE
Targets:            $([ "$MODE" = "MULTIPLE" ] && echo "${TARGET_PATHS[*]}" || echo "$TARGET_PATH")
Iterations:         $NUM_ITERATIONS
Protected:          /var/log, /etc/lvm/archive, /etc/lvm/backup
===============================================================================

SECTION 1: MODIFIED FILES
-------------------------------------------------------------------------------
REPORT_HEADER
    fi

    # Helper: Check if path is in protected directories
#begin is_protected()
    is_protected() {
        local path="$1"
        for protected in "${PROTECTED_DIRS[@]}"; do
            if [[ "$path" == "$protected"* ]]; then
                return 0  # True - is protected
            fi
        done
        return 1  # False - not protected
    }
#end is_protected()

    # Process based on MODE
    if [ "$MODE" = "FILE" ]; then
        # Single file mode
        echo "[*] Processing single file..."
        
        for ((i=0; i<NUM_ITERATIONS; i++)); do
            randomize_file "$TARGET_PATH"
        done

        FILES_PROCESSED=1

        echo "[OK] File randomized: $TARGET_PATH"
        echo "[DEBUG] New timestamp: $(stat -c '%y' "$TARGET_PATH" 2>/dev/null)"

        # Add to report if enabled
        if [ "$REPORT_ENABLED" = true ]; then
            {
                echo "File: $TARGET_PATH"
                echo "  Timestamp MTIME: $(stat -c '%y' "$TARGET_PATH" 2>/dev/null)"
                echo "  Timestamp ATIME: $(stat -c '%x' "$TARGET_PATH" 2>/dev/null)"
                echo "  Timestamp CTIME: $(stat -c '%z' "$TARGET_PATH" 2>/dev/null)"
                echo ""
                echo "---"
                echo ""
            } >> "$REPORT_FILE"
        fi

    elif [ "$MODE" = "DIR" ]; then
        # Single directory mode
        echo "[*] Processing directory and contents..."
        echo ""

        # Process files
        echo "[*] Phase 1: FILES within $TARGET_PATH"
        find "$TARGET_PATH" -type f 2>/dev/null | while read -r FILE; do
            # Skip protected
            if is_protected "$FILE"; then
                ((SKIPPED++)) || true
                continue
            fi

            for ((i=0; i<NUM_ITERATIONS; i++)); do
                randomize_file "$FILE"
            done

            ((FILES_PROCESSED++)) || true

            # Progress indicator
            if (( FILES_PROCESSED % 100 == 0 )); then
                echo "    ... processed $FILES_PROCESSED files"
            fi

            # Add to report if enabled
            if [ "$REPORT_ENABLED" = true ]; then
                {
                    echo "File: $FILE"
                    echo "  Timestamp MTIME: $(stat -c '%y' "$FILE" 2>/dev/null)"
                    echo "  Timestamp ATIME: $(stat -c '%x' "$FILE" 2>/dev/null)"
                    echo "  Timestamp CTIME: $(stat -c '%z' "$FILE" 2>/dev/null)"
                    echo ""
                } >> "$REPORT_FILE"
            fi
        done

        echo "[+] Files processed: $FILES_PROCESSED"
        echo ""

        # Process directories
        echo "[*] Phase 2: DIRECTORIES within $TARGET_PATH"
        find "$TARGET_PATH" -type d 2>/dev/null | while read -r DIRECTORY; do
            # Skip protected
            if is_protected "$DIRECTORY"; then
                ((SKIPPED++)) || true
                continue
            fi

            for ((i=0; i<NUM_ITERATIONS; i++)); do
                randomize_dir "$DIRECTORY"
            done

            ((DIRS_PROCESSED++)) || true

            # Progress indicator
            if (( DIRS_PROCESSED % 50 == 0 )); then
                echo "    ... processed $DIRS_PROCESSED directories"
            fi

            # Add to report if enabled
            if [ "$REPORT_ENABLED" = true ]; then
                {
                    echo "Directory: $DIRECTORY"
                    echo "  Timestamp MTIME: $(stat -c '%y' "$DIRECTORY" 2>/dev/null)"
                    echo "  Timestamp ATIME: $(stat -c '%x' "$DIRECTORY" 2>/dev/null)"
                    echo "  Timestamp CTIME: $(stat -c '%z' "$DIRECTORY" 2>/dev/null)"
                    echo ""
                } >> "$REPORT_FILE"
            fi
        done

        echo "[+] Directories processed: $DIRS_PROCESSED"

    elif [ "$MODE" = "MULTIPLE" ]; then
        # Multiple critical directories mode - THE KEY FIX
        echo "[*] Processing CRITICAL QUBES METADATA DIRECTORIES..."
        echo ""
        
        for target in "${TARGET_PATHS[@]}"; do
            if [[ ! -d "$target" ]]; then
                echo "[SKIP] Directory does not exist: $target"
                continue
            fi
            
            echo "[*] Phase 1: FILES in $target"
            
            find "$target" -type f \
                -path "*vm-kernels*" -prune -o \
                -path "*updates*" -prune -o \
                -print 2>/dev/null | while read -r FILE; do
                if is_protected "$FILE"; then
                    ((SKIPPED++)) || true
                    continue
                fi
                
                for ((i=0; i<NUM_ITERATIONS; i++)); do
                    randomize_file "$FILE"
                done
                
                ((FILES_PROCESSED++)) || true
                
                if (( FILES_PROCESSED % 1000 == 0 )); then
                    echo "    ... processed $FILES_PROCESSED files"
                fi
                
                # Add to report if enabled (limit to avoid huge reports)
                if [ "$REPORT_ENABLED" = true ] && (( FILES_PROCESSED <= 5000 )); then
                    {
                        echo "File: $FILE"
                        echo "  Timestamp MTIME: $(stat -c '%y' "$FILE" 2>/dev/null)"
                        echo "  Timestamp ATIME: $(stat -c '%x' "$FILE" 2>/dev/null)"
                        echo "  Timestamp CTIME: $(stat -c '%z' "$FILE" 2>/dev/null)"
                        echo ""
                    } >> "$REPORT_FILE"
                fi
            done
            
            echo "[+] Completed files: $target"
        done
        
        echo ""
        echo "[+] Files processed: $FILES_PROCESSED"
        echo ""
        
        echo "[*] Phase 2: DIRECTORIES in all targets"
        
        for target in "${TARGET_PATHS[@]}"; do
            if [[ ! -d "$target" ]]; then
                continue
            fi
            
            echo "Processing directories: $target"
            
            find "$target" -type d 2>/dev/null | while read -r DIRECTORY; do
                if is_protected "$DIRECTORY"; then
                    ((SKIPPED++)) || true
                    continue
                fi
                
                for ((i=0; i<NUM_ITERATIONS; i++)); do
                    randomize_dir "$DIRECTORY"
                done
                
                ((DIRS_PROCESSED++)) || true
                
                if (( DIRS_PROCESSED % 500 == 0 )); then
                    echo "    ... processed $DIRS_PROCESSED directories"
                fi
                
                # Add to report if enabled (limit to avoid huge reports)
                if [ "$REPORT_ENABLED" = true ] && (( DIRS_PROCESSED <= 5000 )); then
                    {
                        echo "Directory: $DIRECTORY"
                        echo "  Timestamp MTIME: $(stat -c '%y' "$DIRECTORY" 2>/dev/null)"
                        echo "  Timestamp ATIME: $(stat -c '%x' "$DIRECTORY" 2>/dev/null)"
                        echo "  Timestamp CTIME: $(stat -c '%z' "$DIRECTORY" 2>/dev/null)"
                        echo ""
                    } >> "$REPORT_FILE"
                fi
            done
            
            echo "[+] Completed directories: $target"
        done
        
        echo ""
        echo "[+] Directories processed: $DIRS_PROCESSED"
        echo ""
        echo "[OK] Critical metadata randomization completed!"
        
        # Debug: Show example of randomized timestamp
        echo ""
        echo "[DEBUG] Sample randomized timestamps:"
        for target in "${TARGET_PATHS[@]}"; do
            if [[ -d "$target" ]]; then
                sample_file=$(find "$target" -type f 2>/dev/null | head -n 1)
                if [[ -n "$sample_file" ]]; then
                    echo "  $sample_file: $(stat -c '%y' "$sample_file" 2>/dev/null)"
                    break
                fi
            fi
        done

    else
        echo "[!] ERROR: Unknown MODE '$MODE'! This should not happen."
        return 1
    fi

    # Finalize report if enabled
    if [ "$REPORT_ENABLED" = true ]; then
        cat >> "$REPORT_FILE" << REPORT_FOOTER

===============================================================================
SECTION 2: SUMMARY
===============================================================================
Files Processed:      $FILES_PROCESSED
Directories Processed: $DIRS_PROCESSED
Skipped (Protected):  $SKIPPED
Iterations:           $NUM_ITERATIONS
Report Generated:     $(date)
===============================================================================

SECTION 3: EXAMPLE STAT OUTPUT
-------------------------------------------------------------------------------
Below is a sample of what the 'stat' output looks like:

EXAMPLE:
$(stat /etc/passwd 2>/dev/null || echo "Unable to fetch example stat")

===============================================================================
END OF REPORT
===============================================================================
REPORT_FOOTER

        echo ""
        echo "==========================================================="
        echo "  REPORT GENERATED"
        echo "==========================================================="
        echo "Location: $REPORT_FILE"
        echo ""
        echo "[i] View report with: cat $REPORT_FILE"
        echo "[i] /dev/shm is RAM-based - report lost on reboot!"
        echo ""
    fi

    # Final Summary
    echo "==========================================================="
    echo "  COMPLETION SUMMARY"
    echo "==========================================================="
    echo "  Files Processed:        $FILES_PROCESSED"
    echo "  Directories Processed:  $DIRS_PROCESSED"
    echo "  Skipped (Protected):    $SKIPPED"
    echo "  Iterations per Item:    $NUM_ITERATIONS"
    echo "  Report Saved To:        ${REPORT_FILE:-N/A}"
    echo ""
    echo "[✓] Metadata randomization completed!"
    echo ""
    echo "[i] Timestamps now appear to be from ~1-5 years ago (365-1825 days)."
    echo "[i] Protected directories were not modified."
    echo ""
    echo "==========================================================="
}
#end system_wide_metadata_randomizer()

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# FINISHED
# Dom0 Amnesic and anti-forensic metadata defense
# FINISHED
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------




# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# BEGIN
# Qubes Anti Cold Boot Attack
# BEGIN
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================


#begin anti_cold_boot()
anti_cold_boot()
{
echo
# Script to install dracut ram-wipe module
# from qubes forum post: https://forum.qubes-os.org/t/ram-wipe-in-dom0-protection-against-cold-boot-attack-in-qubes/39375

echo "Creating dracut ram-wipe module directories and files..."

# Create module directory
mkdir /usr/lib/dracut/modules.d/40ram-wipe/

# module-setup.sh
cat > /usr/lib/dracut/modules.d/40ram-wipe/module-setup.sh << 'EOF'
#!/bin/bash
# -*- mode: shell-script; indent-tabs-mode: nil; sh-basic-offset: 4; -*-
# ex: ts=8 sw=4 sts=4 et filetype=sh

## Copyright (C) 2023 - 2025 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

# called by dracut
check() {
   require_binaries sync || return 1
   require_binaries sleep || return 1
   require_binaries dmsetup || return 1
   return 0
}

# called by dracut
depends() {
   return 0
}

# called by dracut
install() {
   inst_simple "/usr/libexec/ram-wipe/ram-wipe-lib.sh" "/lib/ram-wipe-lib.sh"
   inst_multiple sync
   inst_multiple sleep
   inst_multiple dmsetup
   inst_hook shutdown 40 "$moddir/wipe-ram.sh"
   inst_hook cleanup 80 "$moddir/wipe-ram-needshutdown.sh"
}

# called by dracut
installkernel() {
   return 0
}
EOF

chmod +x /usr/lib/dracut/modules.d/40ram-wipe/module-setup.sh

# wipe-ram-needshutdown.sh
cat > /usr/lib/dracut/modules.d/40ram-wipe/wipe-ram-needshutdown.sh << 'EOF'
#!/bin/sh

## Copyright (C) 2023 - 2025 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

. /lib/ram-wipe-lib.sh

ram_wipe_check_needshutdown() {
   ## 'local' is unavailable in 'sh'.
   #local kernel_wiperam_setting

   kernel_wiperam_setting="$(getarg wiperam)"

   if [ "$kernel_wiperam_setting" = "skip" ]; then
      force_echo "wipe-ram-needshutdown.sh: Skip, because wiperam=skip kernel parameter detected, OK."
      return 0
   fi

   true "wipe-ram-needshutdown.sh: Calling dracut function need_shutdown to drop back into initramfs at shutdown, OK."
   need_shutdown

   return 0
}

ram_wipe_check_needshutdown
EOF

chmod +x /usr/lib/dracut/modules.d/40ram-wipe/wipe-ram-needshutdown.sh

# wipe-ram.sh
cat > /usr/lib/dracut/modules.d/40ram-wipe/wipe-ram.sh << 'EOF'
#!/bin/sh

## Copyright (C) 2023 - 2025 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## Credits:
## First version by @friedy10.
## https://github.com/friedy10/dracut/blob/master/modules.d/40sdmem/wipe.sh

## Use '.' and not 'source' in 'sh'.
. /lib/ram-wipe-lib.sh

drop_caches() {
   sync
   ## https://gitlab.tails.boum.org/tails/tails/-/blob/master/config/chroot_local-includes/usr/local/lib/initramfs-pre-shutdown-hook
   ### Ensure any remaining disk cache is erased by Linux' memory poisoning
   echo 3 > /proc/sys/vm/drop_caches
   sync
}

ram_wipe() {
   ## 'local' is unavailable in 'sh'.
   #local kernel_wiperam_setting dmsetup_actual_output dmsetup_expected_output

   ## getarg returns the last parameter only.
   kernel_wiperam_setting="$(getarg wiperam)"

   if [ "$kernel_wiperam_setting" = "skip" ]; then
      force_echo "wipe-ram.sh: Skip, because wiperam=skip kernel parameter detected, OK."
      return 0
   fi

   force_echo "wipe-ram.sh: RAM extraction attack defense... Starting RAM wipe pass during shutdown..."

   drop_caches

   force_echo "wipe-ram.sh: RAM wipe pass completed, OK."

   ## In theory might be better to check this beforehand, but the test is
   ## really fast.
   force_echo "wipe-ram.sh: Checking if there are still mounted encrypted disks..."

   ## TODO: use 'timeout'?
   dmsetup_actual_output="$(dmsetup ls --target crypt 2>&1)"
   dmsetup_expected_output="No devices found"

   if [ "$dmsetup_actual_output" = "$dmsetup_expected_output" ]; then
      force_echo "wipe-ram.sh: Success, there are no more mounted encrypted disks, OK."
   elif [ "$dmsetup_actual_output" = "" ]; then
      force_echo "wipe-ram.sh: Success, there are no more mounted encrypted disks, OK."
   else
      ## dracut should unmount the root encrypted disk cryptsetup luksClose during shutdown
      ## https://github.com/dracutdevs/dracut/issues/1888
      force_echo "\\
wipe-ram.sh: There are still mounted encrypted disks! RAM wipe incomplete!

debugging information:
dmsetup_expected_output: '$dmsetup_expected_output'
dmsetup_actual_output: '$dmsetup_actual_output'"
      ## How else could the user be informed that something is wrong?
      sleep 5
   fi
}

ram_wipe
EOF

chmod +x /usr/lib/dracut/modules.d/40ram-wipe/wipe-ram.sh

# dracut.conf.d
cat > /usr/lib/dracut/dracut.conf.d/30-ram-wipe.conf << 'EOF'
add_dracutmodules+=" ram-wipe "
EOF

# ram-wipe-lib.sh
mkdir /usr/libexec/ram-wipe
cat > /usr/libexec/ram-wipe/ram-wipe-lib.sh << 'EOF'
#!/bin/sh

## Copyright (C) 2023 - 2025 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

## Based on:
## /usr/lib/dracut/modules.d/99base/dracut-lib.sh
if [ -z "$DRACUT_SYSTEMD" ]; then
    force_echo() {
        echo "<28>dracut INFO: $*" > /dev/kmsg
        echo "dracut INFO: $*" >&2
    }
else
    force_echo() {
        echo "INFO: $*" >&2
    }
fi
EOF

chmod +x /usr/libexec/ram-wipe/ram-wipe-lib.sh

# Update INITRAMFS
dracut --verbose --force
echo "ram-wipe module created successfully!"
echo "Use a shortcut key like Control + Alt + Space to activate fast shutdown against physical attackers."
echo "Manually configure the settings manager / Keyboard."
echo "Dom0 does not support USB drives to create a USB kill switch like Tails OS does."


echo;
# Just for testing at the beginning of the creation of the algorithm
# Commented out now to be used in the future if something is modified to change the remove_anti_cold_boot() function with new hashes
#remove : << 'END_COMMENT' and END_COMMENT to apply again...

: << 'END_COMMENT'
#echo "Hash of the files created"
# Define the directory and files to check
files=(
    "/usr/lib/dracut/modules.d/40ram-wipe/module-setup.sh"
    "/usr/lib/dracut/modules.d/40ram-wipe/wipe-ram-needshutdown.sh"
    "/usr/lib/dracut/modules.d/40ram-wipe/wipe-ram.sh"
    "/usr/lib/dracut/dracut.conf.d/30-ram-wipe.conf"
    "/usr/libexec/ram-wipe/ram-wipe-lib.sh"
)

# Iterate through the files and calculate the SHA-256 hash
for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
        hash=$(sha256sum "$file" | awk '{ print $1 }')
        echo "File: $file"
        echo "SHA-256 Hash: $hash"
        echo "-----------------------------"
    else
        echo "File: $file does not exist."
        echo "-----------------------------"
    fi
done
END_COMMENT

}
#end anti_cold_boot()

#begin remove_anti_cold_boot()
remove_anti_cold_boot()
{
echo
# Define the files and their expected hashes
declare -A files_hashes
files_hashes=(
    ["/usr/lib/dracut/modules.d/40ram-wipe/module-setup.sh"]="246d9f7fb41d7f2361d0e086889a1570625c4468ee17ccf06fdd8c3044cb6049"
    ["/usr/lib/dracut/modules.d/40ram-wipe/wipe-ram-needshutdown.sh"]="55be0355df0cdf9eb4f135602a87e2b47f6807e00baf24becea41a478064795d"
    ["/usr/lib/dracut/modules.d/40ram-wipe/wipe-ram.sh"]="a1a121e7faaaf5b4a042a8a63887fdfd4e4891c9ccdb976bcafc0a228c0b1a48"
    ["/usr/lib/dracut/dracut.conf.d/30-ram-wipe.conf"]="60463385aff5cf70d815a0b399f0c8142a8eef6b8a5e643da82e4a59e7fa73c4"
    ["/usr/libexec/ram-wipe/ram-wipe-lib.sh"]="1fdd83475d59f1942492cac643d63a607339190c11bda4a401a51c34112a871d"
)

# Check each file's existence and hash
all_exist=true
all_match=true

for file in "${!files_hashes[@]}"; do
    if [[ -f "$file" ]]; then
        # Calculate the SHA-256 hash
        calculated_hash=$(sha256sum "$file" | awk '{ print $1 }')
        expected_hash=${files_hashes[$file]}

        echo "File: $file"
        echo "Calculated Hash: $calculated_hash"
        echo "Expected Hash: $expected_hash"

        if [[ "$calculated_hash" != "$expected_hash" ]]; then
            echo "Warning: Hash does not match for $file."
            all_match=false
        else
            echo "Hash matches for $file."
        fi
        echo "-----------------------------"
    else
        echo "File: $file does not exist."
        all_exist=false
    fi
done
echo "Anti-cold boot attack module files and their status are listed above."


# Prompt to continue or cancel the operation
read -p "Do you wish to continue or cancel the operation? (type 'y' or 'n'): " user_input
echo

if [[ "$user_input" == "y" ]]; then
    echo "Continuing the operation..."

# Inform the user about the deletion process
echo "Deleting Dracut Anti Cold Boot Attack Modules..."

# List of directories and files to delete
items=(
    "/usr/lib/dracut/modules.d/40ram-wipe/"
    "/usr/lib/dracut/modules.d/40ram-wipe/"  # Appears multiple times
    "/usr/lib/dracut/modules.d/40ram-wipe/"
    "/usr/lib/dracut/modules.d/40ram-wipe/"
    "/usr/libexec/ram-wipe/"
    "/usr/lib/dracut/dracut.conf.d/30-ram-wipe.conf"
)

# Loop through the items and delete each one
for item in "${items[@]}"; do
    if [[ -e "$item" ]]; then
        echo "Deleting: $item"
        sudo rm -rf "$item"
    else
        echo "Warning: $item does not exist or cannot be deleted."
    fi
done
echo
# Regenerate Dracut
echo "Regenerating Dracut..."
sudo dracut --verbose --force
echo "Operation completed."

else
    echo "Operation canceled."
fi

}
#end remove_anti_cold_boot()


# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# FINISHED
# Qubes Anti Cold Boot Attack
# FINISHED
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================
# =============================================================================


# =============================================================================
# MAIN MENU
# =============================================================================
#begin show_menu_main()
show_menu_main() {
    clear
    echo ""
    echo "==========================================================="
    echo "               QUBES ZRAM DVM CLONE MANAGER"
    echo "==========================================================="
    echo ""
    echo "  --- ZRAM POOL (ANTI-FORENSIC) ---"
    echo "   1) Create ZRAM Pool for amnesic DVMs and appVMs"
    echo "   2) Remove ZRAM Pool and Related Artifacts"
    echo ""
    echo "  --- DVM CLONE MANAGER (ZRAM_POOL) ---"
    echo "   3) Add VM to clone registry"
    echo "   4) Create all registered clones (to zram_pool)"
    echo "   5) Create one registered clone (to zram_pool)"
    echo "   6) Remove entry from registry"
    echo "   7) Clear entire registry"
    echo "   8) Delete specific DVM from zram_pool"
    echo "   9) Delete ALL DVMs from zram_pool"
    echo "  10) Check registry & zram_pool status"
    echo ""
    echo "  --- ANTI-COLD BOOT ATTACK ---"
    echo "  11) Enable Anti-Cold Boot Protection"
    echo "  12) Disable Anti-Cold Boot Protection"
    echo ""
    echo "  --- ANTI-METADATA LEAKING FROM dom0 ---"
    echo "  13) Tmpfs Metadata Protection Only (tmpfs mounts)"
    echo "  14) Revert Tmpfs Optimization"
    echo "  15) Disable .bash_history"
    echo "  16) Enable .bash_history"
    echo "  17) System-Wide Metadata Randomizer"
    echo ""
    echo "  --- SWAP CONTROL ---"
    echo "  18) Activate Swap"
    echo "  19) Deactivate Swap"
    echo ""
    echo "  --- GRUB MEMORY MANAGEMENT ---"
    echo "  20) Increase dom0 Memory Limit (GRUB Config)"
    echo "  21) Restore GRUB Default RAM memory"
    echo ""
    echo "  --- STATUS CHECKS ---"
    echo "  22) Check critical metadata dom0 status"
    echo ""
    echo "  --- SYSTEM ---"
    echo "   0) Exit"
    echo ""
    echo "==========================================================="
}
#end show_menu_main()

# =============================================================================
# MAIN LOOP
# =============================================================================

while true; do
    show_menu_main
    read -p "Select an option (0-22): " choice
    
    case "$choice" in
        1)
            echo "[*] Starting ZRAM pool creation..."
            zram_pool
            amnesic_logs_metadata_dom0
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        2)
            echo "[*] Removing ZRAM pool and all related artifacts..."
            remove_zram_pool
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        3)
            add_entry
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        4)
            create_all_clones
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        5)
            create_single_clone
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        6)
            remove_entry
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        7)
            clear_registry
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        8)
            delete_specific_dvm
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        9)
            delete_all_dvms
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        10)
            check_status
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        11)
            echo "[*] Enabling Anti-Cold Boot Protection..."
            anti_cold_boot
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        12)
            echo "[*] Disabling Anti-Cold Boot Protection..."
            remove_anti_cold_boot
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        13)
            echo "[*] Applying tmpfs metadata protection only..."
            dom0_tmpfs_metadata
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        14)
            echo "[*] Reverting tmpfs optimization..."
            revert_tmpfs_optimization
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        15)
            echo "[*] Disabling .bash_history..."
            disable_bash_history
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        16)
            echo "[*] Enabling .bash_history..."
            enable_bash_history
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        17)
            echo "[*] Running System-Wide Metadata Randomizer..."
            system_wide_metadata_randomizer
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        18)
            echo "[*] Activating Swap..."
            swap_on
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        19)
            echo "[*] Deactivating Swap..."
            swap_off
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        20)
            echo "[*] Running Full dom0 RAM Manager (GRUB + Memory Limit)..."
            dom0-ram-manager
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        21)
            echo "[*] Restoring GRUB default + Swap + ZRAM service..."
            restore_grub_default_4g
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        22)
            echo "[*] Checking critical metadata dom0 status..."
            check_tmpfs_simple
            echo ""
            read -p "Press Enter to continue..."
            ;;
        
        0)
            echo "[*] Exiting..."
            exit 0
            ;;
        
        *)
            echo "[!] Invalid option!"
            sleep 1
            ;;
    esac
done












