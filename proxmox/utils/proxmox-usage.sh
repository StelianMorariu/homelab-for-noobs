#!/bin/bash
# proxmox-ram-usage.sh
# Robust RAM usage snapshot for LXCs and VMs using cgroup counters.
# Works on Proxmox 8 (cgroup v2) and falls back to v1 paths when needed.

set -euo pipefail

printf "%-6s %-4s %-8s %-12s %-12s\n" "ID" "Type" "State" "Alloc_MB" "Used_MB"
echo "----------------------------------------------------------"

sum_alloc=0
sum_used=0

# ---- Helpers ----
to_mb() { awk -v b="$1" 'BEGIN{printf "%.0f", b/1024/1024}'; }

read_mem_cgroup() {
  # Try multiple known cgroup paths (v2 then v1)
  local id="$1" type="$2" val=""
  if [ "$type" = "LXC" ]; then
    for p in \
      "/sys/fs/cgroup/system.slice/pve-container@${id}.service/memory.current" \
      "/sys/fs/cgroup/lxc.payload.${id}/memory.current" \
      "/sys/fs/cgroup/lxc/${id}/memory.current" \
      "/sys/fs/cgroup/memory/lxc/${id}/memory.usage_in_bytes" \
      "/sys/fs/cgroup/memory/lxc/${id}/memory.max_usage_in_bytes"
    do
      [ -f "$p" ] && val=$(cat "$p" 2>/dev/null || true)
      [ -n "${val:-}" ] && { echo "$val"; return 0; }
    done
  else # VM (QEMU)
    for p in \
      "/sys/fs/cgroup/system.slice/qemu-server@${id}.service/memory.current" \
      "/sys/fs/cgroup/machine.slice/qemu-${id}.scope/memory.current" \
      "/sys/fs/cgroup/memory/qemu/${id}/memory.usage_in_bytes"
    do
      [ -f "$p" ] && val=$(cat "$p" 2>/dev/null || true)
      [ -n "${val:-}" ] && { echo "$val"; return 0; }
    done
  fi
  echo ""
}

# ---- LXCs ----
if command -v pct >/dev/null 2>&1; then
  pct list | awk 'NR>1 {print $1,$2}' | while read -r id status; do
    alloc=$(pct config "$id" 2>/dev/null | awk '/^memory:/ {print $2}')
    [ -z "${alloc:-}" ] && alloc=0  # 0 means "unlimited" in LXC, but we’ll show 0 here for simplicity

    used_bytes=$(read_mem_cgroup "$id" "LXC")
    [ -z "${used_bytes:-}" ] && used_bytes=0

    alloc_mb="$alloc"
    used_mb=$(to_mb "$used_bytes")

    printf "%-6s %-4s %-8s %-12s %-12s\n" "$id" "LXC" "$status" "$alloc_mb" "$used_mb"

    sum_alloc=$(( sum_alloc + alloc_mb ))
    sum_used=$(( sum_used + used_mb ))
  done
fi

# ---- QEMU VMs ----
if command -v qm >/dev/null 2>&1; then
  # qm list columns: VMID NAME STATUS MEM(MB) BOOTDISK(GB) PID
  qm list | awk 'NR>1 {print $1,$3,$4}' | while read -r id status memcol; do
    # memcol is Alloc_MB according to `qm list`
    alloc_mb="$memcol"
    [ -z "${alloc_mb:-}" ] && alloc_mb=0

    used_bytes=$(read_mem_cgroup "$id" "VM")
    [ -z "${used_bytes:-}" ] && used_bytes=0
    used_mb=$(to_mb "$used_bytes")

    printf "%-6s %-4s %-8s %-12s %-12s\n" "$id" "VM" "$status" "$alloc_mb" "$used_mb"

    sum_alloc=$(( sum_alloc + alloc_mb ))
    sum_used=$(( sum_used + used_mb ))
  done
fi

echo "----------------------------------------------------------"
printf "%-6s %-4s %-8s %-12s %-12s\n" "TOTAL" "" "" "$sum_alloc" "$sum_used"
